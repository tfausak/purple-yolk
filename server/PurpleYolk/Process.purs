module PurpleYolk.Process
  ( Process
  , onClose
  , spawn
  , stderr
  , stdin
  , stdout
  ) where

import PurpleYolk.IO as IO
import PurpleYolk.Stream as Stream
import PurpleYolk.Unit as Unit

foreign import data Process :: Type

foreign import onClose
  :: Process -> (Int -> String -> IO.IO Unit.Unit) -> IO.IO Unit.Unit

foreign import spawn :: String -> Array String -> IO.IO Process

foreign import stderr :: Process -> Stream.Stream Stream.Readable

foreign import stdin :: Process -> Stream.Stream Stream.Writable

foreign import stdout :: Process -> Stream.Stream Stream.Readable
