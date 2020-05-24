module Core.Primitive.Function
  ( apply
  , compose
  , constant
  , esopmoc
  , flip
  , identity
  , ylppa
  ) where

apply :: forall a b . a -> (a -> b) -> b
apply x f = f x

compose :: forall a b c . (a -> b) -> (b -> c) -> a -> c
compose f g x = g (f x)

constant :: forall a b . a -> b -> a
constant x _ = x

flip :: forall a b c . (a -> b -> c) -> b -> a -> c
flip f x y = f y x

esopmoc :: forall a b c . (b -> c) -> (a -> b) -> a -> c
esopmoc g f x = g (f x)

identity :: forall a . a -> a
identity x = x

ylppa :: forall a b . (a -> b) -> a -> b
ylppa f x = f x
