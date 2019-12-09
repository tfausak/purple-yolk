module Core.Type.Unit
  ( Unit
  , inspect
  , unit
  ) where

newtype Unit = Unit {}

inspect :: Unit -> String
inspect _ = "unit"

unit :: Unit
unit = Unit {}
