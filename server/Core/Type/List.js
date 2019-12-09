'use strict';

exports.fromArrayWith = (nil) => (cons) => (array) => {
  let list = nil;

  for (let index = array.length - 1; index >= 0; index -= 1) {
    list = cons(array[index])(list);
  }

  return list;
};

exports.toArray = (list) => {
  let current = list;
  const array = [];

  for (;;) {
    if (!current.value0) {
      break;
    }

    array.push(current.value0);
    current = current.value1;
  }

  return array;
};
