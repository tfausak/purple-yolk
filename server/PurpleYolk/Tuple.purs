module PurpleYolk.Tuple
  ( Tuple(Tuple)
  , first
  , second
  ) where

data Tuple a b = Tuple a b

first :: forall a b . Tuple a b -> a
first (Tuple x _) = x

second :: forall a b . Tuple a b -> b
second (Tuple _ y) = y
