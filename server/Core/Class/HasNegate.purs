module Core.Class.HasNegate
  ( class HasNegate
  , negate
  ) where

import Core.Primitive.Int as Int
import Core.Primitive.Number as Number

class HasNegate a where
  negate :: a -> a

instance _Int_HasNegate :: HasNegate Int where
  negate = Int.negate

instance _Number_HasNegate :: HasNegate Number where
  negate = Number.negate
