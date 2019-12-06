'use strict';

exports.fromJsonWith = (nothing) => (just) => (string) => {
  try {
    const json = JSON.parse(string);

    [
      [['doc'], 'string'],
      [['reason'], 'string'],
      [['severity'], 'string'],
      [['span'], 'object'],
      [['span', 'endCol'], 'number'],
      [['span', 'endLine'], 'number'],
      [['span', 'file'], 'string'],
      [['span', 'startCol'], 'number'],
      [['span', 'startLine'], 'number'],
    ].forEach(([keys, expected]) => {
      let value = json;
      keys.forEach((key) => {
        value = value[key];
      });
      const actual = typeof value;
      if (actual !== expected) {
        const path = keys.join('.');
        throw new Error(`expected ${path} to be ${expected} but got ${actual}`);
      }
    });

    if (json.span.file === '<interactive>') {
      throw new Error('ignoring interactive span');
    }

    return just({
      doc: json.doc,
      reason: json.reason,
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
