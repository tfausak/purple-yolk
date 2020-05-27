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
import PurpleYolk.Connection as Connection
import PurpleYolk.Job as Job
import PurpleYolk.Message as Message
import PurpleYolk.Package as Package
import PurpleYolk.Path as Path
import PurpleYolk.Readable as Readable
import PurpleYolk.Url as Url
import PurpleYolk.Workspace as Workspace
import PurpleYolk.Writable as Writable

main :: Unit
main = unsafely runServer

runServer :: IO Unit
runServer = do
  output PurpleYolk ("Starting vesion " + Package.version)

  events <- Mutable.new Queue.empty
  diagnostics <- Mutable.new Object.empty

  initializeConnection events \ connection ->
    withConfiguration connection \ configuration -> do
      ghci <- startGhci events diagnostics connection configuration
      updateStatusBarItem connection "Idle"
      processEvents Queue.empty events diagnostics connection ghci

output :: Source -> String -> IO Unit
output source message = do
  now <- getCurrentDate
  log (String.join ""
    [ Date.format now
    , " ["
    , case source of
      Ghci stream -> "ghci/" + case stream of
        Stderr -> "stderr"
        Stdin -> "stdin"
        Stdout -> "stdout"
      PurpleYolk -> namespace
    , "] "
    , message
    ])

data Source
  = Ghci Stream
  | PurpleYolk

data Stream
  = Stderr
  | Stdin
  | Stdout

namespace :: String
namespace = "purpleYolk"

type Events = Mutable (Queue Event)

data Event
  = HandleLine String
  | NoOp
  | QueueJob Job.Job
  | RestartGhci
  | SavedFile Connection.DocumentUri

-- { url: { key: diagnostic } }
type Diagnostics = Mutable (Object (Object Connection.Diagnostic))

initializeConnection :: Events -> (Connection.Connection -> IO Unit) -> IO Unit
initializeConnection events callback = do
  connection <- Connection.create

  Connection.onInitialize connection do
    output PurpleYolk "Initializing"
    pure initializeParams

  Connection.onInitialized connection do
    output PurpleYolk "Initialized"
    callback connection

  Connection.onDidSaveTextDocument connection \ params -> do
    let uri = params.textDocument.uri
    output PurpleYolk ("Saved " + inspect uri)
    enqueueEvent events (SavedFile uri)

  flip IO.mapM_ notifications \ (Tuple notification event) ->
    Connection.onNotification connection (namespaced notification) do
      output PurpleYolk ("Received " + notification + " notification")
      enqueueEvent events event

  Connection.listen connection

initializeParams :: Connection.InitializeParams
initializeParams =
  { capabilities:
    { textDocumentSync:
      { save:
        { includeText: false
        }
      }
    }
  }

enqueueEvent :: Events -> Event -> IO Unit
enqueueEvent events event = Mutable.modify events (Queue.enqueue event)

notifications :: List (Tuple String Event)
notifications = List.fromArray
  [ Tuple "restartGhci" RestartGhci
  ]

namespaced :: String -> String
namespaced string = namespace + "/" + string

withConfiguration
  :: Connection.Connection -> (Workspace.Configuration -> IO Unit) -> IO Unit
withConfiguration connection =
  Workspace.getConfiguration (Connection.workspace connection) namespace

startGhci
  :: Events
  -> Diagnostics
  -> Connection.Connection
  -> Workspace.Configuration
  -> IO ChildProcess.ChildProcess
startGhci events diagnostics connection configuration = do
  let command = configuration.ghci.command
  output PurpleYolk ("Starting GHCi with " + inspect command)
  ghci <- ChildProcess.spawn command

  ChildProcess.onClose ghci \ code signal -> if code == 0
    then output PurpleYolk "GHCi exited successfully"
    else throw (String.join " "
      [ "GHCi closed unexpectedly with code"
      , inspect code
      , "and signal"
      , inspect signal
      ])

  stderr <- Mutable.new ""
  Readable.onData (ChildProcess.stderr ghci) (handleStderr stderr)

  stdout <- Mutable.new ""
  Readable.onData (ChildProcess.stdout ghci) (handleStdout events stdout)

  flip IO.mapM_ commands \ cmd -> do
    job <- Job.queue (withDiagnostics cmd connection diagnostics)
    enqueueEvent events (QueueJob job)

  pure ghci

handleStderr :: Mutable String -> String -> IO Unit
handleStderr buffer = handleStream buffer (output (Ghci Stderr))

handleStdout :: Events -> Mutable String -> String -> IO Unit
handleStdout events buffer = handleStream buffer \ line -> do
  output (Ghci Stdout) line
  enqueueEvent events (HandleLine line)

handleStream :: Mutable String -> (String -> IO Unit) -> String -> IO Unit
handleStream buffer callback chunk = do
  Mutable.modify buffer (_ + chunk)
  contents <- Mutable.get buffer
  case List.fromArray (String.split "\n" contents) of
    Nil -> pure unit
    Cons _ Nil -> pure unit
    lines -> do
      let
        loop xs = case xs of
          Nil -> pure unit
          Cons x Nil -> Mutable.set buffer x
          Cons x ys -> do
            callback x
            loop ys
      loop lines

commands :: List String
commands = List.fromArray
  [ ":set prompt \"" + prompt + "\\n\""
  , ":set -ddump-json"
  , ":reload"
  ]

withDiagnostics :: String -> Connection.Connection -> Diagnostics -> Job.Job
withDiagnostics command connection diagnostics = Job.unqueued
  { command = command
  , onOutput = \ line -> case Message.fromJson line of
    Nothing -> pure unit
    Just message -> processMessage connection diagnostics message
  , onFinish = sendDiagnostics connection diagnostics
  }

processMessage
  :: Connection.Connection -> Diagnostics -> Message.Message -> IO Unit
processMessage connection diagnostics message =
  case Nullable.toMaybe message.span of
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
          Just inner ->
            Object.set uri (Object.set key diagnostic inner) outer
        sendDiagnostics connection diagnostics

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

prompt :: String
prompt = "{- " + namespaced Package.version + " -}"

updateStatusBarItem :: Connection.Connection -> String -> IO Unit
updateStatusBarItem connection message = Connection.sendNotification
  connection (namespaced "updateStatusBarItem") ("Purple Yolk: " + message)

processEvents
  :: Queue Job.Job
  -> Events
  -> Diagnostics
  -> Connection.Connection
  -> ChildProcess.ChildProcess
  -> IO Unit
processEvents jobs queue diagnostics connection ghci = do
  events <- Mutable.get queue
  case Queue.dequeue events of
    Nothing ->
      IO.delay 0.01 (processEvents jobs queue diagnostics connection ghci)
    Just (Tuple event newEvents) -> do
      Mutable.set queue newEvents
      newJobs <- startNextJob connection ghci jobs
      processEvent newJobs queue diagnostics connection ghci event

startNextJob
  :: Connection.Connection
  -> ChildProcess.ChildProcess
  -> Queue Job.Job
  -> IO (Queue Job.Job)
startNextJob connection ghci jobs = case Queue.toList jobs of
  Nil -> pure jobs
  Cons job rest -> case job.startedAt of
    Just _ -> pure jobs
    Nothing -> do
      let command = job.command
      output PurpleYolk ("Starting " + inspect command)
      updateStatusBarItem connection ("Running " + command)
      started <- Job.start job
      tellGhci ghci command
      pure (Queue.fromList (started : rest))

tellGhci :: ChildProcess.ChildProcess -> String -> IO Unit
tellGhci ghci command = do
  Writable.write (ChildProcess.stdin ghci) (command + "\n")
  output (Ghci Stdin) command

processEvent
  :: Queue Job.Job
  -> Events
  -> Diagnostics
  -> Connection.Connection
  -> ChildProcess.ChildProcess
  -> Event
  -> IO Unit
processEvent jobs queue diagnostics connection ghci event = case event of

  HandleLine line -> case Queue.dequeue jobs of
    Nothing -> processEvents jobs queue diagnostics connection ghci
    Just (Tuple job rest) -> do
      job.onOutput line
      if String.indexOf prompt line == -1
        then processEvents jobs queue diagnostics connection ghci
        else do
          finished <- Job.finish job
          let
            ms maybeStart maybeEnd = case maybeStart, maybeEnd of
              Just start, Just end -> inspect (round (1000.0 * delta start end))
              _, _ -> "unknown"
          output PurpleYolk (String.join ""
            [ "Finished "
            , inspect finished.command
            , " ("
            , ms finished.queuedAt finished.startedAt
            , " + "
            , ms finished.startedAt finished.finishedAt
            , " = "
            , ms finished.queuedAt finished.finishedAt
            , ")"
            ])
          updateStatusBarItem connection "Idle"
          newJobs <- startNextJob connection ghci rest
          processEvents newJobs queue diagnostics connection ghci

  NoOp -> processEvents jobs queue diagnostics connection ghci

  QueueJob job -> do
    let command = job.command
    newJobs <- if Queue.any (\ other -> other.command == command) jobs
      then do
        output PurpleYolk ("Ignoring " + inspect command)
        pure jobs
      else do
        output PurpleYolk ("Queueing " + inspect command)
        pure (Queue.enqueue job jobs)
    processEvents newJobs queue diagnostics connection ghci

  RestartGhci -> do
    output PurpleYolk "Restarting GHCi"
    updateStatusBarItem connection "Restarting"
    ChildProcess.onClose ghci \ _ _ -> do
      clearDiagnostics diagnostics connection
      withConfiguration connection \ configuration -> do
        Mutable.set queue Queue.empty
        newGhci <- startGhci queue diagnostics connection configuration
        updateStatusBarItem connection "Idle"
        processEvents Queue.empty queue diagnostics connection newGhci
    killed <- ChildProcess.kill ghci
    if killed then pure unit else throw "Failed to kill GHCi!"

  SavedFile _ -> do
    queued <- Job.queue (withDiagnostics ":reload" connection diagnostics)
    enqueueEvent queue (QueueJob queued)
    enqueueEvent queue NoOp
    processEvents jobs queue diagnostics connection ghci

clearDiagnostics :: Diagnostics -> Connection.Connection -> IO Unit
clearDiagnostics diagnostics connection = do
  Mutable.modify diagnostics (map (constant Object.empty))
  sendDiagnostics connection diagnostics
  Mutable.set diagnostics Object.empty

delta :: Date -> Date -> Number
delta start end = Date.toPosix end - Date.toPosix start
