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
  print "Initializing ..."

  connection <- initializeConnection

  stdout <- Mutable.new Queue.empty
  ghci <- initializeGhci stdout

  jobs <- initializeJobs

  print "Initialized."

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
prompt = String.join "" ["{- purple-yolk/", Package.version, " -}"]

type Job =
  { command :: String
  , state :: State
  }

data State
  = Unqueued
  | Queued Date
  | Started Date Date

initializeJobs :: IO (Mutable (Queue Job))
initializeJobs = do
  queue <- Mutable.new Queue.empty
  enqueueJob queue { command: String.join "" [":set prompt \"", prompt, "\\n\""], state: Unqueued }
  enqueueJob queue { command: ":set +c", state: Unqueued }
  enqueueJob queue { command: ":reload", state: Unqueued }
  pure queue

enqueueJob :: Mutable (Queue Job) -> Job -> IO Unit
enqueueJob queue job = do
  print ("Enqueueing job: " + inspect job.command)
  case job.state of
    Unqueued -> do
      now <- getCurrentDate
      Mutable.modify queue (Queue.enqueue job { state = Queued now })
    _ -> throw "trying to enqueue a job that's not unqueued"

processJobs
  :: Mutable (Queue String)
  -> ChildProcess.ChildProcess
  -> Mutable (Queue Job)
  -> IO Unit
processJobs stdout ghci queue = do
  jobs <- Mutable.get queue
  case Queue.dequeue jobs of
    Nothing -> IO.delay 0.1 (processJobs stdout ghci queue)
    Just (Tuple job newJobs) -> do
      print ("Starting job: " + inspect job.command)
      Mutable.set queue newJobs
      Writable.write (ChildProcess.stdin ghci) (job.command + "\n")
      print ("[ghci/stdin] " + job.command)
      case job.state of
        Queued queuedAt -> do
          now <- getCurrentDate
          processJob stdout ghci queue job { state = Started queuedAt now }
        _ -> throw "trying to start a job that's not queued"

processJob
  :: Mutable (Queue String)
  -> ChildProcess.ChildProcess
  -> Mutable (Queue Job)
  -> Job
  -> IO Unit
processJob stdout ghci queue job = do
  lines <- Mutable.get stdout
  case Queue.dequeue lines of
    Nothing -> IO.delay 0.1 (processJob stdout ghci queue job)
    Just (Tuple line rest) -> do
      Mutable.set stdout rest
      print (inspect line) -- TODO
      if String.indexOf prompt line == -1
        then processJob stdout ghci queue job
        else case job.state of
          Started queuedAt startedAt -> do
            finishedAt <- getCurrentDate
            let
              ms start end = inspect <| round <|
                1000.0 * (Date.toPosix end - Date.toPosix start)
            print (String.join ""
              [ "Finished job: "
              , inspect job.command
              , " ("
              , ms queuedAt startedAt
              , " + "
              , ms startedAt finishedAt
              , " = "
              , ms queuedAt finishedAt
              , ")"
              ])
            processJobs stdout ghci queue
          _ -> throw "trying to finish a job that's not started"
