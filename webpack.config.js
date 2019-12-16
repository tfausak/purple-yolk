// https://webpack.js.org/configuration/
'use strict';

module.exports = {
  entry: {
    client: './client/index.js',
    server: './server/index.js',
    test: './server/test.js',
  },
  externals: {
    vscode: 'commonjs vscode',
  },
  mode: 'development',
  module: {
    rules: [
      {
        exclude: /node_modules/u,
        loader: 'eslint-loader',
        test: /[.]js$/u,
      },
    ],
  },
  output: {
    libraryTarget: 'commonjs2',
  },
  target: 'node',
};
