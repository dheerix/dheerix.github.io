# Grind 75 — 59. Container With Most Water

## Problem

You are given an array `height`, where each value represents a vertical line at that index.

Choose two lines that, together with the x-axis, hold the greatest amount of water. Return that maximum area.

Example:

```text
height = [1,8,6,2,5,4,8,3,7]
answer = 49
```

Lines at indices `1` and `8` have:

```text
width  = 8 - 1 = 7
height = min(8, 7) = 7
area   = 7 × 7 = 49
```

---

## 1. Area formula

For two indices `left` and `right`:

```text
width = right - left
```

Water cannot rise above the shorter line, so:

```text
container height = min(height[left], height[right])
```

Therefore:

```text
area = (right - left)
       × min(height[left], height[right])
```

The problem is a tradeoff:

- wider lines increase area;
- taller limiting walls increase area.

---

## 2. Brute-force solution

Try every pair of lines.

```javascript
function maxAreaBruteForce(height) {
  let maximum = 0;

  for (let left = 0; left < height.length; left++) {
    for (let right = left + 1; right < height.length; right++) {
      const width = right - left;
      const containerHeight = Math.min(height[left], height[right]);
      maximum = Math.max(maximum, width * containerHeight);
    }
  }

  return maximum;
}
```

- Time: O(n²)
- Space: O(1)

It is correct but ignores a useful elimination rule.

---

## 3. Start with maximum width

Place pointers at the two ends:

```text
left = 0
right = n - 1
```

This pair has the maximum possible width.

After calculating its area, move one pointer inward. Width must decrease, so an improved area is possible only if the limiting height can increase.

The shorter line is the current limiting wall. Replace that one.

---

## 4. Recommended JavaScript solution

```javascript
function maxArea(height) {
  let left = 0;
  let right = height.length - 1;
  let maximumArea = 0;

  while (left < right) {
    const width = right - left;
    const containerHeight = Math.min(
      height[left],
      height[right]
    );

    maximumArea = Math.max(
      maximumArea,
      width * containerHeight
    );

    if (height[left] <= height[right]) {
      left++;
    } else {
      right--;
    }
  }

  return maximumArea;
}
```

---

## 5. Why move the shorter wall?

Suppose:

```text
height[left] < height[right]
```

The current area is limited by `height[left]`.

If we move `right` inward while keeping `left`:

- width decreases;
- the container height cannot exceed `height[left]`, because the same short left wall remains.

Therefore, no pair using the same `left` with a smaller width can beat the current pair.

Those pairs can be safely discarded.

Moving `left` is the only move that might replace the limiting wall with a taller one and compensate for lost width.

The same argument applies symmetrically when the right wall is shorter.

---

## 6. What if both walls have equal height?

If:

```text
height[left] === height[right]
```

moving either pointer is safe.

Any inward pair that retains one of these equal-height walls has:

- smaller width;
- limiting height no greater than the retained wall.

So it cannot beat the current pair unless the retained limiting wall is eventually replaced. The implementation moves `left` when heights are equal, but moving `right` would also be correct.

---

## 7. Walkthrough

```text
height = [1,8,6,2,5,4,8,3,7]
```

### First pair

```text
left = 0, right = 8
heights = 1 and 7
width = 8
area = 8 × 1 = 8
```

Left is shorter, so move `left`.

### Second pair

```text
left = 1, right = 8
heights = 8 and 7
width = 7
area = 7 × 7 = 49
```

Right is shorter, so move `right`.

The remaining pointer moves inspect narrower containers. None exceeds `49`, so the final answer is `49`.

---

## 8. Compact pointer table

For the same input:

| Left | Right | Heights | Width | Area | Move |
| ---: | ---: | --- | ---: | ---: | --- |
| 0 | 8 | 1, 7 | 8 | 8 | left |
| 1 | 8 | 8, 7 | 7 | 49 | right |
| 1 | 7 | 8, 3 | 6 | 18 | right |
| 1 | 6 | 8, 8 | 5 | 40 | left |
| 2 | 6 | 6, 8 | 4 | 24 | left |
| 3 | 6 | 2, 8 | 3 | 6 | left |
| 4 | 6 | 5, 8 | 2 | 10 | left |
| 5 | 6 | 4, 8 | 1 | 4 | left |

---

## 9. Correctness reasoning

We need to prove that moving the shorter pointer never discards an unseen optimal pair.

Assume `height[left] <= height[right]`.

For any inward index `r` where `left < r < right`:

```text
width(left, r) < width(left, right)
```

and:

```text
min(height[left], height[r]) <= height[left]
```

The current pair already has limiting height `height[left]`. Thus:

```text
area(left, r) < or = area(left, right)
```

No future pair that keeps this `left` can improve upon the current area. Discarding `left` is therefore safe.

The symmetric argument proves it is safe to discard `right` when it is shorter.

At every step, the algorithm evaluates the best-width pair involving the pointer it discards. Therefore, it cannot discard an optimal solution without having already considered an equal or better area. When the pointers meet, the global maximum has been examined or safely bounded.

---

## 10. Complexity

- Time: **O(n)**
- Auxiliary space: **O(1)**

Each pointer moves inward at most `n - 1` times. No pair enumeration or extra data structure is needed.

---

## 11. Why moving the taller wall is not useful

Suppose:

```text
left height  = 4
right height = 10
```

The water height is `4`, not `10`.

Moving the taller right wall inward:

- reduces width;
- keeps the same left limit of at most `4`.

Even if the new right wall is taller than `10`, water is still limited by `4`. The area must be smaller.

The only hope is to move past the height-`4` wall and find a taller left boundary.

---

## 12. Do not skip directly to the next taller wall without care

An optimization can skip walls that are no taller than the discarded short wall, because narrower containers with an equal or shorter limiting height cannot improve the area.

```javascript
function maxAreaSkipping(height) {
  let left = 0;
  let right = height.length - 1;
  let maximumArea = 0;

  while (left < right) {
    const leftHeight = height[left];
    const rightHeight = height[right];

    maximumArea = Math.max(
      maximumArea,
      (right - left) * Math.min(leftHeight, rightHeight)
    );

    if (leftHeight <= rightHeight) {
      while (left < right && height[left] <= leftHeight) {
        left++;
      }
    } else {
      while (left < right && height[right] <= rightHeight) {
        right--;
      }
    }
  }

  return maximumArea;
}
```

The basic one-step solution is already O(n), simpler to prove, and generally preferable in an interview.

---

## 13. Common mistakes

### Mistake 1: use the taller wall as the container height

Water spills over the shorter wall. Use `Math.min()`.

### Mistake 2: calculate width as `right - left + 1`

The horizontal distance between index positions is `right - left`.

### Mistake 3: move the taller pointer

That decreases width without removing the limiting wall.

### Mistake 4: move both pointers every iteration

This can skip viable pairs without justification.

### Mistake 5: sort the heights

Indices determine width. Sorting destroys the geometry of the problem.

### Mistake 6: confuse the problem with Trapping Rain Water

This problem chooses exactly two walls for one container. Trapping Rain Water sums water above many positions using surrounding boundaries.

### Mistake 7: state the two-pointer rule without proving elimination

The interview value is in explaining why all pairs retaining the shorter wall are dominated after width shrinks.

---

## 14. Edge cases

- exactly two lines
- equal heights
- strictly increasing heights
- strictly decreasing heights
- tallest lines near the center
- tallest lines far apart
- zero-height lines

The input contains at least two positions under the standard problem constraints.

---

## 15. JavaScript numeric note

LeetCode's constraints keep the maximum area within JavaScript's exact safe-integer range.

For production data with extremely large indices or heights, verify whether `Number` precision is sufficient or use `BigInt` with compatible arithmetic.

---

## 16. Interview narration

> “I’ll start with the widest possible container using pointers at both ends. Its area is width times the shorter height. Since moving inward always reduces width, the only chance to improve is to replace the limiting shorter wall with a taller one. Keeping that shorter wall while moving the other pointer cannot improve area, so I safely discard the shorter side each step.”

---

## 17. Pattern recognition

Use inward two pointers when:

- a pair is selected from opposite sides of an ordered structure;
- starting with maximum distance is useful;
- one endpoint imposes a bottleneck;
- you can prove that moving one specific endpoint eliminates only dominated choices.

General principle:

```text
evaluate current pair
        ↓
identify the limiting endpoint
        ↓
discard choices that keep that limit with less benefit
```

---

## 18. Quick test

```javascript
console.log(maxArea([1,8,6,2,5,4,8,3,7])); // 49
console.log(maxArea([1,1]));                 // 1
console.log(maxArea([4,3,2,1,4]));           // 16
console.log(maxArea([1,2,1]));               // 2
```

---

## 19. Notebook version

### Pattern

**Two pointers + eliminate the limiting side**

### Formula

```text
area = (right - left) × min(leftHeight, rightHeight)
```

### Pointer rule

```text
move the shorter wall inward
```

### Why?

```text
Width will shrink.
Keeping the shorter wall cannot increase the limiting height.
```

### Memory line

> Width only gets worse; replace the bottleneck.

### Complexity

```text
time: O(n)
space: O(1)
```

