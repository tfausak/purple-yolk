enum InterpreterMode {
  Discover = "discover",
  Cabal = "cabal",
  Stack = "stack",
  Ghci = "ghci",
  Custom = "custom",
  // Secret bonus mode! See <https://github.com/tfausak/purple-yolk/issues/83>.
  StackNonProject = "stack-non-project",
}

export default InterpreterMode;
