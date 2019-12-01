'use strict';

exports.throw = (string) => () => {
  throw new Error(string);
};
