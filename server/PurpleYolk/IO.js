'use strict';

exports.delay = (seconds) => (action) => () => {
  setTimeout(action, seconds * 1000);
  return {};
};
