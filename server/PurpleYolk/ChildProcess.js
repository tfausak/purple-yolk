'use strict';

const childProcess = require('child_process');

exports.onClose = (child) => (callback) => () =>
  child.on('close', (code, signal) => callback(code)(signal)());

exports.spawn = (command) => (args) => () => childProcess.spawn(command, args);

exports.stdin = (child) => child.stdin;

exports.stderr = (child) => child.stderr;

exports.stdout = (child) => child.stdout;
