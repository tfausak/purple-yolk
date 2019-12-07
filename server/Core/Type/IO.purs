module Core.Type.IO
  ( IO
  , apply
  , bind
  , delay
  , error
  , map
  , pure
  , throw
  , undefined
  , unsafely
  ) where

import Core.Type.Unit as Unit

foreign import delay :: Number -> IO Unit.Unit -> IO Unit.Unit

foreign import throw :: forall a . String -> IO a

newtype IO a = IO (Unit.Unit -> a)

apply :: forall a b . IO (a -> b) -> IO a -> IO b
apply (IO f) (IO x) = IO \ unit -> f unit (x unit)

bind :: forall a b . IO a -> (a -> IO b) -> IO b
bind (IO x) f = IO \ unit -> let (IO y) = f (x unit) in y unit

error :: forall a . String -> a
error x = unsafely (throw x)

map :: forall a b . (a -> b) -> IO a -> IO b
map f (IO x) = IO \ unit -> f (x unit)

pure :: forall a . a -> IO a
pure x = IO \ _ -> x

undefined :: forall a . a
undefined = error "undefined"

unsafely :: forall a . IO a -> a
unsafely (IO x) = x Unit.unit
