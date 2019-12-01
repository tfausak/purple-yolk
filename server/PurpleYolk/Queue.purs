module PurpleYolk.Queue
  ( Queue
  , dequeue
  , empty
  , enqueue
  ) where

import PurpleYolk.List as List
import PurpleYolk.Maybe as Maybe
import PurpleYolk.Tuple as Tuple

data Queue a = Queue (List.List a) (List.List a)

dequeue :: forall a . Queue a -> Maybe.Maybe (Tuple.Tuple a (Queue a))
dequeue (Queue f r) = case f of
  List.Nil -> case List.reverse r of
    List.Nil -> Maybe.Nothing
    List.Cons x s -> Maybe.Just (Tuple.Tuple x (Queue s List.Nil))
  List.Cons x g -> Maybe.Just (Tuple.Tuple x (Queue g r))

empty :: forall a . Queue a
empty = Queue List.Nil List.Nil

enqueue :: forall a . a -> Queue a -> Queue a
enqueue x (Queue f r) = Queue f (List.Cons x r)
