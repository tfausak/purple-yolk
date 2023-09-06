import MessageReason from "./MessageReason";
import MessageSeverity from "./MessageSeverity";
import MessageSpan from "./MessageSpan";

interface Message {
  doc: string;
  messageClass: string | null; // Used by GHC >= 9.4.
  reason: MessageReason | null;
  severity: MessageSeverity | null; // Used by GHC < 9.4.
  span: MessageSpan | null;
}

export default Message;
