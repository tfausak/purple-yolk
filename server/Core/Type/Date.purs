module Core.Type.Date
  ( Date
  , compare
  , fromPosix
  , getCurrentDate
  , inspect
  , toPosix
  ) where

import Core.Primitive.Number as Number
import Core.Primitive.String as String
import Core.Type.IO as IO
import Core.Type.Ordering as Ordering

foreign import data Date :: Type

foreign import compareWith
  :: Ordering.Ordering
  -> Ordering.Ordering
  -> Ordering.Ordering
  -> Date
  -> Date
  -> Ordering.Ordering

foreign import fromPosix :: Number -> Date

foreign import getCurrentDate :: IO.IO Date

foreign import toPosix :: Date -> Number

compare :: Date -> Date -> Ordering.Ordering
compare = compareWith Ordering.LT Ordering.EQ Ordering.GT

inspect :: Date -> String
inspect x = String.join "" ["fromPosix (", Number.inspect (toPosix x), ")"]
