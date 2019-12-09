module Core.Type.Object
  ( Object
  , empty
  , fromList
  , get
  , inspect
  , map
  , set
  , toList
  ) where

import Core.Primitive.String as String
import Core.Type.List as List
import Core.Type.Maybe as Maybe
import Core.Type.Tuple as Tuple

foreign import data Object :: Type -> Type

foreign import empty :: forall a . Object a

foreign import getWith
  :: forall a
  . Maybe.Maybe a
  -> (a -> Maybe.Maybe a)
  -> String
  -> Object a
  -> Maybe.Maybe a

foreign import map :: forall a b . (a -> b) -> Object a -> Object b

foreign import set :: forall a . String -> a -> Object a -> Object a

foreign import toListWith
  :: forall a
  . (String -> a -> Tuple.Tuple String a)
  -> List.List (Tuple.Tuple String a)
  -> ((Tuple.Tuple String a) -> List.List (Tuple.Tuple String a) -> List.List (Tuple.Tuple String a))
  -> Object a
  -> List.List (Tuple.Tuple String a)

fromList :: forall a . List.List (Tuple.Tuple String a) -> Object a
fromList xs = case xs of
  List.Nil -> empty
  List.Cons (Tuple.Tuple k v) ys -> set k v (fromList ys)

get :: forall a . String -> Object a -> Maybe.Maybe a
get = getWith Maybe.Nothing Maybe.Just

inspect :: forall a . (a -> String) -> Object a -> String
inspect f o = String.join ""
  [ "fromList ("
  , (List.inspect (Tuple.inspect String.inspect f) (toList o))
  , ")"
  ]

toList :: forall a . Object a -> List.List (Tuple.Tuple String a)
toList = toListWith Tuple.Tuple List.Nil List.Cons
