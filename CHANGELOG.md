# Change log

Purple Yolk uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 2025-03-18: 1.1.0

- Added ability to use Stack for non-project workspaces. <https://github.com/tfausak/purple-yolk/pull/105>

## 2025-03-17: 1.0.10

- Also publish extension to Open VSX Registry. <https://github.com/tfausak/purple-yolk/pull/102>

## 2025-03-08: 1.0.9

- Fixed handling of JSON diagnostics from newer versions of GHC using `-fdiagnostics-as-json`. <https://github.com/tfausak/purple-yolk/pull/100>

## 2025-03-02: 1.0.8

- Fixed a bug that caused diagnostics to not be cleared when using Cabal's `--enable-multi-repl` flag. <https://github.com/tfausak/purple-yolk/pull/98>

## 2024-06-22: 1.0.7

- Fixed a bug that prevented Purple Yolk from working on Windows due to problems with getting the current directory. <https://github.com/tfausak/purple-yolk/pull/86>
- Fixed CI to run on pull requests. <https://github.com/tfausak/purple-yolk/pull/87>
- Bumped esbuild from 0.20.2 to 0.21.2. <https://github.com/tfausak/purple-yolk/pull/82>

## 2024-05-09: 1.0.6

- Fixed a bug that prevented Purple Yolk from working with individual Haskell files through GHCi. <https://github.com/tfausak/purple-yolk/pull/80>

## 2024-05-06: 1.0.5

- Fixed a bug that prevented problems from being cleared when using Stack. <https://github.com/tfausak/purple-yolk/pull/77>

## 2024-05-03: 1.0.4

- Fixed another bug that would sometimes prevent the Haskell interpreter from starting. <https://github.com/tfausak/purple-yolk/pull/73>

## 2024-05-02: 1.0.3

- Fixed a bug that would sometimes prevent the Haskell interpreter from starting. <https://github.com/tfausak/purple-yolk/pull/71>
- Fixed diagnostic collection names. Now they're `ghc` and `hlint` rather than `purple-yolk`. <https://github.com/tfausak/purple-yolk/pull/70>
- Fixed a bug that would sometimes get the status bar item stuck displaying an error icon. <https://github.com/tfausak/purple-yolk/pull/69>

## 2024-04-22: 1.0.2

- Fixed diagnostic codes (like `unused-top-binds`) with GHC >= 9.4. <https://github.com/tfausak/purple-yolk/pull/66>
- Added tags (like unused or deprecated) to diagnostics. <https://github.com/tfausak/purple-yolk/pull/67>

## 2024-02-20: 1.0.1

- Updated documentation. <https://github.com/tfausak/purple-yolk/pull/62>

## 2024-02-18: 1.0.0

- Enabled HLint on save by default. <https://github.com/tfausak/purple-yolk/pull/59>

## 2024-02-18: 0.13.0

- Added Gild as a formatter for Cabal files. <https://github.com/tfausak/purple-yolk/pull/56>

## 2023-09-19: 0.12.0

- Changed "discover" configuration to prefer custom commands when they are present. <https://github.com/tfausak/purple-yolk/pull/51>

## 2023-09-09: 0.11.1

- Improved automatic discovery of Haskell formatter. <https://github.com/tfausak/purple-yolk/pull/49>

## 2023-09-06: 0.11.0

- Improved configuration to be more automatic. <https://github.com/tfausak/purple-yolk/pull/46>

## 2023-08-28: 0.10.2

- Fixed a bug that caused diagnostics from Stack to be reported at the wrong location. <https://github.com/tfausak/purple-yolk/pull/44>

## 2023-06-27: 0.10.1

- No changes.

## 2023-05-24: 0.10.0

- Added template variable expansion to commands. You can use `${file}` as the path to the current file. <https://github.com/tfausak/purple-yolk/pull/39>

## 2023-01-25: 0.9.2

- Changed the default Cabal file formatter to allow formatting more files, like `cabal.project`. <https://github.com/tfausak/purple-yolk/pull/38>

## 2023-01-14: 0.9.1

- Fixed a bug that assigned the wrong severity to diagnostics when using GHC >= 9.4. <https://github.com/tfausak/purple-yolk/pull/36>
- Fixed a bug that attempted to lint non-Haskell documents in certain situations. <https://github.com/tfausak/purple-yolk/pull/37>

## 2022-11-01: 0.9.0

- Added the ability to format Cabal files. <https://github.com/tfausak/purple-yolk/pull/35>

## 2022-08-02: 0.8.2

- Fixed language status item details.

## 2022-08-02: 0.8.1

- Changed interpreter to avoid reloading while a reload is ongoing.
- Added workspace diagnostics to interpreter.
- Changed interpreter to clear workspace diagnostics on reload.
- Changed linter to report all diagnostics as "information".
- Fixed language status item severity.

## 2022-08-02: 0.8.0

- Rewrote everything: <https://github.com/tfausak/purple-yolk/pull/32>.
  - No more LSP server; now just a VSCode client.
  - Status reported through a language status bar item.
- Changed commands:
  - `purple-yolk.lintFile` is now `purple-yolk.haskell.lint`
  - `purple-yolk.restart` is now `purple-yolk.haskell.interpret`
  - `purple-yolk.showOutput` is now `purple-yolk.output.show`
- Changed configuration properties:
  - `purple-yolk.brittany.command` is now `purple-yolk.haskell.formatter.command`
  - `purple-yolk.ghci.command` is now `purple-yolk.haskell.interpreter.command`
  - `purple-yolk.hlint.command` is now `purple-yolk.haskell.linter.command`
  - `purple-yolk.hlint.onSave` is now `purple-yolk.haskell.linter.onSave`

## 2022-07-27: 0.7.2

- Added syntax highlighting for `cabal.project`, `cabal.project.local`, and
  `cabal.project.freeze` files.
- Improved how elapsed times are logged.
- Updated dependencies.

## 2022-06-19: 0.7.1

- Fixed a bug that prevented the client from starting.

## 2022-06-18: 0.7.0

- Switched license from ISC to MIT.
- Prevented Brittany and HLint from crashing the language server.

## 2021-02-25: 0.6.1

- Added syntax highlighting for operators. Thanks Daniel Sokil! <https://github.com/tfausak/purple-yolk/pull/30>

## 2021-02-02: 0.6.0

- Added rudimentary formatting support. <https://github.com/tfausak/purple-yolk/pull/28>

## 2021-02-01: 0.5.0

- Added tags to diagnostics, which label unnecessary and deprecated things. <https://github.com/tfausak/purple-yolk/issues/27>
- Fixed a bug that incorrectly highlighted some operators as comments. <https://github.com/tfausak/purple-yolk/issues/9>

## 2021-01-30: 0.4.1

- No changes.

## 2021-01-30: 0.4.0

- Added the ability to lint on save and enabled it by default. <https://github.com/tfausak/purple-yolk/issues/24>
- Fixed a bug that cleared diagnostics when linting. <https://github.com/tfausak/purple-yolk/issues/23>

## 2021-01-14: 0.3.0

- Added basic linting through the `purple-yolk.lintFile` command. <https://github.com/tfausak/purple-yolk/issues/5>

## 2020-12-31: 0.2.3

- Changed the progress notification to only show after one second. <https://github.com/tfausak/purple-yolk/issues/22>
- Fixed a bug that caused multiple duplicate commands to be queued. <https://github.com/tfausak/purple-yolk/issues/10>

## 2020-10-03: 0.2.2

- Fixed a bug with the default GHCi command. <https://github.com/tfausak/purple-yolk/pull/21>

## 2020-09-27: 0.2.1

- Fixed a bug with the default GHCi command on Windows.

## 2020-09-27: 0.2.0

- Started displaying progress notifications. <https://github.com/tfausak/purple-yolk/issues/17>
- Started reporting import cycles as errors. <https://github.com/tfausak/purple-yolk/issues/15>

## 2020-09-18: 0.1.2

- No changes.

## 2020-09-18: 0.1.1

- No changes.

## 2020-09-18: 0.1.0

- Switched implementation from PureScript to JavaScript. <https://github.com/tfausak/purple-yolk/pull/16>
- Changed namespace for commands and config from `purpleYolk.*` to `purple-yolk.*`.

## 2020-05-26: 0.0.11

- Made it so the status bar item takes you to Purple Yolk's output when you click on it. <https://github.com/tfausak/purple-yolk/issues/14>

## 2020-05-26: 0.0.10

- Fixed how GHCi is managed to avoid crashing when a buffer fills up. <https://github.com/tfausak/purple-yolk/issues/13>

## 2020-05-24: 0.0.9

- Changed how GHCi restarts to make it more reliable. <https://github.com/tfausak/purple-yolk/issues/12>
- Made the default command more compatible with Windows.

## 2020-05-22: 0.0.8

- Changed the GHCi command to allow quoted arguments. This lets you pass multiple arguments through to GHCi, for example with `stack ghci --ghc-options '-O0 -j4'. <https://github.com/tfausak/purple-yolk/issues/11>
- Changed the default GHCi command to build benchmarks and test suites, as well as passing `-fobject-code -j4 -O0` to GHC.

## 2020-05-22: 0.0.7

- Added a status bar item to show progress. This allows you to see what Purple Yolk is working on without checking the output panel. <https://github.com/tfausak/purple-yolk/issues/3>

## 2020-05-22: 0.0.6

- Added the "Purple Yolk: Restart" command to restart GHCi. This is useful when you change something, like a `*.cabal` file, that Purple Yolk doesn't notice. <https://github.com/tfausak/purple-yolk/issues/2>
- Stopped setting `-fdefer-type-errors`, `-fno-code`, and `-j` when starting GHCi. If you want these settings enabled, add them to your GHCi command.
- Change the job queue to avoid enqueueing duplicate jobs. This avoids repeatedly running `:reload` when you save multiple files. <https://github.com/tfausak/purple-yolk/issues/10>
- Changed diagnostics to clear when compiling that file, instead of clearing everything when a reload starts. This prevents some diagnostics from disappearing on reload. <https://github.com/tfausak/purple-yolk/issues/8>
- Changed the default command to set `-ddump-json`.
- Improved startup to more reliably capture warnings and errors.

## 2019-12-21: 0.0.5

- Simplified GHCi command.

## 2019-12-20: 0.0.4

- Rewrote internals to be easier to maintain and extend.

## 2019-12-09: 0.0.3

- No user facing changes.

## 2019-12-06: 0.0.2

- Added the `purpleYolk.ghci.command` configuration option for customizing how to start GHCi.

## 2019-12-06: 0.0.1

- Initially released.
