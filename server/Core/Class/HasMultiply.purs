module Core.Class.HasMultiply
  ( class HasMultiply
  , multiply
  ) where

import Core.Primitive.Int as Int
import Core.Primitive.Number as Number

class HasMultiply a where
  multiply :: a -> a -> a

instance _Int_HasMultiply :: HasMultiply Int where
  multiply = Int.multiply

instance _Number_HasMultiply :: HasMultiply Number where
  multiply = Number.multiply
