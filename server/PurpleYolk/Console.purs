module PurpleYolk.Console
  ( info
  ) where

import Core

import Core.Primitive.String as String
import Core.Type.Date as Date

info :: String -> IO Unit
info message = do
  now <- getCurrentDate
  log (String.join " " [Date.format now, message])
