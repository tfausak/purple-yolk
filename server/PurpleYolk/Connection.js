'use strict';

const vscode = require('vscode-languageserver');

exports.create = () => vscode.createConnection();

exports.listen = (connection) => () => {
  connection.listen();
  return {};
};

exports.onDidSaveTextDocument = (connection) => (callback) => () => {
  connection.onDidSaveTextDocument((params) => callback(params)());
  return {};
};

exports.onInitialize = (connection) => (callback) => () => {
  connection.onInitialize(() => callback());
  return {};
};

exports.sendDiagnostics = (connection) => (diagnostics) => () => {
  connection.sendDiagnostics(diagnostics);
  return {};
};
