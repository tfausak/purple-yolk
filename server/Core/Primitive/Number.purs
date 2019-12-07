module Core.Primitive.Number
  ( add
  , ceiling
  , compare
  , divide
  , floor
  , infinity
  , inspect
  , isFinite
  , isNaN
  , nan
  , modulo
  , multiply
  , negate
  , power
  , round
  , subtract
  , truncate
  ) where

import Core.Type.Ordering as Ordering

foreign import add :: Number -> Number -> Number

foreign import ceiling :: Number -> Int

foreign import compareWith :: Ordering.Ordering -> Ordering.Ordering -> Ordering.Ordering -> Number -> Number -> Ordering.Ordering

foreign import divide :: Number -> Number -> Number

foreign import floor :: Number -> Int

foreign import infinity :: Number

foreign import inspect :: Number -> String

foreign import isFinite :: Number -> Boolean

foreign import isNaN :: Number -> Boolean

foreign import modulo :: Number -> Number -> Number

foreign import multiply :: Number -> Number -> Number

foreign import nan :: Number

foreign import negate :: Number -> Number

foreign import power :: Number -> Number -> Number

foreign import round :: Number -> Int

foreign import subtract :: Number -> Number -> Number

foreign import truncate :: Number -> Int

compare :: Number -> Number -> Ordering.Ordering
compare = compareWith Ordering.LT Ordering.EQ Ordering.GT
