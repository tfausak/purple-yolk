module Core.Primitive.String
  ( add
  , compare
  , concat
  , join
  , inspect
  ) where

import Core.Type.Ordering as Ordering

foreign import add :: String -> String -> String

foreign import compareWith :: Ordering.Ordering -> Ordering.Ordering -> Ordering.Ordering -> String -> String -> Ordering.Ordering

foreign import join :: String -> Array String -> String

foreign import inspect :: String -> String

compare :: String -> String -> Ordering.Ordering
compare = compareWith Ordering.LT Ordering.EQ Ordering.GT

concat :: Array String -> String
concat = join ""
