module Core.Type.Ordering
  ( Ordering(EQ, GT, LT)
  , compare
  , inspect
  ) where

data Ordering
  = LT
  | EQ
  | GT

compare :: Ordering -> Ordering -> Ordering
compare x y = case x, y of
  LT, LT -> EQ
  LT, EQ -> LT
  LT, GT -> LT
  EQ, LT -> GT
  EQ, EQ -> EQ
  EQ, GT -> LT
  GT, LT -> GT
  GT, EQ -> GT
  GT, GT -> EQ

inspect :: Ordering -> String
inspect x = case x of
  LT -> "LT"
  EQ -> "EQ"
  GT -> "GT"
