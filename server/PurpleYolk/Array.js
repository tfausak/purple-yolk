'use strict';

exports.length = (array) => array.length;

exports.map = (modify) => (array) => array.map((element) => modify(element));
