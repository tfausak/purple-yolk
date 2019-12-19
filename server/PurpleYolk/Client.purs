module PurpleYolk.Client
  ( Client
  , register
  ) where

import Core

foreign import data Client :: Type

foreign import register :: Client -> String -> IO Unit
