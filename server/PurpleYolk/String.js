/* eslint-disable id-length */
'use strict';

exports.append = (x) => (y) => `${x}${y}`;

exports.concat = (xs) => xs.join('');
