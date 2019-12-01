module Main
  ( main
  ) where

import PurpleYolk.Connection as Connection
import PurpleYolk.Console as Console
import PurpleYolk.Exception as Exception
import PurpleYolk.IO as IO
import PurpleYolk.Int as Int
import PurpleYolk.Path as Path
import PurpleYolk.Process as Process
import PurpleYolk.Stream as Stream
import PurpleYolk.String as String
import PurpleYolk.Unit as Unit
import PurpleYolk.Url as Url

main :: IO.IO Unit.Unit
main =
  let
    bind = IO.bind
    discard = IO.bind
  in do
    Console.log "Starting up ..."

    ghci <- Process.spawn "stack"
      -- Separate from GHC, Stack tries to colorize its messages. We don't try to
      -- parse Stack's output, so it doesn't really matter. But it's annoying to
      -- see the ANSI escape codes in the debug output.
      [ "--color=never"
      -- Explicitly setting the terminal width avoids a warning about `stty`.
      , "--terminal-width=0"
      , "exec"
      , "--"
      , "ghci"
      -- This one is critical. Rather than trying to parse GHC's human-readable
      -- output, we can get it to print out JSON instead. Note that the
      -- messages themselves are still human readable. It's the metadata that
      -- gets turned into structured JSON.
      , "-ddump-json"
      -- Deferring type errors turns them into warnings, which allows more
      -- warnings to be reported when there are type errors.
      , "-fdefer-type-errors"
      -- We're not interested in actually building anything, just type
      -- checking. This has the nice side effect of making things faster.
      , "-fno-code"
      -- Using multiple cores should be faster. Might need to actually
      -- benchmark this, and maybe expose it as an option.
      , "-j"
      ]

    Stream.onData (Process.stderr ghci) \ chunk ->
      Console.log (String.append "ghci stderr: " (String.inspect chunk))

    Stream.onData (Process.stdout ghci) \ chunk ->
      Console.log (String.append "ghci stdout: " (String.inspect chunk))

    Process.onClose ghci \ code signal ->
      Exception.throw (String.concat
        [ "GHCi closed with code "
        , Int.inspect code
        , " and signal "
        , String.inspect signal
        ])

    let
      write message = do
        Console.log (String.append "ghci stdin: " (String.inspect message))
        Stream.write (Process.stdin ghci) (String.append message "\n")
    write ":set prompt \"{- purple-yolk -}\\n\""
    write ":set +c"

    connection <- Connection.create

    Connection.onInitialize connection (IO.pure
      { capabilities: { textDocumentSync: { save: true } } })

    Connection.onDidSaveTextDocument connection \ event ->
      write (String.append ":load "
        (Path.toString (Url.toPath event.textDocument.uri)))

    Connection.listen connection

    Console.log "Up and running!"
