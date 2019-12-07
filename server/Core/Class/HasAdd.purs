module Core.Class.HasAdd
  ( class HasAdd
  , add
  ) where

import Core.Primitive.Array as Array
import Core.Primitive.Int as Int
import Core.Primitive.Number as Number
import Core.Primitive.String as String
import Core.Type.List as List

class HasAdd a where
  add :: a -> a -> a

instance _HasAdd_Array :: HasAdd (Array a) where
  add = Array.add

instance _HasAdd_Int :: HasAdd Int where
  add = Int.add

instance _HasAdd_List :: HasAdd (List.List a) where
  add = List.add

instance _HasAdd_Number :: HasAdd Number where
  add = Number.add

instance _HasAdd_String :: HasAdd String where
  add = String.add
