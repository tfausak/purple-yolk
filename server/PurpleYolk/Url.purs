module PurpleYolk.Url
  ( Url
  , fromString
  , toPath
  , toString
  ) where

import PurpleYolk.Inspect as Inspect
import PurpleYolk.Path as Path
import PurpleYolk.String as String

foreign import toPath :: Url -> Path.Path

newtype Url = Url String

instance urlHasInspect :: Inspect.HasInspect Url where
  inspect url = String.concat ["Url (", Inspect.inspect (toString url), ")"]

fromString :: String -> Url
fromString = Url

toString :: Url -> String
toString (Url string) = string
