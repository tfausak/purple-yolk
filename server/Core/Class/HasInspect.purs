module Core.Class.HasInspect
  ( class HasInspect
  , inspect
  ) where

import Core.Primitive.Array as Array
import Core.Primitive.Boolean as Boolean
import Core.Primitive.Char as Char
import Core.Primitive.Int as Int
import Core.Primitive.Number as Number
import Core.Primitive.String as String
import Core.Type.List as List

class HasInspect a where
  inspect :: a -> String

instance _Array_HasInspect :: HasInspect a => HasInspect (Array a) where
  inspect xs = String.concat ["[", String.join ", " (Array.map inspect xs), "]"]

instance _Boolean_HasInspect :: HasInspect Boolean where
  inspect = Boolean.inspect

instance _Char_HasInspect :: HasInspect Char where
  inspect = Char.inspect

instance _Int_HasInspect :: HasInspect Int where
  inspect = Int.inspect

instance _List_HasInspect :: HasInspect a => HasInspect (List.List a) where
  inspect xs = case xs of
    List.Nil -> "Nil"
    List.Cons x ys -> String.concat ["Cons (", inspect x, ") (", inspect ys, ")"]

instance _Number_HasInspect :: HasInspect Number where
  inspect = Number.inspect

instance _String_HasInspect :: HasInspect String where
  inspect = String.inspect
