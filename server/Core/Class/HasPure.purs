module Core.Class.HasPure
  ( class HasPure
  , pure
  ) where

import Core.Primitive.Array as Array
import Core.Type.IO as IO
import Core.Type.List as List
import Core.Type.Maybe as Maybe
import Core.Type.Queue as Queue

class HasPure t where
  pure :: forall a . a -> t a

instance _Array_HasPure :: HasPure Array where
  pure = Array.pure

instance _IO_HasPure :: HasPure IO.IO where
  pure = IO.pure

instance _List_HasPure :: HasPure List.List where
  pure = List.pure

instance _Maybe_HasPure :: HasPure Maybe.Maybe where
  pure = Maybe.pure

instance _Queue_HasPure :: HasPure Queue.Queue where
  pure = Queue.pure
