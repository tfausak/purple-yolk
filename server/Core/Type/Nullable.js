/* eslint-disable id-length */
'use strict';

exports.notNull = (x) => x;

exports.null = null;

exports.toMaybeWith = (nothing) => (just) => (x) => {
  if (x === null) {
    return nothing;
  }

  return just(x);
};
