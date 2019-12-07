module Core.Class.HasDivide
  ( class HasDivide
  , divide
  ) where

import Core.Primitive.Int as Int
import Core.Primitive.Number as Number

class HasDivide a where
  divide :: a -> a -> a

instance _HasDivide_Int :: HasDivide Int where
  divide = Int.divide

instance _HasDivide_Number :: HasDivide Number where
  divide = Number.divide
