/* eslint-disable camelcase, id-length */
'use strict';

const childProcess = require('child_process');
const url = require('url');
const vscode = require('vscode-languageserver');

exports.childProcess_onClose = (x) => (f) => () =>
  x.on('close', (code) => f(code)());

exports.childProcess_onStderr = (x) => (f) => () =>
  x.stderr.on('data', (data) => f(data.toString())());

exports.childProcess_onStdout = (x) => (f) => () =>
  x.stdout.on('data', (data) => f(data.toString())());

exports.childProcess_spawn = (x) => (xs) => () =>
  childProcess.spawn(x, xs);

exports.childProcess_writeStdin = (x) => (s) => () =>
  x.stdin.write(`${s}\n`);

exports.connection_create = () =>
  vscode.createConnection();

exports.connection_listen = (connection) => () =>
  connection.listen();

exports.connection_onDidSaveTextDocument = (connection) => (f) => () =>
  connection.onDidSaveTextDocument((event) => f(event)());

exports.connection_onInitialize = (connection) => (f) => () =>
  connection.onInitialize(f);

exports.intToString = (x) =>
  x.toString();

exports.io_bind = (x) => (f) => () =>
  f(x())();

exports.io_map = (f) => (x) => () =>
  f(x());

exports.io_pure = (x) => () =>
  x;

exports.log = (x) => () =>
  console.log(x);

exports.string_append = (x) => (y) =>
  x + y;

exports.throw = (x) => () => {
  throw new Error(x);
};

exports.uriToPath = (x) =>
  url.fileURLToPath(x);
