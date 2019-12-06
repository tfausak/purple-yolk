module PurpleYolk.Nullable
  ( Nullable
  , notNull
  , null
  ) where

foreign import data Nullable :: Type -> Type

foreign import notNull :: forall a . a -> Nullable a

foreign import null :: forall a . Nullable a
