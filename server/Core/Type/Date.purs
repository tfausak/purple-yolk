module Core.Type.Date
  ( Date
  , now
  ) where

import Core.Type.IO as IO

foreign import data Date :: Type

foreign import now :: IO.IO Date
