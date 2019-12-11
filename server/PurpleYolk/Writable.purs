module PurpleYolk.Writable
  ( Writable
  , write
  ) where

import Core

foreign import data Writable :: Type

foreign import write :: Writable -> String -> IO Unit
