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
  , create
  , listen
  , onDidSaveTextDocument
  , onInitialize
  , sendDiagnostics
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

foreign import sendDiagnostics :: Connection -> Diagnostics -> IO Unit

-- | <https://microsoft.github.io//language-server-protocol/specifications/specification-3-14/>

type ClientCapabilities = { textDocumentSync :: TextDocumentSyncOptions  }
type Diagnostic = { code :: Nullable String, message :: String, range :: Range, severity :: Nullable Int, source :: String }
type Diagnostics = { diagnostics :: Array Diagnostic, uri :: DocumentUri }
type DidSaveTextDocumentParams = { textDocument :: TextDocumentIdentifier }
type DocumentUri = String
type InitializeParams = { capabilities :: ClientCapabilities }
type Position = { character :: Int, line :: Int }
type Range = { end :: Position, start :: Position }
type SaveOptions = { includeText :: Boolean }
type TextDocumentIdentifier = { uri :: DocumentUri }
type TextDocumentSyncOptions = { save :: SaveOptions }
