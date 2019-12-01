module PurpleYolk.Connection
  ( Connection
  , create
  , listen
  , onDidSaveTextDocument
  , onInitialize
  ) where

import PurpleYolk.IO as IO
import PurpleYolk.Unit as Unit
import PurpleYolk.Url as Url

foreign import data Connection :: Type

foreign import create :: IO.IO Connection

foreign import listen :: Connection -> IO.IO Unit.Unit

foreign import onDidSaveTextDocument
  :: Connection
  -> ({ textDocument :: { uri :: Url.Url, version :: Int } } -> IO.IO Unit.Unit)
  -> IO.IO Unit.Unit

foreign import onInitialize
  :: Connection
  -> IO.IO { capabilities :: { textDocumentSync :: { save :: Boolean } } }
  -> IO.IO Unit.Unit
