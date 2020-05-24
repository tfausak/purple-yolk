# Purple Yolk

Purple Yolk is a Haskell IDE for Visual Studio Code.

Purple Yolk works best for Haskell projects that can be loaded into GHCi.
Behind the scenes it launches GHCi for you, reloads it when you make changes,
and displays GHCi's output in VSCode. This makes it very similar to [ghcid][].

Purple Yolk doesn't care which build tool you use. The default configuration
uses Stack, but you can just as easily use Cabal, Nix, or anything else. You
can even use different build tools in different workspaces thanks to VSCode's
built-in workspace configurations.

[ghcid]: https://github.com/ndmitchell/ghcid
