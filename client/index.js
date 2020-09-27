'use strict';

const lsp = require('vscode-languageclient');
const path = require('path');
const py = require('../package.json');
const vscode = require('vscode');

let progress = null;

/* eslint-disable max-lines-per-function, max-statements */
const activate = (context) => {
  const outputChannel = vscode.window.createOutputChannel(py.displayName);

  const client = new lsp.LanguageClient(
    py.displayName,
    {
      run: {
        module: context.asAbsolutePath(path.join('dist', 'server.js')),
        transport: lsp.TransportKind.ipc,
      },
    },
    {
      documentSelector: [{ language: 'haskell', scheme: 'file' }],
      outputChannel,
    }
  );

  context.subscriptions.push(vscode.commands.registerCommand(
    `${py.name}.restart`,
    () => client.sendNotification(`${py.name}/restart`, null)
  ));

  context.subscriptions.push(vscode.commands.registerCommand(
    `${py.name}.showOutput`,
    () => outputChannel.show(true)
  ));

  const statusBarItem = vscode.window.createStatusBarItem();
  statusBarItem.command = `${py.name}.showOutput`;
  statusBarItem.text = py.displayName;
  statusBarItem.tooltip = 'Click to show output.';
  statusBarItem.show();

  client.onReady().then(() => {
    client.onNotification(`${py.name}/showProgress`, (title) =>
      vscode.window.withProgress({
        location: vscode.ProgressLocation.Notification,
        title: `${py.displayName}: ${title}`,
      }, (it) => {
        progress = { it };
        return new Promise((resolve) => {
          progress.resolve = resolve;
        });
      }));

    client.onNotification(`${py.name}/updateProgress`, (message) =>
      progress.it.report({ message }));

    client.onNotification(`${py.name}/hideProgress`, () => {
      progress.resolve();
      progress = null;
    });
  });

  client.start();
};

module.exports = { activate };
