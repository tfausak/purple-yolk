module Core.Class.HasApply
  ( class HasApply
  , apply
  ) where

import Core.Primitive.Array as Array
import Core.Type.IO as IO
import Core.Type.List as List
import Core.Type.Maybe as Maybe
import Core.Type.Queue as Queue

class HasApply t where
  apply :: forall a b . t (a -> b) -> t a -> t b

instance _Array_HasApply :: HasApply Array where
  apply = Array.apply

instance _IO_HasApply :: HasApply IO.IO where
  apply = IO.apply

instance _List_HasApply :: HasApply List.List where
  apply = List.apply

instance _Maybe_HasApply :: HasApply Maybe.Maybe where
  apply = Maybe.apply

instance _Queue_HasApply :: HasApply Queue.Queue where
  apply = Queue.apply
