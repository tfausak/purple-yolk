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
initializeGhci stdout = do
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

  stdoutBuffer <- Mutable.new ""
  Readable.onData
    (ChildProcess.stdout ghci)
    (handleChunk "stdout" stdoutBuffer stdout)

  stderr <- Mutable.new ""
  Readable.onData (ChildProcess.stderr ghci) (handleStderr stderr)

  pure ghci

handleChunk
  :: String
  -> Mutable String
  -> Mutable (Queue String)
  -> String
  -> IO Unit
handleChunk label buffer queue chunk = do
  Mutable.modify buffer (_ + chunk)
  string <- Mutable.get buffer
  case List.fromArray (String.split "\n" string) of
    Nil -> pure unit
    Cons _ Nil -> pure unit
    lines -> let
      loop xs = case xs of
        Nil -> pure unit
        Cons x Nil -> Mutable.set buffer x
        Cons x ys -> do
          print (String.join "" ["[ghci/", label, "] ", x])
          Mutable.modify queue (Queue.enqueue x)
          loop ys
      in loop lines

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

newtype Job = Job String

initializeJobs :: IO (Mutable (Queue Job))
initializeJobs = Mutable.new (Queue.fromList (List.fromArray (map Job
  [ String.join "" [":set prompt \"", prompt, "\\n\""]
  , ":set +c"
  , ":reload"
  ])))

processJobs
  :: Mutable (Queue String)
  -> ChildProcess.ChildProcess
  -> Mutable (Queue Job)
  -> IO Unit
processJobs stdout ghci queue = do
  jobs <- Mutable.get queue
  case Queue.dequeue jobs of
    Nothing -> IO.delay 0.1 (processJobs stdout ghci queue)
    Just (Tuple (Job job) newJobs) -> do
      Mutable.set queue newJobs
      Writable.write (ChildProcess.stdin ghci) (job + "\n")
      print ("[ghci/stdin] " + job)
      processJob stdout ghci queue

processJob
  :: Mutable (Queue String)
  -> ChildProcess.ChildProcess
  -> Mutable (Queue Job)
  -> IO Unit
processJob stdout ghci queue = do
  lines <- Mutable.get stdout
  case Queue.dequeue lines of
    Nothing -> IO.delay 0.1 (processJob stdout ghci queue)
    Just (Tuple line rest) -> do
      Mutable.set stdout rest
      print (inspect line) -- TODO
      if String.indexOf prompt line == -1
        then processJob stdout ghci queue
        else processJobs stdout ghci queue
