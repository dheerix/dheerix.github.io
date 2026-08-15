# Grind 75 — 08: Binary Search

**Difficulty:** Easy  
**Primary pattern:** Binary search / search-space reduction  
**LeetCode:** https://leetcode.com/problems/binary-search/  
**Target time:** 15 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given an array of integers sorted in ascending order and a target value:

- return the target's index if it exists;
- otherwise return `-1`.

The required runtime is O(log n).

```text
nums   = [-1, 0, 3, 5, 9, 12]
target = 9
result = 4
```

```text
nums   = [-1, 0, 3, 5, 9, 12]
target = 2
result = -1
```

---

## 2. Why sorted order changes the search

In an unsorted array, examining one value tells us nothing about where another value might be. Linear search may need to inspect all `n` elements.

In a sorted array, comparing the target with the middle value eliminates half the remaining interval:

```text
target < middle value → discard middle and everything to its right
target > middle value → discard middle and everything to its left
target = middle value → found
```

Binary search is possible because the ordering lets one comparison rule out a large, contiguous region.

---

## 3. Search-space contract

We will use an **inclusive interval**:

```text
[left, right]
```

Both `left` and `right` are valid candidate indices.

Invariant:

> At the start of every loop iteration, if the target exists, at least one occurrence lies within indices `left` through `right`, inclusive.

Consequences of choosing an inclusive interval:

```text
initial right:       nums.length - 1
loop condition:      left <= right
discard middle left: left = middle + 1
discard middle right:right = middle - 1
```

These four choices must agree. Many binary-search bugs come from mixing rules belonging to different interval conventions.

---

## 4. Step-by-step algorithm

1. Set `left = 0` and `right = nums.length - 1`.
2. While the inclusive interval is non-empty (`left <= right`):
   - calculate the middle index;
   - return it if its value equals the target;
   - if the middle value is too small, search strictly to its right;
   - otherwise search strictly to its left.
3. If the interval becomes empty, return `-1`.

Why exclude `middle` after a mismatch? We just proved `nums[middle]` is not the target. Keeping it would make no progress and can cause an infinite loop.

---

## 5. Optimal JavaScript solution

```javascript
function search(nums, target) {
  let left = 0;
  let right = nums.length - 1;

  while (left <= right) {
    const middle = left + Math.floor((right - left) / 2);
    const middleValue = nums[middle];

    if (middleValue === target) {
      return middle;
    }

    if (middleValue < target) {
      left = middle + 1;
    } else {
      right = middle - 1;
    }
  }

  return -1;
}
```

---

## 6. Dry run: target exists

```text
nums   = [-1, 0, 3, 5, 9, 12]
target = 9
```

| Iteration | `left` | `right` | `middle` | `nums[middle]` | Decision |
|---:|---:|---:|---:|---:|---|
| 1 | 0 | 5 | 2 | 3 | Too small → `left = 3` |
| 2 | 3 | 5 | 4 | 9 | Found → return `4` |

Four of the six positions were eliminated after the first comparison.

---

## 7. Dry run: target absent

```text
nums   = [1, 3, 5, 7]
target = 4
```

| Iteration | Interval | Middle value | Decision |
|---:|---|---:|---|
| 1 | `[0, 3]` | `3` at index 1 | search `[2, 3]` |
| 2 | `[2, 3]` | `5` at index 2 | search `[2, 1]` |

Now `left = 2` and `right = 1`. Since `left > right`, the candidate interval is empty, so return `-1`.

---

## 8. Code walkthrough

### `let right = nums.length - 1`

The interval is inclusive, so the last candidate is the last valid array index. For an empty array, `right` becomes `-1`, making the loop skip safely.

### `while (left <= right)`

When `left === right`, one candidate remains and must still be checked. Using `<` would skip that last element under this interval convention.

### Safe midpoint formula

```javascript
const middle = left + Math.floor((right - left) / 2);
```

This is traditionally preferred over:

```javascript
Math.floor((left + right) / 2)
```

because fixed-width integer languages can overflow when adding two large indices. JavaScript numbers do not overflow in the same way within safe integer limits, but the safe formula is portable and clearly positions the midpoint inside the interval.

Avoid the common JavaScript shortcut `(left + right) >> 1` for general code: bitwise operations convert values to signed 32-bit integers and can corrupt large indices.

### `left = middle + 1`

If the middle value is smaller than the target, sorted order proves every index at or left of `middle` is also too small. The next candidate begins at `middle + 1`.

### `right = middle - 1`

The symmetric reasoning applies when the middle value is too large.

---

## 9. Correctness reasoning

Suppose the invariant holds at the start of an iteration.

- If `nums[middle] === target`, returning `middle` is correct.
- If `nums[middle] < target`, every element at indices `left...middle` is at most `nums[middle]` because the array is sorted. None can equal the target, so discarding them preserves the invariant.
- If `nums[middle] > target`, every element at indices `middle...right` is at least `nums[middle]`. None can equal the target, so discarding them preserves the invariant.

Each unsuccessful iteration strictly shrinks the interval. When `left > right`, no candidate remains. By the invariant, the target cannot exist in the array, so `-1` is correct.

---

## 10. Complexity

- **Time: O(log n)** — each comparison reduces the remaining search interval to at most half its previous size.
- **Auxiliary space: O(1)** — the iterative implementation stores only a few numeric variables.

Why logarithmic?

After `k` reductions, at most `n / 2^k` elements remain. Searching ends when:

```text
n / 2^k ≤ 1
2^k ≥ n
k ≥ log₂(n)
```

Therefore, the number of iterations grows logarithmically.

---

## 11. Common mistakes

1. **Using binary search on unsorted data.** The half-elimination reasoning requires monotonic order.
2. **Mixing interval conventions.** For `[left, right]`, use `right = length - 1` and `left <= right`.
3. **Using `left < right` with the inclusive template.** The final candidate may never be checked.
4. **Writing `left = middle` or `right = middle`.** A two-element interval can stop shrinking and loop forever.
5. **Returning the value instead of the index.** The problem requests the index.
6. **Returning `0` when absent.** Index `0` is valid; use `-1` as the sentinel.
7. **Using a bitwise midpoint in JavaScript.** Bitwise operators force signed 32-bit conversion.
8. **Assuming this template finds the first duplicate.** It returns an arbitrary matching occurrence unless modified for a boundary search.

---

## 12. What to say in an interview

> “Because the array is sorted, comparing the target with the middle value tells me which half cannot contain it. I’ll maintain an inclusive candidate interval `[left, right]`. On a mismatch I exclude the middle using `middle + 1` or `middle - 1`, which guarantees progress. The interval halves each iteration, so time is O(log n), with O(1) extra space.”

If asked for the invariant:

> “If the target exists, it remains somewhere inside the inclusive interval `[left, right]`.”

---

## 13. Pattern recognition

Think **binary search** when:

- the input or answer space is ordered or monotonic;
- a condition divides candidates into two regions;
- one observation can eliminate half the remaining possibilities;
- the question asks for an exact value or a first/last valid boundary.

Binary search is broader than “find a number in a sorted array.” It can search:

- a rotated sorted array;
- a timestamped history;
- the first failing version;
- the minimum capacity that satisfies a condition;
- an answer range rather than explicit array elements.

Memory cue:

> State the candidate interval; prove which half is impossible; discard it.

---

## 14. Alternative interval convention

Some implementations use a half-open interval:

```text
[left, right)
```

Then the rules become:

```text
right starts at nums.length
loop while left < right
discard right with right = middle
```

This is also correct. The danger is combining pieces from the inclusive and half-open versions.

For interviews, choose one convention and state it. These notes standardize ordinary exact-match binary search on the inclusive interval `[left, right]`.

---

## 15. Recursive alternative

```javascript
function searchRecursive(nums, target) {
  function find(left, right) {
    if (left > right) return -1;

    const middle = left + Math.floor((right - left) / 2);

    if (nums[middle] === target) return middle;

    if (nums[middle] < target) {
      return find(middle + 1, right);
    }

    return find(left, middle - 1);
  }

  return find(0, nums.length - 1);
}
```

- Time: **O(log n)**.
- Call-stack space: **O(log n)**.

The iterative solution is usually preferable because it preserves O(1) auxiliary space and avoids recursion overhead.

---

## 16. Follow-up: first occurrence among duplicates

Ordinary binary search may return any matching position. To find the first occurrence, save a match and continue searching left:

```javascript
function firstOccurrence(nums, target) {
  let left = 0;
  let right = nums.length - 1;
  let answer = -1;

  while (left <= right) {
    const middle = left + Math.floor((right - left) / 2);

    if (nums[middle] >= target) {
      if (nums[middle] === target) answer = middle;
      right = middle - 1;
    } else {
      left = middle + 1;
    }
  }

  return answer;
}
```

Finding boundaries is the next level of binary search: a match becomes a candidate answer, not necessarily the stopping point.

---

## 17. Edge cases

| Input | Target | Result |
|---|---:|---:|
| `[]` | `5` | `-1` |
| `[5]` | `5` | `0` |
| `[5]` | `3` | `-1` |
| `[1, 3]` | `1` | `0` |
| `[1, 3]` | `3` | `1` |
| `[1, 3]` | `2` | `-1` |
| `[-5, -2, 0, 4]` | `-2` | `1` |

Always test one-element and two-element arrays. They expose most off-by-one and non-progress bugs.

---

## 18. Notebook-ready notes

### 📚 Concept

**Binary Search — inclusive interval `[left, right]`**

```text
left = 0
right = n - 1
while left <= right:
    middle = left + floor((right - left) / 2)
    equal     → return middle
    too small → left = middle + 1
    too large → right = middle - 1
not found → -1
```

### 🧠 My understanding

Sorted order lets one middle comparison eliminate half the candidate interval. My invariant is that the target, if present, remains inside `[left, right]`. I exclude `middle` after a mismatch because it has already been disproved.

### 💼 Interview line

> “I’ll maintain an inclusive candidate interval and discard the half that sorted order proves impossible.”

### ⚠️ Traps

- Do not mix inclusive and half-open templates.
- With an inclusive interval, use `left <= right`.
- Always move past `middle` after a mismatch.
- Avoid JavaScript bitwise midpoint shortcuts.

---

## 19. Dheerix Glance

```text
BINARY SEARCH

Precondition:     sorted/monotonic space
Interval:         [left, right], inclusive
Initialize:       left = 0, right = n - 1
Continue while:   left <= right
Middle:           left + floor((right-left)/2)
Too small:        left = middle + 1
Too large:        right = middle - 1
Absent:           return -1
Time:             O(log n)
Auxiliary space:  O(1)
Invariant:        target, if present, remains in interval
Memory cue:       “Prove one half impossible.”
```

---

## 20. Recall test

Without looking back:

1. What prerequisite makes binary search possible?
2. What exactly does `[left, right]` represent?
3. Why is the loop condition `left <= right`?
4. Why must updates move past `middle`?
5. Why is the runtime O(log n)?
6. Why avoid `(left + right) >> 1` in general JavaScript code?
7. How would searching for the first occurrence differ from exact-match search?
8. State the invariant in one sentence.

