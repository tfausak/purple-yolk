/* eslint-disable id-length */
'use strict';

exports.throw = (x) => () => {
  throw new Error(x);
};
