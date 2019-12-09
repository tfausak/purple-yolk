/* eslint-disable id-length */
'use strict';

exports.add = (x) => (y) => x.concat(y);

exports.apply = (fs) => (xs) => fs.flatMap((f) => xs.map((x) => f(x)));

exports.bind = (xs) => (f) => xs.flatMap((x) => f(x));

exports.compareWith = (lt) => (eq) => (gt) => (compare) => (xs) => (ys) => {
  const length = Math.max(xs.length, ys.length);

  for (let i = 0; i < length; i += 1) {
    if (i >= xs.length) {
      return lt;
    }

    if (i >= ys.length) {
      return gt;
    }

    const ordering = compare(xs[i])(ys[i]);
    if (ordering !== eq) {
      return ordering;
    }
  }

  return eq;
};

exports.inspect = (inspect) => (xs) =>
  `[${xs.map((x) => inspect(x)).join(', ')}]`;

exports.map = (f) => (xs) => xs.map((x) => f(x));
