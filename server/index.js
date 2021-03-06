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
let stderr = null;
let stdout = null;
const queuedCommands = new Set();

const format = (ms) => (ms / 1000).toFixed(3);

const say = (message) =>
  connection.console.info(`${format(performance.now())} ${message}`);

jobs.on('error', (error) => {
  throw error;
});

jobs.on('data', (job) => {
  if (activeJob) {
    throw new Error('Attempted to activate job but one is already active!');
  }

  jobs.pause();
  queuedCommands.delete(job.command);
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
    default:
      if (json.doc.indexOf('Module imports form a cycle:') === -1) {
        return lsp.DiagnosticSeverity.Information;
      }
      return lsp.DiagnosticSeverity.Error;
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

const defaultFile = url.pathToFileURL('.');

const getFile = (json) => {
  if (json.span && json.span.file !== '<interactive>') {
    return url.pathToFileURL(json.span.file);
  }

  return defaultFile;
};

const onOutput = (line, json) => {
  const pattern = /^\[ *(\d+) of (\d+)\] Compiling (\S+) *\( ([^,]+), /;
  const match = json.doc.match(pattern);
  if (!match) {
    return onStdoutLine(line);
  }

  if (activeJob) {
    connection.sendNotification(
      `${py.name}/updateProgress`,
      {
        key: activeJob.key,
        message: `${match[1]} of ${match[2]}: ${match[3]}`,
        percent: match[1] / match[2],
      }
    );
  }

  const file = url.pathToFileURL(match[4]);
  diagnostics[file] = {};
  return sendDiagnostics(file);
};

const getKey = (range, json) => [
  range.start.line,
  range.start.character,
  range.end.line,
  range.end.character,
  json.reason,
].join(' ');

const shouldIgnore = (reason) => {
  switch (reason) {
    case 'Opt_WarnMissingHomeModules': return true;
    case 'Opt_WarnMissingImportList': return true;
    case 'Opt_WarnMissingLocalSignatures': return true;
    default: return false;
  }
};

const sendDiagnostic = (file, key, diagnostic) => {
  if (!diagnostics[file]) {
    diagnostics[file] = {};
  }

  diagnostics[file][key] = diagnostic;

  return sendDiagnostics(file);
};

const getTags = (reason) => {
  const unnecessary = [lsp.DiagnosticTag.Unnecessary];
  const deprecated = [lsp.DiagnosticTag.Deprecated];
  switch (reason) {
    case 'Opt_WarnDuplicateConstraints': return unnecessary;
    case 'Opt_WarnDuplicateExports': return unnecessary;
    case 'Opt_WarnRedundantConstraints': return unnecessary;
    case 'Opt_WarnRedundantRecordWildcards': return unnecessary;
    case 'Opt_WarnUnusedForalls': return unnecessary;
    case 'Opt_WarnUnusedImports': return unnecessary;
    case 'Opt_WarnUnusedLocalBinds': return unnecessary;
    case 'Opt_WarnUnusedMatches': return unnecessary;
    case 'Opt_WarnUnusedPatternBinds': return unnecessary;
    case 'Opt_WarnUnusedRecordWildcards': return unnecessary;
    case 'Opt_WarnUnusedTopBinds': return unnecessary;
    case 'Opt_WarnUnusedTypePatterns': return unnecessary;
    case 'Opt_WarnWarningsDeprecations': return deprecated;
    default: return null;
  }
};

const onStdoutJson = (line, json) => {
  if (json.span === null && json.severity === 'SevOutput') {
    return onOutput(line, json);
  }

  const file = getFile(json);
  const range = getRange(json);
  const key = getKey(range, json);

  if (file === defaultFile && shouldIgnore(json.reason)) {
    return null;
  }

  const diagnostic = {
    code: json.reason,
    message: json.doc,
    range,
    severity: getSeverity(json),
    source: py.name,
    tags: getTags(json.reason),
  };

  return sendDiagnostic(file, key, diagnostic);
};

const onStdout = (line) => {
  const json = parseJson(line);
  if (json) {
    onStdoutJson(line, json);
  } else {
    onStdoutLine(line);
  }
};

const makeJob = (title, command) => {
  const key = Math.random();
  return {
    command,
    finishedAt: null,
    key,
    onFinish: (job) => {
      const elapsed = format(job.finishedAt - job.startedAt);
      say(`Finished ${job.command} in ${elapsed}`);
      connection.sendNotification(`${py.name}/hideProgress`, { key });
    },
    onQueue: (job) => say(`Queueing ${job.command}`),
    onStart: (job) => {
      if (ghci) {
        const elapsed = format(job.startedAt - job.queuedAt);
        say(`Starting ${job.command} after ${elapsed}`);
        ghci.stdin.write(`${job.command}\n`);
        connection.sendNotification(
          `${py.name}/showProgress`,
          { key, title: job.title }
        );
      } else {
        say(`Ignoring ${job.command}`);
      }
    },
    onStdout,
    queuedAt: null,
    startedAt: null,
    title,
  };
};

const queueCommand = (title, command) => {
  if (queuedCommands.has(command)) {
    say(`Ignoring ${command}`);
  } else {
    queuedCommands.add(command);
    const job = makeJob(title, command);
    job.queuedAt = performance.now();
    job.onQueue(job);
    jobs.push(job);
  }
};

const setUpStreams = () => {
  stderr = readline.createInterface({ input: ghci.stderr });
  stderr.on('line', (line) => say(`[stderr] ${line}`));

  stdout = readline.createInterface({ input: ghci.stdout });
  stdout.on('line', (line) => {
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
};

const startGhciWith = (command) => {
  say(`Starting GHCi: ${command}`);

  ghci = childProcess.spawn(command, { shell: true });

  ghci.on('error', (error) => {
    throw error;
  });

  ghci.on('exit', (code, signal) => {
    if (!ghci.killed) {
      throw new Error(`GHCi exited with code ${code} and signal ${signal}!`);
    }
    say(`Killed GHCi (${signal})`);
  });

  setUpStreams();

  queueCommand('Starting', `:set prompt "${prompt}\\n"`);
  queueCommand('Configuring', ':set -ddump-json');
  queueCommand('Loading', ':reload');
};

const startGhci = () => {
  if (ghci) {
    throw new Error('Attempted to start GHCi but it is already running!');
  }

  connection.workspace.getConfiguration(py.name)
    .then((config) => startGhciWith(config.ghci.command));
};

const clearStreams = () => {
  stderr.close();
  stdout.close();

  stderr = null;
  stdout = null;
};

const clearDiagnostics = () => Object.keys(diagnostics).forEach((key) => {
  diagnostics[key] = {};
  sendDiagnostics(key);
});

const clearProgress = () => {
  if (activeJob) {
    connection.sendNotification(
      `${py.name}/hideProgress`,
      { key: activeJob.key }
    );
  }
};

const clearJobs = () => {
  jobs.pause();
  for (;;) {
    activeJob = null;
    if (!jobs.read()) {
      break;
    }
  }
  queuedCommands.clear();
  jobs.resume();
};

const restartGhci = () => {
  say('Restarting GHCi');

  ghci.on('exit', () => {
    ghci = null;
    clearStreams();
    clearDiagnostics();
    clearProgress();
    clearJobs();
    startGhci();
  });

  const killed = ghci.kill();
  if (!killed) {
    throw new Error('Failed to kill GHCi!');
  }
};

connection.onInitialize(() => {
  say(`Initializing ${py.name} ${py.version}`);
  return { capabilities: {
    documentFormattingProvider: true,
    textDocumentSync: { save: true },
  } };
});

connection.onInitialized(() => {
  startGhci();
});

const getLintRange = (hint) => ({
  end: {
    character: hint.endColumn - 1,
    line: hint.endLine - 1,
  },
  start: {
    character: hint.startColumn - 1,
    line: hint.startLine - 1,
  },
});

const getLintKey = (hint) => [
  hint.startLine,
  hint.startColumn,
  hint.endLine,
  hint.endColumn,
  hint.hint,
].join(' ');

const lintFileWith = (file, uri, config) => {
  const startedAt = performance.now();
  say(`Linting ${uri}`);
  childProcess.exec(
    `${config.hlint.command} ${file}`,
    (error, output) => {
      if (error) {
        throw error;
      }
      const finishedAt = performance.now();
      say(`Linted ${uri} in ${finishedAt - startedAt}`);
      JSON.parse(output).forEach((hint) => {
        const range = getLintRange(hint);
        const key = getLintKey(hint);
        const diagnostic = {
          code: hint.hint,
          data: { source: 'lint' },
          message: [
            `${hint.severity}: ${hint.hint}`,
            `Found: ${hint.from}`,
            `Perhaps: ${hint.to}`,
          ].join('\n'),
          range,
          severity: lsp.DiagnosticSeverity.Information,
          source: py.name,
        };

        sendDiagnostic(uri, key, diagnostic);
      });
    }
  );
};

const lintFile = (file, uri) => {
  if (diagnostics[uri]) {
    Object.keys(diagnostics[uri]).forEach((key) => {
      const diagnostic = diagnostics[uri][key];
      if (diagnostic.data && diagnostic.data.source === 'lint') {
        delete diagnostics[uri][key];
      }
    });
    sendDiagnostics(uri);
  }

  connection.workspace.getConfiguration(py.name)
    .then((config) => lintFileWith(file, uri, config));
};

connection.onDidSaveTextDocument((params) => {
  const file = url.fileURLToPath(params.textDocument.uri);
  const uri = url.pathToFileURL(file);
  say(`Saved ${uri}`);
  diagnostics[defaultFile] = {};
  sendDiagnostics(defaultFile);
  queueCommand('Reloading', ':reload');

  connection.workspace.getConfiguration(py.name).then((config) => {
    if (config.hlint.onSave) {
      lintFileWith(file, uri, config);
    }
  });
});

connection.onNotification(`${py.name}/lintFile`, (file) => {
  const uri = url.pathToFileURL(file);
  lintFile(file, uri);
});

connection.onNotification(`${py.name}/restart`, () => restartGhci());

connection.onDocumentFormatting((params) => {
  const { uri } = params.textDocument;
  const file = url.fileURLToPath(uri);
  connection.workspace.getConfiguration(py.name).then((config) => {
    const startedAt = performance.now();
    say(`Formatting ${uri}`);
    childProcess.exec(
      `${config.brittany.command} ${file}`,
      (error) => {
        if (error) {
          throw error;
        }
        const finishedAt = performance.now();
        say(`Formatted ${uri} in ${finishedAt - startedAt}`);
        return null;
      }
    );
  });
});

connection.listen();
