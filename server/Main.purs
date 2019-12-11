module Main
  ( main
  ) where

import Core

import Core.Type.Date as Date
import PurpleYolk.ChildProcess as ChildProcess
import PurpleYolk.Connection as Connection
import PurpleYolk.Package as Package
import PurpleYolk.Readable as Readable
import PurpleYolk.Writable as Writable

main :: IO Unit
main = do
  print "Initializing ..."

  _connection <- initializeConnection
  _ghci <- initializeGhci

  print "Initialized."

print :: String -> IO Unit
print message = do
  now <- getCurrentDate
  log (join " " [Date.format now, message])

initializeConnection :: IO Connection.Connection
initializeConnection = do
  connection <- Connection.create

  Connection.onInitialize connection (pure
    { capabilities: { textDocumentSync: { save: { includeText: false } } } })

  Connection.onDidSaveTextDocument connection \ params ->
    print (inspect params)

  Connection.listen connection

  pure connection

initializeGhci :: IO ChildProcess.ChildProcess
initializeGhci = do
  ghci <- ChildProcess.spawn "stack"
    [ "ghci"
    , "--color"
    , "never"
    , "--terminal-width"
    , "0"
    , "--ghc-options"
    , join " "
      [ "-ddump-json"
      , "-fdefer-type-errors"
      , "-fno-code"
      , "-j"
      ]
    ]

  ChildProcess.onClose ghci \ code signal -> throw (join " "
    [ "GHCi closed unexpectedly with code"
    , inspect code
    , "and signal"
    , inspect signal
    ])

  Readable.onData (ChildProcess.stdout ghci) \ chunk ->
    print ("STDOUT " + chunk)

  Readable.onData (ChildProcess.stderr ghci) \ chunk ->
    print ("STDERR " + chunk)

  Writable.write (ChildProcess.stdin ghci)
    (join "" [":set prompt \"", prompt, "\\n\"\n"])

  pure ghci

prompt :: String
prompt = join "" ["{- purple-yolk/", Package.version, " -}"]
