module Core.Primitive.Int
  ( add
  , compare
  , divide
  , inspect
  , multiply
  , negate
  , subtract
  , toNumber
  ) where

import Core.Type.Ordering as Ordering

foreign import add :: Int -> Int -> Int

foreign import compareWith
  :: Ordering.Ordering
  -> Ordering.Ordering
  -> Ordering.Ordering
  -> Int
  -> Int
  -> Ordering.Ordering

foreign import divide :: Int -> Int -> Int

foreign import inspect :: Int -> String

foreign import multiply :: Int -> Int -> Int

foreign import negate :: Int -> Int

foreign import subtract :: Int -> Int -> Int

foreign import toNumber :: Int -> Number

compare :: Int -> Int -> Ordering.Ordering
compare = compareWith Ordering.LT Ordering.EQ Ordering.GT
