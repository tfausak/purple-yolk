module Core.Type.Queue
  ( Queue
  , add
  , apply
  , bind
  , compare
  , dequeue
  , empty
  , enqueue
  , fromList
  , inspect
  , map
  , pure
  , toList
  ) where

import Core.Primitive.String as String
import Core.Type.List as List
import Core.Type.Maybe as Maybe
import Core.Type.Ordering as Ordering
import Core.Type.Tuple as Tuple

data Queue a = Queue (List.List a) (List.List a)

add :: forall a . Queue a -> Queue a -> Queue a
add (Queue f1 r1) (Queue f2 r2) =
  Queue (List.add f1 (List.add (List.reverse r1) f2)) r2

apply :: forall a b . Queue (a -> b) -> Queue a -> Queue b
apply fs xs = fromList (List.apply (toList fs) (toList xs))

bind :: forall a b . Queue a -> (a -> Queue b) -> Queue b
bind q f = fromList (List.bind (toList q) (\ x -> toList (f x)))

compare
  :: forall a
  . (a -> a -> Ordering.Ordering)
  -> Queue a
  -> Queue a
  -> Ordering.Ordering
compare f x y = List.compare f (toList x) (toList y)

dequeue :: forall a . Queue a -> Maybe.Maybe (Tuple.Tuple a (Queue a))
dequeue (Queue f r) = case f of
  List.Nil -> case List.reverse r of
    List.Nil -> Maybe.Nothing
    List.Cons x s -> Maybe.Just (Tuple.Tuple x (Queue s List.Nil))
  List.Cons x g -> Maybe.Just (Tuple.Tuple x (Queue g r))

empty :: forall a . Queue a
empty = fromList List.Nil

enqueue :: forall a . a -> Queue a -> Queue a
enqueue x (Queue f r) = Queue f (List.Cons x r)

fromList :: forall a . List.List a -> Queue a
fromList xs = Queue xs List.Nil

inspect :: forall a . (a -> String) -> Queue a -> String
inspect f q = String.join ""
  [ "fromList ("
  , List.inspect f (toList q)
  , ")"
  ]

map :: forall a b . (a -> b) -> Queue a -> Queue b
map f q = fromList (List.map f (toList q))

pure :: forall a . a -> Queue a
pure x = Queue (List.Cons x List.Nil) List.Nil

toList :: forall a . Queue a -> List.List a
toList (Queue f r) = List.add f (List.reverse r)
