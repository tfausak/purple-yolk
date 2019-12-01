module PurpleYolk.Stream
  ( Readable
  , Stream
  , Writable
  , onData
  , write
  ) where

import PurpleYolk.IO as IO
import PurpleYolk.Unit as Unit

foreign import data Stream :: Type -> Type

foreign import onData
  :: Stream Readable -> (String -> IO.IO Unit.Unit) -> IO.IO Unit.Unit

foreign import write :: Stream Writable -> String -> IO.IO Unit.Unit

data Readable

data Writable
