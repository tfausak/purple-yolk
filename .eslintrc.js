// https://eslint.org/docs/user-guide/configuring
'use strict';

module.exports = {
  env: { node: true },
  extends: 'eslint:all',
  ignorePatterns: ['dist/', 'output/', '!.eslintrc.js'],
  parserOptions: { ecmaVersion: 6 },
  rules: {
    'array-element-newline': ['error', 'consistent'],
    'capitalized-comments': 'off',
    'comma-dangle': ['error', 'always-multiline'],
    'function-call-argument-newline': ['error', 'consistent'],
    indent: ['error', 2, { SwitchCase: 1 }],
    'linebreak-style': 'off',
    'multiline-comment-style': ['error', 'separate-lines'],
    'no-console': 'off',
    'no-magic-numbers': 'off',
    'object-curly-spacing': ['error', 'always'],
    'one-var': ['error', 'never'],
    'padded-blocks': ['error', 'never'],
    'quote-props': ['error', 'as-needed'],
    quotes: ['error', 'single'],
  },
};
