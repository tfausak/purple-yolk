module PurpleYolk.Int
  ( add
  , equal
  , subtract
  , toString
  ) where

foreign import add :: Int -> Int -> Int

foreign import equal :: Int -> Int -> Boolean

foreign import subtract :: Int -> Int -> Int

foreign import toString :: Int -> String
