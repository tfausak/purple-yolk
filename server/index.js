'use strict';

const childProcess = require('child_process');
const lsp = require('vscode-languageserver');
const { performance } = require('perf_hooks');
const py = require('../package.json');
const readline = require('readline');
const stream = require('stream');

let activeJob = null;
const connection = lsp.createConnection();
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
  onStdout: (line) => {
    connection.sendNotification(`${py.name}/updateProgress`, line);
  },
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
  restartGhci();
});

connection.listen();
