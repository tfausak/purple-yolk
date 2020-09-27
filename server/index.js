'use strict';

const childProcess = require('child_process');
const lsp = require('vscode-languageserver');
const { performance } = require('perf_hooks');
const py = require('../package.json');
const readline = require('readline');

const connection = lsp.createConnection();
let ghci = null;
const prompt = `{- ${py.name} ${py.version} ${performance.timeOrigin} -}`;

const say = (message) => {
  const timestamp = (performance.now() / 1000).toFixed(3);
  connection.console.info(`${timestamp} ${message}`);
};

const tellGhci = (command) => {
  say(`[stdin] ${command}`);
  ghci.stdin.write(`${command}\n`);
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

  readline.createInterface({ input: ghci.stderr }).on('line', (line) => {
    say(`[stderr] ${line}`);
  });

  readline.createInterface({ input: ghci.stdout }).on('line', (line) => {
    say(`[stdout] ${line}`);
  });

  tellGhci(`:set prompt "${prompt}\\n"`);
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
  tellGhci(':reload');
});

connection.onNotification(`${py.name}/restart`, () => {
  restartGhci();
});

connection.listen();
