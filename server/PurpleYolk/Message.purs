module PurpleYolk.Message
  ( Message
  , fromJson
  ) where

import PurpleYolk.Maybe as Maybe

foreign import fromJsonWith
  :: forall a
  . Maybe.Maybe a
  -> (a -> Maybe.Maybe a)
  -> String
  -> Maybe.Maybe Message

type Message =
  { doc :: String
  , reason :: Maybe.Maybe String
  , severity :: String
  , span ::
    { endCol :: Int
    , endLine :: Int
    , file :: String
    , startCol :: Int
    , startLine :: Int
    }
  }

fromJson :: String -> Maybe.Maybe Message
fromJson = fromJsonWith Maybe.Nothing Maybe.Just
