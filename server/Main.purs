module Main
  ( main
  ) where

import Core

import Core.Primitive.String as String
import Core.Type.Date as Date
import Core.Type.IO as IO
import Core.Type.List as List
import Core.Type.Mutable as Mutable
import Core.Type.Nullable as Nullable
import Core.Type.Object as Object
import Core.Type.Queue as Queue
import PurpleYolk.ChildProcess as ChildProcess
import PurpleYolk.Client as Client
import PurpleYolk.Connection as Connection
import PurpleYolk.Console as Console
import PurpleYolk.Job as Job
import PurpleYolk.Message as Message
import PurpleYolk.Package as Package
import PurpleYolk.Readable as Readable
import PurpleYolk.Url as Url
import PurpleYolk.Workspace as Workspace
import PurpleYolk.Writable as Writable

main :: Unit
main = IO.unsafely do
  Console.info (String.join " "
    ["[purple-yolk] Starting version", Package.version, "..."])

  jobs <- initializeJobs
  diagnostics <- Mutable.new Object.empty
  connection <- Connection.create
  enqueueJob jobs (reloadGhci connection diagnostics)

  Connection.onInitialize connection (pure
    { capabilities: { textDocumentSync: { save: { includeText: false } } } })

  Connection.onInitialized connection do
    Client.register
      (Connection.client connection)
      "workspace/didChangeConfiguration"
    Workspace.getConfiguration
      (Connection.workspace connection)
      "purpleYolk"
      \ configuration -> do
        Console.info (inspect configuration)

        stdout <- Mutable.new Queue.empty
        ghci <- initializeGhci stdout

        processJobs stdout ghci jobs

  Connection.onDidSaveTextDocument connection \ params -> do
    Console.info ("[purple-yolk] Saved " + inspect params.textDocument.uri)
    enqueueJob jobs (reloadGhci connection diagnostics)

  Connection.listen connection

-- { url: { key: diagnostic } }
type Diagnostics = Mutable (Object (Object Connection.Diagnostic))

reloadGhci :: Connection.Connection -> Diagnostics -> Job.Unqueued
reloadGhci connection diagnostics = Job.unqueued
  { command = ":reload"
  , onStart = do
    Mutable.modify diagnostics (map (constant Object.empty))
    sendDiagnostics connection diagnostics
  , onOutput = \ line -> case Message.fromJson line of
    Nothing -> pure unit
    Just message -> do
      let uri = Url.toString (Url.fromPath message.span.file)
      let key = Message.key message
      let diagnostic = messageToDiagnostic message
      Mutable.modify diagnostics \ outer -> case Object.get uri outer of
        Nothing -> Object.set uri (Object.singleton key diagnostic) outer
        Just inner -> Object.set uri (Object.set key diagnostic inner) outer
      sendDiagnostics connection diagnostics
  , onFinish = sendDiagnostics connection diagnostics
  }

sendDiagnostics :: Connection.Connection -> Diagnostics -> IO Unit
sendDiagnostics connection mutable = do
  diagnostics <- Mutable.get mutable
  sendDiagnosticsHelper connection (Object.toList diagnostics)

sendDiagnosticsHelper
  :: Connection.Connection
  -> List (Tuple String (Object Connection.Diagnostic))
  -> IO Unit
sendDiagnosticsHelper connection list = case list of
  Nil -> pure unit
  Cons (Tuple uri object) rest -> do
    Connection.sendDiagnostics connection
      { diagnostics: List.toArray (map second (Object.toList object))
      , uri
      }
    sendDiagnosticsHelper connection rest

messageToDiagnostic :: Message.Message -> Connection.Diagnostic
messageToDiagnostic message =
  { code: message.reason
  , message: message.doc
  , range:
    { end:
      { character: message.span.endCol - 1
      , line: message.span.endLine - 1
      }
    , start:
      { character: message.span.startCol - 1
      , line: message.span.startLine - 1
      }
    }
  , severity: case message.severity of
    "SevError" -> Nullable.notNull 1
    "SevWarning" -> case Nullable.toMaybe message.reason of
      Just "Opt_WarnDeferredOutOfScopeVariables" -> Nullable.notNull 1
      Just "Opt_WarnDeferredTypeErrors" -> Nullable.notNull 1
      _ -> Nullable.notNull 2
    _ -> Nullable.null
  , source: "ghc"
  }

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
        Console.info ("[ghci/stdout] " + first)
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
        Console.info ("[ghci/stderr] " + first)
        loop rest
  Mutable.modify stderr (_ + chunk)
  buffer <- Mutable.get stderr
  case List.fromArray (String.split "\n" buffer) of
    Nil -> pure unit
    Cons _ Nil -> pure unit
    lines -> loop lines

prompt :: String
prompt = String.join " " ["{- purple-yolk", Package.version, "-}"]

type Jobs = Mutable (Queue Job.Queued)

initializeJobs :: IO Jobs
initializeJobs = do
  queue <- Mutable.new Queue.empty
  enqueueJob queue Job.unqueued
    { command = String.join "" [":set prompt \"", prompt, "\\n\""] }
  enqueueJob queue Job.unqueued { command = ":set +c" }
  pure queue

enqueueJob :: Jobs -> Job.Unqueued -> IO Unit
enqueueJob queue job = do
  Console.info ("[purple-yolk] Enqueueing " + inspect job.command)
  queuedJob <- Job.queue job
  Mutable.modify queue (Queue.enqueue queuedJob)

processJobs
  :: Mutable (Queue String)
  -> ChildProcess.ChildProcess
  -> Jobs
  -> IO Unit
processJobs stdout ghci queue = do
  jobs <- Mutable.get queue
  case Queue.dequeue jobs of
    Nothing -> IO.delay 0.1 (processJobs stdout ghci queue)
    Just (Tuple job newJobs) -> do
      Console.info ("[purple-yolk] Starting " + inspect job.command)
      Mutable.set queue newJobs
      Writable.write (ChildProcess.stdin ghci) (job.command + "\n")
      Console.info ("[ghci/stdin] " + job.command)
      job.onStart
      startedJob <- Job.start job
      processJob stdout ghci queue startedJob

processJob
  :: Mutable (Queue String)
  -> ChildProcess.ChildProcess
  -> Jobs
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
  Console.info (String.join " "
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
