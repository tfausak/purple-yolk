'use strict';

exports.fromArrayWith = (nil) => (cons) => (array) => {
  let result = nil;
  for (let index = array.length - 1; index >= 0; index -= 1) {
    result = cons(array[index])(result);
  }
  return result;
};
