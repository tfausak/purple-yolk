module Core.Primitive.Boolean
  ( and
  , bottom
  , compare
  , fromInt
  , inspect
  , not
  , or
  , toInt
  , top
  ) where

import Core.Type.Maybe as Maybe
import Core.Type.Ordering as Ordering

and :: Boolean -> Boolean -> Boolean
and x y = if x then y else false

bottom :: Boolean
bottom = false

compare :: Boolean -> Boolean -> Ordering.Ordering
compare x y = case x, y of
  false, true -> Ordering.LT
  true, false -> Ordering.GT
  _, _ -> Ordering.EQ

fromInt :: Int -> Maybe.Maybe Boolean
fromInt x = case x of
  0 -> Maybe.Just false
  1 -> Maybe.Just true
  _ -> Maybe.Nothing

inspect :: Boolean -> String
inspect x = if x then "true" else "false"

not :: Boolean -> Boolean
not x = if x then false else true

or :: Boolean -> Boolean -> Boolean
or x y = if x then true else y

toInt :: Boolean -> Int
toInt x = if x then 1 else 0

top :: Boolean
top = true
