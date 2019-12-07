/* eslint-disable id-length */
'use strict';

exports.delay = (s) => (x) => () => {
  setTimeout(x, s * 1000);
  return {};
};

exports.throw = (x) => {
  throw new Error(x);
};
