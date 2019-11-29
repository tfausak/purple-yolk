'use strict';

const vscode = require('vscode-languageserver');

const app = require('../elm-stuff/main.js').Elm.Main.init();

app.ports.log.subscribe(console.log);

const connection = vscode.createConnection();
connection.listen();
