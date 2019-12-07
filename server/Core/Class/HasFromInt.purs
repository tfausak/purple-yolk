module Core.Class.HasFromInt
  ( class HasFromInt
  , fromInt
  ) where

import Core.Primitive.Boolean as Boolean
import Core.Primitive.Char as Char
import Core.Primitive.Int as Int
import Core.Type.Maybe as Maybe
import Core.Type.Ordering as Ordering

class HasFromInt a where
  fromInt :: Int -> Maybe.Maybe a

instance _Boolean_HasFromInt :: HasFromInt Boolean where
  fromInt = Boolean.fromInt

instance _Char_HasFromInt :: HasFromInt Char where
  fromInt = Char.fromInt

instance _Int_HasFromInt :: HasFromInt Int where
  fromInt = Int.fromInt

instance _Ordering_HasFromInt :: HasFromInt Ordering.Ordering where
  fromInt = Ordering.fromInt
