module PurpleYolk.Array
  ( map
  ) where

foreign import map :: forall a b . (a -> b) -> Array a -> Array b
