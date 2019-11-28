'use strict';

const vscode = require('vscode-languageserver');

const connection = vscode.createConnection();
connection.listen();
