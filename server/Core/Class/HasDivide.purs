module Core.Class.HasDivide
  ( class HasDivide
  , divide
  ) where

import Core.Primitive.Int as Int
import Core.Primitive.Number as Number

class HasDivide a where
  divide :: a -> a -> a

instance _Int_HasDivide :: HasDivide Int where
  divide = Int.divide

instance _Number_HasDivide :: HasDivide Number where
  divide = Number.divide
