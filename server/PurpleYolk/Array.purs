module PurpleYolk.Array
  ( filter
  , length
  , map
  ) where

foreign import filter :: forall a . (a -> Boolean) -> Array a -> Array a

foreign import length :: forall a . Array a -> Int

foreign import map :: forall a b . (a -> b) -> Array a -> Array b
