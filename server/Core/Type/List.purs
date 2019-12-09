module Core.Type.List
  ( List(Nil, Cons)
  , add
  , apply
  , bind
  , compare
  , drop
  , fromArray
  , inspect
  , length
  , map
  , pure
  , replicate
  , reverse
  , toArray
  ) where

import Core.Primitive.Int as Int
import Core.Primitive.String as String
import Core.Type.Ordering as Ordering

foreign import fromArrayWith
  :: forall a
  . List a
  -> (a -> List a -> List a)
  -> Array a
  -> List a

foreign import toArray :: forall a . List a -> Array a

data List a
  = Nil
  | Cons a (List a)

add :: forall a . List a -> List a -> List a
add xs zs = case xs of
  Nil -> zs
  Cons x ys -> Cons x (add ys zs)

apply :: forall a b . List (a -> b) -> List a -> List b
apply fs xs = case fs of
  Nil -> Nil
  Cons f gs -> add (map f xs) (apply gs xs)

bind :: forall a b . List a -> (a -> List b) -> List b
bind xs f = case xs of
  Nil -> Nil
  Cons x ys -> add (f x) (bind ys f)

compare
  :: forall a
  . (a -> a -> Ordering.Ordering)
  -> List a
  -> List a
  -> Ordering.Ordering
compare f xs ys = case xs, ys of
  Nil, Nil -> Ordering.EQ
  Nil, Cons _ _ -> Ordering.LT
  Cons _ _, Nil -> Ordering.GT
  Cons x xs_, Cons y ys_ -> case f x y of
    Ordering.EQ -> compare f xs_ ys_
    ordering -> ordering

drop :: forall a . Int -> List a -> List a
drop n xs = case Int.compare n 1 of
  Ordering.LT -> xs
  _ -> case xs of
    Nil -> Nil
    Cons _ ys -> drop (Int.subtract n 1) ys

fromArray :: forall a . Array a -> List a
fromArray = fromArrayWith Nil Cons

inspect :: forall a . (a -> String) -> List a -> String
inspect f xs = case xs of
  Nil -> "Nil"
  Cons x ys -> String.join "" ["Cons (", f x, ") (", inspect f ys, ")"]

length :: forall a . List a -> Int
length xs = case xs of
  Nil -> 0
  Cons _ ys -> Int.add 1 (length ys)

map :: forall a b . (a -> b) -> List a -> List b
map f xs = case xs of
  Nil -> Nil
  Cons x ys -> Cons (f x) (map f ys)

pure :: forall a . a -> List a
pure x = Cons x Nil

replicate :: forall a . Int -> a -> List a
replicate n x = case Int.compare n 1 of
  Ordering.LT -> Nil
  _ -> Cons x (replicate (Int.subtract n 1) x)

reverse :: forall a . List a -> List a
reverse =
  let
    go acc xs = case xs of
      Nil -> acc
      Cons x ys -> go (Cons x acc) ys
  in go Nil
