# Grind 75 — 75: Largest Rectangle in Histogram

**Difficulty:** Hard  
**Primary pattern:** Monotonic increasing stack  
**LeetCode:** 84  
**Target interview time:** 35 minutes  
**Language:** JavaScript

## Problem

Given an array `heights`, where `heights[i]` is the height of a histogram bar of width `1`, return the area of the largest rectangle that can be formed using contiguous bars.

Example:

```text
heights = [2,1,5,6,2,3]
answer = 10
```

The largest rectangle uses the bars of heights `5` and `6`:

```text
height = 5
width  = 2
area   = 10
```

---

## 1. Intuition

Choose any bar as the limiting height of a rectangle.

That rectangle can extend:

- left until the first bar shorter than it;
- right until the first bar shorter than it.

If those shorter boundaries are at indices `leftSmaller` and `rightSmaller`, then:

```text
width = rightSmaller - leftSmaller - 1
area  = height[i] × width
```

So the real problem is:

```text
For every bar, where is the first smaller bar on each side?
```

A monotonic increasing stack answers this incrementally.

### Key event

When a shorter bar arrives, it closes every taller bar on the stack. Those taller bars cannot extend through the new shorter bar, so their maximum possible rectangles can now be finalized.

```text
increasing/equal height -> rectangle may still grow, push
smaller height          -> taller rectangles must end, pop
```

---

## 2. Brute Force — Expand from Every Bar

Treat each bar as the limiting height and scan outward until a shorter bar appears.

```js
function largestRectangleArea(heights) {
  let maximumArea = 0;

  for (let i = 0; i < heights.length; i++) {
    let left = i;
    let right = i;

    while (left > 0 && heights[left - 1] >= heights[i]) {
      left--;
    }

    while (
      right < heights.length - 1 &&
      heights[right + 1] >= heights[i]
    ) {
      right++;
    }

    const width = right - left + 1;
    maximumArea = Math.max(maximumArea, heights[i] * width);
  }

  return maximumArea;
}
```

### Complexity

- Time: `O(n²)` in a monotonic or equal-height histogram.
- Space: `O(1)`.

Neighboring bars repeatedly scan the same ranges.

---

## 3. Better Solution — Precompute Smaller Boundaries

Use monotonic stacks in two passes:

- one pass for the first smaller bar on the left;
- one pass for the first smaller bar on the right.

```js
function largestRectangleArea(heights) {
  const n = heights.length;
  const leftSmaller = new Array(n).fill(-1);
  const rightSmaller = new Array(n).fill(n);
  const stack = [];

  for (let i = 0; i < n; i++) {
    while (
      stack.length > 0 &&
      heights[stack[stack.length - 1]] >= heights[i]
    ) {
      stack.pop();
    }

    if (stack.length > 0) {
      leftSmaller[i] = stack[stack.length - 1];
    }

    stack.push(i);
  }

  stack.length = 0;

  for (let i = n - 1; i >= 0; i--) {
    while (
      stack.length > 0 &&
      heights[stack[stack.length - 1]] >= heights[i]
    ) {
      stack.pop();
    }

    if (stack.length > 0) {
      rightSmaller[i] = stack[stack.length - 1];
    }

    stack.push(i);
  }

  let maximumArea = 0;

  for (let i = 0; i < n; i++) {
    const width = rightSmaller[i] - leftSmaller[i] - 1;
    maximumArea = Math.max(maximumArea, heights[i] * width);
  }

  return maximumArea;
}
```

### Complexity

- Time: `O(n)`.
- Space: `O(n)` for the stack and boundary arrays.

The optimal one-pass method calculates areas at the moment their right boundary becomes known, eliminating the two boundary arrays.

---

## 4. Optimal Solution — One-Pass Monotonic Stack

Store pairs:

```text
[startIndex, height]
```

`startIndex` is the farthest left position where a rectangle of that height can begin.

```js
/**
 * Returns the largest rectangle area in a histogram.
 *
 * @param {number[]} heights
 * @return {number}
 */
function largestRectangleArea(heights) {
  const stack = [];
  let maximumArea = 0;

  // The final zero-height sentinel flushes all remaining bars.
  for (let index = 0; index <= heights.length; index++) {
    const currentHeight = index === heights.length ? 0 : heights[index];
    let startIndex = index;

    while (
      stack.length > 0 &&
      stack[stack.length - 1][1] > currentHeight
    ) {
      const [rectangleStart, rectangleHeight] = stack.pop();
      const width = index - rectangleStart;

      maximumArea = Math.max(
        maximumArea,
        rectangleHeight * width
      );

      // The shorter current bar can inherit this farther-left start.
      startIndex = rectangleStart;
    }

    stack.push([startIndex, currentHeight]);
  }

  return maximumArea;
}
```

---

## 5. What the Stack Represents

The stack maintains nondecreasing heights.

Each pair:

```text
[start, height]
```

means:

> A rectangle of this height can extend from `start` through the most recently processed index.

Example after processing `[2,1,5,6]`:

```text
stack = [
  [0,1],
  [2,5],
  [3,6]
]
```

Interpretation:

- height `1` can extend from index `0`;
- height `5` can extend from index `2`;
- height `6` can extend from index `3`.

The original height `2` was popped when height `1` arrived, and height `1` inherited its start index `0`.

---

## 6. Why a Pop Finalizes the Area

Suppose a stack entry is:

```text
[start, height]
```

and the current bar at `index` is shorter than `height`.

Then:

- every bar from `start` through `index - 1` is at least `height`;
- the current bar at `index` is too short;
- therefore the rectangle of `height` cannot extend farther right.

Its maximum width is now known:

```text
width = index - start
```

So its maximum area is:

```text
area = height × (index - start)
```

This is why area is computed when a bar is popped, not when it is pushed.

---

## 7. Why the Current Bar Inherits an Earlier Start

Consider:

```text
heights = [5, 6, 2]
```

When `2` arrives:

- pop height `6`, whose start is `1`;
- pop height `5`, whose start is `0`.

Although `2` originally appears at index `2`, it can extend left across both taller bars:

```text
[5, 6, 2]
 all are >= 2
```

Therefore, push:

```text
[0, 2]
```

not `[2,2]`.

The `startIndex` variable carries the earliest popped start forward.

---

## 8. Why Add a Sentinel Zero

In an increasing histogram:

```text
[1,2,3,4]
```

no real bar is shorter than the stack top, so nothing would be popped during the main scan.

An imaginary height `0` after the final bar is shorter than every positive height and forces all remaining rectangles to be evaluated.

```js
const currentHeight =
  index === heights.length ? 0 : heights[index];
```

This avoids a separate cleanup loop.

---

## 9. Walkthrough

```text
heights = [2,1,5,6,2,3]
```

### `index = 0`, height `2`

```text
push [0,2]
stack: [[0,2]]
```

### `index = 1`, height `1`

Pop `[0,2]`:

```text
area = 2 × (1 - 0) = 2
```

Height `1` inherits start `0`:

```text
push [0,1]
```

### `index = 2`, height `5`

```text
push [2,5]
```

### `index = 3`, height `6`

```text
push [3,6]
```

### `index = 4`, height `2`

Pop `[3,6]`:

```text
area = 6 × (4 - 3) = 6
```

Pop `[2,5]`:

```text
area = 5 × (4 - 2) = 10
```

Height `2` inherits start `2`:

```text
push [2,2]
```

### `index = 5`, height `3`

```text
push [5,3]
```

### Sentinel at `index = 6`, height `0`

Pop remaining positive heights:

```text
height 3: area = 3 × (6 - 5) = 3
height 2: area = 2 × (6 - 2) = 8
height 1: area = 1 × (6 - 0) = 6
```

Maximum area remains `10`.

---

## 10. Correctness Proof

We prove that the algorithm returns the largest rectangle area.

### Stack invariant

After processing each index, stack heights are nondecreasing. For every pair `[start, height]`, all processed bars from `start` through the current index have height at least `height`, so a rectangle of that height can span that range.

### Popped rectangles are finalized correctly

When a current bar is shorter than the stack top, the current index is the first position to the right that cannot support the popped height. The stored `start` is the first position after a smaller boundary on the left. Therefore, `index - start` is the maximum possible width for a rectangle using that popped height.

### No candidate is missed

Every bar is pushed. It is eventually popped either by a shorter real bar or by the final zero sentinel. At that moment, its maximum-width rectangle is evaluated.

### Start inheritance is correct

When taller bars are popped, the current shorter height can extend across every range those bars occupied because all those bars are at least as tall as the current height. Assigning the earliest popped start therefore records exactly the current height's farthest valid left boundary.

### Conclusion

Every possible limiting height has its maximum-width rectangle evaluated exactly when its right boundary becomes known. The algorithm retains the maximum of these areas, so it returns the largest rectangle in the histogram.

---

## 11. Complexity

### Time

```text
O(n)
```

Although a `while` loop is nested inside the `for` loop, each bar is pushed once and popped at most once. Total stack operations are linear.

### Space

```text
O(n)
```

An increasing histogram can place every bar on the stack before the sentinel flushes it.

---

## 12. Common Mistakes

### Mistake 1: Using the popped index as width directly

With `[start, height]`, width is:

```js
index - start
```

### Mistake 2: Forgetting to inherit the popped start

Without:

```js
startIndex = rectangleStart;
```

the current shorter bar cannot extend left far enough, and large rectangles are missed.

### Mistake 3: Computing area when pushing

The right boundary is not known yet. Finalize area only when a shorter bar causes a pop.

### Mistake 4: Forgetting the final flush

Use a sentinel `0` or a cleanup loop so increasing suffixes are evaluated.

### Mistake 5: Calling the nested loop `O(n²)`

Use amortized analysis: each pair enters and leaves the stack once.

### Mistake 6: Confusing bar count with index difference

For a rectangle beginning at `start` and ending at `index - 1`:

```text
width = (index - 1) - start + 1 = index - start
```

### Mistake 7: Using a decreasing stack

This solution needs nondecreasing candidate heights. A shorter incoming bar closes taller candidates.

### Mistake 8: Mutating `heights` to append a sentinel unnecessarily

An imaginary sentinel in the loop preserves the input array.

---

## 13. Equal Heights

This implementation pops only strictly taller bars:

```js
stackTopHeight > currentHeight
```

Equal heights may coexist in the stack with different start indices. The earlier entry will eventually calculate the widest rectangle, so correctness is preserved.

An alternative is to pop on `>=` and carry the earliest start into a single entry for that height. Both strategies work when implemented consistently.

---

## 14. Edge Cases

### Empty histogram

```text
[] -> 0
```

Only the sentinel is processed.

### Single bar

```text
[5] -> 5
```

### All zeros

```text
[0,0,0] -> 0
```

### Strictly increasing

```text
[1,2,3,4]
```

All bars remain until the sentinel.

### Strictly decreasing

```text
[4,3,2,1]
```

Each new bar pops the previous taller bar and inherits its start.

### All equal

```text
[3,3,3] -> 9
```

### Valley

```text
[5,1,5]
```

Height `1` spans all three bars for area `3`; each height `5` gives area `5`, so the answer is `5`.

### Large plateau inside taller bars

Equal-height handling must preserve the earliest possible start for the widest candidate.

---

## 15. Interview Explanation

> For any bar used as a rectangle's limiting height, its best width extends until the first shorter bar on each side. I find those boundaries implicitly with a monotonic nondecreasing stack of `[startIndex, height]`. When the current height is smaller than the stack top, the current index is the first smaller boundary on the right, so I pop and calculate `height × (currentIndex - startIndex)`. The current shorter bar inherits the earliest popped start because it can extend across all those taller bars. A final zero-height sentinel flushes the remaining stack. Each bar is pushed and popped at most once, so the solution is `O(n)` time and `O(n)` space.

### Clarify aloud

1. Does each bar have width `1`? Yes.
2. Are heights non-negative? Yes.
3. Should the input be preserved? This solution preserves it.
4. Can the array be empty? The implementation safely returns `0`.

### Related pattern

The same smaller-boundary reasoning appears in:

- maximal rectangle in a binary matrix;
- sum of subarray minimums;
- next smaller element;
- stock span and visibility problems.

---

## 16. Notebook Version

### Recognition

```text
For each height, need first smaller left and right
=> monotonic increasing stack
```

### Stack entry

```text
[earliestStart, height]
```

### Rule

```text
current >= top -> push
current < top  -> pop and finalize area
```

When popping:

```text
area = poppedHeight × (currentIndex - poppedStart)
current inherits poppedStart
```

### JavaScript

```js
function largestRectangleArea(heights) {
  const stack = [];
  let best = 0;

  for (let i = 0; i <= heights.length; i++) {
    const height = i === heights.length ? 0 : heights[i];
    let start = i;

    while (stack.length && stack.at(-1)[1] > height) {
      const [left, poppedHeight] = stack.pop();
      best = Math.max(best, poppedHeight * (i - left));
      start = left;
    }

    stack.push([start, height]);
  }

  return best;
}
```

### Complexity

```text
Time:  O(n)
Space: O(n)
```

### Invariant

Every stack entry describes a height that can span continuously from its stored start through the latest processed bar.

---

## 17. Memory Line

**A shorter bar closes every taller rectangle; pop it, measure it, and carry its start leftward.**

