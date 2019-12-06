/* eslint-disable max-statements */
'use strict';

exports.toArray = (list) => {
  const result = [];
  let current = list;
  for (;;) {
    if (!current.value0) {
      break;
    }
    result.push(current.value0);
    current = current.value1;
  }
  return result;
};

exports.fromArrayWith = (nil) => (cons) => (array) => {
  let result = nil;
  for (let index = array.length - 1; index >= 0; index -= 1) {
    result = cons(array[index])(result);
  }
  return result;
};
