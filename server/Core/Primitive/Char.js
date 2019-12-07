/* eslint-disable id-length, yoda */
'use strict';

exports.compareWith = (lt) => (eq) => (gt) => (x) => (y) => {
  if (x > y) {
    return gt;
  }
  if (x < y) {
    return lt;
  }
  return eq;
};

exports.fromIntNullable = (x) => {
  if (x < 0) {
    return null;
  }
  if (x > 0xffff) {
    return null;
  }
  return String.fromCharCode(x);
};

exports.inspect = (x) => {
  if (' ' <= x && x <= '~') {
    return `'${x}'`;
  }
  return `'\\x${x.charCodeAt(0).toString(16)}'`;
};

exports.toInt = (x) => x.charCodeAt(0);
