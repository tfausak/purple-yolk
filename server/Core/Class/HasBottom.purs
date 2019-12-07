module Core.Class.HasBottom
  ( class HasBottom
  , bottom
  ) where

import Core.Primitive.Boolean as Boolean
import Core.Primitive.Char as Char
import Core.Primitive.Int as Int
import Core.Type.Ordering as Ordering

class HasBottom a where
  bottom :: a

instance _Boolean_HasBottom :: HasBottom Boolean where
  bottom = Boolean.bottom

instance _Char_HasBottom :: HasBottom Char where
  bottom = Char.bottom

instance _Int_HasBottom :: HasBottom Int where
  bottom = Int.bottom

instance _Ordering_HasBottom :: HasBottom Ordering.Ordering where
  bottom = Ordering.bottom
