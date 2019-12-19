module PurpleYolk.Connection
  ( ClientCapabilities
  , Connection
  , Diagnostic
  , Diagnostics
  , DidSaveTextDocumentParams
  , DocumentUri
  , InitializeParams
  , Position
  , Range
  , SaveOptions
  , TextDocumentIdentifier
  , TextDocumentSyncOptions
  , client
  , create
  , listen
  , onDidSaveTextDocument
  , onInitialize
  , onInitialized
  , sendDiagnostics
  , workspace
  ) where

import Core

import PurpleYolk.Client as Client
import PurpleYolk.Workspace as Workspace

foreign import data Connection :: Type

foreign import client :: Connection -> Client.Client

foreign import create :: IO Connection

foreign import listen :: Connection -> IO Unit

foreign import onDidSaveTextDocument
  :: Connection
  -> (DidSaveTextDocumentParams -> IO Unit)
  -> IO Unit

foreign import onInitialize :: Connection -> IO InitializeParams -> IO Unit

foreign import onInitialized :: Connection -> IO Unit -> IO Unit

foreign import sendDiagnostics :: Connection -> Diagnostics -> IO Unit

foreign import workspace :: Connection -> Workspace.Workspace

-- | <https://microsoft.github.io//language-server-protocol/specifications/specification-3-14/>

type ClientCapabilities =
  { textDocumentSync :: TextDocumentSyncOptions
  }

type Diagnostic =
  { code :: Nullable String
  , message :: String
  , range :: Range
  , severity :: Nullable Int
  , source :: String
  }

type Diagnostics =
  { diagnostics :: Array Diagnostic
  , uri :: DocumentUri
  }

type DidSaveTextDocumentParams =
  { textDocument :: TextDocumentIdentifier
  }

type DocumentUri = String

type InitializeParams =
  { capabilities :: ClientCapabilities
  }

type Position =
  { character :: Int
  , line :: Int
  }

type Range =
  { end :: Position
  , start :: Position
  }

type SaveOptions =
  { includeText :: Boolean
  }

type TextDocumentIdentifier =
  { uri :: DocumentUri
  }

type TextDocumentSyncOptions =
  { save :: SaveOptions
  }
