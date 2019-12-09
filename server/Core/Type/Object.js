/* eslint-disable id-length */
'use strict';

const hasKey = (object, key) =>
  Object.prototype.hasOwnProperty.call(object, key);

const clone = (object) => {
  const result = {};

  for (const key in object) {
    if (hasKey(object, key)) {
      result[key] = object[key];
    }
  }

  return result;
};

exports.empty = {};

exports.getWith = (nothing) => (just) => (key) => (object) => {
  if (hasKey(object, key)) {
    return just(object[key]);
  }

  return nothing;
};

exports.map = (f) => (object) => {
  const result = {};

  for (const key in object) {
    if (hasKey(object, key)) {
      result[key] = f(object[key]);
    }
  }

  return result;
};

exports.set = (key) => (value) => (object) => {
  const result = clone(object);
  result[key] = value;
  return result;
};

exports.toListWith = (tuple) => (nil) => (cons) => (object) => {
  let list = nil;

  for (const key in object) {
    if (hasKey(object, key)) {
      list = cons(tuple(key)(object[key]))(list);
    }
  }

  return list;
};
