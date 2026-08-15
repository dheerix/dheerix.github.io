# Grind 75 — 45. Merge Intervals

## Problem

Given an array of intervals where `intervals[i] = [start, end]`, merge every overlapping interval and return the non-overlapping intervals covering the same ranges.

Example:

```text
input:  [[1,3], [2,6], [8,10], [15,18]]
output: [[1,6], [8,10], [15,18]]
```

`[1,3]` overlaps `[2,6]`, so together they form `[1,6]`.

---

## 1. Why the unsorted problem is awkward

Without ordering, an interval might overlap another interval located anywhere in the array. A direct approach could repeatedly compare intervals against many others, leading toward O(n²) work and complicated merging chains.

Sorting by starting point creates structure:

```text
earlier starts → later starts
```

After sorting, once we have merged everything seen so far, the next interval can overlap only the **last merged interval**. It cannot reach backward past a confirmed gap.

This turns the problem into a single left-to-right scan.

---

## 2. Core overlap rule

Let:

```text
last merged interval = [lastStart, lastEnd]
current interval     = [currentStart, currentEnd]
```

Because intervals are sorted by start, they overlap when:

```text
currentStart <= lastEnd
```

If they overlap, extend the last interval's end:

```text
lastEnd = max(lastEnd, currentEnd)
```

If they do not overlap, a permanent gap exists, so append the current interval as a new merged region.

---

## 3. Recommended JavaScript solution

This version copies the intervals so that sorting and merging do not mutate the caller's nested arrays.

```javascript
function merge(intervals) {
  if (intervals.length <= 1) {
    return intervals.map(interval => [...interval]);
  }

  const sorted = intervals
    .map(interval => [...interval])
    .sort((a, b) => a[0] - b[0]);

  const merged = [sorted[0]];

  for (let i = 1; i < sorted.length; i++) {
    const current = sorted[i];
    const lastMerged = merged[merged.length - 1];

    if (current[0] <= lastMerged[1]) {
      lastMerged[1] = Math.max(lastMerged[1], current[1]);
    } else {
      merged.push(current);
    }
  }

  return merged;
}
```

---

## 4. Why sort by start time?

After sorting, for any current interval:

```text
current.start >= every earlier start
```

The last merged interval already represents the full continuous range formed by all overlapping intervals immediately before the current one.

There are only two possibilities:

1. `current.start <= last.end`: the ranges touch or overlap, so extend `last.end` if needed.
2. `current.start > last.end`: there is a gap. Because all future intervals begin at least as late as `current`, none can bridge backward across this gap.

That makes the last merged interval final whenever a gap is found.

---

## 5. Walkthrough

Input:

```text
[[1,3], [2,6], [8,10], [15,18]]
```

It is already sorted by start.

Initialize:

```text
merged = [[1,3]]
```

### Current `[2,6]`

```text
2 <= 3 → overlap
new end = max(3,6) = 6
```

```text
merged = [[1,6]]
```

### Current `[8,10]`

```text
8 > 6 → gap
```

```text
merged = [[1,6], [8,10]]
```

### Current `[15,18]`

```text
15 > 10 → gap
```

Final result:

```text
[[1,6], [8,10], [15,18]]
```

---

## 6. Chained overlap walkthrough

```text
[[1,4], [2,5], [4,8]]
```

- `[1,4]` and `[2,5]` merge into `[1,5]`.
- `[4,8]` must then be compared with the updated interval `[1,5]`, not merely the original `[2,5]`.
- Since `4 <= 5`, the result becomes `[1,8]`.

This is why the algorithm compares against the last **merged** interval.

---

## 7. Containment case

```text
last    = [1,10]
current = [3,5]
```

They overlap, but the current interval contributes no additional coverage:

```text
max(10,5) = 10
```

The merged interval remains `[1,10]`. Never blindly replace the end with `current[1]`; doing so would incorrectly shrink the range.

---

## 8. Touching endpoints

Intervals such as:

```text
[1,4] and [4,5]
```

are considered overlapping in this problem because the endpoint `4` belongs to both closed intervals.

Therefore, use:

```javascript
current[0] <= lastMerged[1]
```

not `<`.

The exact comparison can differ in production systems if intervals are half-open, such as `[start, end)`.

---

## 9. Correctness reasoning

We maintain this invariant:

> After processing the first `i` sorted intervals, `merged` is a correct, non-overlapping representation of their complete coverage.

### Initialization

One interval is already a correct merged representation of itself.

### Overlap case

If `current.start <= last.end`, the current interval joins the last merged region. Their union begins at `last.start` and ends at `max(last.end, current.end)`. Updating that end preserves the invariant.

### Gap case

If `current.start > last.end`, the two intervals are separated. Since future intervals have starts at least as large as `current.start`, none can overlap the previous merged interval. Appending `current` begins the next region and preserves the invariant.

After every sorted interval is processed, `merged` contains exactly the union of all input intervals without overlap.

---

## 10. Complexity

Let `n` be the number of intervals.

- Sorting: **O(n log n)**
- Merge scan: **O(n)**
- Total time: **O(n log n)**
- Output space: **O(n)** in the worst case

The working copies also use O(n) space. If mutating the input is acceptable, the copy can be avoided, though the output itself can still contain O(n) intervals.

---

## 11. Mutating concise version

LeetCode solutions often sort and reuse the original interval arrays:

```javascript
function mergeInPlace(intervals) {
  if (intervals.length <= 1) return intervals;

  intervals.sort((a, b) => a[0] - b[0]);
  const merged = [intervals[0]];

  for (let i = 1; i < intervals.length; i++) {
    const current = intervals[i];
    const last = merged[merged.length - 1];

    if (current[0] <= last[1]) {
      last[1] = Math.max(last[1], current[1]);
    } else {
      merged.push(current);
    }
  }

  return merged;
}
```

This is slightly shorter but mutates:

- the order of `intervals` through `sort()`;
- some nested interval arrays through `last[1] = ...`.

That is usually accepted in the coding problem, but should be an intentional API decision in production.

---

## 12. JavaScript sorting pitfall

Never rely on the default array sort for numeric interval starts:

```javascript
intervals.sort();
```

JavaScript's default comparison converts values to strings. Always supply a numeric comparator:

```javascript
intervals.sort((a, b) => a[0] - b[0]);
```

---

## 13. Common mistakes

### Mistake 1: scanning without sorting

Then the previous interval may not be the only possible overlap.

### Mistake 2: comparing with the original previous interval

Compare with `merged[merged.length - 1]`, which may have expanded through several prior intervals.

### Mistake 3: replace instead of extend

Use `Math.max(lastEnd, currentEnd)` to handle containment.

### Mistake 4: use `<` instead of `<=`

Closed intervals sharing an endpoint must merge.

### Mistake 5: forget the empty input

Do not access `sorted[0]` before confirming that an interval exists.

### Mistake 6: accidentally mutate caller-owned data

Remember that `sort()` mutates the outer array and modifying an interval mutates the nested array object.

### Mistake 7: push every current interval after merging

Append only when a gap exists. Overlapping intervals update the existing last result.

---

## 14. Edge cases

- empty array → `[]`
- one interval → the same coverage
- no overlaps → every interval remains
- all intervals overlap → one result
- one interval contained inside another
- equal starts, such as `[1,4]` and `[1,5]`
- touching endpoints, such as `[1,4]` and `[4,5]`
- negative endpoints

---

## 15. Interview narration

> “I’ll first sort by start time. Then the output remains non-overlapping, and each new interval needs to be compared only with the last merged interval. If its start is at most the last end, I extend the end to their maximum. Otherwise, the gap is permanent, so I append a new interval. Sorting dominates at O(n log n).”

---

## 16. Pattern recognition

For interval problems, sorting often converts global relationships into local ones.

Look for this pattern when asked to:

- merge schedules or reservations;
- calculate total covered time;
- detect conflicts;
- insert a new interval;
- find gaps or free time;
- remove overlaps.

General template:

```text
sort by start
     ↓
compare current with last accepted interval
     ↓
merge overlap or finalize a gap
```

---

## 17. Quick test

```javascript
console.log(merge([[1,3], [2,6], [8,10], [15,18]]));
// [[1,6], [8,10], [15,18]]

console.log(merge([[1,4], [4,5]]));
// [[1,5]]

console.log(merge([[1,10], [2,3], [4,8]]));
// [[1,10]]

console.log(merge([]));
// []
```

---

## 18. Notebook version

### Pattern

**Sort intervals + linear merge scan**

### Overlap rule

```text
current.start <= last.end
```

### Merge rule

```text
last.end = max(last.end, current.end)
```

### Memory line

> Sort by start; compare only with the last merged interval.

### Complexity

```text
time: O(n log n)
space: O(n) including output/copies
```

