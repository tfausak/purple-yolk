module Core.Type.Tuple
  ( Tuple(Tuple)
  , curry
  , first
  , second
  , swap
  , uncurry
  ) where

data Tuple a b = Tuple a b

curry :: forall a b c . (Tuple a b -> c) -> a -> b -> c
curry f x y = f (Tuple x y)

first :: forall a b . Tuple a b -> a
first (Tuple x _) = x

second :: forall a b . Tuple a b -> b
second (Tuple _ y) = y

swap :: forall a b . Tuple a b -> Tuple b a
swap (Tuple x y) = Tuple y x

uncurry :: forall a b c . (a -> b -> c) -> Tuple a b -> c
uncurry f (Tuple x y) = f x y
