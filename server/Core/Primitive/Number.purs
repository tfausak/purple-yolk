module Core.Primitive.Number
  ( add
  , compare
  , divide
  , infinity
  , inspect
  , isFinite
  , isNaN
  , multiply
  , nan
  , negate
  , round
  , subtract
  ) where

import Core.Type.Ordering as Ordering

foreign import add :: Number -> Number -> Number

foreign import compareWith
  :: Ordering.Ordering
  -> Ordering.Ordering
  -> Ordering.Ordering
  -> Number
  -> Number
  -> Ordering.Ordering

foreign import divide :: Number -> Number -> Number

foreign import infinity :: Number

foreign import inspect :: Number -> String

foreign import isFinite :: Number -> Boolean

foreign import isNaN :: Number -> Boolean

foreign import multiply :: Number -> Number -> Number

foreign import nan :: Number

foreign import negate :: Number -> Number

foreign import round :: Number -> Int

foreign import subtract :: Number -> Number -> Number

compare :: Number -> Number -> Ordering.Ordering
compare = compareWith Ordering.LT Ordering.EQ Ordering.GT
