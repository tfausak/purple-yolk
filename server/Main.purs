module Main
  ( main
  ) where

import Core

import Core.Primitive.String as String
import Core.Type.Date as Date
import Core.Type.IO as IO
import Core.Type.List as List
import Core.Type.Mutable as Mutable
import Core.Type.Queue as Queue
import PurpleYolk.ChildProcess as ChildProcess
import PurpleYolk.Connection as Connection
import PurpleYolk.Package as Package
import PurpleYolk.Readable as Readable
import PurpleYolk.Writable as Writable

main :: IO Unit
main = do
  print (String.join " "
    ["[purple-yolk] Starting version", Package.version, "..."])

  connection <- initializeConnection

  stdout <- Mutable.new Queue.empty
  ghci <- initializeGhci stdout

  jobs <- initializeJobs

  processJobs stdout ghci jobs

print :: String -> IO Unit
print message = do
  now <- getCurrentDate
  log (String.join " " [Date.format now, message])

initializeConnection :: IO Connection.Connection
initializeConnection = do
  connection <- Connection.create

  Connection.onInitialize connection (pure
    { capabilities: { textDocumentSync: { save: { includeText: false } } } })

  Connection.onDidSaveTextDocument connection \ params ->
    print (inspect params)

  Connection.listen connection

  pure connection

initializeGhci
  :: Mutable (Queue String)
  -> IO ChildProcess.ChildProcess
initializeGhci queue = do
  ghci <- ChildProcess.spawn "stack"
    [ "ghci"
    , "--color"
    , "never"
    , "--terminal-width"
    , "80"
    , "--ghc-options"
    , String.join " "
      [ "-ddump-json"
      , "-fdefer-type-errors"
      , "-fno-code"
      , "-j"
      ]
    ]

  ChildProcess.onClose ghci \ code signal -> throw (String.join " "
    [ "GHCi closed unexpectedly with code"
    , inspect code
    , "and signal"
    , inspect signal
    ])

  stdout <- Mutable.new ""
  Readable.onData (ChildProcess.stdout ghci) (handleStdout stdout queue)

  stderr <- Mutable.new ""
  Readable.onData (ChildProcess.stderr ghci) (handleStderr stderr)

  pure ghci

handleStdout
  :: Mutable String
  -> Mutable (Queue String)
  -> String
  -> IO Unit
handleStdout stdout queue chunk = do
  let
    loop lines = case lines of
      Nil -> pure unit
      Cons leftover Nil -> Mutable.set stdout leftover
      Cons first rest -> do
        print ("[ghci/stdout] " + first)
        Mutable.modify queue (Queue.enqueue first)
        loop rest
  Mutable.modify stdout (_ + chunk)
  buffer <- Mutable.get stdout
  case List.fromArray (String.split "\n" buffer) of
    Nil -> pure unit
    Cons _ Nil -> pure unit
    lines -> loop lines

handleStderr :: Mutable String -> String -> IO Unit
handleStderr stderr chunk = do
  let
    loop lines = case lines of
      Nil -> pure unit
      Cons leftover Nil -> Mutable.set stderr leftover
      Cons first rest -> do
        print ("[ghci/stderr] " + first)
        loop rest
  Mutable.modify stderr (_ + chunk)
  buffer <- Mutable.get stderr
  case List.fromArray (String.split "\n" buffer) of
    Nil -> pure unit
    Cons _ Nil -> pure unit
    lines -> loop lines

prompt :: String
prompt = String.join " " ["{- purple-yolk", Package.version, "-}"]

type Job queuedAt startedAt finishedAt =
  { command :: String
  , finishedAt :: finishedAt
  , onFinish :: IO Unit
  , onOutput :: String -> IO Unit
  , queuedAt :: queuedAt
  , startedAt :: startedAt
  }

type UnqueuedJob = Job Unit Unit Unit

type QueuedJob = Job Date Unit Unit

type StartedJob = Job Date Date Unit

type FinishedJob = Job Date Date Date

defaultJob :: UnqueuedJob
defaultJob =
  { command: ""
  , finishedAt: unit
  , onFinish: pure unit
  , onOutput: \ _ -> pure unit
  , queuedAt: unit
  , startedAt: unit
  }

initializeJobs :: IO (Mutable (Queue QueuedJob))
initializeJobs = do
  queue <- Mutable.new Queue.empty
  enqueueJob queue defaultJob
    { command = String.join "" [":set prompt \"", prompt, "\\n\""] }
  enqueueJob queue defaultJob { command = ":set +c" }
  enqueueJob queue defaultJob { command = ":reload" }
  pure queue

enqueueJob :: Mutable (Queue QueuedJob) -> UnqueuedJob -> IO Unit
enqueueJob queue job = do
  print ("[purple-yolk] Enqueueing " + inspect job.command)
  now <- getCurrentDate
  Mutable.modify queue (Queue.enqueue job { queuedAt = now })

processJobs
  :: Mutable (Queue String)
  -> ChildProcess.ChildProcess
  -> Mutable (Queue QueuedJob)
  -> IO Unit
processJobs stdout ghci queue = do
  jobs <- Mutable.get queue
  case Queue.dequeue jobs of
    Nothing -> IO.delay 0.1 (processJobs stdout ghci queue)
    Just (Tuple job newJobs) -> do
      print ("[purple-yolk] Starting " + inspect job.command)
      Mutable.set queue newJobs
      Writable.write (ChildProcess.stdin ghci) (job.command + "\n")
      print ("[ghci/stdin] " + job.command)
      now <- getCurrentDate
      processJob stdout ghci queue job { startedAt = now }

processJob
  :: Mutable (Queue String)
  -> ChildProcess.ChildProcess
  -> Mutable (Queue QueuedJob)
  -> StartedJob
  -> IO Unit
processJob stdout ghci queue job = do
  lines <- Mutable.get stdout
  case Queue.dequeue lines of
    Nothing -> IO.delay 0.1 (processJob stdout ghci queue job)
    Just (Tuple line rest) -> do
      Mutable.set stdout rest
      job.onOutput line
      if String.indexOf prompt line == -1
        then processJob stdout ghci queue job
        else do
          now <- getCurrentDate
          finishJob job { finishedAt = now }
          processJobs stdout ghci queue

finishJob :: FinishedJob -> IO Unit
finishJob job = do
  job.onFinish
  let ms start end = inspect (round (1000.0 * delta start end))
  print (String.join " "
    [ "[purple-yolk] Finished"
    , inspect job.command
    , "(" + ms job.queuedAt job.startedAt
    , "+"
    , ms job.startedAt job.finishedAt
    , "="
    , ms job.queuedAt job.finishedAt + ")"
    ])

delta :: Date -> Date -> Number
delta start end = Date.toPosix end - Date.toPosix start
