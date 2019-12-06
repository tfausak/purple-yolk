'use strict';

const url = require('url');

exports.fromPath = (path) => url.pathToFileURL(path);

exports.fromString = (string) => new url.URL(string);

exports.toPath = (url_) => url.fileURLToPath(url_);

exports.toString = (url_) => url_.toString();
