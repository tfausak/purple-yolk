module Main
  ( main
  ) where

import Core

import Core.Type.Date as Date
import PurpleYolk.Connection as Connection

main :: IO Unit
main = do
  print "Initializing ..."

  _connection <- initializeConnection

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
