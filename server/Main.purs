module Main
  ( main
  ) where

import PurpleYolk.IO (bind, discard)

import PurpleYolk.Connection as Connection
import PurpleYolk.Console as Console
import PurpleYolk.Exception as Exception
import PurpleYolk.IO as IO
import PurpleYolk.Inspect as Inspect
import PurpleYolk.Maybe as Maybe
import PurpleYolk.Mutable as Mutable
import PurpleYolk.Path as Path
import PurpleYolk.Process as Process
import PurpleYolk.Queue as Queue
import PurpleYolk.Stream as Stream
import PurpleYolk.String as String
import PurpleYolk.Tuple as Tuple
import PurpleYolk.Unit as Unit
import PurpleYolk.Url as Url

main :: IO.IO Unit.Unit
main = do
  stdout <- Mutable.new ""
  stderr <- Mutable.new ""
  ghci <- initializeGhci stdout stderr
  queue <- initializeQueue
  connection <- initializeConnection ghci queue

  let
    loop = do
      jobs <- Mutable.read queue
      case Queue.dequeue jobs of
        Maybe.Nothing -> do
          Console.log "Nothing to do."
          IO.delay 1.0 loop -- TODO: Shorten delay and remove logging.
        Maybe.Just result -> do
          Mutable.modify queue \ _ -> Tuple.second result
          let job = Tuple.first result
          Console.log (String.append "STDIN " job.command)
          Stream.write (Process.stdin ghci) (String.append job.command "\n")
          -- TODO: Wait for command to finish.
          loop
  loop

initializeGhci
  :: Mutable.Mutable String
  -> Mutable.Mutable String
  -> IO.IO Process.Process
initializeGhci stdout stderr = do
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

  Stream.onData (Process.stdout ghci) \ chunk ->
    Mutable.modify stdout \ buffer -> String.append buffer chunk

  Stream.onData (Process.stderr ghci) \ chunk ->
    Mutable.modify stderr \ buffer -> String.append buffer chunk
    -- TODO: Output STDERR using line buffering.

  Process.onClose ghci \ code signal ->
    Exception.throw (String.concat
      [ "GHCi closed with code "
      , Inspect.inspect code
      , " and signal "
      , Inspect.inspect signal
      ])

  IO.pure ghci

type Job =
  { callback :: String -> IO.IO Unit.Unit
  , command :: String
  }

initializeQueue :: IO.IO (Mutable.Mutable (Queue.Queue Job))
initializeQueue = do
  queue <- Mutable.new Queue.empty

  Mutable.modify queue (Queue.enqueue
    { callback: Console.log
    , command: ":set prompt \"{- purple-yolk -}\\n\""
    })

  Mutable.modify queue (Queue.enqueue
    { callback: Console.log
    , command: ":set +c"
    })

  IO.pure queue

initializeConnection
  :: Process.Process
  -> Mutable.Mutable (Queue.Queue Job)
  -> IO.IO Connection.Connection
initializeConnection ghci queue = do
  connection <- Connection.create

  Connection.onInitialize connection (IO.pure
    { capabilities: { textDocumentSync: { save: true } } })

  Connection.onDidSaveTextDocument connection \ event ->
    Mutable.modify queue (Queue.enqueue
      { callback: Console.log
      , command: String.append ":load " (Path.toString (Url.toPath event.textDocument.uri))
      })

  Connection.listen connection
  IO.pure connection
