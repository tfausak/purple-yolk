module Core.Class.HasAdd
  ( class HasAdd
  , add
  ) where

import Core.Primitive.Array as Array
import Core.Primitive.Int as Int
import Core.Primitive.Number as Number
import Core.Primitive.String as String
import Core.Type.List as List
import Core.Type.Queue as Queue

class HasAdd a where
  add :: a -> a -> a

instance _Array_HasAdd :: HasAdd (Array a) where
  add = Array.add

instance _Int_HasAdd :: HasAdd Int where
  add = Int.add

instance _List_HasAdd :: HasAdd (List.List a) where
  add = List.add

instance _Number_HasAdd :: HasAdd Number where
  add = Number.add

instance _Queue_HasAdd :: HasAdd (Queue.Queue a) where
  add = Queue.add

instance _String_HasAdd :: HasAdd String where
  add = String.add
