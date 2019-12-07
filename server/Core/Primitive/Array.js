/* eslint-disable id-length */
'use strict';

exports.add = (x) => (y) => x.concat(y);

exports.filter = (f) => (xs) => xs.filter((x) => f(x));

exports.map = (f) => (xs) => xs.map((x) => f(x));

exports.reduce = (f) => (z) => (xs) => xs.reduce((a, e) => f(a)(e), z);
