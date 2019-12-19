'use strict';

const path = require('path');
const vscode = require('vscode-languageclient');

module.exports = {
  activate: (context) => {
    const server = context.asAbsolutePath(path.join('dist', 'server.js'));
    const client = new vscode.LanguageClient(
      'Purple Yolk',
      {
        debug: {
          module: server,
          options: { execArgv: ['--inspect=6009', '--nolazy'] },
          transport: vscode.TransportKind.ipc,
        },
        run: { module: server, transport: vscode.TransportKind.ipc },
      },
      { documentSelector: [{ language: 'haskell', scheme: 'file' }] }
    );
    client.start();
  },
};
