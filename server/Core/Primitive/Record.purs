module Core.Primitive.Record
  ( unsafeGet
  ) where

foreign import unsafeGet :: forall r a . String -> Record r -> a
