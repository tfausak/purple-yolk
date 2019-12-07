module Core.Type.Object
  ( Object
  , delete
  , empty
  , insert
  , lookup
  ) where

import Core.Type.Maybe as Maybe

foreign import data Object :: Type -> Type

foreign import delete :: forall a . String -> Object a -> Object a

foreign import empty :: forall a . Object a

foreign import insert :: forall a . String -> a -> Object a -> Object a

foreign import lookupWith :: forall a . Maybe.Maybe a -> (a -> Maybe.Maybe a) -> String -> Object a -> Maybe.Maybe a

lookup :: forall a . String -> Object a -> Maybe.Maybe a
lookup = lookupWith Maybe.Nothing Maybe.Just
