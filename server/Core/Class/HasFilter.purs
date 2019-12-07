module Core.Class.HasFilter
  ( class HasFilter
  , filter
  ) where

import Core.Primitive.Array as Array
import Core.Type.List as List

class HasFilter t where
  filter :: forall a . (a -> Boolean) -> t a -> t a

instance _Array_HasFilter :: HasFilter Array where
  filter = Array.filter

instance _List_HasFilter :: HasFilter List.List where
  filter = List.filter
