/* eslint-disable id-length */
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

exports.fromPosix = (x) => new Date(x * 1000);

exports.getCurrentDate = () => new Date();

exports.toPosix = (x) => Math.round(x / 1000);
