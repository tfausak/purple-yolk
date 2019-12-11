module Core.Type.IO
  ( IO
  , apply
  , bind
  , delay
  , log
  , map
  , pure
  , throw
  , unsafely
  ) where

import Core.Type.Unit as Unit

foreign import delay :: Number -> IO Unit.Unit -> IO Unit.Unit

foreign import log :: String -> IO Unit.Unit

foreign import throw :: forall a . String -> IO a

newtype IO a = IO (Unit.Unit -> a)

apply :: forall a b . IO (a -> b) -> IO a -> IO b
apply (IO f) (IO x) = IO \ unit -> f unit (x unit)

bind :: forall a b . IO a -> (a -> IO b) -> IO b
bind (IO x) f = IO \ unit -> let IO y = f (x unit) in y unit

map :: forall a b . (a -> b) -> IO a -> IO b
map f (IO x) = IO \ unit -> f (x unit)

pure :: forall a . a -> IO a
pure x = IO \ _ -> x

unsafely :: forall a . IO a -> a
unsafely (IO x) = x Unit.unit
