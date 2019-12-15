module Core.Class.HasBind
  ( class HasBind
  , bind
  , discard
  ) where

import Core.Primitive.Array as Array
import Core.Type.IO as IO
import Core.Type.List as List
import Core.Type.Maybe as Maybe
import Core.Type.Nullable as Nullable
import Core.Type.Queue as Queue
import Core.Type.Unit as Unit

class HasBind t where
  bind :: forall a b . t a -> (a -> t b) -> t b

instance _Array_HasBind :: HasBind Array where
  bind = Array.bind

instance _IO_HasBind :: HasBind IO.IO where
  bind = IO.bind

instance _List_HasBind :: HasBind List.List where
  bind = List.bind

instance _Maybe_HasBind :: HasBind Maybe.Maybe where
  bind = Maybe.bind

instance _Nullable_HasBind :: HasBind Nullable.Nullable where
  bind = Nullable.bind

instance _Queue_HasBind :: HasBind Queue.Queue where
  bind = Queue.bind

discard :: forall t a . HasBind t => t Unit.Unit -> (Unit.Unit -> t a) -> t a
discard = bind
