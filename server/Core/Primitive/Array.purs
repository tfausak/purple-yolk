module Core.Primitive.Array
  ( add
  , apply
  , bind
  , compare
  , inspect
  , map
  , pure
  ) where

import Core.Type.Ordering as Ordering

foreign import add :: forall a . Array a -> Array a -> Array a

foreign import apply :: forall a b . Array (a -> b) -> Array a -> Array b

foreign import bind :: forall a b . Array a -> (a -> Array b) -> Array b

foreign import compareWith
  :: forall a
  . Ordering.Ordering
  -> Ordering.Ordering
  -> Ordering.Ordering
  -> (a -> a -> Ordering.Ordering)
  -> Array a
  -> Array a
  -> Ordering.Ordering

foreign import inspect :: forall a . (a -> String) -> Array a -> String

foreign import map :: forall a b . (a -> b) -> Array a -> Array b

compare
  :: forall a
  . (a -> a -> Ordering.Ordering)
  -> Array a
  -> Array a
  -> Ordering.Ordering
compare = compareWith Ordering.LT Ordering.EQ Ordering.GT

pure :: forall a . a -> Array a
pure x = [x]
