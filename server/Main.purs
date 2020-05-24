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
import PurpleYolk.Path as Path
import PurpleYolk.Readable as Readable
import PurpleYolk.Url as Url
import PurpleYolk.Workspace as Workspace
import PurpleYolk.Writable as Writable

main :: Unit
main = IO.unsafely do
  output PurpleYolk ("Starting Purple Yolk " + Package.version)

  diagnostics <- Mutable.new Object.empty
  connection <- Connection.create
  jobs <- initializeJobs connection diagnostics

  -- Assuming that everything has been set up correctly, reloading GHCi should
  -- do nothing. But sometimes GHCi starts up weird or without certain options
  -- that we set at runtime. In those cases we need to reload in order to get
  -- everything working properly.
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
        stdout <- Mutable.new Queue.empty
        ghci <- initializeGhci configuration stdout

        processJobs stdout ghci jobs connection
    updateStatusBarItem connection "Starting up ..."

  Connection.onDidSaveTextDocument connection \ params -> do
    output PurpleYolk ("Saved " + inspect params.textDocument.uri)
    enqueueJob jobs (reloadGhci connection diagnostics)

  Connection.onNotification connection "purpleYolk/restartGhci" do
    enqueueJob jobs (restartGhci connection diagnostics)

  Connection.listen connection

data Source
  = Ghci Stream
  | PurpleYolk

data Stream
  = Stderr
  | Stdin
  | Stdout

output :: Source -> String -> IO Unit
output source message = do
  let
    tag = case source of
      Ghci Stderr -> "ghci/stderr"
      Ghci Stdin -> "ghci/stdin"
      Ghci Stdout -> "ghci/stdout"
      PurpleYolk -> "purple-yolk"
  Console.info ("[" + tag + "] " + message)

updateStatusBarItem :: Connection.Connection -> String -> IO Unit
updateStatusBarItem connection message = Connection.sendNotification
  connection "purpleYolk/updateStatusBarItem" ("Purple Yolk: " + message)

-- { url: { key: diagnostic } }
type Diagnostics = Mutable (Object (Object Connection.Diagnostic))

restartGhci :: Connection.Connection -> Diagnostics -> Job.Unqueued
restartGhci connection diagnostics = Job.unqueued
  { command = ":quit"
  , onStart = do
    Mutable.modify diagnostics (map (constant Object.empty))
    sendDiagnostics connection diagnostics
  }

reloadGhci :: Connection.Connection -> Diagnostics -> Job.Unqueued
reloadGhci = withDiagnostics ":reload"

withDiagnostics :: String -> Connection.Connection -> Diagnostics -> Job.Unqueued
withDiagnostics command connection diagnostics = Job.unqueued
  { command = command
  , onOutput = \ line -> case Message.fromJson line of
    Nothing -> pure unit
    Just message -> case Nullable.toMaybe message.span of
      Nothing -> case Nullable.toMaybe (Message.getCompilingFile message) of
        Nothing -> pure unit
        Just path -> do
          let uri = Url.toString (Url.fromPath path)
          Mutable.modify diagnostics (Object.set uri Object.empty)
          sendDiagnostics connection diagnostics
      Just span -> if Path.toString span.file == "<interactive>"
        then pure unit
        else do
          let uri = Url.toString (Url.fromPath span.file)
          let key = Message.key message
          let diagnostic = messageToDiagnostic message span
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

messageToDiagnostic :: Message.Message -> Message.Span -> Connection.Diagnostic
messageToDiagnostic message span =
  { code: message.reason
  , message: message.doc
  , range:
    { end:
      { character: span.endCol - 1
      , line: span.endLine - 1
      }
    , start:
      { character: span.startCol - 1
      , line: span.startLine - 1
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
  :: Workspace.Configuration
  -> Mutable (Queue String)
  -> IO ChildProcess.ChildProcess
initializeGhci configuration queue = do
  let command = configuration.ghci.command
  output PurpleYolk ("Starting GHCi with " + inspect command)
  ghci <- ChildProcess.exec command

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
        output (Ghci Stdout) first
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
        output (Ghci Stderr) first
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

initializeJobs :: Connection.Connection -> Diagnostics -> IO Jobs
initializeJobs connection diagnostics = do
  queue <- Mutable.new Queue.empty
  IO.mapM_
    (\ command -> do
      let job = withDiagnostics command connection diagnostics
      enqueueJob queue job)
    initialCommands
  pure queue

initialCommands :: List String
initialCommands = List.fromArray
  -- We use the prompt to determine when a command finishes. That means setting
  -- the prompt has to be the very first thing we do, otherwise we'd be stuck
  -- waiting for the command to finish.
  [ ":set prompt \"" + prompt + "\\n\""

  -- This tells GHCi to collect type and location information, which is super
  -- useful for us. Unfortunately it makes compilation take much longer. We're
  -- disabling it until we actually need features it provides.
  -- , ":set +c"

  -- This tells GHC to output warnings and errors as JSON, which makes them
  -- easier for us to consume. Note that the text of the warning/error is still
  -- human readable. This setting only affects metadata.
  --
  -- This should be set by the GHCi launch command. Since it's necessary for
  -- Purple Yolk to work, we make sure that it's set here. If it's already set,
  -- then re-setting it should be harmless.
  , ":set -ddump-json"
  ]

enqueueJob :: Jobs -> Job.Unqueued -> IO Unit
enqueueJob queue unqueuedJob = do
  queuedJob <- Job.queue unqueuedJob
  jobs <- Mutable.get queue
  let command = unqueuedJob.command
  if Queue.any (\ job -> job.command == command) jobs
    then output PurpleYolk ("Ignoring " + inspect command)
    else do
      output PurpleYolk ("Enqueueing " + inspect command)
      Mutable.modify queue (Queue.enqueue queuedJob)

processJobs
  :: Mutable (Queue String)
  -> ChildProcess.ChildProcess
  -> Jobs
  -> Connection.Connection
  -> IO Unit
processJobs stdout ghci queue connection = do
  jobs <- Mutable.get queue
  case Queue.dequeue jobs of
    Nothing -> IO.delay 0.1 (processJobs stdout ghci queue connection)
    Just (Tuple job newJobs) -> do
      let command = job.command
      output PurpleYolk ("Starting " + inspect command)
      updateStatusBarItem connection ("Running " + command + " ...")
      Mutable.set queue newJobs
      Writable.write (ChildProcess.stdin ghci) (command + "\n")
      output (Ghci Stdin) command
      job.onStart
      startedJob <- Job.start job
      processJob stdout ghci queue startedJob connection

processJob
  :: Mutable (Queue String)
  -> ChildProcess.ChildProcess
  -> Jobs
  -> Job.Started
  -> Connection.Connection
  -> IO Unit
processJob stdout ghci queue job connection = do
  lines <- Mutable.get stdout
  case Queue.dequeue lines of
    Nothing -> IO.delay 0.01 (processJob stdout ghci queue job connection)
    Just (Tuple line rest) -> do
      Mutable.set stdout rest
      job.onOutput line
      if String.indexOf prompt line == -1
        then processJob stdout ghci queue job connection
        else do
          finishedJob <- Job.finish job
          finishJob finishedJob connection
          processJobs stdout ghci queue connection

finishJob :: Job.Finished -> Connection.Connection -> IO Unit
finishJob job connection = do
  job.onFinish
  let ms start end = inspect (round (1000.0 * delta start end))
  output PurpleYolk (String.join ""
    [ "Finished "
    , inspect job.command
    , " ("
    , ms job.queuedAt job.startedAt
    , " + "
    , ms job.startedAt job.finishedAt
    , " = "
    , ms job.queuedAt job.finishedAt
    , ")"
    ])
  updateStatusBarItem connection "Idle."

delta :: Date -> Date -> Number
delta start end = Date.toPosix end - Date.toPosix start
