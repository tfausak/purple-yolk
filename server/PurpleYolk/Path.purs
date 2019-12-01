module PurpleYolk.Path
  ( Path
  , fromString
  , toString
  ) where

import PurpleYolk.Inspect as Inspect
import PurpleYolk.String as String

newtype Path = Path String

instance pathHasInspect :: Inspect.HasInspect Path where
  inspect path = String.concat ["Path (", Inspect.inspect (toString path), ")"]

fromString :: String -> Path
fromString = Path

toString :: Path -> String
toString (Path string) = string
