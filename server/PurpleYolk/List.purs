module PurpleYolk.List
  ( List(Nil, Cons)
  , append
  , foldl
  , foldr
  , fromArray
  , map
  , reverse
  ) where

import PurpleYolk.Inspect as Inspect
import PurpleYolk.String as String

foreign import fromArrayWith
  :: forall a . List a -> (a -> List a -> List a) -> Array a -> List a

data List a
  = Nil
  | Cons a (List a)

instance listHasInspect :: Inspect.HasInspect a => Inspect.HasInspect (List a) where
  inspect xs = case xs of
    Nil -> "Nil"
    Cons x ys -> String.concat
      ["Cons (", Inspect.inspect x, ") (", Inspect.inspect ys, ")"]

append :: forall a . List a -> List a -> List a
append xs ys = foldr Cons ys xs

foldl :: forall a b . (a -> b -> b) -> b -> List a -> b
foldl f z xs = case xs of
  Nil -> z
  Cons x ys -> foldl f (f x z) ys

foldr :: forall a b . (a -> b -> b) -> b -> List a -> b
foldr f z xs = case xs of
  Nil -> z
  Cons x ys -> f x (foldr f z ys)

fromArray :: forall a . Array a -> List a
fromArray = fromArrayWith Nil Cons

map :: forall a b . (a -> b) -> List a -> List b
map f xs = case xs of
  Nil -> Nil
  Cons x ys -> Cons (f x) (map f ys)

reverse :: forall a . List a -> List a
reverse = foldl Cons Nil
