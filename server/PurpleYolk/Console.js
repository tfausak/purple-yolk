'use strict';

exports.log = (string) => () => {
  console.log(`${new Date().toISOString()} ${string}`);
  return {};
};
