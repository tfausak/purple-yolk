'use strict';

// There needs to be some way to avoid queueing up a bunch of reload commands
// when the user saves a bunch of files.

const childProcess = require('child_process');
const languageServer = require('vscode-languageserver');
const purpleYolk = require('../package.json');
const readline = require('readline');
const url = require('url');

const connection = languageServer.createConnection();
const diagnostics = {};
const epoch = Date.now();
let ghci = null;
const prompt = `{- ${purpleYolk.name} ${purpleYolk.version} ${epoch} -}`;

const say = (message) => {
  const timestamp = ((Date.now() - epoch) / 1000).toFixed(3);
  connection.console.info(`${timestamp} ${message}`);
};

const updateStatus = (message) =>
  connection.sendNotification(
    `${purpleYolk.name}/updateStatusBarItem`,
    `Purple Yolk: ${message}`
  );

const writeStdin = (message) => {
  say(`[stdin] ${message}`);
  updateStatus(`Running ${message}`);
  ghci.stdin.write(`${message}\n`);
};

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

const onStderr = (line) => say(`[stderr] ${line}`);

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
  } else {
    updateStatus('Idle');
  }
};

const getSeverity = (json) => {
  switch (json.severity) {
    case 'SevError': return languageServer.DiagnosticSeverity.Error;
    case 'SevWarning': switch (json.reason) {
      case 'Opt_WarnDeferredOutOfScopeVariables':
        return languageServer.DiagnosticSeverity.Error;
      case 'Opt_WarnDeferredTypeErrors':
        return languageServer.DiagnosticSeverity.Error;
      default: switch (json.span && json.span.file) {
        case '<interactive>':
          return languageServer.DiagnosticSeverity.Information;
        default: return languageServer.DiagnosticSeverity.Warning;
      }
    }
    default: return languageServer.DiagnosticSeverity.Information;
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
    source: purpleYolk.name,
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

const onExit = (code, signal) => {
  if (code === 0) {
    say('GHCi exited successfully.');
  } else if (ghci.killed) {
    say(`GHCi killed with ${code} (${signal}).`);
  } else {
    throw new Error(`GHCi exited with ${code} (${signal})!`);
  }
};

const startGhci = () => {
  say('Starting GHCi ...');
  updateStatus('Starting GHCi');
  connection.workspace.getConfiguration(purpleYolk.name).then((config) => {
    const { command } = config.ghci;
    say(`Spawning GHCi with: ${command}`);
    ghci = childProcess.spawn(command, { shell: true });
    ghci.on('exit', onExit);
    readline.createInterface({ input: ghci.stderr }).on('line', onStderr);
    readline.createInterface({ input: ghci.stdout }).on('line', onStdout);
    writeStdin(`:set prompt "${prompt}\\n"`);
  });
};

say(`Starting ${purpleYolk.name} version ${purpleYolk.version} ...`);

connection.onInitialize(() =>
  ({ capabilities: { textDocumentSync: { save: {} } } }));

connection.onInitialized(() => {
  say('Initialized.');
  startGhci();
});

connection.onDidSaveTextDocument((params) => {
  say(`Saved ${params.textDocument.uri}.`);
  writeStdin(':reload');
});

connection.onNotification(`${purpleYolk.name}/restartGhci`, () => {
  say('Stopping GHCi ...');
  updateStatus('Stopping GHCi');
  ghci.on('exit', () => {
    ghci = null;
    clearDiagnostics();
    startGhci();
  });
  ghci.kill();
});

connection.listen();
