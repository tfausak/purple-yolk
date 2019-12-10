module Test.Main
  ( main
  ) where

import Core

import Core.Type.Date as Date
import Core.Type.List as List
import Core.Type.Mutable as Mutable
import Core.Type.Object as Object
import Core.Type.Queue as Queue

main :: IO Unit
main = do
  log "Running tests ..."
  start <- getCurrentDate

  describe "Core" do

    describe "Class" do

      describe "HasAdd" do

        describe "Array" do
          add [] [] ==> ([] :: Array Int)
          add [] [1] ==> [1]
          add [1] [2] ==> [1, 2]
          add [1, 2] [3, 4] ==> [1, 2, 3, 4]

        describe "Int" do
          add 1 2 ==> 3

        describe "List" do
          add Nil Nil ==> (Nil :: List Int)
          add Nil (1 : Nil) ==> 1 : Nil
          add (1 : Nil) Nil ==> 1 : Nil
          add (1 : Nil) (2 : Nil) ==> 1 : 2 : Nil
          add (1 : 2 : Nil) (3 : 4 : Nil) ==> 1 : 2 : 3 : 4 : Nil

        describe "Number" do
          add 1.2 3.4 ==> 4.6

        describe "Queue" do
          add Queue.empty Queue.empty ==> (Queue.empty :: Queue Int)
          add Queue.empty (Queue.fromList (1 : Nil)) ==> Queue.fromList (1 : Nil)
          add (Queue.fromList (1 : Nil)) Queue.empty ==> Queue.fromList (1 : Nil)
          add (Queue.fromList (1 : Nil)) (Queue.fromList (2 : Nil)) ==> Queue.fromList (1 : 2 : Nil)

        describe "String" do
          add "ho" "me" ==> "home"

      describe "HasApply" do

        describe "Array" do
          apply [] [] ==> ([] :: Array Int)
          apply [] [5] ==> ([] :: Array Int)
          apply [(_ * 2)] [] ==> []
          apply [(_ * 2)] [5] ==> [10]
          apply [(_ * 2)] [5, 7] ==> [10, 14]
          apply [(_ * 2), (_ * 3)] [5] ==> [10, 15]
          apply [(_ * 2), (_ * 3)] [5, 7] ==> [10, 14, 15, 21]

        describe "IO" do
          x <- apply (pure (_ * 2)) (pure 5)
          x ==> 10

        describe "List" do
          apply Nil Nil ==> (Nil :: List Int)
          apply Nil (5 : Nil) ==> (Nil :: List Int)
          apply ((_ * 2) : Nil) Nil ==> Nil
          apply ((_ * 2) : Nil) (5 : Nil) ==> 10 : Nil
          apply ((_ * 2) : Nil) (5 : 7 : Nil) ==> 10 : 14 : Nil
          apply ((_ * 2) : (_ * 3) : Nil) (5 : Nil) ==> 10 : 15 : Nil
          apply ((_ * 2) : (_ * 3) : Nil) (5 : 7 : Nil) ==> 10 : 14 : 15 : 21 : Nil

        describe "Maybe" do
          apply Nothing Nothing ==> (Nothing :: Maybe Int)
          apply Nothing (Just 5) ==> (Nothing :: Maybe Int)
          apply (Just (_ * 2)) Nothing ==> Nothing
          apply (Just (_ * 2)) (Just 5) ==> Just 10

        describe "Queue" do
          apply Queue.empty Queue.empty ==> (Queue.empty :: Queue Int)
          apply Queue.empty (Queue.fromList (5 : Nil)) ==> (Queue.empty :: Queue Int)
          apply (Queue.fromList ((_ * 2) : Nil)) Queue.empty ==> Queue.empty
          apply (Queue.fromList ((_ * 2) : Nil)) (Queue.fromList (5 : Nil)) ==> Queue.fromList (10 : Nil)
          apply (Queue.fromList ((_ * 2) : Nil)) (Queue.fromList (5 : 7 : Nil)) ==> Queue.fromList (10 : 14 : Nil)
          apply (Queue.fromList ((_ * 2) : (_ * 3) : Nil)) (Queue.fromList (5 : Nil)) ==> Queue.fromList (10 : 15 : Nil)
          apply (Queue.fromList ((_ * 2) : (_ * 3) : Nil)) (Queue.fromList (5 : 7 : Nil)) ==> Queue.fromList (10 : 14 : 15 : 21 : Nil)

      describe "HasBind" do

        describe "Array" do
          bind [] (\ _ -> []) ==> ([] :: Array Int)
          bind [5] (\ _ -> []) ==> ([] :: Array Int)
          bind [] (\ x -> [x * 2]) ==> []
          bind [5] (\ x -> [x * 2]) ==> [10]
          bind [5, 7] (\ x -> [x * 2]) ==> [10, 14]
          bind [5] (\ x -> [x * 2, x * 3]) ==> [10, 15]
          bind [5, 7] (\ x -> [x * 2, x * 3]) ==> [10, 15, 14, 21]

        describe "IO" do
          x <- bind (pure 5) (\ x -> pure (x * 2))
          x ==> 10

        describe "List" do
          bind Nil (\ _ -> Nil) ==> (Nil :: List Int)
          bind (5 : Nil) (\ _ -> Nil) ==> (Nil :: List Int)
          bind Nil (\ x -> x * 2 : Nil) ==> Nil
          bind (5 : Nil) (\ x -> x * 2 : Nil) ==> 10 : Nil
          bind (5 : 7 : Nil) (\ x -> x * 2 : Nil) ==> 10 : 14 : Nil
          bind (5 : Nil) (\ x -> x * 2 : x * 3 : Nil) ==> 10 : 15 : Nil
          bind (5 : 7 : Nil) (\ x -> x * 2 : x * 3 : Nil) ==> 10 : 15 : 14 : 21 : Nil

        describe "Maybe" do
          bind Nothing (\ _ -> Nothing) ==> (Nothing :: Maybe Int)
          bind (Just 5) (\ _ -> Nothing) ==> (Nothing :: Maybe Int)
          bind Nothing (\ x -> Just (x * 2)) ==> Nothing
          bind (Just 5) (\ x -> Just (x * 2)) ==> Just 10

        describe "Queue" do
          bind Queue.empty (\ _ -> Queue.empty) ==> (Queue.empty :: Queue Int)
          bind (Queue.fromList (5 : Nil)) (\ _ -> Queue.empty) ==> (Queue.empty :: Queue Int)
          bind Queue.empty (\ x -> Queue.fromList (x * 2 : Nil)) ==> Queue.empty
          bind (Queue.fromList (5 : Nil)) (\ x -> Queue.fromList (x * 2 : Nil)) ==> Queue.fromList (10 : Nil)
          bind (Queue.fromList (5 : 7 : Nil)) (\ x -> Queue.fromList (x * 2 : Nil)) ==> Queue.fromList (10 : 14 : Nil)
          bind (Queue.fromList (5 : Nil)) (\ x -> Queue.fromList (x * 2 : x * 3 : Nil)) ==> Queue.fromList (10 : 15 : Nil)
          bind (Queue.fromList (5 : 7 : Nil)) (\ x -> Queue.fromList (x * 2 : x * 3 : Nil)) ==> Queue.fromList (10 : 15 : 14 : 21 : Nil)

      describe "HasCompare" do

        describe "Array" do
          compare [] ([] :: Array Int) ==> EQ
          compare [] [1] ==> LT
          compare [1] [] ==> GT
          compare [1] [1] ==> EQ
          compare [1] [2] ==> LT
          compare [2] [1] ==> GT

        describe "Boolean" do
          compare false false ==> EQ
          compare false true ==> LT
          compare true false ==> GT
          compare true true ==> EQ

        describe "Char" do
          compare 'a' 'a' ==> EQ
          compare 'a' 'b' ==> LT
          compare 'b' 'a' ==> GT

        describe "Date" do
          let now = Date.fromPosix 1.0
          compare now now ==> EQ
          let later = Date.fromPosix 2.0
          compare now later ==> LT
          compare later now ==> GT

        describe "Int" do
          compare 1 1 ==> EQ
          compare 1 2 ==> LT
          compare 2 1 ==> GT

        describe "List" do
          compare Nil (Nil :: List Int) ==> EQ
          compare Nil (1 : Nil) ==> LT
          compare (1 : Nil) Nil ==> GT
          compare (1 : Nil) (1 : Nil) ==> EQ
          compare (1 : Nil) (2 : Nil) ==> LT
          compare (2 : Nil) (1 : Nil) ==> GT

        describe "Maybe" do
          compare Nothing (Nothing :: Maybe Int) ==> EQ
          compare Nothing (Just 1) ==> LT
          compare (Just 1) Nothing ==> GT
          compare (Just 1) (Just 1) ==> EQ
          compare (Just 1) (Just 2) ==> LT
          compare (Just 2) (Just 1) ==> GT

        describe "Number" do
          compare 1.1 1.1 ==> EQ
          compare 1.1 2.2 ==> LT
          compare 2.2 1.1 ==> GT

        describe "Ordering" do
          compare LT LT ==> EQ
          compare LT EQ ==> LT
          compare LT GT ==> LT
          compare EQ LT ==> GT
          compare EQ EQ ==> EQ
          compare EQ GT ==> LT
          compare GT LT ==> GT
          compare GT EQ ==> GT
          compare GT GT ==> EQ

        describe "Queue" do
          compare Queue.empty (Queue.empty :: Queue Int) ==> EQ
          compare Queue.empty (Queue.fromList (1 : Nil)) ==> LT
          compare (Queue.fromList (1 : Nil)) Queue.empty ==> GT
          compare (Queue.fromList (1 : Nil)) (Queue.fromList (1 : Nil)) ==> EQ
          compare (Queue.fromList (1 : Nil)) (Queue.fromList (2 : Nil)) ==> LT
          compare (Queue.fromList (2 : Nil)) (Queue.fromList (1 : Nil)) ==> GT

        describe "String" do
          compare "" "" ==> EQ
          compare "" "a" ==> LT
          compare "a" "" ==> GT
          compare "a" "a" ==> EQ
          compare "a" "b" ==> LT
          compare "b" "a" ==> GT

        describe "Tuple" do
          compare (Tuple 1 1) (Tuple 1 1) ==> EQ
          compare (Tuple 1 1) (Tuple 1 2) ==> LT
          compare (Tuple 1 1) (Tuple 2 1) ==> LT
          compare (Tuple 1 2) (Tuple 1 1) ==> GT
          compare (Tuple 2 1) (Tuple 1 1) ==> GT

      describe "HasDivide" do

        describe "Int" do
          divide 4 2 ==> 2
          divide 5 2 ==> 2

        describe "Number" do
          divide 4.0 2.0 ==> 2.0
          divide 5.0 2.0 ==> 2.5

      describe "HasInspect" do

        describe "Array" do
          inspect ([] :: Array Int) ==> "[]"
          inspect [1] ==> "[1]"
          inspect [1, 2] ==> "[1, 2]"

        describe "Boolean" do
          inspect false ==> "false"
          inspect true ==> "true"

        describe "Char" do
          inspect 'a' ==> "'a'"
          inspect '\n' ==> "'\\xa'"

        describe "Date" do
          inspect (Date.fromPosix 1.0) ==> "fromPosix (1.0)"

        describe "Int" do
          inspect 1 ==> "1"

        describe "List" do
          inspect (Nil :: List Int) ==> "Nil"
          inspect (1 : Nil) ==> "Cons (1) (Nil)"
          inspect (1 : 2 : Nil) ==> "Cons (1) (Cons (2) (Nil))"

        describe "Maybe" do
          inspect (Nothing :: Maybe Int) ==> "Nothing"
          inspect (Just 1) ==> "Just (1)"

        describe "Number" do
          inspect 1.0 ==> "1.0"
          inspect 1.2 ==> "1.2"
          inspect nan ==> "nan"
          inspect infinity ==> "infinity"
          inspect (-infinity) ==> "-infinity"

        describe "Object" do
          inspect (Object.empty :: Object Int) ==> "fromList (Nil)"
          inspect (Object.fromList (Tuple "a" 5 : Nil)) ==> "fromList (Cons (Tuple (\"a\") (5)) (Nil))"
          inspect (Object.fromList (Tuple "a" 5 : Tuple "b" 7 : Nil)) ==> "fromList (Cons (Tuple (\"a\") (5)) (Cons (Tuple (\"b\") (7)) (Nil)))"

        describe "Ordering" do
          inspect LT ==> "LT"
          inspect EQ ==> "EQ"
          inspect GT ==> "GT"

        describe "Queue" do
          inspect (Queue.empty :: Queue Int) ==> "fromList (Nil)"
          inspect (Queue.fromList (1 : Nil)) ==> "fromList (Cons (1) (Nil))"
          inspect (Queue.fromList (1 : 2 : Nil)) ==> "fromList (Cons (1) (Cons (2) (Nil)))"

        describe "Record" do
          inspect {} ==> "{}"
          inspect { a: 1 } ==> "{ a: 1 }"
          inspect { a: 1, b: 2.3 } ==> "{ a: 1, b: 2.3 }"

        describe "String" do
          inspect "" ==> "\"\""
          inspect "a" ==> "\"a\""
          inspect "ab" ==> "\"ab\""
          inspect "\n" ==> "\"\\xa\""

        describe "Tuple" do
          inspect (Tuple 1 2) ==> "Tuple (1) (2)"

        describe "Unit" do
          inspect unit ==> "unit"

      describe "HasMap" do

        describe "Array" do
          map (_ * 2) [] ==> ([] :: Array Int)
          map (_ * 2) [5] ==> [10]
          map (_ * 2) [5, 7] ==> [10, 14]

        describe "IO" do
          x <- map (_ * 2) (pure 5)
          x ==> 10

        describe "List" do
          map (_ * 2) Nil ==> Nil
          map (_ * 2) (5 : Nil) ==> 10 : Nil
          map (_ * 2) (5 : 7 : Nil) ==> 10 : 14 : Nil

        describe "Maybe" do
          map (_ * 2) Nothing ==> Nothing
          map (_ * 2) (Just 5) ==> Just 10

        describe "Object" do
          Object.toList (map (_ * 2) Object.empty) ==> Nil
          Object.toList (map (_ * 2) (Object.fromList (Tuple "a" 5 : Nil))) ==> Tuple "a" 10 : Nil
          Object.toList (map (_ * 2) (Object.fromList (Tuple "a" 5 : Tuple "b" 7 : Nil))) ==> Tuple "a" 10 : Tuple "b" 14 : Nil

        describe "Queue" do
          map (_ * 2) Queue.empty ==> Queue.empty
          map (_ * 2) (Queue.fromList (5 : Nil)) ==> Queue.fromList (10 : Nil)
          map (_ * 2) (Queue.fromList (5 : 7 : Nil)) ==> Queue.fromList (10 : 14 : Nil)

      describe "HasMultiply" do

        describe "Int" do
          multiply 2 3 ==> 6

        describe "Number" do
          multiply 10.0 0.25 ==> 2.5

      describe "HasNegate" do

        describe "Int" do
          negate 1 ==> -1

        describe "Number" do
          negate 1.2 ==> -1.2

      describe "HasPure" do

        describe "Array" do
          pure 1 ==> [1]

        describe "IO" do
          x <- pure 1
          x ==> 1

        describe "List" do
          pure 1 ==> 1 : Nil

        describe "Maybe" do
          pure 1 ==> Just 1

        describe "Queue" do
          pure 1 ==> Queue.fromList (1 : Nil)

      describe "HasSubtract" do

        describe "Int" do
          subtract 1 2 ==> -1

        describe "Number" do
          subtract 1.0 0.25 ==> 0.75

    describe "Operator" do
      (round >> inspect) 1.2 ==> "1"
      (inspect << round) 1.2 ==> "1"
      2 * 3 ==> 6
      6 / 2 ==> 3
      1 + 2 ==> 3
      3 - 2 ==> 1
      1 : Nil ==> Cons 1 Nil
      1 == 1 ==> true
      1 >= 1 ==> true
      1 > 1 ==> false
      1 <= 1 ==> true
      1 < 1 ==> false
      1 != 1 ==> false
      true && true ==> true
      true || true ==> true
      true |> not ==> false
      not <| true ==> false

    describe "Primitive" do

      describe "Boolean" do

        describe "and" do
          and false false ==> false
          and false true ==> false
          and true false ==> false
          and true true ==> true

        describe "not" do
          not false ==> true
          not true ==> false

        describe "or" do
          or false false ==> false
          or false true ==> true
          or true false ==> true
          or true true ==> true

      describe "Function" do

        describe "compose" do
          compose (_ + "?") (_ + "!") "What" ==> "What?!"

        describe "constant" do
          constant 1 2.3 ==> 1

        describe "identity" do
          identity 1 ==> 1

      describe "Int" do

        describe "toNumber" do
          toNumber 1 ==> 1.0

      describe "Number" do

        describe "isFinite" do
          isFinite 1.2 ==> true
          isFinite nan ==> false
          isFinite infinity ==> false
          isFinite (-infinity) ==> false

        describe "isNaN" do
          isNaN 1.2 ==> false
          isNaN nan ==> true
          isNaN infinity ==> false
          isNaN (-infinity) ==> false

        describe "round" do
          round 1.0 ==> 1
          round 1.4 ==> 1
          round 1.5 ==> 2
          round 1.6 ==> 2
          round 2.5 ==> 3

      describe "String" do

        describe "join" do
          join "" [] ==> ""
          join "" ["ab"] ==> "ab"
          join "" ["ho", "me"] ==> "home"
          join " + " ["12", "34"] ==> "12 + 34"

        describe "split" do
          split " " "" ==> [""]
          split " " "ab" ==> ["ab"]
          split " " "hello world" ==> ["hello", "world"]
          split " " " a  b " ==> ["", "a", "", "b", ""]

    describe "Type" do

      describe "Date" do

        describe "format" do
          Date.format (Date.fromPosix 0.0) ==> "1970-01-01T00:00:00.000Z"

      describe "IO" do

        describe "unsafely" do
          unsafely (pure 1) ==> 1

      describe "List" do

        describe "drop" do
          List.drop (-1) Nil ==> (Nil :: List Int)
          List.drop 0 Nil ==> (Nil :: List Int)
          List.drop 1 Nil ==> (Nil :: List Int)
          List.drop (-1) (1 : Nil) ==> 1 : Nil
          List.drop 0 (1 : Nil) ==> 1 : Nil
          List.drop 1 (1 : Nil) ==> Nil
          List.drop 2 (1 : Nil) ==> Nil
          List.drop (-1) (1 : 2 : Nil) ==> 1 : 2 : Nil
          List.drop 0 (1 : 2 : Nil) ==> 1 : 2 : Nil
          List.drop 1 (1 : 2 : Nil) ==> 2 : Nil
          List.drop 2 (1 : 2 : Nil) ==> Nil
          List.drop 3 (1 : 2 : Nil) ==> Nil

        describe "fromArray" do
          List.fromArray [] ==> (Nil :: List Int)
          List.fromArray [1] ==> 1 : Nil
          List.fromArray [1, 2] ==> 1 : 2 : Nil

        describe "length" do
          List.length Nil ==> 0
          List.length (0 : Nil) ==> 1
          List.length (0 : 0 : Nil) ==> 2

        describe "replicate" do
          List.replicate 0 'a' ==> Nil
          List.replicate (-1) 'a' ==> Nil
          List.replicate 1 'a' ==> 'a' : Nil
          List.replicate 2 'a' ==> 'a' : 'a' : Nil

        describe "reverse" do
          List.reverse Nil ==> (Nil :: List Int)
          List.reverse (1 : Nil) ==> 1 : Nil
          List.reverse (1 : 2 : Nil) ==> 2 : 1 : Nil

        describe "toArray" do
          List.toArray Nil ==> ([] :: Array Int)
          List.toArray (1 : Nil) ==> [1]
          List.toArray (1 : 2 : Nil) ==> [1, 2]

      describe "Maybe" do

        describe "withDefault" do
          withDefault 1 Nothing ==> 1
          withDefault 1 (Just 2) ==> 2

      describe "Mutable" do
        m <- Mutable.new 5
        x <- Mutable.get m
        x ==> 5
        Mutable.set m 7
        y <- Mutable.get m
        y ==> 7
        Mutable.modify m (_ * 2)
        z <- Mutable.get m
        z ==> 14

      describe "Object" do

        describe "get" do
          Object.get "a" (Object.fromList Nil) ==> (Nothing :: Maybe Int)
          Object.get "a" (Object.fromList (Tuple "a" 1 : Nil)) ==> Just 1
          Object.get "b" (Object.fromList (Tuple "a" 1 : Nil)) ==> Nothing
          Object.get "a" (Object.fromList (Tuple "b" 1 : Nil)) ==> Nothing

        describe "set" do
          Object.toList (Object.set "a" 1 Object.empty) ==> Tuple "a" 1 : Nil
          Object.toList (Object.set "a" 2 (Object.fromList (Tuple "a" 1 : Nil))) ==> Tuple "a" 2 : Nil
          Object.toList (Object.set "b" 2 (Object.fromList (Tuple "a" 1 : Nil))) ==> Tuple "b" 2 : Tuple "a" 1 : Nil

      describe "Queue" do

        describe "dequeue" do
          Queue.dequeue (Queue.empty :: Queue Int) ==> Nothing
          Queue.dequeue (Queue.fromList (1 : Nil)) ==> Just (Tuple 1 Queue.empty)
          Queue.dequeue (Queue.fromList (1 : 2 : Nil)) ==> Just (Tuple 1 (Queue.fromList (2 : Nil)))
          Queue.dequeue (Queue.enqueue 1 Queue.empty) ==> Just (Tuple 1 Queue.empty)
          Queue.dequeue (Queue.enqueue 2 (Queue.enqueue 1 Queue.empty)) ==> Just (Tuple 1 (Queue.fromList (2 : Nil)))

        describe "enqueue" do
          Queue.enqueue 1 Queue.empty ==> Queue.fromList (1 : Nil)
          Queue.enqueue 2 (Queue.enqueue 1 Queue.empty) ==> Queue.fromList (1 : 2 : Nil)

      describe "Tuple" do

        describe "curry" do
          curry (\ (Tuple x y) -> x + y) "ho" "me" ==> "home"

        describe "first" do
          first (Tuple 1 2.3) ==> 1

        describe "second" do
          second (Tuple 1 2.3) ==> 2.3

        describe "swap" do
          swap (Tuple 1 2.3) ==> Tuple 2.3 1

        describe "uncurry" do
          uncurry add (Tuple "ho" "me") ==> "home"

  end <- getCurrentDate
  let elapsed = round (1000.0 * (Date.toPosix end - Date.toPosix start))
  log (join " " ["All tests passed in", inspect elapsed, "milliseconds."])

context :: Mutable (List String)
context = unsafely (Mutable.new Nil)

describe :: String -> IO Unit -> IO Unit
describe label action = do
  Mutable.modify context (label : _)
  action
  Mutable.modify context (List.drop 1)

assertEqual :: forall a . HasCompare a => HasInspect a => a -> a -> IO Unit
assertEqual actual expected = do
  labels <- Mutable.get context
  if actual == expected
    then pure unit
    else throw (join ""
      [ join "." (List.toArray (List.reverse labels))
      , ": expected "
      , inspect expected
      , " but got "
      , inspect actual
      ])

infix 0 assertEqual as ==>
