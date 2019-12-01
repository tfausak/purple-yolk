module PurpleYolk.Unit
  ( Unit
  , unit
  ) where

import PurpleYolk.Inspect as Inspect

newtype Unit = Unit {}

instance unitHasInspect :: Inspect.HasInspect Unit where
  inspect _ = "unit"

unit :: Unit
unit = Unit {}
