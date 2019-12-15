'use strict';

exports.fromJsonWith = (nothing) => (just) => (string) => {
  let json = null;

  try {
    json = JSON.parse(string);
  } catch (_err) {
    return nothing;
  }

  if (
    typeof json.doc !== 'string' ||
    typeof json.reason !== 'string' ||
    typeof json.severity !== 'string' ||
    typeof json.span.endCol !== 'number' ||
    typeof json.span.endLine !== 'number' ||
    typeof json.span.file !== 'string' ||
    typeof json.span.startCol !== 'number' ||
    typeof json.span.startLine !== 'number' ||
    json.span.file === '<interactive>'
  ) {
    return nothing;
  }

  return just(json);
};
