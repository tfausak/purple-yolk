module Core.Primitive.String
  ( add
  , compare
  , indexOf
  , inspect
  , join
  , split
  ) where

import Core.Type.Ordering as Ordering

foreign import add :: String -> String -> String

foreign import compareWith
  :: Ordering.Ordering
  -> Ordering.Ordering
  -> Ordering.Ordering
  -> String
  -> String
  -> Ordering.Ordering

foreign import indexOf :: String -> String -> Int

foreign import inspect :: String -> String

foreign import join :: String -> Array String -> String

foreign import split :: String -> String -> Array String

compare :: String -> String -> Ordering.Ordering
compare = compareWith Ordering.LT Ordering.EQ Ordering.GT
