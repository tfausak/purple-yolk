module Core.Class.HasCompare
  ( class HasCompare
  , compare
  , eq
  , le
  , lt
  , ge
  , gt
  , ne
  ) where

import Core.Primitive.Array as Array
import Core.Primitive.Boolean as Boolean
import Core.Primitive.Char as Char
import Core.Primitive.Int as Int
import Core.Primitive.Number as Number
import Core.Primitive.String as String
import Core.Type.Date as Date
import Core.Type.List as List
import Core.Type.Maybe as Maybe
import Core.Type.Nullable as Nullable
import Core.Type.Ordering as Ordering
import Core.Type.Queue as Queue
import Core.Type.Tuple as Tuple

class HasCompare a where
  compare :: a -> a -> Ordering.Ordering

instance _Array_HasCompare :: HasCompare a => HasCompare (Array a) where
  compare = Array.compare compare

instance _Boolean_HasCompare :: HasCompare Boolean where
  compare = Boolean.compare

instance _Char_HasCompare :: HasCompare Char where
  compare = Char.compare

instance _Date_HasCompare :: HasCompare Date.Date where
  compare = Date.compare

instance _Int_HasCompare :: HasCompare Int where
  compare = Int.compare

instance _List_HasCompare :: HasCompare a => HasCompare (List.List a) where
  compare = List.compare compare

instance _Maybe_HasCompare :: HasCompare a => HasCompare (Maybe.Maybe a) where
  compare = Maybe.compare compare

instance _Nullable_HasCompare :: HasCompare a => HasCompare (Nullable.Nullable a) where
  compare = Nullable.compare compare

instance _Number_HasCompare :: HasCompare Number where
  compare = Number.compare

instance _Ordering_HasCompare :: HasCompare Ordering.Ordering where
  compare = Ordering.compare

instance _Queue_HasCompare :: HasCompare a => HasCompare (Queue.Queue a) where
  compare = Queue.compare compare

instance _String_HasCompare :: HasCompare String where
  compare = String.compare

instance _Tuple_HasCompare :: (HasCompare a, HasCompare b) => HasCompare (Tuple.Tuple a b) where
  compare = Tuple.compare compare compare

eq :: forall a . HasCompare a => a -> a -> Boolean
eq x y = case compare x y of
  Ordering.EQ -> true
  _ -> false

le :: forall a . HasCompare a => a -> a -> Boolean
le x y = case compare x y of
  Ordering.GT -> false
  _ -> true

lt :: forall a . HasCompare a => a -> a -> Boolean
lt x y = case compare x y of
  Ordering.LT -> true
  _ -> false

ge :: forall a . HasCompare a => a -> a -> Boolean
ge x y = case compare x y of
  Ordering.LT -> false
  _ -> true

gt :: forall a . HasCompare a => a -> a -> Boolean
gt x y = case compare x y of
  Ordering.GT -> true
  _ -> false

ne :: forall a . HasCompare a => a -> a -> Boolean
ne x y = case compare x y of
  Ordering.EQ -> false
  _ -> true
