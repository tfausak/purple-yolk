/* eslint-disable id-length */
'use strict';

const vscode = require('vscode-languageserver');

exports.create = () => vscode.createConnection();

exports.listen = (x) => () => x.listen();

exports.onDidSaveTextDocument = (x) => (f) => () =>
  x.onDidSaveTextDocument((e) => f(e)());

exports.onInitialize = (x) => (f) => () => x.onInitialize(f);
