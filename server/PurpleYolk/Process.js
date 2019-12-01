/* eslint-disable id-length */
'use strict';

const process = require('child_process');

exports.onClose = (x) => (f) => () => x.on('close', (c, s) => f(c)(s)());

exports.spawn = (x) => (xs) => () => process.spawn(x, xs);

exports.stderr = (x) => x.stderr;

exports.stdin = (x) => x.stdin;

exports.stdout = (x) => x.stdout;
