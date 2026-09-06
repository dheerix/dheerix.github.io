# Grind 75 — 44. Permutations

## Problem

Given an array `nums` containing distinct integers, return all possible permutations in any order.

Example:

```text
nums = [1, 2, 3]

answer =
[
  [1, 2, 3],
  [1, 3, 2],
  [2, 1, 3],
  [2, 3, 1],
  [3, 1, 2],
  [3, 2, 1]
]
```

---

## 1. What is a permutation?

A permutation uses every input value exactly once, but order matters.

For example:

```text
[1, 2, 3] ≠ [2, 1, 3]
```

For `n` distinct values, there are:

```text
n! permutations
```

The problem asks us to enumerate an entire decision tree, making backtracking the natural approach.

---

## 2. Connection to Combination Sum

Both problems use:

```text
choose → explore → undo
```

But their choice rules differ:

| Combination Sum | Permutations |
| --- | --- |
| Candidate reuse is allowed | Each value is used once per permutation |
| Order does not matter | Order matters |
| `startIndex` prevents reordered duplicates | Every unused value is considered at every position |
| Complete when remaining target is zero | Complete when path length is `n` |

Recognizing which choices remain legal is the main skill in backtracking problems.

---

## 3. Recommended JavaScript solution

```javascript
function permute(nums) {
  const permutations = [];
  const current = [];
  const used = new Array(nums.length).fill(false);

  function backtrack() {
    if (current.length === nums.length) {
      permutations.push([...current]);
      return;
    }

    for (let i = 0; i < nums.length; i++) {
      if (used[i]) continue;

      current.push(nums[i]);
      used[i] = true;

      backtrack();

      current.pop();
      used[i] = false;
    }
  }

  backtrack();
  return permutations;
}
```

---

## 4. Meaning of the state

### `current`

The partial permutation constructed along the active recursion path.

### `used[i]`

Whether the value at index `i` is already present in `current`.

### Recursion depth

The depth is also the next position being filled:

```text
depth 0 → choose value for position 0
depth 1 → choose value for position 1
...
depth n → permutation complete
```

---

## 5. Why no `startIndex`?

For combinations, `[1,2]` and `[2,1]` may represent the same selection, so we prevent moving backward.

For permutations, those orders are different answers. Every position must consider every value that has not already been used.

Therefore, each recursion level loops from index `0` again:

```javascript
for (let i = 0; i < nums.length; i++) {
  // Consider each value that is not already used.
}
```

The `used` array—not a start index—defines which choices remain available.

---

## 6. Choose, explore, undo

```javascript
current.push(nums[i]); // choose the value
used[i] = true;        // make it unavailable

backtrack();           // fill the next position

current.pop();         // undo the path choice
used[i] = false;       // make it available again
```

Both pieces of state must be restored. If we pop the value but forget to reset `used[i]`, other branches will incorrectly believe that value is unavailable.

---

## 7. Walkthrough with `[1, 2, 3]`

Start:

```text
current = []
used = [false, false, false]
```

### Choose `1` first

```text
current = [1]
used = [true, false, false]
```

At the next position, `1` is skipped. Choose `2`:

```text
current = [1, 2]
used = [true, true, false]
```

Only `3` remains:

```text
current = [1, 2, 3]
```

The path length equals `3`, so save a copy.

Now backtrack:

```text
remove 3 → [1,2]
remove 2 → [1]
```

At `[1]`, choose `3` instead, then `2`, producing:

```text
[1, 3, 2]
```

After exhausting all permutations beginning with `1`, undo `1`. The root can then begin branches with `2` and `3`.

---

## 8. Compact recursion tree

```text
[]
├─ [1]
│  ├─ [1,2] → [1,2,3]
│  └─ [1,3] → [1,3,2]
├─ [2]
│  ├─ [2,1] → [2,1,3]
│  └─ [2,3] → [2,3,1]
└─ [3]
   ├─ [3,1] → [3,1,2]
   └─ [3,2] → [3,2,1]
```

Every root-to-leaf path uses all values exactly once.

---

## 9. Why save a copy?

Use:

```javascript
permutations.push([...current]);
```

The `current` array is shared and repeatedly modified by `push()` and `pop()`. Saving the array itself would store the same reference many times, so later backtracking would mutate previously recorded answers.

The spread operator captures an independent snapshot.

---

## 10. Correctness reasoning

We maintain this invariant:

> `current` contains distinct input positions, and `used[i]` is true exactly when `nums[i]` appears in `current`.

### Every recorded result is valid

A result is recorded only when `current.length === nums.length`. The invariant guarantees that no index is repeated, so the path contains every input value exactly once.

### Every permutation is generated

At each position, the loop considers every unused input index. For any desired permutation, the recursion can choose its first value, then its second unused value, and continue until the entire order is formed.

### No permutation is generated twice

Each recursion path is uniquely determined by its sequence of chosen indices. Distinct paths produce distinct orders because the input values are distinct.

Therefore, the algorithm returns every permutation exactly once.

---

## 11. Complexity

For `n` distinct values, there are `n!` results, each of length `n`.

- Time: **O(n × n!)**
- Output space: **O(n × n!)**
- Auxiliary recursion/path/used space: **O(n)**

Why not merely O(n!)?

We must copy `n` values into the output for each of the `n!` permutations. The size of the required output itself is O(n × n!).

---

## 12. Alternative: in-place swapping

Instead of a `used` array, make index `first` represent the next position to fill. Swap each candidate into that position, recurse, then swap back.

```javascript
function permuteBySwapping(nums) {
  const permutations = [];
  const values = [...nums];

  function swap(first, second) {
    [values[first], values[second]] = [values[second], values[first]];
  }

  function backtrack(first) {
    if (first === values.length) {
      permutations.push([...values]);
      return;
    }

    for (let i = first; i < values.length; i++) {
      swap(first, i);
      backtrack(first + 1);
      swap(first, i);
    }
  }

  backtrack(0);
  return permutations;
}
```

This avoids the `used` array but mutates the working array during recursion. Copying `nums` into `values` preserves the caller's input.

Both approaches have the same asymptotic complexity. The `used` version often makes the decision logic easier to explain.

---

## 13. Common mistakes

### Mistake 1: using a `startIndex`

That generates combinations or only a subset of possible orders. Permutations must reconsider earlier indices when they are not already used.

### Mistake 2: checking used values with `current.includes(nums[i])`

This works for distinct values but costs O(n) per check. A boolean array provides O(1) membership checks.

### Mistake 3: forgetting to reset `used[i]`

The chosen value stays unavailable after returning to the parent branch.

### Mistake 4: forgetting to pop

The partial path retains a choice that should have been undone.

### Mistake 5: storing `current` without copying

All output entries share one mutable reference.

### Mistake 6: using a set of values when duplicates are allowed

This exact problem guarantees distinct values. For duplicate inputs, index usage and duplicate-skipping rules require additional care.

---

## 14. If the input contains duplicates

The related “Permutations II” problem asks for unique permutations with duplicate values.

A common solution sorts the input and skips a duplicate value when its identical predecessor has not been used in the current branch:

```javascript
function permuteUnique(nums) {
  const values = [...nums].sort((a, b) => a - b);
  const result = [];
  const current = [];
  const used = new Array(values.length).fill(false);

  function backtrack() {
    if (current.length === values.length) {
      result.push([...current]);
      return;
    }

    for (let i = 0; i < values.length; i++) {
      if (used[i]) continue;

      if (i > 0 && values[i] === values[i - 1] && !used[i - 1]) {
        continue;
      }

      used[i] = true;
      current.push(values[i]);
      backtrack();
      current.pop();
      used[i] = false;
    }
  }

  backtrack();
  return result;
}
```

This is not required for the Grind 75 version, but it clarifies why the distinct-values guarantee matters.

---

## 15. Interview narration

> “I’ll fill the permutation one position at a time using backtracking. At each position I can choose any input index not already used. I’ll mark it used, append its value, recurse, then pop and unmark it so sibling branches can use it. Once the path length equals the input length, I’ll store a copy.”

---

## 16. Pattern recognition

For arrangement problems, ask:

1. Does order matter?
2. Can a choice be reused?
3. What makes a path complete?
4. What state records unavailable choices?
5. What must be undone after recursion?

For this problem:

```text
order matters: yes
reuse in one path: no
completion: path length equals n
availability: used[index]
undo: pop path and clear used[index]
```

---

## 17. Quick test

```javascript
console.log(permute([1, 2, 3])); // 6 permutations
console.log(permute([0, 1]));    // [[0,1], [1,0]]
console.log(permute([1]));       // [[1]]
console.log(permute([]));        // [[]]
```

The empty input has one permutation: the empty arrangement.

---

## 18. Notebook version

### Pattern

**Backtracking with a used-index array**

### Completion

```text
current.length === nums.length
```

### Core move

```javascript
current.push(nums[i]);
used[i] = true;
backtrack();
current.pop();
used[i] = false;
```

### Memory line

> Fill one position; try every value not already used; restore both path and availability.

### Complexity

```text
time: O(n × n!)
auxiliary space: O(n)
output: O(n × n!)
```
