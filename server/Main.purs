module Main ( IO, Unit, main ) where

applyBackward :: forall a b . (a -> b) -> a -> b
applyBackward f x = f x

infixr 1 applyBackward as <|

newtype Unit = Unit {}

unit :: Unit
unit = Unit {}

newtype Uri = Uri String

uriToString :: Uri -> String
uriToString (Uri string) = string

newtype Path = Path String

pathToString :: Path -> String
pathToString (Path string) = string

foreign import uriToPath :: Uri -> Path

foreign import intToString :: Int -> String

foreign import string_append :: String -> String -> String

foreign import data IO :: Type -> Type

foreign import io_bind :: forall a b . IO a -> (a -> IO b) -> IO b

foreign import io_map :: forall a b . (a -> b) -> IO a -> IO b

foreign import io_pure :: forall a . a -> IO a

foreign import data Connection :: Type

foreign import connection_create :: IO Connection

foreign import connection_listen :: Connection -> IO Unit

foreign import connection_onDidSaveTextDocument
  :: Connection
  -> ({ textDocument :: { uri :: Uri, version :: Int } } -> IO Unit)
  -> IO Unit

foreign import connection_onInitialize
  :: Connection
  -> IO { capabilities :: { textDocumentSync :: { save :: Boolean } } }
  -> IO Unit

foreign import log :: String -> IO Unit

foreign import throw :: forall a . String -> IO a

foreign import data ChildProcess :: Type

foreign import childProcess_onClose
  :: ChildProcess
  -> (Int -> IO Unit)
  -> IO Unit

foreign import childProcess_onStderr
  :: ChildProcess
  -> (String -> IO Unit)
  -> IO Unit

foreign import childProcess_onStdout
  :: ChildProcess
  -> (String -> IO Unit)
  -> IO Unit

foreign import childProcess_spawn :: String -> Array String -> IO ChildProcess

foreign import childProcess_writeStdin :: ChildProcess -> String -> IO Unit

class HasMap t where
  map :: forall a b . (a -> b) -> t a -> t b

instance ioHasMap :: HasMap IO where
  map = io_map

class HasPure t where
  pure :: forall a . a -> t a

instance ioHasPure :: HasPure IO where
  pure = io_pure

class HasBind t where
  bind :: forall a b . t a -> (a -> t b) -> t b

instance ioHasBind :: HasBind IO where
  bind = io_bind

discard :: forall t b . HasBind t => t Unit -> (Unit -> t b) -> t b
discard = bind

class HasEmpty t where
  empty :: t

instance stringHasEmpty :: HasEmpty String where
  empty = ""

class HasAppend t where
  append :: t -> t -> t

infixr 6 append as <>

instance stringHasAppend :: HasAppend String where
  append = string_append

main :: IO Unit
main = do
  ghci <- childProcess_spawn "stack"
    -- Separate from GHC, Stack tries to colorize its messages. We don't try to
    -- parse Stack's output, so it doesn't really matter. But it's annoying to
    -- see the ANSI escape codes in the debug output.
    [ "--color=never"
    -- Explicitly setting the terminal width avoids a warning about `stty`.
    , "--terminal-width=0"
    , "exec"
    , "--"
    , "ghci"
    -- This one is critical. Rather than trying to parse GHC's human-readable
    -- output, we can get it to print out JSON instead. Note that the
    -- messages themselves are still human readable. It's the metadata that
    -- gets turned into structured JSON.
    , "-ddump-json"
    -- Deferring type errors turns them into warnings, which allows more
    -- warnings to be reported when there are type errors.
    , "-fdefer-type-errors"
    -- We're not interested in actually building anything, just type
    -- checking. This has the nice side effect of making things faster.
    , "-fno-code"
    -- Using multiple cores should be faster. Might need to actually
    -- benchmark this, and maybe expose it as an option.
    , "-j"
    ]

  childProcess_onStderr ghci \ chunk ->
    log <| "ghci stderr: " <> chunk

  childProcess_onStdout ghci \ chunk ->
    log <| "ghci stdout: " <> chunk

  childProcess_onClose ghci \ code ->
    log <| "GHCi closed with code " <> intToString code

  childProcess_writeStdin ghci ":set prompt \"{- purple-yolk -}\""
  childProcess_writeStdin ghci ":set +c"

  connection <- connection_create

  connection_onInitialize connection <| pure
    { capabilities: { textDocumentSync: { save: true } } }

  connection_onDidSaveTextDocument connection \ event -> do
    let uri = event.textDocument.uri
    log (uriToString uri)
    let path = uriToPath event.textDocument.uri
    let string = pathToString path
    -- TODO: this is outputting `_URI { ... }` which doesn't seem right
    log string
    childProcess_writeStdin ghci <| ":load " <> string

  connection_listen connection
  log "Purple Yolk is up and running!"
