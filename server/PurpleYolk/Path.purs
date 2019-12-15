module PurpleYolk.Path
  ( Path
  , fromString
  , toString
  ) where

newtype Path = Path String

fromString :: String -> Path
fromString = Path

toString :: Path -> String
toString (Path x) = x
