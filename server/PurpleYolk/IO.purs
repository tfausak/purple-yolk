module PurpleYolk.IO
  ( IO
  , bind
  , delay
  , discard
  , pure
  ) where

import PurpleYolk.Unit as Unit

foreign import delay :: Number -> IO Unit.Unit -> IO Unit.Unit

newtype IO a = IO (Unit.Unit -> a)

bind :: forall a b . IO a -> (a -> IO b) -> IO b
bind (IO x) f = IO \ unit -> let (IO g) = f (x unit) in g unit

discard :: forall b . IO Unit.Unit -> (Unit.Unit -> IO b) -> IO b
discard = bind

pure :: forall a . a -> IO a
pure x = IO \ _ -> x
