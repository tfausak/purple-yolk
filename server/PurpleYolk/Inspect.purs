module PurpleYolk.Inspect
  ( class HasInspect
  , inspect
  ) where

import PurpleYolk.Array as Array
import PurpleYolk.String as String

foreign import unsafeInspect :: forall a . a -> String

class HasInspect a where
  inspect :: a -> String

instance arrayHasInspect :: HasInspect a => HasInspect (Array a) where
  inspect array = String.concat
    ["[", String.join ", " (Array.map inspect array), "]"]

instance booleanHasInspect :: HasInspect Boolean where
  inspect = unsafeInspect

instance charHasInspect :: HasInspect Char where
  inspect = unsafeInspect

instance intHasInspect :: HasInspect Int where
  inspect = unsafeInspect

instance numberHasInspect :: HasInspect Number where
  inspect = unsafeInspect

-- TODO: recordHasInspect

instance stringHasInspect :: HasInspect String where
  inspect = unsafeInspect
