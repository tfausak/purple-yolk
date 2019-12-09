module Core.Class.HasMap
  ( class HasMap
  , map
  ) where

import Core.Primitive.Array as Array
import Core.Type.IO as IO
import Core.Type.List as List
import Core.Type.Maybe as Maybe
import Core.Type.Object as Object
import Core.Type.Queue as Queue

class HasMap t where
  map :: forall a b . (a -> b) -> t a -> t b

instance _Array_HasMap :: HasMap Array where
  map = Array.map

instance _IO_HasMap :: HasMap IO.IO where
  map = IO.map

instance _List_HasMap :: HasMap List.List where
  map = List.map

instance _Maybe_HasMap :: HasMap Maybe.Maybe where
  map = Maybe.map

instance _Object_HasMap :: HasMap Object.Object where
  map = Object.map

instance _Queue_HasMap :: HasMap Queue.Queue where
  map = Queue.map
