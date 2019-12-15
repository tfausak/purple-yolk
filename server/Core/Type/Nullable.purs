module Core.Type.Nullable
  ( Nullable
  , apply
  , bind
  , compare
  , fromMaybe
  , inspect
  , map
  , notNull
  , null
  , pure
  , toMaybe
  ) where

import Core.Primitive.String as String
import Core.Type.Maybe as Maybe
import Core.Type.Ordering as Ordering

foreign import data Nullable :: Type -> Type

foreign import notNull :: forall a . a -> Nullable a

foreign import null :: forall a . Nullable a

foreign import toMaybeWith
  :: forall a
  . Maybe.Maybe a
  -> (a -> Maybe.Maybe a)
  -> Nullable a
  -> Maybe.Maybe a

apply :: forall a b . Nullable (a -> b) -> Nullable a -> Nullable b
apply f x = fromMaybe (Maybe.apply (toMaybe f) (toMaybe x))

bind :: forall a b . Nullable a -> (a -> Nullable b) -> Nullable b
bind x f = fromMaybe (Maybe.bind (toMaybe x) (\ y -> toMaybe (f y)))

compare
  :: forall a
  . (a -> a -> Ordering.Ordering)
  -> Nullable a
  -> Nullable a
  -> Ordering.Ordering
compare f x y = Maybe.compare f (toMaybe x) (toMaybe y)

fromMaybe :: forall a . Maybe.Maybe a -> Nullable a
fromMaybe m = case m of
  Maybe.Nothing -> null
  Maybe.Just x -> notNull x

inspect :: forall a . (a -> String) -> Nullable a -> String
inspect f n = case toMaybe n of
  Maybe.Nothing -> "null"
  Maybe.Just x -> String.join "" ["notNull (", f x, ")"]

map :: forall a b . (a -> b) -> Nullable a -> Nullable b
map f x = fromMaybe (Maybe.map f (toMaybe x))

pure :: forall a . a -> Nullable a
pure = notNull

toMaybe :: forall a . Nullable a -> Maybe.Maybe a
toMaybe = toMaybeWith Maybe.Nothing Maybe.Just
