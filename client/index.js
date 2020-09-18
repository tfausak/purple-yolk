'use strict';

const lsp = require('vscode-languageclient');
const path = require('path');
const purpleYolk = require('../package.json');
const vscode = require('vscode');

module.exports = {
  /* eslint-disable max-statements */
  activate: (context) => {
    const outputChannel = vscode.window.createOutputChannel('Purple Yolk');
    const server = context.asAbsolutePath(path.join('dist', 'server.js'));
    const client = new lsp.LanguageClient(
      'Purple Yolk',
      {
        debug: {
          module: server,
          options: { execArgv: ['--inspect=6009', '--nolazy'] },
          transport: lsp.TransportKind.ipc,
        },
        run: { module: server, transport: lsp.TransportKind.ipc },
      },
      {
        documentSelector: [{ language: 'haskell', scheme: 'file' }],
        outputChannel,
      }
    );
    client.start();

    context.subscriptions.push(vscode.commands.registerCommand(
      `${purpleYolk.name}.restart`,
      () => client.sendNotification(`${purpleYolk.name}/restartGhci`, null)
    ));

    context.subscriptions.push(vscode.commands.registerCommand(
      `${purpleYolk.name}.showOutput`,
      () => outputChannel.show(true)
    ));

    const statusBarItem = vscode.window.createStatusBarItem();
    statusBarItem.command = `${purpleYolk.name}.showOutput`;
    statusBarItem.text = 'Purple Yolk: Initializing';
    statusBarItem.show();

    client.onReady().then(() => client
      .onNotification(`${purpleYolk.name}/updateStatusBarItem`, (text) => {
        statusBarItem.text = text;
      }));
  },
};
