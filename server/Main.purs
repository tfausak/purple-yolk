module Main ( IO, main ) where

foreign import data IO :: Type -> Type

foreign import io_bind :: forall a b . IO a -> (a -> IO b) -> IO b

foreign import io_map :: forall a b . (a -> b) -> IO a -> IO b

foreign import io_pure :: forall a . a -> IO a

foreign import data Connection :: Type

foreign import connection_create :: IO Connection

foreign import connection_listen :: Connection -> IO {}

foreign import log :: String -> IO {}

class HasMap t where
  map :: forall a b . (a -> b) -> t a -> t b

instance ioHasMap :: HasMap IO where
  map = io_map

class HasPure t where
  pure :: forall a . a -> t a

instance ioHasPure :: HasPure IO where
  pure = io_pure

class HasBind t where
  bind :: forall a b . t a -> (a -> t b) -> t b

instance ioHasBind :: HasBind IO where
  bind = io_bind

discard :: forall t b . HasBind t => t {} -> ({} -> t b) -> t b
discard = bind

main :: IO {}
main = do
  connection <- connection_create
  connection_listen connection
  log "Hello from PureScript!"
