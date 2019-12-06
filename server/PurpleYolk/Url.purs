module PurpleYolk.Url
  ( Url
  , fromPath
  , fromString
  , toPath
  , toString
  ) where

import PurpleYolk.Path as Path

foreign import fromPath :: Path.Path -> Url

foreign import toPath :: Url -> Path.Path

newtype Url = Url String

fromString :: String -> Url
fromString = Url

toString :: Url -> String
toString (Url string) = string
