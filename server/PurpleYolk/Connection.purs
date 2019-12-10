module PurpleYolk.Connection
  ( ClientCapabilities
  , Connection
  , DidSaveTextDocumentParams
  , DocumentUri
  , InitializeParams
  , SaveOptions
  , TextDocumentIdentifier
  , TextDocumentSyncOptions
  , create
  , listen
  , onDidSaveTextDocument
  , onInitialize
  ) where

import Core

foreign import data Connection :: Type

foreign import create :: IO Connection

foreign import listen :: Connection -> IO Unit

foreign import onDidSaveTextDocument
  :: Connection
  -> (DidSaveTextDocumentParams -> IO Unit)
  -> IO Unit

foreign import onInitialize :: Connection -> IO InitializeParams -> IO Unit

-- | <https://microsoft.github.io//language-server-protocol/specifications/specification-3-14/>

type ClientCapabilities = { textDocumentSync :: TextDocumentSyncOptions  }
type DidSaveTextDocumentParams = { textDocument :: TextDocumentIdentifier }
type DocumentUri = String
type InitializeParams = { capabilities :: ClientCapabilities }
type SaveOptions = { includeText :: Boolean }
type TextDocumentIdentifier = { uri :: DocumentUri }
type TextDocumentSyncOptions = { save :: SaveOptions }
