/* eslint-disable id-length */
'use strict';

const url = require('url');

exports.fromPath = (path) => url.pathToFileURL(path);

exports.fromString = (string) => new url.URL(string);

exports.toPath = (x) => url.fileURLToPath(x);

exports.toString = (x) => x.toString();
