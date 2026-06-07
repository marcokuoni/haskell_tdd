module Todo (
    Status (..),
    Task (..),
    TodoList,
    addTask,
    completeTask,
    removeTask,
    pendingTasks,
    completedTasks,
) where

-- | A task can either still be Pending or already Done.
data Status = Pending | Done deriving (Eq, Show)

-- | A single task: a unique numeric id, a textual description, and a status.
data Task = Task
    { taskId :: Int
    , description :: String
    , status :: Status
    }
    deriving (Eq, Show)

-- | A todo list is just a list of tasks.
type TodoList = [Task]

{- | Add a new task to the list with status Pending.
  The new id must be (maximum existing id) + 1, or 1 if the list is empty.
  The new task should be appended at the end.
-}
addTask :: String -> TodoList -> TodoList
addTask desc tasks = undefined

{- | Mark the task with the given id as Done.
  If no task has that id, return the list unchanged.
-}
completeTask :: Int -> TodoList -> TodoList
completeTask tid tasks = undefined

{- | Remove the task with the given id.
  If no task has that id, return the list unchanged.
-}
removeTask :: Int -> TodoList -> TodoList
removeTask tid tasks = undefined

-- | All tasks whose status is Pending (order preserved).
pendingTasks :: TodoList -> [Task]
pendingTasks tasks = undefined

-- | All tasks whose status is Done (order preserved).
completedTasks :: TodoList -> [Task]
completedTasks tasks = undefined
