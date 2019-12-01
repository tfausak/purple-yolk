'use strict';

const url = require('url');

exports.toPath = (theUrl) => url.fileURLToPath(theUrl);
