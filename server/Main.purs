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
import PurpleYolk.Job as Job
import PurpleYolk.Package as Package
import PurpleYolk.Readable as Readable
import PurpleYolk.Writable as Writable

main :: IO Unit
main = do
  print (String.join " "
    ["[purple-yolk] Starting version", Package.version, "..."])

  jobs <- initializeJobs
  connection <- initializeConnection jobs

  stdout <- Mutable.new Queue.empty
  ghci <- initializeGhci stdout

  processJobs stdout ghci jobs

print :: String -> IO Unit
print message = do
  now <- getCurrentDate
  log (String.join " " [Date.format now, message])

initializeConnection :: JobQueue -> IO Connection.Connection
initializeConnection jobs = do
  connection <- Connection.create

  Connection.onInitialize connection (pure
    { capabilities: { textDocumentSync: { save: { includeText: false } } } })

  Connection.onDidSaveTextDocument connection \ params -> do
    print ("[purple-yolk] Saved " + inspect params.textDocument.uri)
    enqueueJob jobs Job.unqueued { command = ":reload" }

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

type JobQueue = Mutable (Queue Job.Queued)

initializeJobs :: IO JobQueue
initializeJobs = do
  queue <- Mutable.new Queue.empty
  enqueueJob queue Job.unqueued
    { command = String.join "" [":set prompt \"", prompt, "\\n\""] }
  enqueueJob queue Job.unqueued { command = ":set +c" }
  enqueueJob queue Job.unqueued { command = ":reload" }
  pure queue

enqueueJob :: JobQueue -> Job.Unqueued -> IO Unit
enqueueJob queue job = do
  print ("[purple-yolk] Enqueueing " + inspect job.command)
  queuedJob <- Job.queue job
  Mutable.modify queue (Queue.enqueue queuedJob)

processJobs
  :: Mutable (Queue String)
  -> ChildProcess.ChildProcess
  -> JobQueue
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
      startedJob <- Job.start job
      processJob stdout ghci queue startedJob

processJob
  :: Mutable (Queue String)
  -> ChildProcess.ChildProcess
  -> JobQueue
  -> Job.Started
  -> IO Unit
processJob stdout ghci queue job = do
  lines <- Mutable.get stdout
  case Queue.dequeue lines of
    Nothing -> IO.delay 0.01 (processJob stdout ghci queue job)
    Just (Tuple line rest) -> do
      Mutable.set stdout rest
      job.onOutput line
      if String.indexOf prompt line == -1
        then processJob stdout ghci queue job
        else do
          finishedJob <- Job.finish job
          finishJob finishedJob
          processJobs stdout ghci queue

finishJob :: Job.Finished -> IO Unit
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
