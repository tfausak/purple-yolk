module PurpleYolk.Job
  ( Job
  , finish
  , queue
  , start
  , unqueued
  ) where

import Core

type Job =
  { command :: String
  , finishedAt :: Maybe Date
  , onFinish :: IO Unit
  , onOutput :: String -> IO Unit
  , onQueue :: IO Unit
  , onStart :: IO Unit
  , queuedAt :: Maybe Date
  , startedAt :: Maybe Date
  }

unqueued :: Job
unqueued =
  { command: ""
  , finishedAt: Nothing
  , onFinish: pure unit
  , onOutput: \ _ -> pure unit
  , onQueue: pure unit
  , onStart: pure unit
  , queuedAt: Nothing
  , startedAt: Nothing
  }

queue :: Job -> IO Job
queue job = do
  now <- getCurrentDate
  job.onQueue
  pure job { queuedAt = Just now }

start :: Job -> IO Job
start job = do
  now <- getCurrentDate
  job.onStart
  pure job { startedAt = Just now }

finish :: Job -> IO Job
finish job = do
  now <- getCurrentDate
  job.onFinish
  pure job { finishedAt = Just now }
