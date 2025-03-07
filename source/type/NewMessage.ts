import NewMessageReason from "./NewMessageReason";
import NewMessageSeverity from "./NewMessageSeverity";
import NewMessageSpan from "./NewMessageSpan";

// https://gitlab.haskell.org/ghc/ghc/-/blob/30bdea67fcd9755619b1f513d199f2122591b28e/docs/users_guide/diagnostics-as-json-schema-1_1.json
interface NewMessage {
    code: number | null;
    message: string[];
    reason: NewMessageReason | null;
    severity: NewMessageSeverity | null;
    span: NewMessageSpan | null;
}

export default NewMessage;
