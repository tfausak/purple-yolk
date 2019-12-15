module PurpleYolk.Job
  ( Finished
  , Job
  , Queued
  , Started
  , Unqueued
  , finish
  , queue
  , start
  , unqueued
  ) where

import Core

type Job queuedAt startedAt finishedAt =
  { command :: String
  , finishedAt :: finishedAt
  , onFinish :: IO Unit
  , onOutput :: String -> IO Unit
  , queuedAt :: queuedAt
  , startedAt :: startedAt
  }

type Unqueued = Job Unit Unit Unit

type Queued = Job Date Unit Unit

type Started = Job Date Date Unit

type Finished = Job Date Date Date

unqueued :: Unqueued
unqueued =
  { command: ""
  , finishedAt: unit
  , onFinish: pure unit
  , onOutput: \ _ -> pure unit
  , queuedAt: unit
  , startedAt: unit
  }

queue :: Unqueued -> IO Queued
queue job = do
  now <- getCurrentDate
  pure job { queuedAt = now }

start :: Queued -> IO Started
start job = do
  now <- getCurrentDate
  pure job { startedAt = now }

finish :: Started -> IO Finished
finish job = do
  now <- getCurrentDate
  pure job { finishedAt = now }
