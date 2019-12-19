'use strict';

exports.getConfiguration = (workspace) => (name) => (callback) => () =>
  workspace.getConfiguration(name).then((configuration) =>
    callback(configuration)());
