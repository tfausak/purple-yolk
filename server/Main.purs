module Main ( IO, Unit, main ) where

applyBackward :: forall a b . (a -> b) -> a -> b
applyBackward f x = f x

infixr 1 applyBackward as <|

newtype Unit = Unit {}

unit :: Unit
unit = Unit {}

newtype Uri = Uri String

uriToString :: Uri -> String
uriToString (Uri string) = string

foreign import data IO :: Type -> Type

foreign import io_bind :: forall a b . IO a -> (a -> IO b) -> IO b

foreign import io_map :: forall a b . (a -> b) -> IO a -> IO b

foreign import io_pure :: forall a . a -> IO a

foreign import data Connection :: Type

foreign import connection_create :: IO Connection

foreign import connection_listen :: Connection -> IO Unit

foreign import connection_onDidSaveTextDocument
  :: Connection
  -> ({ textDocument :: { uri :: Uri, version :: Int } } -> IO Unit)
  -> IO Unit

foreign import connection_onInitialize
  :: Connection
  -> IO { capabilities :: { textDocumentSync :: { save :: Boolean } } }
  -> IO Unit

foreign import log :: String -> IO Unit

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

discard :: forall t b . HasBind t => t Unit -> (Unit -> t b) -> t b
discard = bind

main :: IO Unit
main = do
  connection <- connection_create

  connection_onDidSaveTextDocument connection \ event ->
    log (uriToString event.textDocument.uri)

  connection_onInitialize connection <| pure
    { capabilities: { textDocumentSync: { save: true } } }

  connection_listen connection
  log "Purple Yolk is up and running!"
