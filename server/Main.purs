{- TODO
Handle JSON output from GHCi when loading files. It looks like this:
  {
    "span": {
      "file": "c:\\Users\\Taylor\\.vscode\\extensions\\purple-yolk\\Example.hs",
      "startLine": 1,
      "startCol": 1,
      "endLine": 1,
      "endCol": 1
    },
    "doc": "Module `Prelude' implicitly imported",
    "severity": "SevWarning",
    "reason": "Opt_WarnImplicitPrelude"
  }
-}

module Main
  ( main
  ) where

import PurpleYolk.IO (bind, discard)

import PurpleYolk.Array as Array
import PurpleYolk.Connection as Connection
import PurpleYolk.Console as Console
import PurpleYolk.Exception as Exception
import PurpleYolk.IO as IO
import PurpleYolk.Int as Int
import PurpleYolk.Maybe as Maybe
import PurpleYolk.Mutable as Mutable
import PurpleYolk.Package as Package
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

  -- First we initialize a job queue. This is how we send input to GHCi and
  -- react to its output.
  queue <- initializeQueue

  -- Next we initialize a connection with Visual Studio Code. This lets us
  -- respond to actions taken in the editor as well as display things in the
  -- interface.
  connection <- initializeConnection queue

  -- Then we spawn GHCi in a separate process and initialize some buffers to
  -- capture its output.
  stdout <- Mutable.new ""
  stderr <- Mutable.new ""
  ghci <- initializeGhci stdout stderr

  processJobs queue stdout ghci

-- We need a prompt that is unlikely to appear naturally in the output. That's
-- because we use the presence of the prompt in the output to determine when
-- GHCi is done processing a command.
prompt :: String
prompt = String.concat ["{- purple-yolk/", Package.version, " -}"]

type Job =
  { command :: String
  , callback :: String -> IO.IO Unit.Unit
  }

-- If there's nothing interesting to do with the output, simply print each line
-- out to the console. The assumption here is that any structured output from
-- GHCi that we parse will not be output to anything.
defaultCallback :: String -> IO.IO Unit.Unit
defaultCallback string = IO.mapM_
  (\ line -> if Int.equal (String.length line) 0
    then IO.pure Unit.unit
    else Console.log (String.append "STDOUT " line))
  (Array.map String.trim (String.split "\n" string))

initializeQueue :: IO.IO (Mutable.Mutable (Queue.Queue Job))
initializeQueue = do
  queue <- Mutable.new Queue.empty

  -- Since we use the prompt to figure out when a command is done, the very
  -- first thing we do needs to be to set the prompt. Otherwise the first
  -- command would hang forever waiting to finish.
  Mutable.modify queue (Queue.enqueue
    { command: String.concat [":set prompt \"", prompt, "\\n\""]
    , callback: defaultCallback
    })

  -- This tells GHCi to collect additional type and location information, which
  -- is used by other commands.
  -- <https://downloads.haskell.org/~ghc/8.8.1/docs/html/users_guide/ghci.html#ghci-cmd-:set%20+c>
  Mutable.modify queue (Queue.enqueue
    { command: ":set +c"
    , callback: defaultCallback
    })

  IO.pure queue

initializeConnection
  :: Mutable.Mutable (Queue.Queue Job)
  -> IO.IO Connection.Connection
initializeConnection queue = do
  connection <- Connection.create

  -- When the connection is initialized we need to tell VSCode which
  -- capabilities we support.
  Connection.onInitialize connection (IO.pure
    { capabilities: { textDocumentSync: { save: true } } })

  -- When the user saves a text document we need to enqueue a job that tells
  -- GHCi to load that document.
  Connection.onDidSaveTextDocument connection \ event ->
    Mutable.modify queue (Queue.enqueue
      { callback: defaultCallback
      , command: String.append ":load " (Path.toString (Url.toPath event.textDocument.uri))
      })

  -- We start listening on the connection after all our callbacks have been set
  -- up. That way we can be sure we don't miss anything.
  Connection.listen connection

  IO.pure connection

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

  -- When GHCi outputs to STDOUT we simply append to our buffer.
  Stream.onData (Process.stdout ghci) \ chunk ->
    Mutable.modify stdout \ buffer -> String.append buffer chunk

  -- When GHCi outputs to STDERR we append to our buffer and then output each
  -- line prefixed with "STDERR". This assumes that we'll never want to act on
  -- anything in STDERR, only output it for debugging.
  Stream.onData (Process.stderr ghci) \ chunk -> do
    Mutable.modify stderr \ buffer -> String.append buffer chunk
    drainStderr stderr

  -- During normal operation GHCi should never close (aka exit). If it does,
  -- that means something has gone horribly wrong. The only reasonable thing we
  -- can do is crash and let VSCode restart us.
  Process.onClose ghci \ _code _signal ->
    Exception.throw "GHCi closed unexpectedly!"

  IO.pure ghci

-- Outputs the contents of the buffer (which is assumed to be STDERR) one line
-- at a time. If there's not yet a full line of content, this does nothing.
-- Note that blank lines will not be printed out.
drainStderr :: Mutable.Mutable String -> IO.IO Unit.Unit
drainStderr stderr = do
  buffer <- Mutable.read stderr
  case String.indexOf "\n" buffer of
    Maybe.Nothing -> IO.pure Unit.unit
    Maybe.Just index -> do
      let
        line = String.trim (String.substring 0 index buffer)
        rest = String.substring (Int.add index 1) (String.length buffer) buffer
      if Int.equal (String.length line) 0
        then IO.pure Unit.unit
        else Console.log (String.append "STDERR " line)
      Mutable.modify stderr \ _ -> rest
      drainStderr stderr

processJobs
  :: Mutable.Mutable (Queue.Queue Job)
  -> Mutable.Mutable String
  -> Process.Process
  -> IO.IO Unit.Unit
processJobs queue stdout ghci = do
  jobs <- Mutable.read queue
  case Queue.dequeue jobs of
    Maybe.Nothing ->
      -- If there are not jobs to process then we'll wait a little while and
      -- try again. The goal here is to avoid using 100% of the CPU when idle
      -- but still remain responsive.
      IO.delay 0.1 (processJobs queue stdout ghci)

    Maybe.Just (Tuple.Tuple job newQueue) -> do
      -- We successfully pulled a job off the queue, so update the queue to
      -- remove that job.
      Mutable.modify queue \ _ -> newQueue

      -- Output the job for debugging so we can see when it started and what
      -- exactly was sent to GHCi.
      Console.log (String.append "STDIN " job.command)

      -- Actually send the job to GHCi by running the command.
      Stream.write (Process.stdin ghci) (String.append job.command "\n")

      -- Wait for the job to finish and handle its output.
      processJob queue stdout ghci job

processJob
  :: Mutable.Mutable (Queue.Queue Job)
  -> Mutable.Mutable String
  -> Process.Process
  -> Job
  -> IO.IO Unit.Unit
processJob queue stdout ghci job = do
  buffer <- Mutable.read stdout
  case String.indexOf prompt buffer of
    Maybe.Nothing ->
      -- If the prompt hasn't appeared in the output yet, that (hopefully)
      -- means that the job hasn't completed. Wait for a bit then try again.
      IO.delay 0.1 (processJob queue stdout ghci job)

    Maybe.Just index -> do
      -- The prompt has appeared in the output, so (hopefully) the job has
      -- completed. Split the output into the part before the prompt and the
      -- part after, ignoring the prompt entirely. In other words:
      -- "<before><prompt><after>".
      let
        before = String.substring 0 index buffer
        after = String.substring (Int.add index (String.length prompt)) (String.length buffer) buffer

      -- Typically there shouldn't be anything after the prompt, so this
      -- usually resets the buffer to an empty string. However if there is
      -- something in the buffer it won't be lost.
      Mutable.modify stdout \ _ -> after

      -- Run the job's callback, which should do all the interesting stuff.
      job.callback before

      -- Go back to processing more jobs. Note that this "delays" for zero
      -- seconds, which should give other processes a chance to breath.
      IO.delay 0.0 (processJobs queue stdout ghci)
