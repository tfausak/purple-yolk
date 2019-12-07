module Core.Class.HasMap
  ( class HasMap
  , map
  ) where

import Core.Primitive.Array as Array
import Core.Type.List as List
import Core.Type.IO as IO

class HasMap t where
  map :: forall a b . (a -> b) -> t a -> t b

instance _Array_HasMap :: HasMap Array where
  map = Array.map

instance _IO_HasMap :: HasMap IO.IO where
  map = IO.map

instance _List_HasMap :: HasMap List.List where
  map = List.map
