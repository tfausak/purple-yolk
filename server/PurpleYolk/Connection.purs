module PurpleYolk.Connection
  ( ClientCapabilities
  , Connection
  , InitializeParams
  , SaveOptions
  , TextDocumentSyncOptions
  , create
  , listen
  , onInitialize
  ) where

import Core

foreign import data Connection :: Type

foreign import create :: IO Connection

foreign import listen :: Connection -> IO Unit

foreign import onInitialize
  :: Connection
  -> IO InitializeParams
  -> IO Unit

-- | <https://microsoft.github.io//language-server-protocol/specifications/specification-3-14/>

type InitializeParams = { capabilities :: ClientCapabilities }

type ClientCapabilities = { textDocumentSync :: TextDocumentSyncOptions  }

type TextDocumentSyncOptions = { save :: SaveOptions }

type SaveOptions = { includeText :: Boolean }
