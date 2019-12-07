/* eslint-disable id-length */
'use strict';

exports.add = (x) => (y) => x + y;

exports.bottom = -2147483648;

exports.compareWith = (lt) => (eq) => (gt) => (x) => (y) => {
  if (x > y) {
    return gt;
  }
  if (x < y) {
    return lt;
  }
  return eq;
};

exports.divide = (x) => (y) => Math.trunc(x / y);

exports.inspect = (x) => x.toString();

exports.modulo = (x) => (y) => x % y;

exports.multiply = (x) => (y) => x * y;

exports.negate = (x) => -x;

exports.power = (x) => (y) => Math.trunc(Math.pow(x, y));

exports.subtract = (x) => (y) => x - y;

exports.toNumber = (x) => x;
