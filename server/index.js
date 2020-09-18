'use strict';

const childProcess = require('child_process');
const languageServer = require('vscode-languageserver');
const purpleYolk = require('../package.json');
const url = require('url');

const connection = languageServer.createConnection();
const diagnostics = {};
let ghci = null;
const prompt = `{-${purpleYolk.name}-${purpleYolk.version}-${Date.now()}-}`;
let stderr = '';
let stdout = '';

const say = (message) => console.log(`${Date.now()} ${message}`);
say('Starting ...');

const updateStatus = (message) =>
  connection.sendNotification(
    `${purpleYolk.name}/updateStatusBarItem`,
    `Purple Yolk: ${message}`
  );

const handleStream = (stream, data, callback) => {
  let buffer = `${stream}${data}`;
  /* eslint-disable no-constant-condition */
  while (true) {
    const index = buffer.indexOf('\n');
    if (index === -1) {
      break;
    }
    callback(buffer.substring(0, index));
    buffer = buffer.substring(index + 1);
  }
  return buffer;
};

const writeStdin = (command) => {
  if (!ghci) {
    throw new Error('Tried to run a command but GHCi is not running.');
  }
  say(`[stdin] ${command}`);
  ghci.stdin.write(`${command}\n`);
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

const sendDiagnostics = () => {
  Object.keys(diagnostics).forEach((key) => {
    const value = diagnostics[key];
    connection.sendDiagnostics({
      diagnostics: Object.values(value),
      uri: key,
    });
  });
};

/* eslint-disable max-statements */
const handleJson = (json) => {
  const { span } = json;
  if (span === null) {
    if (json.reason === null && json.severity === 'SevOutput') {
      const match = json.doc.match(/Compiling .+ \( (.+), /);
      if (match) {
        const file = url.pathToFileURL(match[1]);
        diagnostics[file] = {};
      }
    }
    return;
  }
  const file = url.pathToFileURL(span.file);
  if (!diagnostics[file]) {
    diagnostics[file] = {};
  }
  const key = [
    span.startLine,
    span.startCol,
    span.endLine,
    span.endCol,
    json.reason,
  ].join(' ');
  diagnostics[file][key] = {
    code: json.reason,
    message: json.doc,
    range: {
      end: {
        character: span.endCol - 1,
        line: span.endLine - 1,
      },
      start: {
        character: span.startCol - 1,
        line: span.startLine - 1,
      },
    },
    severity: 1,
    source: purpleYolk.name,
  };
  sendDiagnostics();
};

const startGhci = () => connection
  .workspace
  .getConfiguration(purpleYolk.name)
  .then((configuration) => {
    const { command } = configuration.ghci;
    say(`Starting GHCi with: ${command}`);
    if (ghci) {
      throw new Error('Wanted to start GHCi but it\'s already running.');
    }
    ghci = childProcess.spawn(command, { shell: true });
    ghci.on('exit', (code, signal) => {
      if (code === 0) {
        say('GHCi exited successfully.');
      } else {
        throw new Error(`GHCi exited with code ${code} and signal ${signal}!`);
      }
    });
    ghci.stderr.on('data', (data) => {
      stderr = handleStream(stderr, data, (line) => say(`[stderr] ${line}`));
    });
    ghci.stdout.on('data', (data) => {
      stdout = handleStream(stdout, data, (line) => {
        say(`[stdout] ${line}`);
        const json = parseJson(line);
        if (json) {
          handleJson(json);
        }
      });
    });
    writeStdin(`:set prompt "${prompt}\\n"`);
  });

connection.onInitialize(() => {
  say('Initializing ...');
  return {
    capabilities: {
      textDocumentSync: {
        save: {},
      },
    },
  };
});

connection.onInitialized(() => {
  say('Initialized.');
  updateStatus('Starting GHCi');
  startGhci();
});

connection.onDidSaveTextDocument((params) => {
  say(`Saved ${params.textDocument.uri}`);
  writeStdin(':reload');
});

connection.onNotification(`${purpleYolk.name}/restartGhci`, () => {
  say('Stopping GHCi ...');
  updateStatus('Stopping GHCi');
  ghci.kill();
  ghci.on('exit', () => {
    say('Starting GHCi ...');
    updateStatus('Starting GHCi');
    startGhci();
  });
  Object.keys(diagnostics).forEach((key) => {
    diagnostics[key] = [];
  });
  sendDiagnostics();
  ghci = null;
});

connection.listen();
