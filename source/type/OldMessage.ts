import OldMessageReason from "./OldMessageReason";
import OldMessageSeverity from "./OldMessageSeverity";
import OldMessageSpan from "./OldMessageSpan";

interface OldMessage {
    doc: string;
    messageClass: string | null; // Used by GHC >= 9.4.
    reason: OldMessageReason | null;
    severity: OldMessageSeverity | null; // Used by GHC < 9.4.
    span: OldMessageSpan | null;
}

export default OldMessage;
