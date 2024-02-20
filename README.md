# Purple Yolk

Purple Yolk is an extension for Visual Studio Code that provides a simple IDE
for Haskell projects.

Purple Yolk is designed to work with Haskell projects rather than individual
Haskell files. That typically means something with a `cabal.project` or
`stack.yaml` file. Although Purple Yolk can work with a single Haskell file,
its utility is somewhat limited.

At a high level, Purple Yolk launches GHCi for you, reloads it when you make
changes, and displays GHCi's output in VS Code. It is designed to work with any
project and build tool that can provide a REPL. It includes built-in support
for both Cabal and Stack. Other tools are supported via custom configuration.

## Features

These are the features that Purple Yolk provides:

- Syntax highlighting for both Haskell and Cabal files.

- Integration with GHCi, displaying GHC's warnings and errors inline and in the
  problems tab. This supports both Cabal and Stack for projects as well as GHCi
  for individual files.

- Formatting of Haskell files. Out of the box this supports both Fourmolu and
  Ormolu. Additional formatters are supported via custom configuration as long
  as the support reading from STDIN and writing to STDOUT.

- Formatting of Cabal files. Out of the box this supports both `cabal-fmt` and
  Gild. Additional formatters are supported via custom configuration as long as
  they support reading from STDIN and writing to STDOUT.

- Linting of Haskell files. Out of the box this supports HLint. Additional
  linters are supported via custom configuration, but their output must be the
  same as HLint's.

## Not Implemented

These features are not (yet?) implemented. Most of them require a GHCi session
loaded for an individual module rather than the entire project.

- Automatically suggesting fixes. Consider using [the Haskutil extension][]
  along with Purple Yolk.

  [the Haskutil extension]: https://marketplace.visualstudio.com/items?itemName=Edka.haskutil

- Contextual auto completion. This could be provided with GHCi's `:complete`
  command.

- Documentation on hover. This could be provided with GHCi's `:doc` and/or
  `:info` commands.

- Displaying the type at the cursor. This could be provided with GHCi's `:type`
  command.

- Sending commands directly to the REPL. This could be supported, but extra
  safeguards would have to be put in place to avoid breaking the integration.
  For example sending a bogus `:load` command could have unintended
  consequences.

- Jump to definition. This is not supported by GHCi.

- Find usages. This is not supported by GHCi.

## Common Problems

If you delete a file/module, you'll have to restart GHCi for the build to
succeed. Similarly if you add a new dependency, you'll have to restart GHCi for
it to be picked up.

In general, if something goes wrong you should run the "Purple Yolk: Start
Interpreter" command to (re)start GHCi. If things go _really_ wrong you can try
"Developer: Reload Window" to reload everything.

Purple Yolk produces some chatty output that can help debugging. Use the
"Purple Yolk: Show Output" command to see it.

## Development

To build Purple Yolk locally and install it, run the following commands:

``` sh
$ npm install
$ rm -f purple-yolk-*.vsix
$ npx vsce package --pre-release
$ code --install-extension purple-yolk-*.vsix
```
