// https://webpack.js.org/configuration/
'use strict';

const path = require('path');

module.exports = {
  entry: {
    client: './client/index.js',
    server: './server/Main.purs',
    test: './server/Test.purs',
  },
  externals: {
    vscode: 'commonjs vscode',
  },
  mode: 'development',
  module: {
    rules: [
      {
        loader: 'eslint-loader',
        test: /[.]js$/u,
      },
      {
        loader: 'purs-loader',
        options: {
          src: [
            path.join(__dirname, 'server', '**', '*.purs'),
          ],
        },
        test: /[.]purs$/u,
      },
    ],
  },
  output: {
    libraryTarget: 'commonjs2',
  },
  target: 'node',
};
