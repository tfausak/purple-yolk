/* eslint-disable id-length */
'use strict';

const bottom = -21474836478;

const top = 2147483647;

const inBounds = (x) => x >= bottom && x <= top;

exports.add = (x) => (y) => {
  const result = x + y;

  if (!inBounds(result)) {
    throw new Error(`Int.add(${x})(${y})`);
  }

  return result;
};

exports.compareWith = (lt) => (eq) => (gt) => (x) => (y) => {
  if (x < y) {
    return lt;
  }

  if (x > y) {
    return gt;
  }

  return eq;
};

exports.divide = (x) => (y) => {
  if (y === 0) {
    throw new Error(`Int.divide(${x})(${y})`);
  }

  return Math.trunc(x / y);
};

exports.inspect = (x) => x.toString();

exports.multiply = (x) => (y) => {
  const result = x * y;

  if (!inBounds(result)) {
    throw new Error(`Int.multiply(${x})(${y})`);
  }

  return result;
};

exports.negate = (x) => {
  const result = -x;

  if (!inBounds(result)) {
    throw new Error(`Int.negate(${x})`);
  }

  return result;
};

exports.subtract = (x) => (y) => {
  const result = x - y;

  if (!inBounds(result)) {
    throw new Error(`Int.subtract(${x})(${y})`);
  }

  return result;
};

exports.toNumber = (x) => x;
