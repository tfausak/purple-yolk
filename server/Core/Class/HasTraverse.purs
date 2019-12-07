module Core.Class.HasTraverse
  ( class HasTraverse
  , traverse
  ) where

import Core.Class.HasApply as HasApply
import Core.Class.HasMap as HasMap
import Core.Class.HasPure as HasPure
import Core.Type.List as List

class HasTraverse t where
  traverse :: forall f a b . HasApply.HasApply f => HasMap.HasMap f => HasPure.HasPure f => (a -> f b) -> t a -> f (t b)

instance _Array_HasTraverse :: HasTraverse Array where
  traverse f xs = HasMap.map List.toArray (traverse f (List.fromArray xs))

instance _List_HasTraverse :: HasTraverse List.List where
  traverse f xs = case xs of
    List.Nil -> HasPure.pure List.Nil
    List.Cons x ys -> HasApply.apply (HasMap.map List.Cons (f x)) (traverse f ys)
