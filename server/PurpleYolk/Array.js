'use strict';

exports.filter = (predicate) => (array) =>
  array.filter((element) => predicate(element));

exports.length = (array) => array.length;

exports.map = (modify) => (array) => array.map((element) => modify(element));
