'use strict';

exports.register = (client) => (name) => () => client.register(name);
