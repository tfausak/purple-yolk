module PurpleYolk.Mutable
  ( Mutable
  , modify
  , new
  , read
  ) where

import PurpleYolk.IO as IO
import PurpleYolk.Unit as Unit

foreign import data Mutable :: Type -> Type

foreign import modify :: forall a . Mutable a -> (a -> a) -> IO.IO Unit.Unit

foreign import new :: forall a . a -> IO.IO (Mutable a)

foreign import read :: forall a . Mutable a -> IO.IO a
