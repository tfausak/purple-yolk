module PurpleYolk.Workspace
  ( Configuration
  , Workspace
  , getConfiguration
  ) where

import Core

foreign import data Workspace :: Type

foreign import getConfiguration
  :: Workspace
  -> String
  -> (Configuration -> IO Unit)
  -> IO Unit

type Configuration = { ghci :: { command :: String } }
