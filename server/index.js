'use strict';

const Main = require('../output/Main/index.js');

const [_code, _server, ghci, ..._rest] = process.argv;
const [command, ...args] = ghci.split(/\s+/u);
Main.main(command)(args)();
