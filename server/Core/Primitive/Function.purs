module Core.Primitive.Function
  ( backward
  , compose
  , constant
  , esopmoc
  , flip
  , forward
  , identity
  ) where

backward :: forall a b . (a -> b) -> a -> b
backward f x = f x

compose :: forall a b c . (a -> b) -> (b -> c) -> a -> c
compose f g x = g (f x)

constant :: forall a b . a -> b -> a
constant x _ = x

esopmoc :: forall a b c . (b -> c) -> (a -> b) -> a -> c
esopmoc g f x = g (f x)

flip :: forall a b c . (a -> b -> c) -> b -> a -> c
flip f y x = f x y

forward :: forall a b . a -> (a -> b) -> b
forward x f = f x

identity :: forall a . a -> a
identity x = x
