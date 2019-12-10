module Main
  ( main
  ) where

import Core

import Core.Type.Date as Date
import PurpleYolk.Connection as Connection

main :: IO Unit
main = do
  print "Starting up ..."

  connection <- Connection.create
  Connection.onInitialize connection (pure
    { capabilities: { textDocumentSync: { save: { includeText: false } } } })
  Connection.listen connection

  print "Listening ..."

print :: String -> IO Unit
print message = do
  now <- getCurrentDate
  log (join " " [Date.format now, message])
