// https://webpack.js.org/configuration/
'use strict';

module.exports = {
  entry: {
    client: './client/index.js',
    server: './server/run-Main.js',
    test: './server/run-Test.js',
  },
  externals: {
    vscode: 'commonjs vscode',
  },
  mode: 'development',
  output: {
    libraryTarget: 'commonjs2',
  },
  target: 'node',
};
