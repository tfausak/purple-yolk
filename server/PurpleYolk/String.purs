module PurpleYolk.String
  ( append
  , concat
  , indexOf
  , join
  , length
  , null
  , split
  , substring
  , trim
  ) where

import PurpleYolk.Int as Int
import PurpleYolk.Maybe as Maybe

foreign import append :: String -> String -> String

foreign import indexOfWith
  :: Maybe.Maybe Int
  -> (Int -> Maybe.Maybe Int)
  -> String
  -> String
  -> Maybe.Maybe Int

foreign import join :: String -> Array String -> String

foreign import length :: String -> Int

foreign import split :: String -> String -> Array String

foreign import substring :: Int -> Int -> String -> String

foreign import trim :: String -> String

concat :: Array String -> String
concat = join ""

indexOf :: String -> String -> Maybe.Maybe Int
indexOf = indexOfWith Maybe.Nothing Maybe.Just

null :: String -> Boolean
null string = Int.equal (length string) 0
