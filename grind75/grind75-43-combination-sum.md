# Grind 75 — 43. Combination Sum

## Problem

Given an array of distinct positive integers `candidates` and a positive integer `target`, return every unique combination whose values sum to `target`.

Each candidate may be selected an unlimited number of times.

Combinations may be returned in any order.

Example:

```text
candidates = [2, 3, 6, 7]
target = 7

answer = [[2, 2, 3], [7]]
```

---

## 1. Why this is a backtracking problem

At each step, we must choose among several candidates. A choice may lead to:

- an exact solution;
- a sum that is still too small, requiring more choices;
- a sum that exceeds the target, requiring us to retreat.

This creates a decision tree. Backtracking systematically explores it:

```text
choose
  ↓
explore
  ↓
undo
  ↓
try the next choice
```

The partial combination is a mutable path through the decision tree.

---

## 2. The duplicate-combination problem

Without a rule, the recursion could generate both:

```text
[2, 2, 3]
[2, 3, 2]
[3, 2, 2]
```

These are different orders of the same combination.

To prevent this, give each recursive call a `startIndex`. It may choose only from that index onward.

This keeps every generated combination in candidate-index order and prevents earlier candidates from being revisited after moving forward.

---

## 3. Recommended JavaScript solution

```javascript
function combinationSum(candidates, target) {
  const combinations = [];
  const current = [];

  function backtrack(startIndex, remaining) {
    if (remaining === 0) {
      combinations.push([...current]);
      return;
    }

    for (let i = startIndex; i < candidates.length; i++) {
      const candidate = candidates[i];

      if (candidate > remaining) continue;

      current.push(candidate);
      backtrack(i, remaining - candidate);
      current.pop();
    }
  }

  backtrack(0, target);
  return combinations;
}
```

---

## 4. Meaning of the recursive state

```javascript
backtrack(startIndex, remaining)
```

means:

> Continue building the current combination using candidates from `startIndex` onward, and find choices that total exactly `remaining`.

The state has three pieces:

| State | Purpose |
| --- | --- |
| `current` | The combination chosen along the current recursion path |
| `remaining` | The amount still needed to reach the target |
| `startIndex` | The earliest candidate still allowed |

---

## 5. Why recurse with `i`, not `i + 1`?

This problem permits unlimited reuse of a candidate.

After choosing `candidates[i]`, we call:

```javascript
backtrack(i, remaining - candidate);
```

The same index remains available, allowing combinations such as:

```text
[2, 2, 3]
```

If each candidate could be used only once, the recursive call would normally use `i + 1` instead.

This one line encodes the reuse rule.

---

## 6. Choose, explore, undo

The heart of the algorithm is:

```javascript
current.push(candidate);                  // choose
backtrack(i, remaining - candidate);      // explore
current.pop();                            // undo
```

`current` is shared by all recursive calls on the active call stack. After exploring one branch, `pop()` restores it to the exact state it had before that choice, allowing the loop to try another candidate.

This restoration is what makes the technique **backtracking**, not merely recursion.

---

## 7. Why copy a completed combination?

Use:

```javascript
combinations.push([...current]);
```

not:

```javascript
combinations.push(current);
```

Arrays are reference values in JavaScript. If the same `current` array reference were stored, later `push()` and `pop()` operations would alter every stored result.

The spread creates an independent snapshot of the current path.

---

## 8. Walkthrough

```text
candidates = [2, 3, 6, 7]
target = 7
```

Start:

```text
current = []
remaining = 7
startIndex = 0
```

### Branch beginning with `2`

```text
choose 2 → current [2], remaining 5
choose 2 → current [2,2], remaining 3
choose 2 → current [2,2,2], remaining 1
```

No candidate fits the remaining `1`, so undo the last `2`.

Now try `3`:

```text
current [2,2,3], remaining 0
```

Record `[2,2,3]`.

### Branch beginning with `3`

The start index prevents choosing `2` afterward, so reordered duplicates such as `[3,2,2]` are never generated.

Repeated `3`s exceed or cannot complete the target, so that branch ends.

### Branch beginning with `7`

```text
current [7], remaining 0
```

Record `[7]`.

Final result:

```text
[[2,2,3], [7]]
```

---

## 9. Optional optimization: sort and break

If we sort the candidates first, then once a candidate exceeds `remaining`, every later candidate is also too large.

```javascript
function combinationSumSorted(candidates, target) {
  const sorted = [...candidates].sort((a, b) => a - b);
  const combinations = [];
  const current = [];

  function backtrack(startIndex, remaining) {
    if (remaining === 0) {
      combinations.push([...current]);
      return;
    }

    for (let i = startIndex; i < sorted.length; i++) {
      const candidate = sorted[i];

      if (candidate > remaining) break;

      current.push(candidate);
      backtrack(i, remaining - candidate);
      current.pop();
    }
  }

  backtrack(0, target);
  return combinations;
}
```

Sorting a copy avoids unexpectedly modifying the caller's array. Sorting costs O(n log n), but it can prune many impossible branches.

---

## 10. Correctness reasoning

We need to show that every valid combination is generated and no combination is duplicated.

### Every valid combination is generated

Any valid combination can be written in nondecreasing candidate-index order. At each recursive level, the loop considers every candidate from `startIndex` onward. Because recursion uses the same index `i`, a candidate can be repeated as many times as needed. Therefore, the recursion contains a path for every valid combination.

### Every recorded combination is valid

A combination is recorded only when `remaining === 0`. Since each chosen positive candidate is subtracted from the target, that path's chosen values sum exactly to the target.

### No duplicate ordering is generated

After choosing index `i`, future choices must have index at least `i`. Thus, candidate indices never decrease along a path. Different permutations of the same values cannot be produced.

Therefore, the output contains exactly the unique valid combinations.

---

## 11. Complexity

Backtracking complexity is output-sensitive and depends on the candidate values.

Let:

- `n` be the number of candidates;
- `T` be the target;
- `m` be the smallest candidate.

The maximum recursion depth is approximately:

```text
T / m
```

A commonly stated loose upper bound is exponential:

```text
O(n^(T/m))
```

The exact runtime depends heavily on pruning and how many valid partial paths exist. Copying each completed combination also costs time proportional to its length.

- Auxiliary recursion/path space: **O(T/m)**
- Output space: proportional to the total size of all returned combinations

In interviews, say clearly that the algorithm is exponential in the worst case and that generating all solutions inherently costs at least the output size.

---

## 12. Why positive candidates matter

Every candidate is positive, so `remaining` strictly decreases after each choice. This guarantees recursion eventually terminates.

If zero were allowed, choosing it repeatedly would never reduce the remainder. If negative values were allowed, the search could move away from zero and potentially cycle indefinitely without additional restrictions.

The input constraints are part of why this backtracking design is safe.

---

## 13. Common mistakes

### Mistake 1: recurse with `i + 1`

That prevents using the same candidate multiple times and misses valid answers.

### Mistake 2: restart every recursive call from index zero

That generates multiple permutations of the same combination.

### Mistake 3: forget to `pop()`

Choices from one branch leak into subsequent branches.

### Mistake 4: store `current` without copying

All results refer to the same mutable array and become corrupted.

### Mistake 5: add a result when the sum exceeds the target

Record only exact matches. Overshooting is a dead end.

### Mistake 6: use `break` without sorting

In an unsorted array, a later candidate may be smaller. Use `continue`, or sort first before using `break`.

### Mistake 7: deduplicate completed arrays afterward

Design the search space to avoid duplicates rather than generating redundant permutations and cleaning them later.

---

## 14. Sum-so-far alternative

We can carry the current sum instead of the remaining amount.

```javascript
function combinationSumUsingCurrentSum(candidates, target) {
  const result = [];
  const current = [];

  function backtrack(startIndex, currentSum) {
    if (currentSum === target) {
      result.push([...current]);
      return;
    }

    if (currentSum > target) return;

    for (let i = startIndex; i < candidates.length; i++) {
      current.push(candidates[i]);
      backtrack(i, currentSum + candidates[i]);
      current.pop();
    }
  }

  backtrack(0, 0);
  return result;
}
```

Both formulations are correct. Tracking `remaining` makes the base case and pruning condition particularly direct.

---

## 15. Interview narration

> “I’ll use backtracking to build one combination at a time. Each recursive call receives a start index so future choices never move backward, preventing reordered duplicates. Because a candidate can be reused, after choosing index `i` I recurse with `i`, not `i + 1`. When the remaining target reaches zero, I save a copy of the path; after each recursive call, I pop the choice to restore state.”

---

## 16. Pattern recognition

Use backtracking when a problem asks for:

- all combinations;
- all permutations;
- all subsets;
- all paths satisfying constraints;
- a constructed arrangement such as parentheses or a board configuration.

The reusable template is:

```javascript
function backtrack(state) {
  if (isSolution(state)) {
    saveSolution();
    return;
  }

  for (const choice of availableChoices(state)) {
    apply(choice);
    backtrack(nextState);
    undo(choice);
  }
}
```

---

## 17. Quick test

```javascript
console.log(combinationSum([2, 3, 6, 7], 7));
// [[2, 2, 3], [7]]

console.log(combinationSum([2, 3, 5], 8));
// [[2, 2, 2, 2], [2, 3, 3], [3, 5]]

console.log(combinationSum([2], 1));
// []
```

---

## 18. Notebook version

### Pattern

**Backtracking with reusable choices**

### Recursive state

```text
startIndex + remaining target + current path
```

### Core move

```javascript
current.push(candidate);
backtrack(i, remaining - candidate);
current.pop();
```

### Why `i`?

Reuse is allowed.

### Why `startIndex`?

Prevent reordered duplicates.

### Memory line

> Choose, reduce, recurse, undo—and never move backward in candidate order.

### Complexity

```text
time: exponential, output-sensitive
path/stack space: O(target / smallestCandidate)
```

