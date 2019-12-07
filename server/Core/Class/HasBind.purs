module Core.Class.HasBind
  ( class HasBind
  , bind
  , discard
  ) where

import Core.Type.IO as IO
import Core.Type.List as List
import Core.Type.Unit as Unit

class HasBind t where
  bind :: forall a b . t a -> (a -> t b) -> t b

instance _Array_HasBind :: HasBind Array where
  bind xs f = List.toArray (bind (List.fromArray xs) (\ x -> List.fromArray (f x)))

instance _IO_HasBind :: HasBind IO.IO where
  bind = IO.bind

instance _List_HasBind :: HasBind List.List where
  bind xs f = case xs of
    List.Nil -> List.Nil
    List.Cons x ys -> List.add (f x) (bind ys f)

discard :: forall t a . HasBind t => t Unit.Unit -> (Unit.Unit -> t a) -> t a
discard = bind
