// https://downloads.haskell.org/ghc/9.6.2/docs/libraries/ghc-9.6.2/GHC-Types-Error.html#t:Severity
enum MessageSeverity {
  SevDump = "SevDump",
  SevError = "SevError",
  SevFatal = "SevFatal",
  SevInfo = "SevInfo",
  SevInteractive = "SevInteractive",
  SevOutput = "SevOutput",
  SevWarning = "SevWarning",
}

export default MessageSeverity;
