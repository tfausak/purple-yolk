module Core.Class.HasModulo
  ( class HasModulo
  , modulo
  ) where

import Core.Primitive.Int as Int
import Core.Primitive.Number as Number

class HasModulo a where
  modulo :: a -> a -> a

instance _HasModulo_Int :: HasModulo Int where
  modulo = Int.modulo

instance _HasModulo_Number :: HasModulo Number where
  modulo = Number.modulo
