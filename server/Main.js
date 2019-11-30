/* eslint-disable camelcase, id-length */
'use strict';

const vscode = require('vscode-languageserver');

exports.connection_create = () => vscode.createConnection();

exports.connection_listen = (connection) => () =>
  connection.listen();

exports.connection_onDidSaveTextDocument = (connection) => (f) => () =>
  connection.onDidSaveTextDocument((event) => f(event)());

exports.connection_onInitialize = (connection) => (f) => () =>
  connection.onInitialize(f);

exports.io_bind = (x) => (f) => () => f(x())();

exports.io_map = (f) => (x) => () => f(x());

exports.io_pure = (x) => () => x;

exports.log = (x) => () => console.log(x);
