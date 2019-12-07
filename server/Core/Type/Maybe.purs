module Core.Type.Maybe
  ( Maybe(Nothing, Just)
  , withDefault
  ) where

data Maybe a
  = Nothing
  | Just a

withDefault :: forall a . a -> Maybe a -> a
withDefault x m = case m of
  Nothing -> x
  Just y -> y
