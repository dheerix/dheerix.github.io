# Grind 75 — 42. Search in Rotated Sorted Array

## Problem

You are given an array of distinct integers that was originally sorted in ascending order and then possibly rotated at an unknown pivot.

Example:

```text
original: [0, 1, 2, 4, 5, 6, 7]
rotated:  [4, 5, 6, 7, 0, 1, 2]
```

Given a target, return its index or `-1` if it is absent. The required runtime is **O(log n)**.

---

## 1. Why ordinary binary search breaks

Normal binary search assumes the entire active range is sorted. Rotation introduces one discontinuity:

```text
4, 5, 6, 7, 0, 1, 2
         ↑
       rotation break
```

Comparing only `target` with `nums[mid]` no longer tells us reliably whether to move left or right.

However, rotation preserves a crucial property:

> For any active range, at least one side of the midpoint is sorted.

That sorted half gives us enough structure to discard half the search space.

---

## 2. Decision framework

At each iteration:

1. calculate `mid`;
2. return immediately if `nums[mid] === target`;
3. determine which half is sorted;
4. ask whether the target falls inside that sorted half;
5. keep that half if it can contain the target; otherwise keep the other half.

To detect the sorted side:

```text
nums[left] <= nums[mid]  → left half is sorted
otherwise                → right half is sorted
```

---

## 3. Recommended JavaScript solution

```javascript
function search(nums, target) {
  let left = 0;
  let right = nums.length - 1;

  while (left <= right) {
    const middle = left + Math.floor((right - left) / 2);

    if (nums[middle] === target) {
      return middle;
    }

    if (nums[left] <= nums[middle]) {
      // The left half is sorted.
      if (nums[left] <= target && target < nums[middle]) {
        right = middle - 1;
      } else {
        left = middle + 1;
      }
    } else {
      // The right half is sorted.
      if (nums[middle] < target && target <= nums[right]) {
        left = middle + 1;
      } else {
        right = middle - 1;
      }
    }
  }

  return -1;
}
```

---

## 4. The boundary conditions

When the left half is sorted, its candidate range is:

```text
nums[left] <= target < nums[middle]
```

When the right half is sorted, its candidate range is:

```text
nums[middle] < target <= nums[right]
```

Why is the midpoint excluded from both range tests?

We already checked `nums[middle] === target`. Therefore, if execution continues, the midpoint is not the answer and can safely be excluded.

The outer boundaries are included because the target may equal `nums[left]` or `nums[right]`.

---

## 5. Walkthrough: target in the rotated portion

```text
nums   = [4, 5, 6, 7, 0, 1, 2]
target = 0
```

### Iteration 1

```text
left = 0, middle = 3, right = 6
values: 4          7           2
```

`nums[left] <= nums[middle]`, so `[4,5,6,7]` is sorted.

Does `0` lie between `4` and `7`? No.

Discard the sorted left half:

```text
left = middle + 1 = 4
```

### Iteration 2

```text
left = 4, middle = 5, right = 6
values: 0          1           2
```

The left half is sorted. Target `0` lies in `[0,1)`, so search left:

```text
right = middle - 1 = 4
```

### Iteration 3

```text
left = middle = right = 4
nums[4] = 0
```

Return index `4`.

---

## 6. Walkthrough: target absent

```text
nums   = [4, 5, 6, 7, 0, 1, 2]
target = 3
```

| `left` | `middle` | `right` | Sorted side | Decision |
| ---: | ---: | ---: | --- | --- |
| `0` | `3` | `6` | Left `[4..7]` | `3` not inside; move right |
| `4` | `5` | `6` | Left `[0..1]` | `3` not inside; move right |
| `6` | `6` | `6` | Left `[2]` | `3` not inside; move right |

Now `left > right`, so return `-1`.

---

## 7. Why at least one half is sorted

The array contains only one rotation break.

When we divide the active range around `middle`, that break can be:

- in the left half;
- in the right half;
- outside the active range.

It cannot disrupt both halves simultaneously. Therefore, at least one side remains normally sorted.

We inspect that side's endpoints to decide whether it contains the target. This lets us eliminate half the remaining values every iteration.

---

## 8. Correctness reasoning

We maintain this invariant:

> If the target exists, it lies within the inclusive range `[left, right]`.

At each iteration:

- if the midpoint is the target, we return it;
- otherwise, one half is known to be sorted;
- its endpoint values tell us exactly whether the target can lie within it;
- we retain the possible half and discard only a half that cannot contain the target.

Therefore, the invariant remains true after every pointer update.

Each update removes at least the midpoint and roughly halves the active range. If the target exists, we eventually reach it. If the range becomes empty, the target cannot be present.

---

## 9. Complexity

- Time: **O(log n)**
- Auxiliary space: **O(1)**

Each iteration discards approximately half of the active search interval, and the algorithm uses only pointer variables.

---

## 10. Why `<=` is used to detect the sorted left half

Use:

```javascript
nums[left] <= nums[middle]
```

not only `<`.

When `left === middle`, the left side contains one value and is trivially sorted. Using `<=` handles this shrinking boundary cleanly and ensures the algorithm continues to make progress.

---

## 11. Assumption: values are distinct

This solution relies on the original problem's distinct-values guarantee.

With duplicates, consider:

```text
[1, 0, 1, 1, 1]
```

If `nums[left] === nums[middle]`, the comparison may not reveal which half contains the rotation. A duplicate-aware variant may need to shrink ambiguous endpoints, which can degrade the worst-case runtime to O(n).

```javascript
function searchWithDuplicates(nums, target) {
  let left = 0;
  let right = nums.length - 1;

  while (left <= right) {
    const middle = left + Math.floor((right - left) / 2);

    if (nums[middle] === target) return true;

    if (
      nums[left] === nums[middle] &&
      nums[middle] === nums[right]
    ) {
      left++;
      right--;
    } else if (nums[left] <= nums[middle]) {
      if (nums[left] <= target && target < nums[middle]) {
        right = middle - 1;
      } else {
        left = middle + 1;
      }
    } else {
      if (nums[middle] < target && target <= nums[right]) {
        left = middle + 1;
      } else {
        right = middle - 1;
      }
    }
  }

  return false;
}
```

That is a related but different problem.

---

## 12. Alternative: find the pivot first

Another valid design is:

1. use binary search to find the smallest element—the rotation pivot;
2. determine which sorted segment may contain the target;
3. run ordinary binary search on that segment.

This remains O(log n), but the one-pass solution is shorter and avoids coordinating two binary searches.

```javascript
function searchUsingPivot(nums, target) {
  if (nums.length === 0) return -1;

  let left = 0;
  let right = nums.length - 1;

  while (left < right) {
    const middle = left + Math.floor((right - left) / 2);

    if (nums[middle] > nums[right]) {
      left = middle + 1;
    } else {
      right = middle;
    }
  }

  const pivot = left;

  if (target >= nums[pivot] && target <= nums[nums.length - 1]) {
    left = pivot;
    right = nums.length - 1;
  } else {
    left = 0;
    right = pivot - 1;
  }

  while (left <= right) {
    const middle = left + Math.floor((right - left) / 2);

    if (nums[middle] === target) return middle;
    if (nums[middle] < target) left = middle + 1;
    else right = middle - 1;
  }

  return -1;
}
```

---

## 13. Common mistakes

### Mistake 1: finding the pivot with a linear scan

This makes the total runtime O(n), violating the requirement.

### Mistake 2: using ordinary binary-search direction rules

`target < nums[middle]` does not always imply the target is physically to the left after rotation.

### Mistake 3: checking whether a half is sorted but not whether the target lies inside it

Both decisions are necessary: identify the sorted half, then test the target against its boundaries.

### Mistake 4: incorrect inclusivity

Use:

```text
left sorted:  nums[left] <= target < nums[middle]
right sorted: nums[middle] < target <= nums[right]
```

### Mistake 5: failing to move beyond `middle`

Updates must use `middle - 1` or `middle + 1`; otherwise the loop may never shrink.

### Mistake 6: forgetting an unrotated array

The same algorithm handles a normally sorted array because the left half will be recognized as sorted.

---

## 14. Edge cases

- empty array → `-1`
- one value matching the target → index `0`
- one value not matching → `-1`
- array not rotated
- target at the rotation pivot
- target at either endpoint
- target absent

---

## 15. Interview narration

> “Rotation breaks global sorted order, but around any midpoint at least one half is still sorted. I’ll identify that half from its endpoints, check whether the target lies within its value range, and either search it or discard it. This preserves binary search's O(log n) runtime.”

---

## 16. Pattern recognition

This is **binary search on a partially ordered search space**.

The broader lesson is:

> Binary search does not require the entire input to look conventionally sorted; it requires a reliable rule that eliminates half the possibilities.

Look for:

- one monotonic or sorted region around the midpoint;
- a predicate that identifies which region is trustworthy;
- endpoint comparisons that prove whether the target can lie there.

---

## 17. Quick test

```javascript
console.log(search([4, 5, 6, 7, 0, 1, 2], 0)); // 4
console.log(search([4, 5, 6, 7, 0, 1, 2], 3)); // -1
console.log(search([1], 1));                     // 0
console.log(search([1], 0));                     // -1
```

---

## 18. Notebook version

### Pattern

**Modified binary search**

### Core observation

```text
At least one half around middle is sorted.
```

### Decision template

```text
Is left half sorted?
├─ Yes: is target inside its range?
│  ├─ Yes → search left
│  └─ No  → search right
└─ No: right half is sorted
   ├─ target inside → search right
   └─ otherwise     → search left
```

### Memory line

> Find the sorted half; ask whether the target belongs there.

### Complexity

```text
time: O(log n)
space: O(1)
```

