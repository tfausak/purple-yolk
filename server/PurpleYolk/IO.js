'use strict';

exports.delay = (seconds) => (action) => () => {
  setTimeout(action, seconds * 1000);
  return {};
};

exports.mapM = (action) => (array) => () => {
  const result = [];
  array.forEach((element) => result.push(action(element)()));
  return result;
};
