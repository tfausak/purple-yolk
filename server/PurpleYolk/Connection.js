'use strict';

const vscode = require('vscode-languageserver');

exports.create = () => vscode.createConnection();

exports.listen = (connection) => () => {
  connection.listen();
  return {};
};

exports.onInitialize = (connection) => (callback) => () => {
  connection.onInitialize(() => callback());
  return {};
};
