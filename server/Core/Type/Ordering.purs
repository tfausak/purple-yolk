module Core.Type.Ordering
  ( Ordering(LT, EQ, GT)
  , bottom
  , fromInt
  , toInt
  , top
  ) where

import Core.Type.Maybe as Maybe

data Ordering
  = LT
  | EQ
  | GT

bottom :: Ordering
bottom = LT

fromInt :: Int -> Maybe.Maybe Ordering
fromInt x = case x of
  0 -> Maybe.Just LT
  1 -> Maybe.Just EQ
  2 -> Maybe.Just GT
  _ -> Maybe.Nothing

toInt :: Ordering -> Int
toInt x = case x of
  LT -> 0
  EQ -> 1
  GT -> 2

top :: Ordering
top = GT
