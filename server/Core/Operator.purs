module Core.Operator
  ( (>>)
  , (<<)
  , (^)
  , (*)
  , (/)
  , (%)
  , (:)
  , (+)
  , (-)
  , (==)
  , (!=)
  , (>)
  , (>=)
  , (<)
  , (<=)
  , (&&)
  , (||)
  , (|>)
  , (<|)
  ) where

import Core.Class.HasAdd (add)
import Core.Class.HasCompare (eq, ge, gt, le, lt, ne)
import Core.Class.HasDivide (divide)
import Core.Class.HasModulo (modulo)
import Core.Class.HasMultiply (multiply)
import Core.Class.HasPower (power)
import Core.Class.HasSubtract (subtract)
import Core.Primitive.Boolean (and, or)
import Core.Primitive.Function (backward, compose, esopmoc, forward)
import Core.Type.List (List(Cons))

infixl 8 compose  as >>
infixr 8 esopmoc  as <<
infixr 7 power    as ^
infixl 6 multiply as *
infixl 6 divide   as /
infixl 6 modulo   as %
infixr 5 Cons     as :
infixl 5 add      as +
infixl 5 subtract as -
infix  4 eq       as ==
infix  4 ne       as !=
infix  4 gt       as >
infix  4 ge       as >=
infix  4 lt       as <
infix  4 le       as <=
infixr 3 and      as &&
infixr 2 or       as ||
infixl 1 forward  as |>
infixr 1 backward as <|
