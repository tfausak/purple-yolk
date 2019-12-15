module PurpleYolk.Url
  ( Url
  , fromPath
  , fromString
  , toPath
  , toString
  ) where

import PurpleYolk.Path as Path

foreign import data Url :: Type

foreign import fromPath :: Path.Path -> Url

foreign import fromString :: String -> Url

foreign import toPath :: Url -> Path.Path

foreign import toString :: Url -> String
