'use strict';

exports.modify = (mutable) => (modify) => () => {
  mutable.value = modify(mutable.value);
  return {};
};

exports.new = (value) => () => ({ value });

exports.read = (mutable) => () => mutable.value;
