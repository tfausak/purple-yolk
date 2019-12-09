/* eslint-disable id-length */
'use strict';

exports.log = (x) => () => {
  console.log(x);
  return {};
};

exports.throw = (x) => {
  throw new Error(x);
};
