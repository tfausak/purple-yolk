module Core.Type.Either
  ( Either(Left, Right)
  ) where

data Either a b
  = Left a
  | Right b
