module PurpleYolk.IO
  ( IO
  , bind
  , map
  , pure
  ) where

import PurpleYolk.Unit as Unit

newtype IO a = IO (Unit.Unit -> a)

bind :: forall a b . IO a -> (a -> IO b) -> IO b
bind (IO x) f = f (x Unit.unit)

map :: forall a b . (a -> b) -> IO a -> IO b
map f (IO x) = IO \ unit -> f (x unit)

pure :: forall a . a -> IO a
pure x = IO \ _ -> x
