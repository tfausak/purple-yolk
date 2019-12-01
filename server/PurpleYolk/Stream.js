/* eslint-disable id-length */
'use strict';

exports.onData = (x) => (f) => () => x.on('data', (d) => f(d.toString())());

exports.write = (x) => (s) => () => x.write(s);
