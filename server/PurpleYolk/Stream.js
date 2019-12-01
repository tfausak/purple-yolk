'use strict';

exports.onData = (stream) => (callback) => () => {
  stream.on('data', (data) => callback(data.toString())());
  return {};
};

exports.write = (stream) => (string) => () => {
  stream.write(string);
  return {};
};
