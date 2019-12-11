'use strict';

exports.onData = (readable) => (callback) => () =>
  readable.on('data', (chunk) => callback(chunk.toString())());
