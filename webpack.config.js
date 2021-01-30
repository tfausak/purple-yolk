// https://webpack.js.org/configuration/
'use strict';

const ESLintPlugin = require('eslint-webpack-plugin');

module.exports = {
  entry: {
    client: './client/index.js',
    server: './server/index.js',
  },
  externals: {
    vscode: 'commonjs vscode',
  },
  mode: 'development',
  output: {
    libraryTarget: 'commonjs2',
  },
  plugins: [
    new ESLintPlugin(),
  ],
  target: 'node',
};
