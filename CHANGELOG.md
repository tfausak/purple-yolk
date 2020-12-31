# Change log

Purple Yolk uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
