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
      () => client.sendNotification('purpleYolk/restart', null)
    ));
  },
};
