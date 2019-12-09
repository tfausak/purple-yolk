'use strict';

exports.get = (mutable) => () => mutable.value;

exports.new = (value) => () => ({ value });

exports.set = (mutable) => (value) => () => {
  mutable.value = value;
  return {};
};
