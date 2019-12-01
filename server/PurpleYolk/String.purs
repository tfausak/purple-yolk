module PurpleYolk.String
  ( append
  , concat
  , inspect
  ) where

foreign import append :: String -> String -> String

foreign import concat :: Array String -> String

foreign import inspect :: String -> String
