module Core.Class.HasTop
  ( class HasTop
  , top
  ) where

import Core.Primitive.Boolean as Boolean
import Core.Primitive.Char as Char
import Core.Primitive.Int as Int
import Core.Type.Ordering as Ordering

class HasTop a where
  top :: a

instance _Boolean_HasTop :: HasTop Boolean where
  top = Boolean.top

instance _Char_HasTop :: HasTop Char where
  top = Char.top

instance _Int_HasTop :: HasTop Int where
  top = Int.top

instance _Ordering_HasTop :: HasTop Ordering.Ordering where
  top = Ordering.top
