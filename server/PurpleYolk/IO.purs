module PurpleYolk.IO
  ( IO
  , bind
  , delay
  , discard
  , map
  , mapM
  , mapM_
  , pure
  , void
  ) where

import PurpleYolk.Unit as Unit

foreign import delay :: Number -> IO Unit.Unit -> IO Unit.Unit

foreign import mapM :: forall a b . (a -> IO b) -> Array a -> IO (Array b)

newtype IO a = IO (Unit.Unit -> a)

bind :: forall a b . IO a -> (a -> IO b) -> IO b
bind (IO x) f = IO \ unit -> let (IO g) = f (x unit) in g unit

discard :: forall b . IO Unit.Unit -> (Unit.Unit -> IO b) -> IO b
discard = bind

map :: forall a b . (a -> b) -> IO a -> IO b
map f io = bind io (\ x -> pure (f x))

mapM_ :: forall a . (a -> IO Unit.Unit) -> Array a -> IO Unit.Unit
mapM_ f io = void (mapM f io)

pure :: forall a . a -> IO a
pure x = IO \ _ -> x

void :: forall a . IO a -> IO Unit.Unit
void = map (\ _ -> Unit.unit)
