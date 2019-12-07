/* eslint-disable id-length, yoda */
'use strict';

exports.add = (x) => (y) => x + y;

exports.compareWith = (lt) => (eq) => (gt) => (x) => (y) => {
  if (x > y) {
    return gt;
  }
  if (x < y) {
    return lt;
  }
  return eq;
};

exports.inspect = (s) => {
  let result = '"';
  for (let i = 0; i < s.length; i += 1) {
    const c = s[i];
    if (' ' <= c && c <= '~') {
      if (c === '"') {
        result += '\\"';
      } else {
        result += c;
      }
    } else {
      result += `\\x${c.charCodeAt(0).toString(16)}`;
    }
  }
  return `${result}"`;
};

exports.join = (s) => (xs) => xs.join(s);
