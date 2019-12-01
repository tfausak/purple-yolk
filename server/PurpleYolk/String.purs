module PurpleYolk.String
  ( append
  , concat
  , join
  ) where

foreign import append :: String -> String -> String

foreign import join :: String -> Array String -> String

concat :: Array String -> String
concat = join ""
