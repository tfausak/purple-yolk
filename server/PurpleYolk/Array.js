'use strict';

exports.map = (modify) => (array) => array.map((element) => modify(element));
