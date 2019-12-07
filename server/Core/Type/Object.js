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

exports.delete = (key) => (object) => {
  const result = clone(object);
  delete result[key];
  return result;
};

exports.empty = {};

exports.insert = (key) => (value) => (object) => {
  const result = clone(object);
  result[key] = value;
  return result;
};

exports.lookupWith = (nothing) => (just) => (key) => (object) => {
  if (hasKey(object, key)) {
    return just(object[key]);
  }
  return nothing;
};
