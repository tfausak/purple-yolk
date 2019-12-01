'use strict';

const child = require('child_process');

exports.onClose = (proc) => (callback) => () => {
  proc.on('close', (code, signal) => callback(code)(signal)());
  return {};
};

exports.spawn = (command) => (args) => () => child.spawn(command, args);

exports.stderr = (proc) => proc.stderr;

exports.stdin = (proc) => proc.stdin;

exports.stdout = (proc) => proc.stdout;
