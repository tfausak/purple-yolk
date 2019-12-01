module PurpleYolk.IO
  ( IO
  , bind
  , map
  , pure
  ) where

foreign import data IO :: Type -> Type

foreign import bind :: forall a b . IO a -> (a -> IO b) -> IO b

foreign import map :: forall a b . (a -> b) -> IO a -> IO b

foreign import pure :: forall a . a -> IO a
