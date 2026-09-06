# Grind 75 — 26: Insert Interval

**Difficulty:** Medium  
**Primary pattern:** Intervals / linear merge  
**LeetCode:** https://leetcode.com/problems/insert-interval/  
**Target time:** 25 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

You are given non-overlapping intervals sorted by start time, plus one new interval. Insert the new interval and merge any overlaps so that the result remains sorted and non-overlapping.

```text
intervals   = [[1,3], [6,9]]
newInterval = [2,5]

result      = [[1,5], [6,9]]
```

Another example:

```text
intervals   = [[1,2], [3,5], [6,7], [8,10], [12,16]]
newInterval = [4,8]

result      = [[1,2], [3,10], [12,16]]
```

The new interval bridges several existing intervals into one merged range.

---

## 2. What the input guarantees give us

Existing intervals are:

- sorted by start;
- internally non-overlapping.

Therefore, while scanning from left to right, every interval belongs to one of three consecutive regions:

```text
1. strictly before new interval
2. overlapping new interval
3. strictly after new interval
```

Once we leave one phase, we never return to it. This makes a single linear pass possible.

---

## 3. Define the three relationships

Let current interval be:

```text
[currentStart, currentEnd]
```

and new interval be:

```text
[newStart, newEnd]
```

### Current interval is strictly before

```text
currentEnd < newStart
```

There is a positive gap. Append current unchanged.

### Current interval is strictly after

```text
currentStart > newEnd
```

There is a positive gap. The merged new interval is finished.

### Otherwise, they overlap

```text
currentStart <= newEnd
and
currentEnd >= newStart
```

Merge:

```text
newStart = min(newStart, currentStart)
newEnd   = max(newEnd, currentEnd)
```

---

## 4. Why touching endpoints merge

Intervals are closed ranges. If:

```text
[1,2] and [2,4]
```

they share point `2`, so they overlap and become `[1,4]`.

That is why “strictly before” uses:

```javascript
currentEnd < newStart
```

not `<=`.

Similarly, “strictly after” uses `currentStart > newEnd`, not `>=`.

Boundary inequalities encode the interval semantics.

---

## 5. Three-phase algorithm

Maintain index `i` and result array.

### Phase 1: intervals before the new one

Append while:

```text
intervals[i].end < newStart
```

### Phase 2: overlapping intervals

Merge while:

```text
intervals[i].start <= newEnd
```

After phase 1, remaining intervals cannot be strictly before. Therefore, checking `start <= newEnd` is sufficient to identify overlap.

### Insert merged interval

Append the expanded new interval once.

### Phase 3: intervals after it

Append every remaining interval unchanged.

---

## 6. Optimal JavaScript solution

```javascript
function insert(intervals, newInterval) {
  const result = [];
  let i = 0;
  let [newStart, newEnd] = newInterval;

  // Phase 1: intervals ending before the new interval starts.
  while (
    i < intervals.length &&
    intervals[i][1] < newStart
  ) {
    result.push(intervals[i]);
    i++;
  }

  // Phase 2: absorb every interval that overlaps the growing range.
  while (
    i < intervals.length &&
    intervals[i][0] <= newEnd
  ) {
    newStart = Math.min(newStart, intervals[i][0]);
    newEnd = Math.max(newEnd, intervals[i][1]);
    i++;
  }

  result.push([newStart, newEnd]);

  // Phase 3: remaining intervals are strictly after the merged range.
  while (i < intervals.length) {
    result.push(intervals[i]);
    i++;
  }

  return result;
}
```

---

## 7. Dry run

```text
intervals = [[1,2], [3,5], [6,7], [8,10], [12,16]]
new       = [4,8]
```

### Phase 1

`[1,2]` ends before `4`, so append it:

```text
result = [[1,2]]
```

`[3,5]` does not end before `4`, so overlap processing begins.

### Phase 2

```text
merge [3,5]  with [4,8]  → [3,8]
merge [6,7]  with [3,8]  → [3,8]
merge [8,10] with [3,8]  → [3,10]
```

`[12,16]` begins after `10`, so merging stops.

Append `[3,10]`.

### Phase 3

Append `[12,16]`.

```text
result = [[1,2], [3,10], [12,16]]
```

---

## 8. The interval grows during merging

An important subtlety: overlap is checked against the **updated** `newEnd`, not only the original interval.

```text
new interval = [4,5]
existing     = [5,7], [7,9]
```

First merge produces `[4,7]`. That expanded end now overlaps `[7,9]`, producing `[4,9]`.

One overlap can create another. The mutable merge boundary captures this transitive chain.

---

## 9. Code walkthrough

### Destructure into local boundaries

```javascript
let [newStart, newEnd] = newInterval;
```

Using local numbers avoids mutating the caller's `newInterval` array. The final merged pair is newly created.

### Phase 1 condition

Only intervals with a strict gap before the new interval are finalized. Because input is sorted, they can be appended in existing order.

### Phase 2 condition

After phase 1, current interval's end is not less than `newStart`. It overlaps exactly when its start is no greater than the current `newEnd`.

### Append merged range exactly once

The new interval may absorb zero, one, or many intervals. In every case, it contributes one final interval to the result.

### Phase 3 requires no more comparisons

When phase 2 ends, current interval starts after `newEnd`. Since later intervals start even later and existing intervals do not overlap, all remaining intervals are safely after the merged range.

---

## 10. Loop invariants

After phase 1:

> `result` contains all original intervals strictly before the new interval, still sorted and non-overlapping.

During phase 2:

> `[newStart, newEnd]` equals the union of the original new interval and every overlapping interval processed so far.

Before phase 3:

> `result` plus the newly appended merged interval is sorted and non-overlapping, and every unprocessed interval lies strictly after it.

These invariants explain why no sorting is required after insertion.

---

## 11. Correctness reasoning

Sorted, non-overlapping input ensures all intervals strictly before the new range form a prefix, which phase 1 appends unchanged.

Phase 2 visits every interval whose start is at or before the expanding merged end. Since phase 1 removed intervals ending before the merged start, each such interval overlaps. Updating with minimum start and maximum end produces exactly the union of all absorbed intervals. The growing end ensures transitive overlaps are included.

When phase 2 stops, the next interval begins strictly after the merged end. Sorted order proves all later intervals do as well. Appending the merged range and untouched suffix therefore produces a complete, sorted, non-overlapping result.

---

## 12. Complexity

Let `n` be the number of existing intervals.

- **Time: O(n)** — index `i` advances through every interval at most once.
- **Output space: O(n)** — the result can contain up to `n + 1` intervals.
- **Auxiliary working space excluding output: O(1)**.

The three loops are sequential, not nested. Their total iterations sum to at most `n`.

---

## 13. Simpler one-loop alternative

```javascript
function insertOneLoop(intervals, newInterval) {
  const result = [];
  let [start, end] = newInterval;
  let inserted = false;

  for (const [currentStart, currentEnd] of intervals) {
    if (currentEnd < start) {
      result.push([currentStart, currentEnd]);
    } else if (currentStart > end) {
      if (!inserted) {
        result.push([start, end]);
        inserted = true;
      }

      result.push([currentStart, currentEnd]);
    } else {
      start = Math.min(start, currentStart);
      end = Math.max(end, currentEnd);
    }
  }

  if (!inserted) {
    result.push([start, end]);
  }

  return result;
}
```

This is also O(n), but the `inserted` flag adds state. The three-phase solution mirrors the sorted interval structure more directly and is easier to prove.

---

## 14. Sort-and-merge alternative

A general fallback is:

1. append `newInterval` to the list;
2. sort all intervals by start;
3. run ordinary Merge Intervals.

That costs O(n log n). It ignores the useful guarantee that existing intervals are already sorted and non-overlapping. In an interview, exploiting that guarantee to achieve O(n) is expected.

---

## 15. Common mistakes

1. **Using `<=` for “strictly before.”** Touching endpoints overlap for closed intervals.
2. **Checking overlaps only against the original `newEnd`.** The merged interval can expand and absorb later intervals.
3. **Appending the new interval before finishing all merges.** Its final boundaries are not known yet.
4. **Forgetting to append the merged interval.** It must appear even when it overlaps nothing.
5. **Forgetting the remaining suffix.** All intervals after the merge still belong in the result.
6. **Sorting unnecessarily.** Existing order allows an O(n) solution.
7. **Mutating `newInterval` without mentioning it.** Local boundary variables avoid the side effect.
8. **Calling the three loops O(3n) as a different class.** O(3n) simplifies to O(n).
9. **Confusing interval order with containment only.** Partial overlaps and bridging chains must merge too.

---

## 16. What to say in an interview

> “Because the existing intervals are sorted and non-overlapping, they divide into three consecutive regions relative to the new interval. I’ll first append intervals ending strictly before it. Then I’ll merge every interval whose start is at most the growing merged end. I append that merged interval once, followed by the untouched suffix. Each interval is processed once, so time is O(n), with O(n) output space.”

If asked about boundary equality:

> “The ranges are closed, so intervals sharing an endpoint overlap; strict separation uses `<` and `>`.”

---

## 17. Pattern recognition

Think **ordered interval sweep** when:

- intervals are already sorted;
- existing intervals do not overlap;
- one new range may overlap a contiguous block;
- the result must preserve sorted non-overlapping form.

For two closed intervals `[a,b]` and `[c,d]`:

```text
strictly separated if b < c or d < a
overlapping otherwise
merged interval = [min(a,c), max(b,d)]
```

Memory cue:

> Before, absorb, after.

---

## 18. Edge cases

| Existing intervals | New interval | Result pattern |
|---|---|---|
| `[]` | `[2,5]` | `[[2,5]]` |
| `[[3,5]]` | `[1,2]` | new interval before all |
| `[[1,2]]` | `[3,5]` | new interval after all |
| `[[1,5]]` | `[2,3]` | new interval contained |
| `[[2,3]]` | `[1,5]` | existing interval absorbed |
| `[[1,2],[5,6]]` | `[2,5]` | touches and bridges both |
| many intervals | spanning interval | all may collapse into one |

---

## 19. Notebook-ready notes

### 📚 Concept

**Insert Interval — three-phase linear merge**

```text
1. Before:
   while current.end < new.start
   append current

2. Overlap:
   while current.start <= new.end
   new = [min starts, max ends]

3. Append merged new interval

4. After:
   append all remaining intervals
```

### 🧠 My understanding

Sorted, disjoint input means overlapping intervals form one contiguous block. I preserve the prefix, grow the new interval across that block, insert it once, and preserve the suffix. The updated end must drive later overlap checks because merging can create transitive overlap.

### 💼 Interview line

> “The sorted input naturally separates into before, overlapping, and after regions.”

### ⚠️ Traps

- Shared endpoints overlap.
- Compare against the growing merged end.
- Insert the merged interval exactly once.
- Three sequential loops remain O(n).

---

## 20. Dheerix Glance

```text
INSERT INTERVAL

Input leverage:    sorted + non-overlapping
Phase 1:           current.end < new.start → append
Phase 2:           current.start <= new.end → merge
Merge formula:     min starts, max ends
Then:              append merged interval once
Phase 3:           append remainder
Endpoint rule:     equality means overlap
Time:              O(n)
Output space:      O(n)
Memory cue:        “Before, absorb, after.”
```

---

## 21. Recall test

Without looking back:

1. What input guarantees make a linear scan possible?
2. What are the three consecutive interval regions?
3. Why does “strictly before” use `<` rather than `<=`?
4. Why must the merged end be updated during overlap checks?
5. Why can phase 3 append everything without more merging?
6. Why do three loops still produce O(n) time?
7. What side effect is avoided by destructuring `newInterval`?
8. State the phase-2 invariant in one sentence.

