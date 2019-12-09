module Core.Primitive.Boolean
  ( and
  , compare
  , inspect
  , not
  , or
  ) where

import Core.Type.Ordering as Ordering

and :: Boolean -> Boolean -> Boolean
and x y = if x then y else false

compare :: Boolean -> Boolean -> Ordering.Ordering
compare x y = case x, y of
  false, false -> Ordering.EQ
  false, true -> Ordering.LT
  true, false -> Ordering.GT
  true, true -> Ordering.EQ

inspect :: Boolean -> String
inspect x = if x then "true" else "false"

not :: Boolean -> Boolean
not x = if x then false else true

or :: Boolean -> Boolean -> Boolean
or x y = if x then true else y
