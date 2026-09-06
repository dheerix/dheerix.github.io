# Grind 75 — 69: Trapping Rain Water

**Difficulty:** Hard  
**Primary pattern:** Two pointers + running boundary maxima  
**LeetCode:** 42  
**Target interview time:** 35 minutes  
**Language:** JavaScript

## Problem

Given `n` non-negative integers representing an elevation map, where every bar has width `1`, return how many units of rainwater can be trapped after raining.

Example:

```text
height = [0,1,0,2,1,0,1,3,2,1,2,1]
answer = 6
```

Water can remain above an index only when a sufficiently tall boundary exists on both its left and right.

---

## 1. Intuition

At any index `i`, the amount of water above the bar is determined by:

- the tallest bar somewhere to its left;
- the tallest bar somewhere to its right;
- the shorter of those two boundaries.

```text
water level at i = min(leftMax, rightMax)
```

The bar itself occupies part of that height, so:

```text
water[i] = min(leftMax[i], rightMax[i]) - height[i]
```

If this difference is negative, the bar traps no water. When maxima include the current bar, the expression is automatically non-negative.

### Why the shorter boundary matters

Imagine a container with walls of height `5` and `3`. Water spills over the height-`3` wall, so the water level cannot rise to `5`.

```text
bounded height = min(5, 3) = 3
```

This leads to three increasingly efficient approaches:

1. Scan left and right for every index.
2. Precompute left and right maxima.
3. Maintain those maxima with two pointers and constant extra space.

---

## 2. Brute Force — Scan Both Sides for Every Bar

For each index, find its maximum left boundary and maximum right boundary.

```js
function trap(height) {
  let totalWater = 0;

  for (let i = 0; i < height.length; i++) {
    let leftMax = 0;
    let rightMax = 0;

    for (let left = 0; left <= i; left++) {
      leftMax = Math.max(leftMax, height[left]);
    }

    for (let right = i; right < height.length; right++) {
      rightMax = Math.max(rightMax, height[right]);
    }

    totalWater += Math.min(leftMax, rightMax) - height[i];
  }

  return totalWater;
}
```

### Correct idea, repeated work

The formula is correct, but neighboring indices repeatedly scan nearly the same bars.

### Complexity

- Time: `O(n²)`.
- Space: `O(1)`.

---

## 3. Better Solution — Prefix and Suffix Maximum Arrays

Precompute the maximum height seen from each direction.

```js
function trap(height) {
  const n = height.length;
  if (n < 3) return 0;

  const leftMax = new Array(n);
  const rightMax = new Array(n);

  leftMax[0] = height[0];
  for (let i = 1; i < n; i++) {
    leftMax[i] = Math.max(leftMax[i - 1], height[i]);
  }

  rightMax[n - 1] = height[n - 1];
  for (let i = n - 2; i >= 0; i--) {
    rightMax[i] = Math.max(rightMax[i + 1], height[i]);
  }

  let totalWater = 0;

  for (let i = 0; i < n; i++) {
    totalWater += Math.min(leftMax[i], rightMax[i]) - height[i];
  }

  return totalWater;
}
```

### Complexity

- Time: `O(n)`.
- Space: `O(n)`.

This is often the easiest correct solution to derive. The optimal two-pointer method compresses these arrays into running variables.

---

## 4. Optimal Solution — Two Pointers

```js
/**
 * Returns the total units of trapped rainwater.
 *
 * @param {number[]} height
 * @return {number}
 */
function trap(height) {
  let left = 0;
  let right = height.length - 1;
  let leftMax = 0;
  let rightMax = 0;
  let totalWater = 0;

  while (left <= right) {
    if (leftMax <= rightMax) {
      leftMax = Math.max(leftMax, height[left]);
      totalWater += leftMax - height[left];
      left++;
    } else {
      rightMax = Math.max(rightMax, height[right]);
      totalWater += rightMax - height[right];
      right--;
    }
  }

  return totalWater;
}
```

---

## 5. The Key Two-Pointer Reasoning

This is the part to understand—not memorize.

At every step:

- `leftMax` is the tallest processed boundary from the left.
- `rightMax` is the tallest processed boundary from the right.

Suppose:

```text
leftMax <= rightMax
```

The right side already has a boundary at least as tall as `leftMax`. Therefore, for the current left position, the limiting boundary cannot be higher than `leftMax`. Whatever exists deeper on the right cannot change the amount finalized at `left`:

```text
water at left = leftMax - height[left]
```

So we can safely process `left` and move it inward.

Conversely, if:

```text
rightMax < leftMax
```

the left side already has a boundary at least as tall as `rightMax`. The current right position is limited by `rightMax`, so we process `right`.

### Decision rule

```text
Smaller known boundary determines the side that is safe to finalize.
```

---

## 6. Alternative Two-Pointer Form

Another common implementation compares the current endpoint heights:

```js
function trap(height) {
  let left = 0;
  let right = height.length - 1;
  let leftMax = 0;
  let rightMax = 0;
  let totalWater = 0;

  while (left < right) {
    if (height[left] <= height[right]) {
      leftMax = Math.max(leftMax, height[left]);
      totalWater += leftMax - height[left];
      left++;
    } else {
      rightMax = Math.max(rightMax, height[right]);
      totalWater += rightMax - height[right];
      right--;
    }
  }

  return totalWater;
}
```

Both versions are valid. Comparing running maxima makes the invariant more explicit; comparing endpoint heights is compact but can be harder to explain under interview pressure.

---

## 7. Walkthrough

Use a compact example:

```text
height = [4, 2, 0, 3, 2, 5]
```

Expected trapped water:

```text
index 1: min(4,5) - 2 = 2
index 2: min(4,5) - 0 = 4
index 3: min(4,5) - 3 = 1
index 4: min(4,5) - 2 = 2
total = 9
```

### Two-pointer execution

| Step | `left` | `right` | `leftMax` | `rightMax` | Side processed | Water added | Total |
| ---: | ---: | ---: | ---: | ---: | --- | ---: | ---: |
| 1 | 0 | 5 | 0 | 0 | left (`0 <= 0`) | `4 - 4 = 0` | 0 |
| 2 | 1 | 5 | 4 | 0 | right | `5 - 5 = 0` | 0 |
| 3 | 1 | 4 | 4 | 5 | left | `4 - 2 = 2` | 2 |
| 4 | 2 | 4 | 4 | 5 | left | `4 - 0 = 4` | 6 |
| 5 | 3 | 4 | 4 | 5 | left | `4 - 3 = 1` | 7 |
| 6 | 4 | 4 | 4 | 5 | left | `4 - 2 = 2` | 9 |

Return `9`.

The algorithm never needs the full `leftMax[]` and `rightMax[]` arrays. It computes only the boundary needed for the side that can be finalized.

---

## 8. Correctness Proof

We prove that the two-pointer algorithm adds the exact trapped water at every index.

### Invariant

Before each iteration:

- all indices outside `[left, right]` have been processed correctly;
- `leftMax` is the maximum height encountered from the original left boundary through the processed left region;
- `rightMax` is the maximum height encountered from the original right boundary through the processed right region.

### Case 1: `leftMax <= rightMax`

There is a known right boundary of height `rightMax`, which is at least `leftMax`. Thus, the shorter relevant boundary for the current left index is `leftMax`. No unseen bar can reduce this established boundary, and a taller unseen right bar cannot raise the limiting boundary above `leftMax`.

After updating `leftMax` with `height[left]`, the exact water at `left` is:

```text
leftMax - height[left]
```

The algorithm adds this amount and advances `left`, preserving the invariant.

### Case 2: `rightMax < leftMax`

Symmetrically, a known left boundary is at least as tall as `rightMax`, so the exact water at `right` is:

```text
rightMax - height[right]
```

The algorithm adds it and decreases `right`, preserving the invariant.

### Termination

Every iteration processes exactly one previously unprocessed index. When the pointers cross, every index has been processed exactly once and its exact trapped water has been added. Therefore, `totalWater` is correct.

---

## 9. Complexity

### Time

```text
O(n)
```

Each pointer moves only inward. Every index is processed once.

### Space

```text
O(1)
```

Only two pointers, two running maxima, and one accumulator are stored.

---

## 10. Common Mistakes

### Mistake 1: Using the taller boundary

Water is limited by the shorter boundary:

```js
Math.min(leftMax, rightMax)
```

### Mistake 2: Looking only at immediate neighbors

A bar can trap water because of distant boundaries. Adjacent bars do not contain enough information.

### Mistake 3: Moving the taller side

Process the side with the smaller established maximum. That side's water can be finalized safely.

### Mistake 4: Adding a negative quantity

Update the side's maximum before calculating water:

```js
leftMax = Math.max(leftMax, height[left]);
totalWater += leftMax - height[left];
```

This ensures the difference is non-negative.

### Mistake 5: Calling the two-pointer method obvious without explaining safety

The interview signal is the invariant: a known taller boundary on the opposite side guarantees that the smaller running maximum is the limiting wall.

### Mistake 6: Confusing horizontal distance with water at an index

Because every bar has width `1`, water at an index is a height difference. Sum that difference across indices.

### Mistake 7: Assuming two nested pointer movements imply quadratic time

Neither pointer moves backward; the total number of movements is linear.

### Mistake 8: Mutating the input unnecessarily

The optimal solution only reads `height`.

---

## 11. Edge Cases

### Empty array

```text
[] -> 0
```

The loop does not run.

### Fewer than three bars

No container can be formed:

```text
[4] -> 0
[4,2] -> 0
```

### Strictly increasing heights

```text
[1,2,3,4] -> 0
```

There is no right boundary higher than an earlier valley.

### Strictly decreasing heights

```text
[4,3,2,1] -> 0
```

There is no sufficient boundary on the right.

### All heights equal

```text
[3,3,3] -> 0
```

### Simple bowl

```text
[3,0,3] -> 3
```

### Multiple bowls

The algorithm naturally accumulates water across separate trapped regions.

### Zero-height bars

They are valid and may trap water when bounded.

---

## 12. Interview Explanation

> At each index, trapped water is `min(maxLeft, maxRight) - height[i]`. The prefix/suffix-array solution computes those maxima in `O(n)` time and `O(n)` space. To remove the arrays, I use two pointers with running maxima. If `leftMax <= rightMax`, the right side already provides a boundary at least as high as `leftMax`, so the current left position is limited by `leftMax` regardless of unseen interior bars. I can safely add `leftMax - height[left]` and move left inward. Otherwise I do the symmetric operation on the right. Every index is finalized once, giving `O(n)` time and `O(1)` extra space.

### Strong derivation path in an interview

1. State the per-index formula.
2. Give the `O(n²)` scanning approach.
3. Improve to prefix/suffix maxima in `O(n)` space.
4. Observe that only the smaller boundary is needed at each step.
5. Compress the arrays into two running maxima.

This shows reasoning rather than recall.

---

## 13. Notebook Version

### Recognition

```text
Water above i = shorter boundary - bar height
```

### Formula

```text
water[i] = min(leftMax[i], rightMax[i]) - height[i]
```

### Two-pointer rule

```text
leftMax <= rightMax -> finalize left
rightMax < leftMax  -> finalize right
```

### JavaScript

```js
function trap(height) {
  let left = 0;
  let right = height.length - 1;
  let leftMax = 0;
  let rightMax = 0;
  let water = 0;

  while (left <= right) {
    if (leftMax <= rightMax) {
      leftMax = Math.max(leftMax, height[left]);
      water += leftMax - height[left];
      left++;
    } else {
      rightMax = Math.max(rightMax, height[right]);
      water += rightMax - height[right];
      right--;
    }
  }

  return water;
}
```

### Complexity

```text
Time:  O(n)
Space: O(1)
```

### Invariant

The side with the smaller running maximum has a sufficiently tall known boundary on the opposite side, so its current water can be finalized.

---

## 14. Memory Line

**Finalize the shorter wall; the taller side already guarantees the boundary.**

