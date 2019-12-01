/* eslint-disable id-length */
'use strict';

exports.bind = (x) => (f) => () => f(x())();

exports.map = (f) => (x) => () => f(x());

exports.pure = (x) => () => x;
