module PurpleYolk.Array
  ( length
  , map
  ) where

foreign import length :: forall a . Array a -> Int

foreign import map :: forall a b . (a -> b) -> Array a -> Array b
