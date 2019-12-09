-- | The name of this module and the type class are special. They are solved
-- | automatically by the PureScript compiler.
module Data.Symbol
  ( class IsSymbol
  , SymbolProxy(SymbolProxy)
  , fromSymbol
  ) where

class IsSymbol (symbol :: Symbol) where
  fromSymbol :: SymbolProxy symbol -> String

data SymbolProxy (symbol :: Symbol) = SymbolProxy
