module PurpleYolk.Readable
  ( Readable
  , onData
  ) where

import Core

foreign import data Readable :: Type

foreign import onData :: Readable -> (String -> IO Unit) -> IO Unit
