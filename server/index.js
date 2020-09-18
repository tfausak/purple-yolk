'use strict';

// The onStdout function needs to be split up.

// Also maybe <interactive> stuff can be sent at a severity below warnings?

// Also there needs to be some way to avoid queueing up a bunch of reload
// commands when the user saves a bunch of files.

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

const getSeverity = (json) => {
  if (json.severity === 'SevError') {
    return 1;
  }
  if (json.severity === 'SevWarning') {
    if (json.reason === 'Opt_WarnDeferredTypeErrors') {
      return 1;
    }
    if (json.reason === 'Opt_WarnDeferredOutOfScopeVariables') {
      return 1;
    }
    return 2;
  }
  return 3;
};

/* eslint-disable max-lines-per-function, max-statements */
const onStdout = (line) => {
  const json = parseJson(line);
  if (json) {
    if (json.span) {
      if (json.span.file === '<interactive>') {
        say(`[stdout] ${line}`);
      } else {
        const file = url.pathToFileURL(json.span.file);
        const key = [
          json.span.startLine,
          json.span.startCol,
          json.span.endLine,
          json.span.endCol,
          json.reason,
        ].join(' ');
        if (!diagnostics[file]) {
          diagnostics[file] = {};
        }
        diagnostics[file][key] = {
          code: json.reason,
          message: json.doc,
          range: {
            end: {
              character: json.span.endCol - 1,
              line: json.span.endLine - 1,
            },
            start: {
              character: json.span.startCol - 1,
              line: json.span.startLine - 1,
            },
          },
          severity: getSeverity(json),
          source: purpleYolk.name,
        };
        sendDiagnostics(file);
      }
    } else if (json.reason === null && json.severity === 'SevOutput') {
      const pattern = /^\[ *(\d+) of (\d+)\] Compiling (\S+) *\( ([^,]+), /;
      const match = json.doc.match(pattern);
      if (match) {
        const file = url.pathToFileURL(match[4]);
        diagnostics[file] = {};
        sendDiagnostics(file);
      } else {
        say(`[stdout] ${line}`);
      }
    } else {
      say(`[stdout] ${line}`);
    }
  } else if (line.indexOf(prompt) === -1) {
    say(`[stdout] ${line}`);
  } else {
    updateStatus('Idle');
  }
};

const onExit = (code, signal) => {
  if (code === 0) {
    say('GHCi exited successfully.');
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
    Object.keys(diagnostics).forEach((key) => {
      diagnostics[key] = {};
      sendDiagnostics(key);
    });
    startGhci();
  });
  ghci.kill();
});

connection.listen();
