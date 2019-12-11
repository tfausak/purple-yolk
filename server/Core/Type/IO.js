/* eslint-disable id-length */
'use strict';

exports.delay = (seconds) => (action) => () => {
  setTimeout(() => action(), seconds * 1000);
  return {};
};

exports.log = (x) => () => {
  console.log(x);
  return {};
};

exports.throw = (x) => {
  throw new Error(x);
};
