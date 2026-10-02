# Sliding Window

## Mental model

Use sliding window for **contiguous ranges** when the next range can be derived from the previous one instead of recomputing it.

## Fixed-size window

Example: maximum sum of exactly `k` elements.

**Add incoming, subtract outgoing.**

```text
newSum = oldSum + incoming - outgoing
```

Window size remains `k`.

## Variable-size window

Example: longest substring without repeating characters.

**Expand right; shrink left until the window is valid again.**

Invariant: before measuring the window, it satisfies the problem's validity rule.

With a `HashSet<char>`:

```csharp
while (seen.Contains(s[right]))
{
    seen.Remove(s[left]);
    left++;
}
```

The `while` matters because removing one character may not remove the duplicate.

## Last-seen optimization

Store:

```text
character → last index
```

Then jump:

```csharp
left = Math.Max(left, previousIndex + 1);
```

`Math.Max` prevents the left boundary from moving backward.

## Complexity / amortized analysis

A `for` containing a `while` is not automatically O(n²).

In the HashSet version:
- `right` moves forward at most n times.
- `left` moves forward at most n times.

Therefore time is O(n) average assuming average O(1) set operations.

## Interview answer

> Sliding window maintains a contiguous range incrementally. For a fixed window I add the incoming value and remove the outgoing one. For a variable window I expand right and move left only as much as necessary to restore the invariant.
