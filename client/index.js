'use strict';

const languageClient = require('vscode-languageclient');
const vscode = require('vscode');

module.exports = {
  activate: (context) => {
    const nodeModule = {
      args: [
        vscode.workspace.getConfiguration('purpleYolk').get('ghci.command'),
      ],
      module: context.asAbsolutePath('./dist/server.js'),
      transport: languageClient.TransportKind.ipc,
    };
    const client = new languageClient.LanguageClient(
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
