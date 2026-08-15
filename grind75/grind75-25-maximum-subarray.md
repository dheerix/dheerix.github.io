# Grind 75 — 25: Maximum Subarray

**Difficulty:** Medium  
**Primary pattern:** Dynamic programming / Kadane's algorithm  
**LeetCode:** https://leetcode.com/problems/maximum-subarray/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given an integer array, return the largest possible sum of a **non-empty contiguous subarray**.

```text
nums = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
```

The best subarray is:

```text
[4, -1, 2, 1]
sum = 6
```

“Contiguous” means the chosen elements occupy consecutive indices. We cannot skip negative values inside a selected interval.

---

## 2. Brute-force approaches

### Generate every subarray and sum each separately

There are O(n²) subarrays, and summing each can take O(n), producing O(n³) time.

### Reuse a running sum for each start index

```javascript
function maxSubArrayBruteForce(nums) {
  let bestSum = -Infinity;

  for (let start = 0; start < nums.length; start++) {
    let currentSum = 0;

    for (let end = start; end < nums.length; end++) {
      currentSum += nums[end];
      bestSum = Math.max(bestSum, currentSum);
    }
  }

  return bestSum;
}
```

- Time: **O(n²)**.
- Extra space: **O(1)**.

The optimal solution asks what information from earlier positions is actually needed for the next decision.

---

## 3. Define the DP state precisely

Let:

```text
bestEndingHere[i] = maximum sum of a non-empty subarray
                    that must end at index i
```

The words **must end at `i`** are crucial. This restricted state creates a simple recurrence.

A subarray ending at `i` has only two possibilities:

1. Start fresh at `nums[i]`.
2. Extend the best subarray ending at `i - 1`.

Therefore:

```text
bestEndingHere[i] = max(
  nums[i],
  bestEndingHere[i - 1] + nums[i]
)
```

This is Kadane's algorithm.

---

## 4. Intuition: extend or restart

Suppose the best sum ending immediately before the current number is negative.

```text
previous ending sum = -5
current value = 4
```

Extending gives:

```text
-5 + 4 = -1
```

Starting at `4` gives `4`, which is better. A negative prefix is baggage: it can only reduce every future sum that includes it.

If the previous ending sum is positive, it helps:

```text
previous ending sum = 3
current value = 4
extend = 7 > restart = 4
```

At every position:

> Extend a helpful history; discard a harmful history.

---

## 5. Local state versus global answer

`bestEndingHere` answers:

> What is the best subarray that ends at this exact position?

But the overall best subarray may have ended earlier. Therefore maintain:

```text
bestEndingHere → best sum forced to end at current index
bestOverall    → best sum seen at any ending index
```

This local-versus-global distinction is central to many dynamic-programming problems.

---

## 6. Optimal JavaScript solution

```javascript
function maxSubArray(nums) {
  let bestEndingHere = nums[0];
  let bestOverall = nums[0];

  for (let i = 1; i < nums.length; i++) {
    bestEndingHere = Math.max(
      nums[i],
      bestEndingHere + nums[i],
    );

    bestOverall = Math.max(bestOverall, bestEndingHere);
  }

  return bestOverall;
}
```

---

## 7. Dry run

```text
nums = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
```

| Value | Extend previous | Restart | Best ending here | Best overall |
|---:|---:|---:|---:|---:|
| -2 | — | -2 | -2 | -2 |
| 1 | -1 | 1 | 1 | 1 |
| -3 | -2 | -3 | -2 | 1 |
| 4 | 2 | 4 | 4 | 4 |
| -1 | 3 | -1 | 3 | 4 |
| 2 | 5 | 2 | 5 | 5 |
| 1 | 6 | 1 | 6 | 6 |
| -5 | 1 | -5 | 1 | 6 |
| 4 | 5 | 4 | 5 | 6 |

Return `6`.

Notice that after reaching `6`, the later values do not improve the global answer, even though `bestEndingHere` continues to evolve.

---

## 8. Why initialize from `nums[0]`?

The selected subarray must be non-empty. If both variables were initialized to zero, an all-negative input would incorrectly return zero—the sum of an empty subarray that is not allowed.

```text
nums = [-5, -2, -8]
correct answer = -2
incorrect zero initialization = 0
```

Initializing from the first actual value makes the state valid for all-negative arrays.

---

## 9. Code walkthrough

### `bestEndingHere = nums[0]`

At index zero, the only non-empty subarray ending there is `[nums[0]]`.

### Recurrence

```javascript
Math.max(nums[i], bestEndingHere + nums[i])
```

Every contiguous subarray ending at `i` either begins at `i` or includes index `i - 1`. If it includes `i - 1`, extending the maximum-sum subarray ending there is always at least as good as extending any worse one.

### Global update

The recurrence overwrites local state. Before moving on, compare it with the best answer found at any earlier ending position.

### Why no DP array?

State `i` depends only on state `i - 1`. Older values are unnecessary, so one rolling variable replaces the array.

---

## 10. Correctness reasoning

Inductive invariant:

> After processing index `i`, `bestEndingHere` is the maximum sum of any non-empty subarray ending exactly at `i`, and `bestOverall` is the maximum sum of any non-empty subarray contained in indices `0...i`.

At index `i`, every ending subarray either consists solely of `nums[i]` or extends a subarray ending at `i - 1`. By the inductive hypothesis, extending `bestEndingHere` is optimal among all extensions. Taking the maximum of restart and extend therefore computes the correct local state.

Updating `bestOverall` with that local state considers every possible ending index. Thus, after the last index, `bestOverall` is the maximum subarray sum for the entire array.

---

## 11. Complexity

- **Time: O(n)** — one pass through the array.
- **Auxiliary space: O(1)** — two rolling sums are stored.

A full DP table would use O(n) space but provides no benefit when only the final maximum sum is required.

---

## 12. Alternative expression

The recurrence can be written as:

```javascript
bestEndingHere =
  Math.max(bestEndingHere, 0) + nums[i];
```

If the previous ending sum is negative, replace it with zero before adding the current value. This is mathematically equivalent.

However, the explicit restart-versus-extend form:

```javascript
Math.max(nums[i], bestEndingHere + nums[i])
```

more clearly communicates the two structural choices and handles the non-empty condition visibly.

---

## 13. Follow-up: return the subarray indices

Track where the current candidate began and save the best boundaries whenever the global answer improves.

```javascript
function maxSubArrayWithIndices(nums) {
  let bestEndingHere = nums[0];
  let bestOverall = nums[0];

  let currentStart = 0;
  let bestStart = 0;
  let bestEnd = 0;

  for (let i = 1; i < nums.length; i++) {
    if (nums[i] > bestEndingHere + nums[i]) {
      bestEndingHere = nums[i];
      currentStart = i;
    } else {
      bestEndingHere += nums[i];
    }

    if (bestEndingHere > bestOverall) {
      bestOverall = bestEndingHere;
      bestStart = currentStart;
      bestEnd = i;
    }
  }

  return {
    sum: bestOverall,
    start: bestStart,
    end: bestEnd,
    values: nums.slice(bestStart, bestEnd + 1),
  };
}
```

The state transition is unchanged; we retain provenance alongside each sum.

---

## 14. Is Kadane's algorithm greedy or DP?

It can be viewed both ways:

- **DP view:** `bestEndingHere[i]` is defined by a recurrence over `i - 1`.
- **Greedy view:** discard a negative accumulated prefix because it cannot help any future subarray.

For interviews, explaining the DP state and recurrence gives the most rigorous derivation. The greedy intuition explains why restarting is safe.

---

## 15. Common mistakes

1. **Initializing the answer to zero.** This fails for all-negative arrays.
2. **Returning `bestEndingHere`.** The best subarray may have ended earlier; return `bestOverall`.
3. **Summing only positive values.** The chosen subarray must be contiguous and may include negative bridges.
4. **Resetting whenever a current value is negative.** A negative value can remain inside the best subarray if the accumulated sum stays beneficial.
5. **Treating this as a subsequence problem.** Elements cannot be skipped inside the chosen range.
6. **Using O(n²) enumeration after recognizing repeated state.** The previous best-ending sum is sufficient.
7. **Allocating a DP array unnecessarily.** Only the preceding state is needed.
8. **Confusing maximum subarray with maximum product subarray.** Products require tracking both maximum and minimum due to negative signs.

---

## 16. What to say in an interview

> “I’ll define `bestEndingHere` as the maximum sum of a non-empty subarray that must end at the current index. Such a subarray either starts at the current value or extends the best subarray ending one position earlier, so the recurrence is `max(current, previousEnding + current)`. I also track a global maximum because the best subarray may end anywhere. This is Kadane's algorithm: O(n) time and O(1) space.”

If asked about negative history:

> “A negative prefix can only reduce every future sum that includes it, so restarting is always at least as good.”

---

## 17. Pattern recognition

Think **Kadane / rolling one-dimensional DP** when:

- the problem asks for an optimal contiguous segment;
- the current segment can either extend previous state or restart;
- a harmful prefix should be discarded;
- local ending state and global answer are different.

Useful design question:

> If the solution must end at the current index, what are all possible ways it could have arrived here?

Memory cue:

> At each number: extend or restart; then update the global best.

---

## 18. Edge cases

| Input | Result | Reason |
|---|---:|---|
| `[5]` | 5 | Only non-empty subarray |
| `[-5]` | -5 | Empty subarray not allowed |
| `[-5, -2, -8]` | -2 | Best single element |
| `[1, 2, 3]` | 6 | Entire array |
| `[5, -1, 5]` | 9 | Negative bridge is worth keeping |
| `[5, -10, 6]` | 6 | Restart after harmful prefix |
| `[0, 0]` | 0 | Valid non-empty zero sum |

---

## 19. Notebook-ready notes

### 📚 Concept

**Maximum Subarray — Kadane's algorithm**

```text
State: best sum of subarray ending exactly here

bestEndingHere = max(
  current value,              // restart
  previous ending + current,  // extend
)

bestOverall = max(bestOverall, bestEndingHere)
```

### 🧠 My understanding

Every subarray ending at the current index either starts there or extends a subarray ending immediately before it. I keep the better choice. Because the best subarray may finish at any index, I separately retain the best local result ever seen.

### 💼 Interview line

> “I’ll optimize the subarray forced to end here, then compare that local answer with the global best.”

### ⚠️ Traps

- Initialize from the first value for all-negative input.
- Return global best, not final local state.
- Contiguous means negative values cannot simply be skipped.
- Only the previous DP state is needed.

---

## 20. Dheerix Glance

```text
MAXIMUM SUBARRAY

Pattern:          Kadane / 1D DP
Local state:      best sum ending at current index
Choices:          restart here OR extend previous
Transition:       max(current, previousEnding + current)
Global state:     best local result seen anywhere
Initialization:   nums[0], not 0
Time:             O(n)
Auxiliary space:  O(1)
Memory cue:       “Extend or restart; preserve global best.”
```

---

## 21. Recall test

Without looking back:

1. What exactly does `bestEndingHere` mean?
2. What are the only two possibilities for a subarray ending at index `i`?
3. Why can a negative prefix be discarded?
4. Why is `bestOverall` separate from `bestEndingHere`?
5. Why must initialization use `nums[0]` rather than zero?
6. Why is a full DP array unnecessary?
7. How would you also return the chosen indices?
8. State the induction invariant in one sentence.

