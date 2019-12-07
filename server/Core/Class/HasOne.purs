module Core.Class.HasOne
  ( class HasOne
  , one
  ) where

class HasOne a where
  one :: a

instance _Int_HasOne :: HasOne Int where
  one = 1

instance _Number_HasOne :: HasOne Number where
  one = 1.0
