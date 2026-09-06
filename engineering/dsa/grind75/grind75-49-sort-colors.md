# Grind 75 — 49. Sort Colors

## Problem

Given an array containing only:

- `0` — red
- `1` — white
- `2` — blue

sort it in place so equal colors are adjacent and appear in the order `0, 1, 2`.

Do not use the language's built-in sort. The follow-up expects a one-pass algorithm using constant extra space.

Example:

```text
input:  [2, 0, 2, 1, 1, 0]
output: [0, 0, 1, 1, 2, 2]
```

---

## 1. Baseline: counting sort

Because there are only three possible values, we can count them and overwrite the array.

```javascript
function sortColorsCounting(nums) {
  const counts = [0, 0, 0];

  for (const color of nums) {
    counts[color]++;
  }

  let index = 0;

  for (let color = 0; color <= 2; color++) {
    for (let count = 0; count < counts[color]; count++) {
      nums[index++] = color;
    }
  }
}
```

This is:

- O(n) time;
- O(1) extra space;
- two passes over the data.

It is a valid solution, but the strongest version performs the partition in one pass.

---

## 2. Dutch National Flag insight

Maintain four regions:

```text
[ confirmed 0s | confirmed 1s | unknown | confirmed 2s ]
                  ↑             ↑
                current       high
```

Using three pointers:

- `low`: next position where a `0` belongs;
- `current`: next unknown value to inspect;
- `high`: next position where a `2` belongs.

More precisely, the invariant is:

```text
indices [0, low)             contain only 0s
indices [low, current)       contain only 1s
indices [current, high]      are unknown
indices (high, nums.length)  contain only 2s
```

The goal is to shrink the unknown region until it becomes empty.

---

## 3. Recommended JavaScript solution

```javascript
function sortColors(nums) {
  let low = 0;
  let current = 0;
  let high = nums.length - 1;

  while (current <= high) {
    if (nums[current] === 0) {
      [nums[low], nums[current]] = [nums[current], nums[low]];
      low++;
      current++;
    } else if (nums[current] === 1) {
      current++;
    } else {
      [nums[current], nums[high]] = [nums[high], nums[current]];
      high--;
    }
  }
}
```

The function modifies `nums` in place, matching the problem contract. It does not need to return the array.

---

## 4. Why each case behaves differently

### Case 1: current value is `0`

```javascript
[nums[low], nums[current]] = [nums[current], nums[low]];
low++;
current++;
```

The `0` belongs at the left boundary.

The value swapped from `low` is safe to skip:

- if `low === current`, it is the same processed `0`;
- if `low < current`, index `low` belongs to the confirmed-ones region, so the swapped value is `1`.

Therefore, both pointers advance.

### Case 2: current value is `1`

```javascript
current++;
```

The `1` already belongs in the middle region. No swap is needed.

### Case 3: current value is `2`

```javascript
[nums[current], nums[high]] = [nums[high], nums[current]];
high--;
```

The `2` moves to the right region.

Do **not** increment `current`. The value swapped in from `high` came from the unknown region and has not been classified yet. It could be `0`, `1`, or `2`.

This asymmetry is the most important detail in the algorithm.

---

## 5. Complete walkthrough

Input:

```text
[2, 0, 2, 1, 1, 0]
```

Initial pointers:

```text
low = 0, current = 0, high = 5
```

| Array state | `low` | `current` | `high` | Action |
| --- | ---: | ---: | ---: | --- |
| `[2,0,2,1,1,0]` | 0 | 0 | 5 | `2`: swap current/high |
| `[0,0,2,1,1,2]` | 0 | 0 | 4 | `0`: swap low/current; advance both |
| `[0,0,2,1,1,2]` | 1 | 1 | 4 | `0`: swap; advance both |
| `[0,0,2,1,1,2]` | 2 | 2 | 4 | `2`: swap current/high |
| `[0,0,1,1,2,2]` | 2 | 2 | 3 | `1`: advance current |
| `[0,0,1,1,2,2]` | 2 | 3 | 3 | `1`: advance current |

Now `current = 4` and `high = 3`, so the unknown region is empty.

---

## 6. Why the loop condition is `current <= high`

The unknown region includes both endpoints:

```text
[current, high]
```

When `current === high`, one unclassified element remains and must still be processed.

The algorithm stops only when:

```text
current > high
```

At that point, no unknown values remain.

---

## 7. Correctness reasoning

We maintain the region invariant:

```text
[0, low)             → all 0
[low, current)       → all 1
[current, high]      → unknown
(high, n)            → all 2
```

### Processing `0`

Swapping it to `low` extends the zero region. The value moved to `current` is known to be `1` when the pointers differ, so advancing `current` extends the classified middle region safely.

### Processing `1`

It already belongs directly before the unknown region. Advancing `current` adds it to the one region.

### Processing `2`

Swapping it to `high` extends the two region and decrementing `high` removes that position from the unknown region. `current` stays because the incoming value is still unknown.

Every iteration shrinks the unknown region by at least one position. When it is empty, the invariant says the entire array consists of zeros, followed by ones, followed by twos. Therefore, the array is sorted.

---

## 8. Complexity

- Time: **O(n)**
- Auxiliary space: **O(1)**
- Passes: one

Although a swapped-in value may be inspected later, each pointer moves only forward or backward through the array. The total number of iterations and swaps remains linear.

---

## 9. Why not use built-in sort?

```javascript
nums.sort((a, b) => a - b);
```

This would produce the correct ordering, but:

- it typically costs O(n log n);
- it ignores the special three-value structure;
- it violates the intended constraint and misses the partitioning pattern.

The point is to use domain knowledge to outperform general-purpose sorting.

---

## 10. Common mistakes

### Mistake 1: increment `current` after swapping with `high`

The incoming value has not been classified and must be examined.

### Mistake 2: fail to increment both pointers after processing `0`

Once the zero is placed, the current position is also known and should leave the unknown region.

### Mistake 3: use `current < high`

That skips the final unknown value when both pointers meet.

### Mistake 4: create three new arrays

That sorts correctly but uses O(n) extra space and misses the in-place requirement.

### Mistake 5: count correctly but claim one pass

Counting plus rewriting requires two passes, even though both are O(n).

### Mistake 6: return a new array instead of modifying `nums`

The LeetCode method is expected to change the input array in place.

### Mistake 7: confuse pointer meanings

Memorize the regions, not just the code. The pointer updates follow directly from the invariant.

---

## 11. Edge cases

- empty array
- one element
- all zeros
- all ones
- all twos
- already sorted
- reverse grouped order: `[2,2,1,1,0,0]`
- alternating colors
- a `2` swapped with another `2`

When a `2` swaps with another `2`, `current` remains fixed and `high` decreases. The same position is correctly examined again.

---

## 12. General partitioning pattern

The Dutch National Flag algorithm partitions values into three categories:

```text
less than pivot | equal to pivot | greater than pivot
```

Sort Colors is the fixed-category version:

```text
0 | 1 | 2
```

This pattern appears in:

- three-way quicksort partitioning;
- grouping negative, zero, and positive values;
- separating invalid, pending, and completed states;
- duplicate-heavy partition problems.

---

## 13. Interview narration

> “Because there are only three values, I’ll maintain four regions: finalized zeros, finalized ones, unknown values, and finalized twos. `low` marks where the next zero belongs, `current` inspects the unknown region, and `high` marks where the next two belongs. A zero swaps left and advances both pointers, a one advances current, and a two swaps right but does not advance current because the incoming value is still unknown.”

---

## 14. Quick test

```javascript
const first = [2, 0, 2, 1, 1, 0];
sortColors(first);
console.log(first); // [0, 0, 1, 1, 2, 2]

const second = [2, 0, 1];
sortColors(second);
console.log(second); // [0, 1, 2]

const third = [2, 2, 0, 0];
sortColors(third);
console.log(third); // [0, 0, 2, 2]
```

---

## 15. Notebook version

### Pattern

**Dutch National Flag / three-way partitioning**

### Regions

```text
[0, low)        = 0s
[low, current)  = 1s
[current, high] = unknown
(high, n)       = 2s
```

### Pointer actions

```text
0 → swap with low; low++; current++
1 → current++
2 → swap with high; high--
```

### Memory line

> After swapping with the unknown right side, inspect what came back.

### Complexity

```text
time: O(n)
space: O(1)
```

