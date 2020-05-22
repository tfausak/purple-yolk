'use strict';

const getDoc = (json) => {
  const { doc } = json;
  if (typeof doc === 'string') {
    return doc;
  }
  throw new Error();
};

const getReason = (json) => {
  const { reason } = json;
  if (reason === null || typeof reason === 'string') {
    return reason;
  }
  throw new Error();
};

const getSeverity = (json) => {
  const { severity } = json;
  if (typeof severity === 'string') {
    return severity;
  }
  throw new Error();
};

const getSpan = (json) => {
  const { span } = json;
  if (span === null) {
    return span;
  }
  if (
    typeof span.endCol === 'number' &&
    typeof span.endLine === 'number' &&
    typeof span.file === 'string' &&
    typeof span.startCol === 'number' &&
    typeof span.startLine === 'number'
  ) {
    return {
      endCol: span.endCol,
      endLine: span.endLine,
      file: span.file,
      startCol: span.startCol,
      startLine: span.startLine,
    };
  }
  throw new Error();
};

exports.fromJsonWith = (nothing) => (just) => (string) => {
  try {
    const json = JSON.parse(string);
    const doc = getDoc(json);
    const reason = getReason(json);
    const severity = getSeverity(json);
    const span = getSpan(json);
    return just({ doc, reason, severity, span });
  } catch (_err) {
    return nothing;
  }
};
