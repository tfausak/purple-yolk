module PurpleYolk.Exception
  ( throw
  ) where

import PurpleYolk.IO as IO

foreign import throw :: forall a . String -> IO.IO a
