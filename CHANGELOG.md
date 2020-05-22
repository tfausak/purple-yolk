# Change log

Purple Yolk uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
