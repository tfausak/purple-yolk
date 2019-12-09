module Core.Class.HasSubtract
  ( class HasSubtract
  , subtract
  ) where

import Core.Primitive.Int as Int
import Core.Primitive.Number as Number

class HasSubtract a where
  subtract :: a -> a -> a

instance _Int_HasSubtract :: HasSubtract Int where
  subtract = Int.subtract

instance _Number_HasSubtract :: HasSubtract Number where
  subtract = Number.subtract
