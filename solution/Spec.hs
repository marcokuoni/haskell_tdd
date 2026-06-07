module Main where

import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.QuickCheck
import Data.List (nub, sort)
import Todo

main :: IO ()
main = defaultMain $ testGroup "Todo"
  [ acceptanceTests
  , unitTests
  , properties
  ]

----------------------------------------------------------------------
-- ACCEPTANCE TESTS
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

  , testCase "a user adds three tasks, removes the second, completes the third" $ do
      let l0 = []
          l1 = addTask "Buy milk"     l0   -- id 1
          l2 = addTask "Walk dog"     l1   -- id 2
          l3 = addTask "Write report" l2   -- id 3
          l4 = removeTask   2 l3
          l5 = completeTask 3 l4

      length l5                              @?= 2
      map taskId      l5                     @?= [1, 3]
      map description (pendingTasks   l5)    @?= ["Buy milk"]
      map description (completedTasks l5)    @?= ["Write report"]

  , testCase "after removing the highest id, the next addTask gets an even higher id" $ do
      -- This catches a common bug where new ids are computed from the
      -- *length* of the list instead of from the max existing id.
      let l1 = addTask "a" []        -- id 1
          l2 = addTask "b" l1        -- id 2
          l3 = addTask "c" l2        -- id 3
          l4 = removeTask 3 l3       -- now only ids [1, 2]
          l5 = addTask "d" l4        -- must get id 3, NOT id 2 again

      map taskId l5 @?= [1, 2, 3]
      last l5      @?= Task 3 "d" Pending
  ]

----------------------------------------------------------------------
-- UNIT TESTS
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

  , testCase "addTask handles non-contiguous ids" $
      let ts = [Task 10 "a" Pending, Task 3 "b" Done]
      in last (addTask "c" ts) @?= Task 11 "c" Pending

  , testCase "completeTask flips the matching task to Done" $
      completeTask 1 [Task 1 "a" Pending] @?= [Task 1 "a" Done]

  , testCase "completeTask with an unknown id is a no-op" $
      let ts = [Task 1 "a" Pending]
      in completeTask 99 ts @?= ts

  , testCase "completeTask on an already-Done task leaves it Done" $
      completeTask 1 [Task 1 "a" Done] @?= [Task 1 "a" Done]

  , testCase "removeTask drops the matching task" $
      removeTask 1 [Task 1 "a" Pending, Task 2 "b" Pending]
        @?= [Task 2 "b" Pending]

  , testCase "removeTask with an unknown id is a no-op" $
      let ts = [Task 1 "a" Pending]
      in removeTask 99 ts @?= ts

  , testCase "removeTask on an empty list is a no-op" $
      removeTask 1 [] @?= []

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

  , testCase "pendingTasks of an empty list is empty" $
      pendingTasks [] @?= []

  , testCase "completedTasks of an empty list is empty" $
      completedTasks [] @?= []
  ]

----------------------------------------------------------------------
-- QUICKCHECK PROPERTIES
----------------------------------------------------------------------

instance Arbitrary Status where
  arbitrary = elements [Pending, Done]

instance Arbitrary Task where
  arbitrary = Task <$> arbitrary <*> arbitrary <*> arbitrary

-- | Build a TodoList with guaranteed-unique ids by going through addTask.
--   Useful for properties that rely on id uniqueness.
buildUnique :: [String] -> TodoList
buildUnique = foldl (flip addTask) []

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

  , testProperty "removeTask never grows the list, and shrinks it by the count of matching ids" $
      \i ts ->
        let matching = length (filter ((== i) . taskId) ts)
        in length (removeTask i ts) == length (ts :: TodoList) - matching

  , testProperty "after completeTask i, no task with id i is Pending" $
      \i ts ->
        all (\t -> taskId t /= i || status t == Done)
            (completeTask i (ts :: TodoList))

  , testProperty "completeTask never decreases the number of completed tasks" $
      \i ts ->
        length (completedTasks (completeTask i ts))
          >= length (completedTasks (ts :: TodoList))

  , testProperty "on lists with unique ids, addTask then removeTask of that id is a no-op" $
      \descs ->
        let ts    = buildUnique descs
            newL  = addTask "new" ts
            -- new id is max existing + 1 (or 1 if empty)
            newId = if null ts then 1 else maximum (map taskId ts) + 1
        in removeTask newId newL == ts

  , testProperty "buildUnique produces lists with unique ids" $
      \descs ->
        let ids = map taskId (buildUnique descs)
        in sort ids == sort (nub ids)
  ]
