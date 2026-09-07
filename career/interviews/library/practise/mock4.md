# IBM Mock 04 — Merge Intervals

## Problem

Given an array of intervals:

```text
intervals[i] = [start, end]
```

merge all overlapping intervals and return the resulting non-overlapping intervals.

The input array is **not necessarily sorted**.

Within each interval:

```text
start <= end
```

Touching intervals count as overlapping.

### Example

```text
Input:
[
  [1, 3],
  [2, 6],
  [8, 10],
  [15, 18]
]

Output:
[
  [1, 6],
  [8, 10],
  [15, 18]
]
```

Another:

```text
[1,4], [4,5]

→ [1,5]
```

---

# 🧠 Pattern Trigger

> **Intervals + overlap → Sort by start → Scan → Merge or Push**

Typical words:

```text
intervals
overlap
appointments
meetings
ranges
start/end times
merge
conflicts
```

When intervals arrive unsorted, ask:

> **Would sorting make overlapping items become neighbors?**

Very often, yes.

---

# 1. Initial Thought — Flatten and Sort

Initial idea:

```text
[[8,10], [1,3], [15,18], [2,6]]

↓

[8,10,1,3,15,18,2,6]

↓

sort
```

This loses information.

After flattening, we no longer know which start belonged to which end.

For example:

```text
[1,2,3,6,8,10,15,18]
```

cannot safely reconstruct the original intervals.

### Lesson

> **Sort intervals as units, not their individual numbers.**

---

# 2. Sort By Start

Sort using the lower boundary:

```js
intervals.sort((a, b) => a[0] - b[0]);
```

Example:

```text
[
  [8,10],
  [1,3],
  [15,18],
  [2,6]
]

↓

[
  [1,3],
  [2,6],
  [8,10],
  [15,18]
]
```

Now possible overlaps are next to each other.

---

# 3. Overlap Condition

Suppose:

```text
lastMerged = [1,3]
current    = [2,6]
```

They overlap because:

```text
currentStart <= lastMergedEnd

2 <= 3
```

General condition:

```js
current[0] <= lastMerged[1];
```

Equivalent:

```js
lastMerged[1] >= current[0];
```

Because touching intervals also overlap:

```text
[1,4]
[4,5]

4 >= 4
```

So they merge.

---

# 4. How To Merge

If:

```text
lastMerged = [1,3]
current    = [2,6]
```

the merged interval becomes:

```text
[1,6]
```

The start is already correct because intervals were sorted.

Only the end may need extension:

```js
lastMerged[1] = Math.max(lastMerged[1], current[1]);
```

---

# 5. Why `Math.max()` Matters

Consider:

```text
lastMerged = [1,10]
current    = [2,3]
```

Wrong:

```text
[1,3]
```

We would accidentally shrink the interval.

Correct:

```text
max(10,3) = 10

→ [1,10]
```

So merging means:

> **Keep the existing start and extend the end only if necessary.**

---

# 6. The Important Invariant

This was the key insight from the mock.

Don't compare:

```text
intervals[i]
vs
intervals[i + 1]
```

Instead compare:

```text
LAST MERGED INTERVAL
vs
CURRENT INTERVAL
```

Why?

Consider:

```text
[1,3], [2,6], [4,8]
```

First:

```text
[1,3] + [2,6]

→ [1,6]
```

Now the next comparison must be:

```text
[1,6] vs [4,8]
```

not merely the original:

```text
[2,6] vs [4,8]
```

The merged result is our current accumulated state.

### Invariant

> **`merged` always contains correctly merged intervals for everything processed so far.**

Therefore:

```js
const lastMerged = merged[merged.length - 1];
```

is the interval we care about.

---

# 7. Merge or Push

For every current interval there are only two cases.

### Case 1 — Overlap

```text
lastMerged.end >= current.start
```

Then:

```text
MERGE
```

by extending:

```js
lastMerged[1] = Math.max(lastMerged[1], current[1]);
```

### Case 2 — No overlap

```text
lastMerged.end < current.start
```

Because everything is sorted, the current interval cannot belong to the previous merged interval.

So:

```js
merged.push(current);
```

---

# 8. Dry Run

Input:

```text
[
  [1,3],
  [2,6],
  [4,8],
  [10,12]
]
```

Start:

```text
merged = [[1,3]]
```

Current:

```text
[2,6]

lastMerged = [1,3]

3 >= 2
→ overlap

merged = [[1,6]]
```

Next:

```text
current = [4,8]
lastMerged = [1,6]

6 >= 4
→ overlap

merged = [[1,8]]
```

Next:

```text
current = [10,12]
lastMerged = [1,8]

8 >= 10 ❌

→ push
```

Final:

```text
[
  [1,8],
  [10,12]
]
```

---

# 9. Optimal Solution

```js
var merge = function (intervals) {
	if (intervals.length === 0) {
		return [];
	}

	intervals.sort((a, b) => a[0] - b[0]);

	const merged = [intervals[0]];

	for (let i = 1; i < intervals.length; i++) {
		const current = intervals[i];
		const lastMerged = merged[merged.length - 1];

		if (lastMerged[1] >= current[0]) {
			lastMerged[1] = Math.max(lastMerged[1], current[1]);
		} else {
			merged.push(current);
		}
	}

	return merged;
};
```

---

# 10. Complexity

Sorting:

```text
O(n log n)
```

Scanning:

```text
O(n)
```

Therefore:

```text
O(n log n) + O(n)
= O(n log n)
```

### Space

Output may contain all intervals:

```text
O(n)
```

Auxiliary space also depends on the language/runtime's sorting implementation.

---

# 11. Mistakes From Mock Interview

## Mistake 1 — Flattening

Wrong idea:

```text
[[1,3], [2,6]]

→ [1,3,2,6]

→ sort numbers
```

This destroys interval relationships.

### Correction

> **Keep each interval intact and sort by start.**

---

## Mistake 2 — Comparing Adjacent Input Intervals

Initial implementation compared:

```js
intervals[i];
```

against:

```js
intervals[i + 1];
```

But merging changes the state.

### Correction

Always compare:

```js
const lastMerged = merged[merged.length - 1];
```

with:

```js
const current = intervals[i];
```

---

## Mistake 3 — Using `>` Instead of `>=`

Wrong:

```js
lastEnd > currentStart;
```

Would fail:

```text
[1,4], [4,5]
```

Correct:

```js
lastEnd >= currentStart;
```

because touching intervals count as overlapping.

---

## Mistake 4 — Replacing End Directly

Wrong:

```js
lastMerged[1] = current[1];
```

Example:

```text
[1,10] + [2,3]
```

would incorrectly become:

```text
[1,3]
```

Correct:

```js
lastMerged[1] = Math.max(lastMerged[1], current[1]);
```

---

# 12. Interview Explanation

> “Since the intervals aren't sorted, I'll first sort them by their start value. This ensures intervals that can overlap appear next to the accumulated merged range.
>
> I'll initialize the result with the first interval and then scan through the remaining intervals.
>
> For each interval, I'll compare its start with the end of the last merged interval. If the current start is less than or equal to that end, they overlap, so I'll extend the merged end using the maximum of both ends.
>
> Otherwise there is no overlap, so I'll append the current interval as a new result interval.
>
> Sorting takes O(n log n), and the subsequent scan takes O(n), giving O(n log n) overall.”

---

# 📓 Notebook Version

```text
Merge Intervals

Trigger:
INTERVALS + OVERLAP
→ SORT + SCAN

1. Sort by START.

2. merged = [first interval]

3. For each current:

   last = merged[last]

   if:
   current.start <= last.end

       OVERLAP
       last.end =
         max(last.end, current.end)

   else:

       PUSH current

Invariant:
Compare CURRENT with
LAST MERGED,
not previous input.

Time:
O(n log n)

Memory:
SORT → MERGE OR PUSH
```

---

# 🧠 Memory Lines

> **Intervals + overlap → sort first.**

> **Sort → compare with last merged → merge or push.**

> **Don't compare with the previous input; compare with the accumulated result.**

> **Overlap: current.start ≤ last.end.**

> **Merge: extend, never shrink.**

---

# 🔗 Pattern Recognition Addition

## Pattern 04 — Sort + Scan Intervals

### Trigger

```text
intervals / ranges
+
overlap / conflict / merge
```

Immediately ask:

> **Can sorting by start turn a global overlap problem into a local comparison?**

Usually:

```text
SORT BY START
      ↓
SCAN LEFT → RIGHT
      ↓
CURRENT vs LAST ACCEPTED
      ↓
MERGE or PUSH
```

### Recognition Question

> **After sorting, can I solve the problem by comparing each item with the last result I've accepted?**

If yes:

```text
Sort + Scan
```

---

# 🧠 Pattern Map So Far

```text
01
Target sum + negative numbers
        ↓
PREFIX SUM + HASH MAP

"What earlier running total do I need?"
```

```text
02
Contiguous + maintainable condition
        ↓
SLIDING WINDOW

"Can I shrink instead of restarting?"
```

```text
03
Every index needs LEFT + RIGHT
        ↓
PREFIX / SUFFIX

"Can I carry information from both directions?"
```

```text
04
Intervals + overlap
        ↓
SORT + SCAN

"Can sorting make the relationship local?"
```

## Four Memory Anchors

```text
PREFIX SUM
Current - Earlier = Target

SLIDING WINDOW
Expand → Invalid → Shrink → Valid

PREFIX / SUFFIX
Left → Store | Right ← Carry

INTERVALS
Sort → Last Merged → Merge or Push
```
