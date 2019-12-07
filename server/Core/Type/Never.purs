module Core.Type.Never
  ( Never
  , never
  ) where

import Core.Type.IO as IO

data Never

never :: forall a . Never -> a
never _ = IO.error "never"
