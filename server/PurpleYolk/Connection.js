'use strict';

const vscode = require('vscode-languageserver');

exports.create = () => vscode.createConnection();

exports.listen = (connection) => () => {
  connection.listen();
  return {};
};

exports.onDidSaveTextDocument = (connection) => (callback) => () => {
  connection.onDidSaveTextDocument((event) => callback(event)());
  return {};
};

exports.onInitialize = (connection) => (callback) => () => {
  connection.onInitialize(() => callback());
  return {};
};
