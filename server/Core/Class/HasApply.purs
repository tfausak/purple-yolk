module Core.Class.HasApply
  ( class HasApply
  , apply
  , ignore
  ) where

import Core.Class.HasPure as HasPure
import Core.Type.IO as IO
import Core.Type.List as List
import Core.Type.Unit as Unit

class HasApply t where
  apply :: forall a b . t (a -> b) -> t a -> t b

instance _Array_HasApply :: HasApply Array where
  apply fs xs = List.toArray (apply (List.fromArray fs) (List.fromArray xs))

instance _IO_HasApply :: HasApply IO.IO where
  apply = IO.apply

instance _List_HasApply :: HasApply List.List where
  apply fs xs = case fs of
    List.Nil -> List.Nil
    List.Cons f gs -> List.add (List.map f xs) (apply gs xs)

ignore :: forall t a . HasApply t => HasPure.HasPure t => t a -> t Unit.Unit
ignore = apply (HasPure.pure \ _ -> Unit.unit)
