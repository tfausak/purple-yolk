/* eslint-disable id-length */
'use strict';

exports.log = (x) => () => {
  console.log(x);
  return {};
};
