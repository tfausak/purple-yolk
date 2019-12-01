module PurpleYolk.Stream
  ( Readable
  , Stream
  , Writable
  , onData
  , readable
  , writable
  , write
  ) where

import PurpleYolk.IO as IO
import PurpleYolk.Unit as Unit

foreign import data Stream :: Type -> Type

foreign import onData
  :: Stream Readable -> (String -> IO.IO Unit.Unit) -> IO.IO Unit.Unit

foreign import write :: Stream Writable -> String -> IO.IO Unit.Unit

newtype Readable = Readable Unit.Unit

newtype Writable = Writable Unit.Unit

readable :: Readable
readable = Readable Unit.unit

writable :: Writable
writable = Writable Unit.unit
