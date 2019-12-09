module Core.Operator
  ( (>>)
  , (<<)
  , (*)
  , (/)
  , (+)
  , (-)
  , (:)
  , (==)
  , (>=)
  , (>)
  , (<=)
  , (<)
  , (!=)
  , (&&)
  , (||)
  , (|>)
  , (<|)
  ) where

import Core.Class.HasAdd (add)
import Core.Class.HasCompare (eq, ge, gt, le, lt, ne)
import Core.Class.HasDivide (divide)
import Core.Class.HasMultiply (multiply)
import Core.Class.HasSubtract (subtract)
import Core.Primitive.Boolean (and, or)
import Core.Primitive.Function (apply, compose, esopmoc, ylppa)
import Core.Type.List (List(Cons))

infixl 8 compose  as >>
infixr 8 esopmoc  as <<
infixl 7 multiply as *
infixl 7 divide   as /
infixl 6 add      as +
infixl 6 subtract as -
infixr 6 Cons     as :
infix  4 eq       as ==
infix  4 ge       as >=
infix  4 gt       as >
infix  4 le       as <=
infix  4 lt       as <
infix  4 ne       as !=
infixr 3 and      as &&
infixr 2 or       as ||
infixl 1 apply    as |>
infixr 1 ylppa    as <|
