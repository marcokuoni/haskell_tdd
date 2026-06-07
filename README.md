# Todo List — TDD Exercise

You'll build a small Todo list module in Haskell, test-driven, using three
layers of tests: **acceptance tests**, **unit tests**, and **QuickCheck
properties**.

## The module

`src/Todo.hs` defines the API you must implement:

```haskell
data Status   = Pending | Done
data Task     = Task { taskId :: Int, description :: String, status :: Status }
type TodoList = [Task]

addTask        :: String -> TodoList -> TodoList
completeTask   :: Int    -> TodoList -> TodoList
removeTask     :: Int    -> TodoList -> TodoList
pendingTasks   :: TodoList -> [Task]
completedTasks :: TodoList -> [Task]
```

Rules:

- New tasks always start as `Pending`.
- New ids are `max(existing ids) + 1`, or `1` if the list is empty.
- New tasks are appended at the end.
- `completeTask` and `removeTask` with an unknown id are **no-ops**
  (return the list unchanged).
- `pendingTasks` / `completedTasks` preserve the order of the input list.

## Running the tests

Enter the Nix dev shell first:

```sh
nix develop
```

Then, in the shell, just run:

```sh
make test       # one-shot
make watch      # re-run on every save (needs the `full` dev shell)
make repl       # GHCi with the test module loaded
```

Tests live in `test/Spec.hs`. They start out failing because every function
in `src/Todo.hs` is `undefined`. Your job is to make them green.

## What to do (in order)

1. **Read the existing tests.** Get a feel for what's expected.
2. **Make them pass.** Replace each `undefined` in `src/Todo.hs` with a real
   implementation. Work one function at a time — red → green → next.
3. **Write your own tests.** There are three `-- TODO (student)` markers in
   `test/Spec.hs`. You must add **at least**:
   - one extra acceptance test
   - one extra unit test
   - one extra QuickCheck property
4. **Make sure everything still passes.**

---

## What each layer is for

- **Acceptance tests** describe a _user-visible workflow_. They use several
  functions together and check observable outcomes — never internal helpers.
- **Unit tests** pin down one function at a time, including edge cases
  (empty list, unknown id, …).
- **Properties** state things that must hold for _every_ input.
  Example: completing a task never changes how many tasks there are.

## Reference solution

`solution/Todo.hs` contains a worked solution. Don't peek until you've
finished — or you've spent 20 minutes stuck on the same function.

To check your work against it, just overwrite `src/Todo.hs` with
`solution/Todo.hs` and re-run the tests.
