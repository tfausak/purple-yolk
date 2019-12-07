module Core.Primitive.Int
  ( add
  , bottom
  , compare
  , divide
  , fromInt
  , inspect
  , modulo
  , multiply
  , negate
  , power
  , subtract
  , toNumber
  , top
  ) where

import Core.Type.Maybe as Maybe
import Core.Type.Ordering as Ordering

foreign import add :: Int -> Int -> Int

foreign import bottom :: Int

foreign import compareWith :: Ordering.Ordering -> Ordering.Ordering -> Ordering.Ordering -> Int -> Int -> Ordering.Ordering

foreign import divide :: Int -> Int -> Int

foreign import inspect :: Int -> String

foreign import modulo :: Int -> Int -> Int

foreign import multiply :: Int -> Int -> Int

foreign import negate :: Int -> Int

foreign import power :: Int -> Int -> Int

foreign import subtract :: Int -> Int -> Int

foreign import toNumber :: Int -> Number

compare :: Int -> Int -> Ordering.Ordering
compare = compareWith Ordering.LT Ordering.EQ Ordering.GT

fromInt :: Int -> Maybe.Maybe Int
fromInt = Maybe.Just

top :: Int
top = 2147483647
