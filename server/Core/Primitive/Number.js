/* eslint-disable id-length */
'use strict';

exports.add = (x) => (y) => x + y;

exports.compareWith = (lt) => (eq) => (gt) => (x) => (y) => {
  if (isNaN(x) || isNaN(y)) {
    throw new Error(`Number.compareWith(${lt})(${eq})(${gt})(${x})(${y})`);
  }

  if (x < y) {
    return lt;
  }

  if (x > y) {
    return gt;
  }

  return eq;
};

exports.divide = (x) => (y) => x / y;

exports.infinity = 1 / 0;

exports.inspect = (x) => {
  if (isNaN(x)) {
    return 'nan';
  }

  if (isFinite(x)) {
    if (x === Math.trunc(x)) {
      return x.toFixed(1);
    }

    return x.toString();
  }

  if (x > 0) {
    return 'infinity';
  }

  return '-infinity';
};

exports.isFinite = (x) => isFinite(x);

exports.isNaN = (x) => isNaN(x);

exports.multiply = (x) => (y) => x * y;

exports.nan = 0 / 0;

exports.negate = (x) => -x;

exports.round = (x) => {
  if (!isFinite(x) || isNaN(x)) {
    throw new Error(`Number.round(${x})`);
  }

  return Math.round(x);
};

exports.subtract = (x) => (y) => x - y;
