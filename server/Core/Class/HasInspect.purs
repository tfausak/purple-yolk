module Core.Class.HasInspect
  ( class HasInspect
  , inspect
  -- records
  , class InspectRecordFields
  , inspectRecordFields
  , RowListProxy
  ) where

import Core.Primitive.Array as Array
import Core.Primitive.Boolean as Boolean
import Core.Primitive.Char as Char
import Core.Primitive.Int as Int
import Core.Primitive.Number as Number
import Core.Primitive.Record as Record
import Core.Primitive.String as String
import Core.Type.Date as Date
import Core.Type.List as List
import Core.Type.Maybe as Maybe
import Core.Type.Object as Object
import Core.Type.Ordering as Ordering
import Core.Type.Queue as Queue
import Core.Type.Tuple as Tuple
import Core.Type.Unit as Unit
import Data.Symbol as Symbol
import Prim.RowList as RowList

class HasInspect a where
  inspect :: a -> String

instance _Array_HasInspect :: HasInspect a => HasInspect (Array a) where
  inspect = Array.inspect inspect

instance _Boolean_HasInspect :: HasInspect Boolean where
  inspect = Boolean.inspect

instance _Char_HasInspect :: HasInspect Char where
  inspect = Char.inspect

instance _Date_HasInspect :: HasInspect Date.Date where
  inspect = Date.inspect

instance _Int_HasInspect :: HasInspect Int where
  inspect = Int.inspect

instance _List_HasInspect :: HasInspect a => HasInspect (List.List a) where
  inspect = List.inspect inspect

instance _Maybe_HasInspect :: HasInspect a => HasInspect (Maybe.Maybe a) where
  inspect = Maybe.inspect inspect

instance _Number_HasInspect :: HasInspect Number where
  inspect = Number.inspect

instance _Object_HasInspect :: HasInspect a => HasInspect (Object.Object a) where
  inspect = Object.inspect inspect

instance _Ordering_HasInspect :: HasInspect Ordering.Ordering where
  inspect = Ordering.inspect

instance _Queue_HasInspect :: HasInspect a => HasInspect (Queue.Queue a) where
  inspect = Queue.inspect inspect

instance _String_HasInspect :: HasInspect String where
  inspect = String.inspect

instance _Tuple_HasInspect :: (HasInspect a, HasInspect b) => HasInspect (Tuple.Tuple a b) where
  inspect = Tuple.inspect inspect inspect

instance _Unit_HasInspect :: HasInspect Unit.Unit where
  inspect = Unit.inspect

-- records

instance _Record_HasInspect:: (RowList.RowToList r l, InspectRecordFields r l) => HasInspect (Record r) where
  inspect record =
    case inspectRecordFields record (RowListProxy :: RowListProxy l) of
      [] -> "{}"
      fields -> String.join ""
        [ "{ "
        , String.join ", "
          (Array.map (\ (Tuple.Tuple k v) -> String.join ": " [k, v]) fields)
        , " }"
        ]

class InspectRecordFields r l where
  inspectRecordFields :: Record r -> RowListProxy l -> Array (Tuple.Tuple String String)

instance _Nil_InspectRecordFields :: InspectRecordFields r RowList.Nil where
  inspectRecordFields _ _ = []

instance _Cons_InspectRecordFields :: (Symbol.IsSymbol k, HasInspect v, InspectRecordFields r l) => InspectRecordFields r (RowList.Cons k v l) where
  inspectRecordFields record _ =
    let k = Symbol.fromSymbol (Symbol.SymbolProxy :: Symbol.SymbolProxy k)
    in Array.add
      [Tuple.Tuple k (inspect (Record.unsafeGet k record :: v))]
      (inspectRecordFields record (RowListProxy :: RowListProxy l))

data RowListProxy (rowList :: RowList.RowList) = RowListProxy
