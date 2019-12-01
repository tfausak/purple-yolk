'use strict';

exports.append = (first) => (second) => `${first}${second}`;

exports.join = (separator) => (strings) => strings.join(separator);
