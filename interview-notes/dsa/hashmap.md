# Hash Map — Two Sum

## Mental model

Use a hash map when the problem can be reframed as: **for the current value, have I already seen the value I need?**

For Two Sum:

```text
complement = target - current
```

Store:

```text
value → index
```

Check the complement before inserting the current value so the same element cannot satisfy both positions.

## Invariant

Before processing index `i`, the map contains only elements from indices less than `i`.

## Complexity

- Time: O(n) average.
- Space: O(n).

## C# articulation

Prefer `TryGetValue` when lookup and retrieval happen together.

## Interview answer

> I trade O(n) extra space for an O(n) average-time lookup. At each index I calculate the complement, check whether it has already appeared, and only then add the current value. That ordering prevents reusing the same element.
