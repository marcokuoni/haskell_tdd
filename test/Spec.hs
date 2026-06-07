module Main where

import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.QuickCheck
import Todo

main :: IO ()
main = defaultMain $ testGroup "Todo"
  [ acceptanceTests
  , unitTests
  , properties
  ]

----------------------------------------------------------------------
-- ACCEPTANCE TESTS
--
-- These describe how a *user* would use the module end-to-end.
-- They go through several functions in a realistic scenario.
----------------------------------------------------------------------
acceptanceTests :: TestTree
acceptanceTests = testGroup "Acceptance tests"
  [ testCase "a user adds three tasks, completes one, and sees the right split" $ do
      let l0 = []
          l1 = addTask "Buy milk"     l0
          l2 = addTask "Walk dog"     l1
          l3 = addTask "Write report" l2
          l4 = completeTask 2 l3      -- complete "Walk dog"

      length l4                              @?= 3
      length (pendingTasks   l4)             @?= 2
      length (completedTasks l4)             @?= 1
      map description (pendingTasks   l4)    @?= ["Buy milk", "Write report"]
      map description (completedTasks l4)    @?= ["Walk dog"]

  -- TODO (student): write at least one more acceptance scenario.
  -- Suggested scenario:
  --   * add three tasks
  --   * remove the second one
  --   * complete the third one
  --   * check that pendingTasks and completedTasks return what you expect,
  --     and that the remaining ids are still what you'd expect.
  ]

----------------------------------------------------------------------
-- UNIT TESTS
--
-- One function at a time, including edge cases.
----------------------------------------------------------------------
unitTests :: TestTree
unitTests = testGroup "Unit tests"
  [ testCase "addTask on an empty list creates a task with id 1" $
      addTask "first" [] @?= [Task 1 "first" Pending]

  , testCase "addTask uses max existing id + 1" $
      let ts     = [Task 5 "a" Pending, Task 2 "b" Done]
          result = addTask "c" ts
      in last result @?= Task 6 "c" Pending

  , testCase "addTask appends at the end" $
      let ts = [Task 1 "a" Pending]
      in addTask "b" ts @?= [Task 1 "a" Pending, Task 2 "b" Pending]

  , testCase "completeTask flips the matching task to Done" $
      completeTask 1 [Task 1 "a" Pending] @?= [Task 1 "a" Done]

  , testCase "completeTask with an unknown id is a no-op" $
      let ts = [Task 1 "a" Pending]
      in completeTask 99 ts @?= ts

  , testCase "removeTask drops the matching task" $
      removeTask 1 [Task 1 "a" Pending, Task 2 "b" Pending]
        @?= [Task 2 "b" Pending]

  , testCase "removeTask with an unknown id is a no-op" $
      let ts = [Task 1 "a" Pending]
      in removeTask 99 ts @?= ts

  , testCase "pendingTasks keeps only Pending, in order" $
      pendingTasks [ Task 1 "a" Pending
                   , Task 2 "b" Done
                   , Task 3 "c" Pending
                   ]
        @?= [Task 1 "a" Pending, Task 3 "c" Pending]

  , testCase "completedTasks keeps only Done, in order" $
      completedTasks [ Task 1 "a" Pending
                     , Task 2 "b" Done
                     , Task 3 "c" Done
                     ]
        @?= [Task 2 "b" Done, Task 3 "c" Done]

  -- TODO (student): write at least one more unit test.
  -- Ideas:
  --   * removeTask on an empty list
  --   * addTask onto a list with non-contiguous ids, e.g. [Task 10, Task 3]
  --   * completeTask on a task that is already Done
  ]

----------------------------------------------------------------------
-- QUICKCHECK PROPERTIES
--
-- Things that should be true for *any* input.
----------------------------------------------------------------------

instance Arbitrary Status where
  arbitrary = elements [Pending, Done]

instance Arbitrary Task where
  arbitrary = Task <$> arbitrary <*> arbitrary <*> arbitrary

properties :: TestTree
properties = testGroup "QuickCheck properties"
  [ testProperty "pendingTasks and completedTasks partition the list" $
      \ts ->
        length (pendingTasks ts) + length (completedTasks ts)
          == length (ts :: TodoList)

  , testProperty "addTask grows the list by exactly one" $
      \d ts ->
        length (addTask d ts) == length (ts :: TodoList) + 1

  , testProperty "completeTask preserves the length of the list" $
      \i ts ->
        length (completeTask i ts) == length (ts :: TodoList)

  -- TODO (student): write at least one more property.
  -- Ideas:
  --   * removeTask either leaves the length the same or decreases it
  --     (by exactly the count of tasks with that id).
  --   * After completeTask i ts, no task with id i has status Pending.
  --   * pendingTasks (completeTask i ts) is a subset of pendingTasks ts
  --     (the size is <= the original).
  --   * addTask then removeTask of the new id is a no-op,
  --     *given* the input has unique ids (see hint below).
  --
  -- Hint: if you need a list with unique ids, you can build one yourself
  -- from a list of descriptions:
  --
  --   buildUnique :: [String] -> TodoList
  --   buildUnique = foldl (flip addTask) []
  ]
