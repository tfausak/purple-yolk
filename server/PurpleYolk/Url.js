'use strict';

const url = require('url');

exports.fromPath = (path) => url.pathToFileURL(path);

exports.toPath = (fileUrl) => url.fileURLToPath(fileUrl);
