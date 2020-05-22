module PurpleYolk.Message
  ( Message
  , Span
  , fromJson
  , getCompilingFile
  , key
  ) where

import Core

import Core.Primitive.String as String
import Core.Type.Nullable as Nullable
import PurpleYolk.Path as Path

foreign import fromJsonWith
  :: Maybe Message
  -> (Message -> Maybe Message)
  -> String
  -> Maybe Message

foreign import getCompilingFile :: Message -> Nullable Path.Path

type Message =
  { doc :: String
  , reason :: Nullable String
  , severity :: String
  , span :: Nullable Span
  }

type Span =
  { endCol :: Int
  , endLine :: Int
  , file :: Path.Path
  , startCol :: Int
  , startLine :: Int
  }

fromJson :: String -> Maybe Message
fromJson = fromJsonWith Nothing Just

key :: Message -> String
key message = String.join " "
  [ case Nullable.toMaybe message.span of
    Nothing -> "unknown"
    Just span -> String.join " "
      [ Path.toString span.file
      , inspect span.startLine
      , inspect span.startCol
      , inspect span.endLine
      , inspect span.endCol
      ]
  , withDefault "unknown" (Nullable.toMaybe message.reason)
  ]
