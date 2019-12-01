module PurpleYolk.Tuple
  ( Tuple(Tuple)
  , first
  , second
  ) where

import PurpleYolk.Inspect as Inspect
import PurpleYolk.String as String

data Tuple a b = Tuple a b

instance tupleHasInspect :: (Inspect.HasInspect a, Inspect.HasInspect b) => Inspect.HasInspect (Tuple a b) where
  inspect tuple = String.concat
    [ "Tuple ("
    , Inspect.inspect (first tuple)
    , ") ("
    , Inspect.inspect (second tuple)
    , ")"
    ]

first :: forall a b . Tuple a b -> a
first (Tuple x _) = x

second :: forall a b . Tuple a b -> b
second (Tuple _ y) = y
