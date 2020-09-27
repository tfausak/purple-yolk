// https://eslint.org/docs/user-guide/configuring
'use strict';

module.exports = {
  env: { node: true },
  extends: 'eslint:all',
  globals: { Promise: 'readonly' },
  ignorePatterns: ['dist/', 'output/', '!.eslintrc.js'],
  parserOptions: { ecmaVersion: 6 },
  rules: {
    'array-bracket-newline': ['error', 'consistent'],
    'array-element-newline': ['error', 'consistent'],
    'capitalized-comments': 'off',
    'comma-dangle': ['error', 'always-multiline'],
    'dot-location': ['error', 'property'],
    'function-call-argument-newline': ['error', 'consistent'],
    'implicit-arrow-linebreak': 'off',
    indent: ['error', 2, { SwitchCase: 1 }],
    'linebreak-style': 'off',
    'max-lines': 'off',
    'multiline-comment-style': ['error', 'separate-lines'],
    'no-console': 'off',
    'no-empty-function': 'off',
    'no-extra-parens': ['error', 'all', { nestedBinaryExpressions: false }],
    'no-magic-numbers': 'off',
    'no-unused-vars':
      ['error', { argsIgnorePattern: '^_', varsIgnorePattern: '^_' }],
    'object-curly-spacing': ['error', 'always'],
    'object-property-newline':
      ['error', { allowAllPropertiesOnSameLine: true }],
    'one-var': ['error', 'never'],
    'padded-blocks': ['error', 'never'],
    'prefer-named-capture-group': 'off',
    'quote-props': ['error', 'as-needed'],
    quotes: ['error', 'single'],
    'require-unicode-regexp': 'off',
  },
};
