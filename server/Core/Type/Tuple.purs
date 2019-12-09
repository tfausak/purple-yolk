module Core.Type.Tuple
  ( Tuple(Tuple)
  , compare
  , curry
  , first
  , inspect
  , second
  , swap
  , uncurry
  ) where

import Core.Primitive.String as String
import Core.Type.Ordering as Ordering

data Tuple a b = Tuple a b

compare
  :: forall a b
  . (a -> a -> Ordering.Ordering)
  -> (b -> b -> Ordering.Ordering)
  -> Tuple a b
  -> Tuple a b
  -> Ordering.Ordering
compare compareX compareY (Tuple x1 y1) (Tuple x2 y2) =
  case compareX x1 x2 of
    Ordering.EQ -> compareY y1 y2
    ordering -> ordering

curry :: forall a b c . (Tuple a b -> c) -> a -> b -> c
curry f x y = f (Tuple x y)

first :: forall a b . Tuple a b -> a
first (Tuple x _) = x

inspect :: forall a b . (a -> String) -> (b -> String) -> Tuple a b -> String
inspect f g (Tuple x y) = String.join "" ["Tuple (", f x, ") (", g y, ")"]

second :: forall a b . Tuple a b -> b
second (Tuple _ y) = y

swap :: forall a b . Tuple a b -> Tuple b a
swap (Tuple x y) = Tuple y x

uncurry :: forall a b c . (a -> b -> c) -> Tuple a b -> c
uncurry f (Tuple x y) = f x y
