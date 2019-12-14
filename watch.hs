#! /usr/bin/env stack
-- stack --resolver lts-14.0 script
{-# OPTIONS_GHC -Weverything -Wno-implicit-prelude -Wno-unsafe #-}
module Main ( main ) where
import qualified Control.Concurrent.STM as Stm
import qualified Control.Exception as Exception
import qualified Control.Monad as Monad
import qualified Data.List as List
import qualified Data.Time as Time
import qualified GHC.Clock as Clock
import qualified Say
import qualified System.Directory as Directory
import qualified System.FilePath as FilePath
import qualified System.FSNotify as Notify
import qualified System.Process as Process
import qualified Text.Printf as Printf

main :: IO ()
main = Notify.withManagerConf watchConfig $ \ watchManager -> do
  var <- Stm.newTMVarIO True

  Monad.void $ Notify.watchTree
    watchManager
    "."
    actionPredicate
    (actionWith var)

  Monad.forever $ do
    reinstall <- Stm.atomically $ Stm.takeTMVar var
    Monad.when reinstall $ sh "docker-compose" ["run", "node", "npm", "install"]

    oldEntries <- Directory.listDirectory "."
    mapM_ Directory.removeFile $ filter isVsix oldEntries

    sh "docker-compose" ["run", "node", "npm", "run", "vsce", "package"]

    newEntries <- Directory.listDirectory "."
    case filter isVsix newEntries of
      [vsix] -> sh "code" ["--install-extension", vsix]
      _ -> pure ()

watchConfig :: Notify.WatchConfig
watchConfig = Notify.defaultConfig
  { Notify.confDebounce = Notify.Debounce 0.1
  }

actionPredicate :: Notify.ActionPredicate
actionPredicate event = not $ any
  (\ match -> match $ Notify.eventPath event)
  [ List.isInfixOf "/.git/"
  , List.isInfixOf "/dist/"
  , List.isInfixOf "/node_modules/"
  , List.isInfixOf "/output/"
  , hasFileName "package-lock.json"
  , isVsix
  ]

actionWith :: Stm.TMVar Bool -> Notify.Action
actionWith var event = do
  Monad.void
    . Stm.atomically
    . Stm.tryPutTMVar var
    . hasFileName "package.json"
    $ Notify.eventPath event

  Say.sayString $ Printf.printf
    "%s %c %s"
    (Time.formatTime
      Time.defaultTimeLocale
      "%Y-%m-%dT%H:%M:%S%3QZ"
      (Notify.eventTime event))
    (case event of
      Notify.Added _ _ _ -> '+'
      Notify.Modified _ _ _ -> '%'
      Notify.Removed _ _ _ -> '-'
      Notify.Unknown _ _ _ -> '?')
    (Notify.eventPath event)

isVsix :: FilePath -> Bool
isVsix = FilePath.isExtensionOf "vsix"

hasFileName :: String -> FilePath -> Bool
hasFileName fileName filePath = FilePath.takeFileName filePath == fileName

sh :: String -> [String] -> IO ()
sh command arguments = do
  let cmd = mconcat ["`", command, " ", unwords arguments, "`"]
  Say.sayString $ Printf.printf "Running %s ..." cmd
  before <- Clock.getMonotonicTime
  result <- Exception.try $ Process.callProcess command arguments
  case result of
    Right () -> do
      after <- Clock.getMonotonicTime
      let elapsed = after - before
      Say.sayString $ Printf.printf "Finished %s in %.3f seconds." cmd elapsed
    Left someException -> Say.sayErrString $ Exception.displayException
      (someException :: Exception.SomeException)
