// https://downloads.haskell.org/ghc/9.6.2/docs/libraries/ghc-9.6.2/GHC-Types-SrcLoc.html#t:SrcSpan
interface MessageSpan {
  endCol: number;
  endLine: number;
  file: string; // Can be `"<interactive>"`.
  startCol: number;
  startLine: number;
}

export default MessageSpan;
