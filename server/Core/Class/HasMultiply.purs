module Core.Class.HasMultiply
  ( class HasMultiply
  , multiply
  ) where

import Core.Primitive.Int as Int
import Core.Primitive.Number as Number

class HasMultiply a where
  multiply :: a -> a -> a

instance _HasMultiply_Int :: HasMultiply Int where
  multiply = Int.multiply

instance _HasMultiply_Number :: HasMultiply Number where
  multiply = Number.multiply
