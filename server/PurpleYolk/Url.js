/* eslint-disable id-length */
'use strict';

const url = require('url');

exports.toPath = (x) => url.fileURLToPath(x);
