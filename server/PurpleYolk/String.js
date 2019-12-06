'use strict';

exports.append = (first) => (second) => `${first}${second}`;

exports.equal = (first) => (second) => first === second;

exports.indexOfWith = (nothing) => (just) => (needle) => (haystack) => {
  const index = haystack.indexOf(needle);
  if (index === -1) {
    return nothing;
  }
  return just(index);
};

exports.join = (separator) => (strings) => strings.join(separator);

exports.length = (string) => string.length;

exports.split = (separator) => (string) => string.split(separator);

exports.substring = (start) => (end) => (string) =>
  string.substring(start, end);

exports.trim = (string) => string.trim();
