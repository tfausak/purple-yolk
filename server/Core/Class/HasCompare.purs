module Core.Class.HasCompare
  ( class HasCompare
  , clamp
  , compare
  , eq
  , ge
  , gt
  , le
  , lt
  , max
  , min
  , ne
  ) where

import Core.Primitive.Boolean as Boolean
import Core.Primitive.Char as Char
import Core.Primitive.Int as Int
import Core.Primitive.Number as Number
import Core.Primitive.String as String
import Core.Type.Ordering as Ordering

class HasCompare a where
  compare :: a -> a -> Ordering.Ordering

instance _Boolean_HasCompare :: HasCompare Boolean where
  compare = Boolean.compare

instance _Char_HasCompare :: HasCompare Char where
  compare = Char.compare

instance _Int_HasCompare :: HasCompare Int where
  compare = Int.compare

instance _Number_HasCompare :: HasCompare Number where
  compare = Number.compare

instance _String_HasCompare :: HasCompare String where
  compare = String.compare

clamp :: forall a . HasCompare a => a -> a -> a -> a
clamp lo hi x = max lo (min hi x)

eq :: forall a . HasCompare a => a -> a -> Boolean
eq x y = case compare x y of
  Ordering.EQ -> true
  _ -> false

ge :: forall a . HasCompare a => a -> a -> Boolean
ge x y = case compare x y of
  Ordering.LT -> false
  _ -> true

gt :: forall a . HasCompare a => a -> a -> Boolean
gt x y = case compare x y of
  Ordering.GT -> true
  _ -> false

le :: forall a . HasCompare a => a -> a -> Boolean
le x y = case compare x y of
  Ordering.GT -> false
  _ -> true

lt :: forall a . HasCompare a => a -> a -> Boolean
lt x y = case compare x y of
  Ordering.LT -> true
  _ -> false

max :: forall a . HasCompare a => a -> a -> a
max x y = if gt y x then y else x

min :: forall a . HasCompare a => a -> a -> a
min x y = if lt y x then y else x

ne :: forall a . HasCompare a => a -> a -> Boolean
ne x y = case compare x y of
  Ordering.EQ -> false
  _ -> true
