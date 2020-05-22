'use strict';

const lsp = require('vscode-languageserver');

exports.client = (connection) => connection.client;

exports.create = () => lsp.createConnection();

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

exports.onInitialized = (connection) => (callback) => () => {
  connection.onInitialized(() => callback());
  return {};
};

exports.onNotification = (connection) => (notification) => (callback) => () => {
  connection.onNotification(notification, () => callback());
  return {};
};

exports.sendDiagnostics = (connection) => (diagnostics) => () => {
  connection.sendDiagnostics(diagnostics);
  return {};
};

exports.workspace = (connection) => connection.workspace;
