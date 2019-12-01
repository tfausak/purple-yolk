module PurpleYolk.String
  ( append
  , concat
  ) where

foreign import append :: String -> String -> String

foreign import concat :: Array String -> String
