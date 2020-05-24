module PurpleYolk.ChildProcess
  ( ChildProcess
  , onClose
  , exec
  , kill
  , stderr
  , stdin
  , stdout
  ) where

import Core

import Core.Type.Nullable as Nullable
import PurpleYolk.Readable as Readable
import PurpleYolk.Writable as Writable

foreign import data ChildProcess :: Type

foreign import onClose
  :: ChildProcess
  -> (Int -> Nullable.Nullable String -> IO Unit)
  -> IO Unit

foreign import exec :: String -> IO ChildProcess

foreign import kill :: ChildProcess -> IO Boolean

foreign import stderr :: ChildProcess -> Readable.Readable

foreign import stdin :: ChildProcess -> Writable.Writable

foreign import stdout :: ChildProcess -> Readable.Readable
