module Core.Class.HasToInt
  ( class HasToInt
  , toInt
  ) where

import Core.Primitive.Boolean as Boolean
import Core.Primitive.Char as Char
import Core.Primitive.Function as Function
import Core.Type.Ordering as Ordering

class HasToInt a where
  toInt :: a -> Int

instance _Boolean_HasToInt :: HasToInt Boolean where
  toInt = Boolean.toInt

instance _Char_HasToInt :: HasToInt Char where
  toInt = Char.toInt

instance _Int_HasToInt :: HasToInt Int where
  toInt = Function.identity

instance _Ordering_HasToInt :: HasToInt Ordering.Ordering where
  toInt = Ordering.toInt
