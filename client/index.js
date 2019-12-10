'use strict';

const vscode = require('vscode-languageclient');

module.exports = {
  activate: (context) => {
    const nodeModule = {
      module: context.asAbsolutePath('./dist/server.js'),
      transport: vscode.TransportKind.ipc,
    };
    const client = new vscode.LanguageClient(
      'Purple Yolk',
      {
        debug: nodeModule,
        run: nodeModule,
      },
      {
        documentSelector: [
          {
            language: 'haskell',
            scheme: 'file',
          },
        ],
      }
    );
    client.start();
  },
};
