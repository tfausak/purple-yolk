module PurpleYolk.Connection
  ( Connection
  , Diagnostic
  , Position
  , Range
  , create
  , listen
  , onDidSaveTextDocument
  , onInitialize
  , sendDiagnostics
  ) where

import PurpleYolk.IO as IO
import PurpleYolk.Nullable as Nullable
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

foreign import sendDiagnostics
  :: Connection
  -> { diagnostics :: Array Diagnostic, uri :: Url.Url }
  -> IO.IO Unit.Unit

-- https://microsoft.github.io//language-server-protocol/specifications/specification-3-14/#diagnostic
type Diagnostic =
  { code :: Nullable.Nullable String
  , message :: String
  , range :: Range
  , severity :: Nullable.Nullable Int
  , source :: String
  }

-- https://microsoft.github.io//language-server-protocol/specifications/specification-3-14/#range
type Range =
  { end :: Position
  , start :: Position
  }

-- https://microsoft.github.io//language-server-protocol/specifications/specification-3-14/#position
type Position =
  { character :: Int
  , line :: Int
  }
