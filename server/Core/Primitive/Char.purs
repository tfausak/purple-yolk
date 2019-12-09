module Core.Primitive.Char
  ( compare
  , inspect
  ) where

import Core.Type.Ordering as Ordering

foreign import compareWith
  :: Ordering.Ordering
  -> Ordering.Ordering
  -> Ordering.Ordering
  -> Char
  -> Char
  -> Ordering.Ordering

foreign import inspect :: Char -> String

compare :: Char -> Char -> Ordering.Ordering
compare = compareWith Ordering.LT Ordering.EQ Ordering.GT
