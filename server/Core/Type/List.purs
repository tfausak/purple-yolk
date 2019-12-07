module Core.Type.List
  ( List(Nil, Cons)
  , add
  , filter
  , fromArray
  , map
  , reduce
  , reverse
  , toArray
  ) where

foreign import fromArrayWith :: forall a . List a -> (a -> List a -> List a) -> Array a -> List a

foreign import toArray :: forall a . List a -> Array a

data List a
  = Nil
  | Cons a (List a)

add :: forall a . List a -> List a -> List a
add xs zs = case xs of
  Nil -> zs
  Cons x ys -> Cons x (add ys zs)

filter :: forall a . (a -> Boolean) -> List a -> List a
filter f xs = case xs of
  Nil -> Nil
  Cons x ys -> if f x then Cons x (filter f ys) else filter f ys

fromArray :: forall a . Array a -> List a
fromArray = fromArrayWith Nil Cons

map :: forall a b . (a -> b) -> List a -> List b
map f xs = case xs of
  Nil -> Nil
  Cons x ys -> Cons (f x) (map f ys)

reduce :: forall a b . (b -> a -> b) -> b -> List a -> b
reduce f z xs = case xs of
  Nil -> z
  Cons x ys -> reduce f (f z x) ys

reverse :: forall a . List a -> List a
reverse = reduce (\ a e -> Cons e a) Nil
