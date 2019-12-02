module PurpleYolk.Int
  ( add
  , equal
  ) where

foreign import add :: Int -> Int -> Int

foreign import equal :: Int -> Int -> Boolean
