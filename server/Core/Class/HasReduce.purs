module Core.Class.HasReduce
  ( class HasReduce
  , reduce
  ) where

import Core.Primitive.Array as Array
import Core.Type.List as List

class HasReduce t where
  reduce :: forall a b . (b -> a -> b) -> b -> t a -> b

instance _Array_HasReduce :: HasReduce Array where
  reduce = Array.reduce

instance _List_HasReduce :: HasReduce List.List where
  reduce = List.reduce
