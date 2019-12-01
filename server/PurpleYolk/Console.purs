module PurpleYolk.Console
  ( log
  ) where

import PurpleYolk.IO as IO
import PurpleYolk.Unit as Unit

foreign import log :: String -> IO.IO Unit.Unit
