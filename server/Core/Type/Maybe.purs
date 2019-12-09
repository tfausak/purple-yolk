module Core.Type.Maybe
  ( Maybe(Nothing, Just)
  , apply
  , bind
  , compare
  , inspect
  , map
  , pure
  , withDefault
  ) where

import Core.Primitive.String as String
import Core.Type.Ordering as Ordering

data Maybe a
  = Nothing
  | Just a

apply :: forall a b . Maybe (a -> b) -> Maybe a -> Maybe b
apply mf mx = case mf, mx of
  Just f, Just x -> Just (f x)
  _, _ -> Nothing

bind :: forall a b . Maybe a -> (a -> Maybe b) -> Maybe b
bind mx f = case mx of
  Nothing -> Nothing
  Just x -> f x

compare
  :: forall a
  . (a -> a -> Ordering.Ordering)
  -> Maybe a
  -> Maybe a
  -> Ordering.Ordering
compare f mx my = case mx, my of
  Nothing, Nothing -> Ordering.EQ
  Nothing, Just _ -> Ordering.LT
  Just _, Nothing -> Ordering.GT
  Just x, Just y -> f x y

inspect :: forall a . (a -> String) -> Maybe a -> String
inspect f m = case m of
  Nothing -> "Nothing"
  Just x -> String.join "" ["Just (", f x, ")"]

map :: forall a b . (a -> b) -> Maybe a -> Maybe b
map f m = case m of
  Nothing -> Nothing
  Just x -> Just (f x)

pure :: forall a . a -> Maybe a
pure = Just

withDefault :: forall a . a -> Maybe a -> a
withDefault x m = case m of
  Nothing -> x
  Just y -> y
