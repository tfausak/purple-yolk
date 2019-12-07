module Core.Class.HasPower
  ( class HasPower
  , power
  ) where

import Core.Primitive.Int as Int
import Core.Primitive.Number as Number

class HasPower a where
  power :: a -> a -> a

instance _HasPower_Int :: HasPower Int where
  power = Int.power

instance _HasPower_Number :: HasPower Number where
  power = Number.power
