module Core.Type.Mutable
  ( Mutable
  , get
  , new
  , set
  ) where

import Core.Type.IO as IO
import Core.Type.Unit as Unit

foreign import data Mutable :: Type -> Type

foreign import get :: forall a . Mutable a -> IO.IO a

foreign import new :: forall a . a -> IO.IO (Mutable a)

foreign import set :: forall a . Mutable a -> a -> IO.IO Unit.Unit
