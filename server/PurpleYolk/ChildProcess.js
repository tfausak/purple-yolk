'use strict';

const childProcess = require('child_process');

exports.onClose = (child) => (callback) => () =>
  child.on('close', (code, signal) => callback(code)(signal)());

exports.exec = (command) => () => childProcess.exec(command);

exports.kill = (child) => () => child.kill();

exports.stdin = (child) => child.stdin;

exports.stderr = (child) => child.stderr;

exports.stdout = (child) => child.stdout;
