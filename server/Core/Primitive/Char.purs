module Core.Primitive.Char
  ( bottom
  , compare
  , fromInt
  , inspect
  , toInt
  , top
  ) where

import Core.Type.Maybe as Maybe
import Core.Type.Nullable as Nullable
import Core.Type.Ordering as Ordering

foreign import compareWith :: Ordering.Ordering -> Ordering.Ordering -> Ordering.Ordering -> Char -> Char -> Ordering.Ordering

foreign import fromIntNullable :: Int -> Nullable.Nullable Char

foreign import inspect :: Char -> String

foreign import toInt :: Char -> Int

bottom :: Char
bottom = '\x0000'

compare :: Char -> Char -> Ordering.Ordering
compare = compareWith Ordering.LT Ordering.EQ Ordering.GT

fromInt :: Int -> Maybe.Maybe Char
fromInt x = Nullable.toMaybe (fromIntNullable x)

top :: Char
top = '\xffff'
