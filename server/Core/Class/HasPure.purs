module Core.Class.HasPure
  ( class HasPure
  , pure
  ) where

import Core.Type.IO as IO
import Core.Type.List as List

class HasPure t where
  pure :: forall a . a -> t a

instance _Array_HasPure :: HasPure Array where
  pure x = [x]

instance _IO_HasPure :: HasPure IO.IO where
  pure = IO.pure

instance _List_HasPure :: HasPure List.List where
  pure x = List.Cons x List.Nil
