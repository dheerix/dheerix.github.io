# Grind 75 — 51. Partition Equal Subset Sum

## Problem

Given an array of positive integers, determine whether it can be divided into two subsets whose sums are equal.

Example:

```text
nums = [1, 5, 11, 5]

true because:
[1, 5, 5] has sum 11
[11]      has sum 11
```

Each array element must belong to exactly one of the two subsets.

---

## 1. Reduce partitioning to subset sum

Let the total array sum be `S`.

If two subsets have equal sums, each must sum to:

```text
S / 2
```

Therefore:

1. if `S` is odd, equal partition is impossible;
2. if `S` is even, ask whether any subset sums to `S / 2`.

Why is finding only one subset enough?

If one subset sums to `S / 2`, every element not chosen automatically forms the other subset, whose sum is:

```text
S - S/2 = S/2
```

The problem is therefore a **0/1 subset-sum** problem.

---

## 2. DP state

Let:

```text
dp[sum] = whether the processed numbers can form this sum
```

Initially:

```text
dp[0] = true
```

The empty subset forms sum zero.

For each number `num`, any previously reachable sum can create:

```text
sum + num
```

Equivalently, sum `s` becomes reachable when:

```text
dp[s - num] was reachable before using num
```

---

## 3. Recommended JavaScript solution

```javascript
function canPartition(nums) {
  const total = nums.reduce((sum, number) => sum + number, 0);

  if (total % 2 !== 0) {
    return false;
  }

  const target = total / 2;
  const dp = new Array(target + 1).fill(false);
  dp[0] = true;

  for (const number of nums) {
    for (let sum = target; sum >= number; sum--) {
      dp[sum] = dp[sum] || dp[sum - number];
    }

    if (dp[target]) {
      return true;
    }
  }

  return dp[target];
}
```

---

## 4. The most important detail: iterate sums backward

Use:

```javascript
for (let sum = target; sum >= number; sum--) {
  // Update reachable sums from high to low.
}
```

This guarantees that `dp[sum - number]` still represents results from **before the current number was processed**.

Therefore, each array element can be used at most once.

### What goes wrong if we iterate forward?

Suppose:

```text
number = 2
dp[0] = true
```

With a forward loop:

```text
dp[2] becomes true from dp[0]
then dp[4] becomes true from the newly updated dp[2]
then dp[6] becomes true from the newly updated dp[4]
```

The same single `2` was effectively reused several times.

Forward iteration models **unbounded reuse**, like Coin Change. Backward iteration models **0/1 choice**, where each item is available once.

---

## 5. Walkthrough: `[1, 5, 11, 5]`

```text
total = 22
target = 11
```

Initially reachable:

```text
{0}
```

### Process `1`

```text
reachable = {0, 1}
```

### Process `5`

From the previous states:

```text
0 + 5 = 5
1 + 5 = 6
```

```text
reachable = {0, 1, 5, 6}
```

### Process `11`

```text
0 + 11 = 11
```

The target becomes reachable, so return `true` immediately.

---

## 6. Walkthrough: impossible partition

```text
nums = [1, 2, 3, 5]
total = 11
```

The total is odd. Two integer subset sums cannot both equal `11 / 2`, so the answer is immediately `false`.

This parity check is both a proof and an optimization.

---

## 7. Visualizing the transition

Suppose target is `7`, and before processing number `3` these sums are reachable:

```text
sum: 0 1 2 3 4 5 6 7
dp:  T F T F T F F F
```

Process `3` backward:

```text
2 + 3 = 5 → dp[5] becomes true
4 + 3 = 7 → dp[7] becomes true
0 + 3 = 3 → dp[3] becomes true
```

Afterward:

```text
sum: 0 1 2 3 4 5 6 7
dp:  T F T T T T F T
```

Backward iteration ensures the new `dp[3]` is not reused during the same number's update to create `dp[6]`.

---

## 8. Correctness reasoning

We maintain this invariant:

> After processing the first `i` numbers, `dp[s]` is true exactly when some subset of those `i` numbers sums to `s`.

### Base case

Before processing any numbers, only sum zero is possible through the empty subset. Thus `dp[0] = true` and all other states are false.

### Processing one number

For each sum `s`, there are two possibilities:

1. Do not use the current number: `dp[s]` remains as it was.
2. Use the current number: sum `s` is possible if `s - number` was possible before processing this number.

The transition:

```text
dp[s] = dp[s] OR dp[s - number]
```

captures both choices. Backward iteration prevents the current number from contributing more than once.

Therefore, after every number, the invariant remains true. At the end, `dp[target]` is true exactly when a subset sums to half the total, which is equivalent to an equal partition.

---

## 9. Complexity

Let:

- `n` be the number of values;
- `S` be their total sum;
- target = `S / 2`.

- Time: **O(n × target)**, equivalent to **O(nS)** up to a factor of two
- Space: **O(target)**

This is called **pseudo-polynomial** time: it is polynomial in the numeric sum, not in the number of bits required to represent that sum.

---

## 10. Two-dimensional DP version

A 2D table makes the 0/1 choice explicit.

```javascript
function canPartition2D(nums) {
  const total = nums.reduce((sum, number) => sum + number, 0);
  if (total % 2 !== 0) return false;

  const target = total / 2;
  const dp = Array.from(
    { length: nums.length + 1 },
    () => new Array(target + 1).fill(false)
  );

  for (let i = 0; i <= nums.length; i++) {
    dp[i][0] = true;
  }

  for (let i = 1; i <= nums.length; i++) {
    const number = nums[i - 1];

    for (let sum = 1; sum <= target; sum++) {
      dp[i][sum] = dp[i - 1][sum];

      if (sum >= number) {
        dp[i][sum] =
          dp[i][sum] || dp[i - 1][sum - number];
      }
    }
  }

  return dp[nums.length][target];
}
```

State:

```text
dp[i][sum] = whether first i numbers can make sum
```

The 1D solution compresses the previous row into one array. Backward iteration is what preserves the previous-row semantics.

---

## 11. Set-of-reachable-sums alternative

A `Set` can make the concept intuitive:

```javascript
function canPartitionWithSet(nums) {
  const total = nums.reduce((sum, number) => sum + number, 0);
  if (total % 2 !== 0) return false;

  const target = total / 2;
  let reachable = new Set([0]);

  for (const number of nums) {
    const nextReachable = new Set(reachable);

    for (const sum of reachable) {
      const newSum = sum + number;

      if (newSum === target) return true;
      if (newSum < target) nextReachable.add(newSum);
    }

    reachable = nextReachable;
  }

  return reachable.has(target);
}
```

Creating `nextReachable` prevents the current number from being reused during the same iteration. The boolean-array version is typically faster and more memory-efficient when the target is reasonably bounded.

---

## 12. Top-down memoization alternative

At each index, choose to include or exclude the current number.

```javascript
function canPartitionTopDown(nums) {
  const total = nums.reduce((sum, number) => sum + number, 0);
  if (total % 2 !== 0) return false;

  const target = total / 2;
  const memo = new Map();

  function search(index, remaining) {
    if (remaining === 0) return true;
    if (index === nums.length || remaining < 0) return false;

    const key = `${index},${remaining}`;
    if (memo.has(key)) return memo.get(key);

    const result =
      search(index + 1, remaining - nums[index]) ||
      search(index + 1, remaining);

    memo.set(key, result);
    return result;
  }

  return search(0, target);
}
```

Memoization avoids recomputing the same `(index, remaining)` state. Bottom-up DP avoids recursion limits and usually has lower overhead.

---

## 13. Difference from Coin Change

The DP arrays may look similar, but the item rules are different.

| Coin Change | Partition Equal Subset Sum |
| --- | --- |
| A coin may be reused | Each array element is used once |
| Often iterate sums forward | Iterate sums backward |
| Unbounded knapsack | 0/1 knapsack |

Pointer direction is not a coding trick—it expresses the mathematical reuse rule.

---

## 14. Common mistakes

### Mistake 1: skip the odd-total check

An odd total can never split equally.

### Mistake 2: iterate sums forward

That reuses the current element multiple times.

### Mistake 3: start with every DP state false

`dp[0]` must be true so reachable sums can begin growing.

### Mistake 4: allocate DP up to the total sum

Only sums through `total / 2` matter.

### Mistake 5: think the two subsets must have equal sizes

Only their sums must match.

### Mistake 6: track array values rather than positions conceptually

Duplicate values are separate elements and may each be used once.

### Mistake 7: call the complexity polynomial without qualification

It is pseudo-polynomial in the numeric target.

---

## 15. Edge cases

- one value → normally false because the other subset cannot match it
- two equal values → true
- odd total → false
- duplicate values
- one value equals half the total → true
- many small numbers
- all values positive, as guaranteed by the problem

The positive-number constraint lets us ignore sums greater than the target safely.

---

## 16. Interview narration

> “If the total is odd, equal partition is impossible. Otherwise, I only need to know whether one subset reaches half the total; the remaining elements automatically form the other half. I’ll use boolean subset-sum DP where `dp[s]` means sum `s` is reachable. For each number I update sums backward so states created by that number cannot reuse it during the same iteration.”

---

## 17. Pattern recognition

Use 0/1 knapsack-style DP when:

- each item can be selected at most once;
- you need to reach a target capacity or sum;
- the state depends on including or excluding each item.

General boolean transition:

```text
dp[capacity] = dp[capacity]
               OR
               dp[capacity - item]
```

General rule:

```text
0/1 use → iterate capacity backward
unlimited use → iterate capacity forward
```

---

## 18. Quick test

```javascript
console.log(canPartition([1, 5, 11, 5])); // true
console.log(canPartition([1, 2, 3, 5]));  // false
console.log(canPartition([1, 1]));        // true
console.log(canPartition([2, 2, 3, 5]));  // false
```

---

## 19. Notebook version

### Pattern

**0/1 knapsack boolean DP**

### Reduction

```text
equal partition ⇔ subset sum = total / 2
```

### State

```text
dp[sum] = processed numbers can form sum
```

### Base case

```text
dp[0] = true
```

### Transition

```javascript
dp[sum] = dp[sum] || dp[sum - number];
```

### Critical direction

```text
iterate sum backward so each number is used once
```

### Memory line

> Half the total is the target; backward DP protects the 0/1 rule.

### Complexity

```text
time: O(n × target)
space: O(target)
```
