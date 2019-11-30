/* eslint-disable camelcase, id-length */
'use strict';

const vscode = require('vscode-languageserver');

exports.connection_create = () => vscode.createConnection();

exports.connection_listen = (x) => () => x.listen();

exports.io_bind = (x) => (f) => () => f(x())();

exports.io_map = (f) => (x) => () => f(x());

exports.io_pure = (x) => () => x;

exports.log = (x) => () => console.log(x);
