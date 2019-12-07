module Core.Type.Nullable
  ( Nullable
  , fromMaybe
  , notNull
  , null
  , toMaybe
  ) where

import Core.Type.Maybe as Maybe

foreign import data Nullable :: Type -> Type

foreign import notNull :: forall a . a -> Nullable a

foreign import null :: forall a . Nullable a

foreign import toMaybeWith :: forall a . Maybe.Maybe a -> (a -> Maybe.Maybe a) -> Nullable a -> Maybe.Maybe a

fromMaybe :: forall a . Maybe.Maybe a -> Nullable a
fromMaybe m = case m of
  Maybe.Nothing -> null
  Maybe.Just x -> notNull x

toMaybe :: forall a . Nullable a -> Maybe.Maybe a
toMaybe = toMaybeWith Maybe.Nothing Maybe.Just
