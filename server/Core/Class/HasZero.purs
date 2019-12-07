module Core.Class.HasZero
  ( class HasZero
  , zero
  ) where

import Core.Type.List as List

class HasZero a where
  zero :: a

instance _Array_HasZero :: HasZero (Array a) where
  zero = []

instance _Int_HasZero :: HasZero Int where
  zero = 0

instance _List_HasZero :: HasZero (List.List a) where
  zero = List.Nil

instance _Number_HasZero :: HasZero Number where
  zero = 0.0

instance _String_HasZero :: HasZero String where
  zero = ""
