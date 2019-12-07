module Core.Class.HasSubtract
  ( class HasSubtract
  , subtract
  ) where

import Core.Primitive.Int as Int
import Core.Primitive.Number as Number

class HasSubtract a where
  subtract :: a -> a -> a

instance _HasSubtract_Int :: HasSubtract Int where
  subtract = Int.subtract

instance _HasSubtract_Number :: HasSubtract Number where
  subtract = Number.subtract
