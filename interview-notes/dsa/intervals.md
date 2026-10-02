# Intervals — Merge Intervals

## Mental model

**Sort first so overlap becomes local.**

After sorting by start time/value, compare each interval with the last merged interval.

```text
next.start <= last.end
→ overlap
→ last.end = max(last.end, next.end)
```

Otherwise append a new interval.

## Complexity

- Sorting: O(n log n)
- Merge pass: O(n)
- Overall: O(n log n)
- Output space: O(n) worst case

## C# reference-semantics trap

With `int[][]`:

- `Array.Sort(intervals, ...)` reorders the caller's outer array.
- Adding an inner `int[]` to another list copies the reference, not the inner array.
- Mutating `lastMerged[1]` can therefore mutate caller-owned data.
- `intervals.ToArray()` is only a shallow outer copy.

If isolation is required, copy the inner arrays too.

## Interview answer

> I sort intervals by start, then make one linear pass. Sorting guarantees that if the next interval overlaps anything relevant, it overlaps the last merged interval. That gives O(n log n) overall time.
