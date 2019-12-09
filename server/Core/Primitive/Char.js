/* eslint-disable id-length */
'use strict';

exports.compareWith = (lt) => (eq) => (gt) => (x) => (y) => {
  if (x < y) {
    return lt;
  }
  if (x > y) {
    return gt;
  }
  return eq;
};

exports.inspect = (x) => {
  if (x >= ' ' && x <= '~') {
    return `'${x}'`;
  }
  return `'\\x${x.charCodeAt(0).toString(16)}'`;
};
