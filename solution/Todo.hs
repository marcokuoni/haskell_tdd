module Todo
  ( Status(..)
  , Task(..)
  , TodoList
  , addTask
  , completeTask
  , removeTask
  , pendingTasks
  , completedTasks
  ) where

data Status = Pending | Done deriving (Eq, Show)

data Task = Task
  { taskId      :: Int
  , description :: String
  , status      :: Status
  } deriving (Eq, Show)

type TodoList = [Task]

-- | Add a new task with status Pending. New id = max existing id + 1, or 1
--   if the list is empty. Appended at the end.
addTask :: String -> TodoList -> TodoList
addTask desc tasks = tasks ++ [Task newId desc Pending]
  where
    newId = if null tasks then 1 else maximum (map taskId tasks) + 1

-- | Mark every task with this id as Done. (Normally there's only one.)
--   If no task matches, the list is unchanged.
completeTask :: Int -> TodoList -> TodoList
completeTask tid = map markIfMatch
  where
    markIfMatch t
      | taskId t == tid = t { status = Done }
      | otherwise       = t

-- | Drop every task with this id. If none matches, the list is unchanged.
removeTask :: Int -> TodoList -> TodoList
removeTask tid = filter ((/= tid) . taskId)

pendingTasks :: TodoList -> [Task]
pendingTasks = filter ((== Pending) . status)

completedTasks :: TodoList -> [Task]
completedTasks = filter ((== Done) . status)
