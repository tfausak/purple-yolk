module Core.Primitive.Array
  ( add
  , filter
  , map
  , reduce
  ) where

foreign import add :: forall a . Array a -> Array a -> Array a

foreign import filter :: forall a . (a -> Boolean) -> Array a -> Array a

foreign import map :: forall a b . (a -> b) -> Array a -> Array b

foreign import reduce :: forall a b . (b -> a -> b) -> b -> Array a -> b
