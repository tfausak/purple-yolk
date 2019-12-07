/* eslint-disable id-length */
'use strict';

exports.add = (x) => (y) => x + y;

exports.ceiling = (x) => Math.ceil(x);

exports.compareWith = (lt) => (eq) => (gt) => (x) => (y) => {
  if (x > y) {
    return gt;
  }
  if (x < y) {
    return lt;
  }
  return eq;
};

exports.divide = (x) => (y) => x / y;

exports.floor = (x) => Math.floor(x);

exports.infinity = 1 / 0;

exports.inspect = (x) => {
  if (x === Math.trunc(x)) {
    return x.toFixed(1);
  }
  return x.toString();
};

exports.isFinite = (x) => isFinite(x);

exports.isNaN = (x) => isNaN(x);

exports.nan = 0 / 0;

exports.modulo = (x) => (y) => x % y;

exports.multiply = (x) => (y) => x * y;

exports.negate = (x) => -x;

exports.power = (x) => (y) => Math.pow(x, y);

exports.round = (x) => Math.round(x);

exports.subtract = (x) => (y) => x - y;

exports.truncate = (x) => Math.trunc(x);
