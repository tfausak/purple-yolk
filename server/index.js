'use strict';

const childProcess = require('child_process');
const lsp = require('vscode-languageserver');
const { performance } = require('perf_hooks');
const py = require('../package.json');
const readline = require('readline');
const stream = require('stream');
const url = require('url');

let activeJob = null;
const connection = lsp.createConnection();
const diagnostics = {};
let ghci = null;
const jobs = new stream.Readable({ objectMode: true, read: () => {} });
const prompt = `{- ${py.name} ${py.version} ${performance.timeOrigin} -}`;

const format = (ms) => (ms / 1000).toFixed(3);

const say = (message) =>
  connection.console.info(`${format(performance.now())} ${message}`);

jobs.on('error', (err) => {
  throw err;
});

jobs.on('data', (job) => {
  if (activeJob) {
    throw new Error('Attempted to activate job but one is already active!');
  }

  jobs.pause();
  activeJob = job;
  activeJob.startedAt = performance.now();
  activeJob.onStart(activeJob);
});

const parseJson = (string) => {
  try {
    return JSON.parse(string);
  } catch (error) {
    if (error instanceof SyntaxError) {
      return null;
    }
    throw error;
  }
};

const sendDiagnostics = (file) => {
  const value = diagnostics[file];
  if (!value) {
    return;
  }
  const values = Object.values(value);
  connection.sendDiagnostics({
    diagnostics: values,
    uri: file,
  });
  if (values.length === 0) {
    delete diagnostics[file];
  }
};

const clearDiagnostics = () => Object.keys(diagnostics).forEach((key) => {
  diagnostics[key] = {};
  sendDiagnostics(key);
});

const onStdoutLine = (line) => {
  if (line.indexOf(prompt) === -1) {
    say(`[stdout] ${line}`);
  }
};

const getSeverity = (json) => {
  switch (json.severity) {
    case 'SevError': return lsp.DiagnosticSeverity.Error;
    case 'SevWarning': switch (json.reason) {
      case 'Opt_WarnDeferredOutOfScopeVariables':
        return lsp.DiagnosticSeverity.Error;
      case 'Opt_WarnDeferredTypeErrors': return lsp.DiagnosticSeverity.Error;
      default: switch (json.span && json.span.file) {
        case '<interactive>': return lsp.DiagnosticSeverity.Information;
        default: return lsp.DiagnosticSeverity.Warning;
      }
    }
    default: return lsp.DiagnosticSeverity.Information;
  }
};

const getRange = (json) => {
  const range = {
    end: {
      character: 0,
      line: 0,
    },
    start: {
      character: 0,
      line: 0,
    },
  };

  if (json.span) {
    range.start.line = json.span.startLine - 1;
    range.start.character = json.span.startCol - 1;
    range.end.line = json.span.endLine - 1;
    range.end.character = json.span.endCol - 1;
  }

  return range;
};

const getFile = (json) => {
  if (json.span && json.span.file !== '<interactive>') {
    return url.pathToFileURL(json.span.file);
  }

  return url.pathToFileURL('.');
};

const onOutput = (line, json) => {
  const pattern = /^\[ *(\d+) of (\d+)\] Compiling (\S+) *\( ([^,]+), /;
  const match = json.doc.match(pattern);
  if (!match) {
    return onStdoutLine(line);
  }

  connection.sendNotification(
    `${py.name}/updateProgress`,
    `${match[1]} of ${match[2]}: ${match[3]}`
  );

  const file = url.pathToFileURL(match[4]);
  diagnostics[file] = {};
  return sendDiagnostics(file);
};

const onStdoutJson = (line, json) => {
  if (
    json.span === null &&
    json.span === null &&
    json.severity === 'SevOutput'
  ) {
    return onOutput(line, json);
  }

  const file = getFile(json);
  const range = getRange(json);

  const key = [
    range.start.line,
    range.start.character,
    range.end.line,
    range.end.character,
    json.reason,
  ].join(' ');

  if (!diagnostics[file]) {
    diagnostics[file] = {};
  }

  diagnostics[file][key] = {
    code: json.reason,
    message: json.doc,
    range,
    severity: getSeverity(json),
    source: py.name,
  };

  return sendDiagnostics(file);
};

const onStdout = (line) => {
  const json = parseJson(line);
  if (json) {
    onStdoutJson(line, json);
  } else {
    onStdoutLine(line);
  }
};

const makeJob = (command) => ({
  command,
  finishedAt: null,
  onFinish: (job) => {
    const elapsed = format(job.finishedAt - job.startedAt);
    say(`Finished ${job.command} in ${elapsed}`);
    connection.sendNotification(`${py.name}/hideProgress`);
  },
  onQueue: (job) => say(`Queueing ${job.command}`),
  onStart: (job) => {
    const elapsed = format(job.startedAt - job.queuedAt);
    say(`Starting ${job.command} after ${elapsed}`);
    ghci.stdin.write(`${job.command}\n`);
    connection.sendNotification(`${py.name}/showProgress`, job.command);
  },
  onStdout,
  queuedAt: null,
  startedAt: null,
});

const queueCommand = (command) => {
  const job = makeJob(command);
  job.queuedAt = performance.now();
  job.onQueue(job);
  jobs.push(job);
};

const startGhciWith = (command) => {
  say(`Starting GHCi: ${command}`);

  ghci = childProcess.spawn(command, { shell: true });

  ghci.on('error', (err) => {
    throw err;
  });

  ghci.on('exit', (code, signal) => {
    if (!ghci.killed) {
      throw new Error(`GHCi exited with code ${code} and signal ${signal}!`);
    }
    say(`Killed GHCi (${signal})`);
  });

  readline.createInterface({ input: ghci.stderr })
    .on('line', (line) => say(`[stderr] ${line}`));

  readline.createInterface({ input: ghci.stdout }).on('line', (line) => {
    if (activeJob) {
      activeJob.onStdout(line);
      if (line.indexOf(prompt) !== -1) {
        activeJob.finishedAt = performance.now();
        activeJob.onFinish(activeJob);
        activeJob = null;
        jobs.resume();
      }
    } else {
      say(`[stdout] ${line}`);
    }
  });

  queueCommand(`:set prompt "${prompt}\\n"`);
  queueCommand(':set -ddump-json');
  queueCommand(':reload');
};

const startGhci = () => {
  if (ghci) {
    throw new Error('Attempted to start GHCi but it is already running!');
  }

  connection.workspace.getConfiguration(py.name)
    .then((config) => startGhciWith(config.ghci.command));
};

const restartGhci = () => {
  ghci.on('exit', () => {
    ghci = null;
    startGhci();
  });

  ghci.kill();
};

connection.onInitialize(() => {
  say(`Initializing ${py.name} ${py.version}`);
  return { capabilities: { textDocumentSync: { save: true } } };
});

connection.onInitialized(() => {
  startGhci();
});

connection.onDidSaveTextDocument((params) => {
  say(`Saved ${params.textDocument.uri}`);
  queueCommand(':reload');
});

connection.onNotification(`${py.name}/restart`, () => {
  clearDiagnostics();
  restartGhci();
});

connection.listen();
