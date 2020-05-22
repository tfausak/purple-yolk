'use strict';

const lsp = require('vscode-languageclient');
const path = require('path');
const vscode = require('vscode');

module.exports = {
  activate: (context) => {
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
      { documentSelector: [{ language: 'haskell', scheme: 'file' }] }
    );
    client.start();

    context.subscriptions.push(vscode.commands.registerCommand(
      'purpleYolk.restart',
      () => client.sendNotification('purpleYolk/restartGhci', null)
    ));

    const statusBarItem = vscode.window.createStatusBarItem();
    statusBarItem.text = 'Purple Yolk';
    statusBarItem.show();

    client.onReady().then(() =>
      client.onNotification('purpleYolk/updateStatusBarItem', (text) => {
        statusBarItem.text = text;
      }));
  },
};
