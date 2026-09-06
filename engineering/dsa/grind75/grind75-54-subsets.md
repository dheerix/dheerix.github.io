# Grind 75 — 54. Subsets

## Problem

Given an array `nums` of distinct integers, return every possible subset—the power set.

The solution must not contain duplicate subsets, and subsets may be returned in any order.

Example:

```text
nums = [1, 2, 3]

output =
[
  [],
  [1], [2], [3],
  [1,2], [1,3], [2,3],
  [1,2,3]
]
```

---

## 1. The mathematical structure

For every input value, a subset makes one binary decision:

```text
exclude it
or
include it
```

With `n` distinct values, there are:

```text
2 × 2 × ... × 2 = 2ⁿ subsets
```

The output is inherently exponential. Our goal is to generate every subset exactly once with minimal additional overhead.

---

## 2. Backtracking view

At any point, `current` is already a valid subset. We record it, then try extending it with later values.

Using a `startIndex` ensures values are chosen only in forward index order:

```text
after choosing index i, future choices begin at i + 1
```

This prevents generating reordered versions of the same subset, such as both `[1,2]` and `[2,1]`.

---

## 3. Recommended JavaScript solution

```javascript
function subsets(nums) {
  const result = [];
  const current = [];

  function backtrack(startIndex) {
    result.push([...current]);

    for (let i = startIndex; i < nums.length; i++) {
      current.push(nums[i]);
      backtrack(i + 1);
      current.pop();
    }
  }

  backtrack(0);
  return result;
}
```

---

## 4. Why record at every recursive call?

In Permutations, a path is valid only when it contains every input value.

In Subsets, every path length is valid:

```text
[]
[1]
[1,2]
[1,2,3]
```

Therefore, save `current` immediately when entering the recursive function, before attempting additional choices.

The initial call records the empty subset automatically.

---

## 5. Choose, explore, undo

```javascript
current.push(nums[i]); // choose
backtrack(i + 1);      // explore later values
current.pop();         // undo
```

`push()` includes the current value. The recursive call explores every subset that begins with the current path. `pop()` removes that choice so the loop can try the next value from the restored parent state.

---

## 6. Why recurse with `i + 1`?

Each input position can appear at most once in a subset.

After choosing index `i`, recurse with:

```javascript
backtrack(i + 1);
```

This has two effects:

1. the same value cannot be chosen again in the current path;
2. indices remain increasing, so each subset has exactly one construction order.

Contrast this with Combination Sum, where candidate reuse is allowed and recursion uses `i`.

---

## 7. Walkthrough with `[1, 2, 3]`

Start:

```text
current = []
record []
```

Choose `1`:

```text
current = [1]
record [1]
```

From `[1]`, choose `2`:

```text
current = [1,2]
record [1,2]
```

Then choose `3`:

```text
current = [1,2,3]
record [1,2,3]
```

Backtrack twice to `[1]`, then choose `3`:

```text
record [1,3]
```

After exhausting subsets beginning with `1`, backtrack to `[]`. The loop then explores subsets beginning with `2`, followed by those beginning with `3`.

---

## 8. Recursion tree

```text
[]
├─ [1]
│  ├─ [1,2]
│  │  └─ [1,2,3]
│  └─ [1,3]
├─ [2]
│  └─ [2,3]
└─ [3]
```

Every node in this tree is an output subset.

---

## 9. Why copy `current`?

Use:

```javascript
result.push([...current]);
```

not:

```javascript
result.push(current);
```

`current` is one shared mutable array. Without copying, all output entries would refer to the same array and would change as backtracking pushes and pops values.

---

## 10. Correctness reasoning

### Every generated result is a valid subset

The path contains only input values, and indices strictly increase because recursive calls use `i + 1`. Therefore, no input position is repeated.

### Every subset is generated

Take any desired subset. List its chosen indices in increasing order. The recursion can follow exactly those choices because every call loops through all later indices. When that path is reached, it is recorded.

### No subset is generated twice

Every subset has one unique increasing sequence of indices. The algorithm never generates an alternate order of the same selected indices.

Thus, every subset appears exactly once.

---

## 11. Complexity

There are `2ⁿ` subsets. Copying one subset can take up to O(n).

- Time: **O(n × 2ⁿ)**
- Output space: **O(n × 2ⁿ)**
- Auxiliary recursion/path space: **O(n)**

The output-size lower bound matters: no algorithm can return every subset in sub-exponential total output space.

---

## 12. Alternative: explicit include/exclude recursion

Another formulation makes the binary decision for each index visible.

```javascript
function subsetsIncludeExclude(nums) {
  const result = [];
  const current = [];

  function decide(index) {
    if (index === nums.length) {
      result.push([...current]);
      return;
    }

    // Exclude nums[index].
    decide(index + 1);

    // Include nums[index].
    current.push(nums[index]);
    decide(index + 1);
    current.pop();
  }

  decide(0);
  return result;
}
```

This recursion forms a full binary tree with exactly `2ⁿ` leaves. It is excellent for understanding the include/exclude model.

The loop-based version records internal paths and is a common reusable template for combination-generation problems.

---

## 13. Alternative: iterative expansion

Start with the empty subset. For each number, copy every existing subset and append the new number.

```javascript
function subsetsIterative(nums) {
  const result = [[]];

  for (const number of nums) {
    const existingCount = result.length;

    for (let i = 0; i < existingCount; i++) {
      result.push([...result[i], number]);
    }
  }

  return result;
}
```

Example:

```text
start:  [[]]
add 1:  [[], [1]]
add 2:  [[], [1], [2], [1,2]]
add 3:  [[], [1], [2], [1,2], [3], [1,3], [2,3], [1,2,3]]
```

Store `existingCount` before appending. Otherwise, the loop would also iterate over newly created subsets and repeatedly add the same number.

---

## 14. Alternative: bitmask enumeration

An `n`-bit number can describe one subset:

```text
bit i = 1 → include nums[i]
bit i = 0 → exclude nums[i]
```

```javascript
function subsetsBitmask(nums) {
  const result = [];
  const subsetCount = 2 ** nums.length;

  for (let mask = 0; mask < subsetCount; mask++) {
    const subset = [];

    for (let i = 0; i < nums.length; i++) {
      if ((mask & (2 ** i)) !== 0) {
        subset.push(nums[i]);
      }
    }

    result.push(subset);
  }

  return result;
}
```

JavaScript bitwise operators coerce values to signed 32-bit integers, so this technique should not be generalized to large `n` without using `BigInt` or another representation. LeetCode's small input limit makes it safe here.

---

## 15. Subsets versus permutations versus combination sum

| Problem | Order matters? | Reuse? | Completion |
| --- | --- | --- | --- |
| Subsets | No | No | Every current path |
| Permutations | Yes | No | Path length is `n` |
| Combination Sum | No | Yes | Remaining target is `0` |

Pointer/state choices follow from those rules:

```text
Subsets:        recurse with i + 1
Permutations:   loop all indices + used array
Combination Sum: recurse with i
```

---

## 16. If input values contain duplicates

The current problem guarantees distinct values. For duplicate inputs, sort first and skip equal choices at the same recursion depth:

```javascript
function subsetsWithDup(nums) {
  const values = [...nums].sort((a, b) => a - b);
  const result = [];
  const current = [];

  function backtrack(startIndex) {
    result.push([...current]);

    for (let i = startIndex; i < values.length; i++) {
      if (i > startIndex && values[i] === values[i - 1]) {
        continue;
      }

      current.push(values[i]);
      backtrack(i + 1);
      current.pop();
    }
  }

  backtrack(0);
  return result;
}
```

The condition skips duplicates only among sibling choices at the same depth. It still allows equal values occupying different input positions to appear together when appropriate.

---

## 17. Common mistakes

### Mistake 1: forget the empty subset

The initial empty path must be recorded.

### Mistake 2: record only when reaching the end

That works only with the explicit include/exclude formulation. In the loop template, every intermediate path is a valid subset.

### Mistake 3: recurse with `i`

That permits reusing the same element and can recurse indefinitely or generate invalid subsets.

### Mistake 4: restart the loop at zero

That produces reordered duplicates and reused indices. Pass a forward-only `startIndex`.

### Mistake 5: forget `pop()`

A choice leaks into sibling branches.

### Mistake 6: store the path without copying

All results share one mutable array reference.

### Mistake 7: claim O(2ⁿ) without output-copy cost

Returning arrays containing up to `n` elements gives O(n × 2ⁿ) total output work.

---

## 18. Edge cases

- empty input → `[[]]`
- one value → `[[], [value]]`
- negative values
- zero as a value
- distinct values in any order

Value signs do not matter because the problem is about selection, not arithmetic.

---

## 19. Interview narration

> “Every partial path is already a valid subset, so I’ll save a copy at the beginning of each recursive call. Then I’ll try adding each value from a start index onward. I recurse with `i + 1` because each input position can be used once, and forward-only indices prevent reordered duplicates. After exploring a choice, I pop it to restore the path.”

---

## 20. Pattern recognition

This is the foundational **choose any combination of distinct items** template.

Use it when:

- every partial selection is a valid result;
- order does not matter;
- each item is used at most once;
- all combinations must be enumerated.

Template:

```javascript
function backtrack(startIndex) {
  saveCopyOfCurrent();

  for (let i = startIndex; i < items.length; i++) {
    choose(items[i]);
    backtrack(i + 1);
    undo(items[i]);
  }
}
```

---

## 21. Quick test

```javascript
console.log(subsets([1, 2, 3])); // 8 subsets
console.log(subsets([0]));       // [[], [0]]
console.log(subsets([]));        // [[]]
```

---

## 22. Notebook version

### Pattern

**Backtracking with forward-only choices**

### Key fact

```text
Every current path is a valid subset.
```

### Core move

```javascript
result.push([...current]);
current.push(nums[i]);
backtrack(i + 1);
current.pop();
```

### Why `i + 1`?

Each value is used at most once, and index order prevents duplicates.

### Memory line

> Save every path; extend only forward; undo after exploring.

### Complexity

```text
time: O(n × 2ⁿ)
auxiliary space: O(n)
output: O(n × 2ⁿ)
```

