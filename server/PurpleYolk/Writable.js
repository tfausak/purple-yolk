'use strict';

exports.write = (writable) => (chunk) => () => writable.write(chunk);
