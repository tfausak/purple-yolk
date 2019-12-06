'use strict';

const checkType = (json, keys, expected) => {
  let value = json;

  keys.forEach((key) => {
    value = value[key];
  });

  const actual = typeof value;

  if (actual !== expected) {
    const path = keys.join('.');
    throw new Error(`expected ${path} to be ${expected} but got ${actual}`);
  }
};

const getReason = (nothing, just, json) => {
  if (typeof json.reason === 'string') {
    return just(json.reason);
  } else if (json.reason === null) {
    return nothing;
  }
  throw new Error(`invalid reason: ${json.reason}`);
};

exports.fromJsonWith = (nothing) => (just) => (string) => {
  try {
    const json = JSON.parse(string);

    [
      [['doc'], 'string'],
      [['severity'], 'string'],
      [['span'], 'object'],
      [['span', 'endCol'], 'number'],
      [['span', 'endLine'], 'number'],
      [['span', 'file'], 'string'],
      [['span', 'startCol'], 'number'],
      [['span', 'startLine'], 'number'],
    ].forEach(([keys, expected]) => checkType(json, keys, expected));

    if (json.span.file === '<interactive>') {
      throw new Error('ignoring interactive span');
    }

    return just({
      doc: json.doc,
      reason: getReason(nothing, just, json),
      severity: json.severity,
      span: {
        endCol: json.span.endCol,
        endLine: json.span.endLine,
        file: json.span.file,
        startCol: json.span.startCol,
        startLine: json.span.startLine,
      },
    });
  } catch (_error) {
    return nothing;
  }
};
