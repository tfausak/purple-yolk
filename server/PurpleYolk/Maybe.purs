module PurpleYolk.Maybe
  ( Maybe(Nothing, Just)
  ) where

import PurpleYolk.Inspect as Inspect
import PurpleYolk.String as String

data Maybe a
  = Nothing
  | Just a

instance maybeHasInspect :: Inspect.HasInspect a => Inspect.HasInspect (Maybe a) where
  inspect m = case m of
    Nothing -> "Nothing"
    Just x -> String.concat ["Just (", Inspect.inspect x, ")"]
