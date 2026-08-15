# Grind 75 — 47. Time Based Key-Value Store

## Problem

Design a time-based key-value store supporting:

- `set(key, value, timestamp)` — store a value for a key at a timestamp;
- `get(key, timestamp)` — return the value associated with the largest stored timestamp less than or equal to the query timestamp.

If no qualifying value exists, return an empty string.

All timestamps passed to `set` are strictly increasing.

Example:

```text
set("foo", "bar", 1)
get("foo", 1)  → "bar"
get("foo", 3)  → "bar"
set("foo", "bar2", 4)
get("foo", 4)  → "bar2"
get("foo", 5)  → "bar2"
```

---

## 1. What must the data structure answer?

For each key, we need its version history:

```text
foo → [(1, "bar"), (4, "bar2"), (9, "bar3")]
```

For a query timestamp `6`, we need:

```text
the rightmost stored timestamp <= 6
```

That is a **floor search** or **rightmost-valid binary search**.

The design naturally separates into:

```text
hash map → locate one key's history
binary search → locate the correct historical version
```

---

## 2. Why the timestamp guarantee matters

`set` timestamps arrive in strictly increasing order. Therefore, each key's history remains sorted simply by appending:

```javascript
history.push([timestamp, value]);
```

No insertion search and no re-sorting are needed.

This makes:

- `set`: O(1) amortized;
- `get`: O(log k), where `k` is the number of versions stored for that key.

---

## 3. Recommended JavaScript solution

```javascript
class TimeMap {
  constructor() {
    this.historyByKey = new Map();
  }

  set(key, value, timestamp) {
    if (!this.historyByKey.has(key)) {
      this.historyByKey.set(key, []);
    }

    this.historyByKey.get(key).push([timestamp, value]);
  }

  get(key, timestamp) {
    const history = this.historyByKey.get(key);

    if (history === undefined) {
      return '';
    }

    let left = 0;
    let right = history.length - 1;
    let answer = '';

    while (left <= right) {
      const middle = left + Math.floor((right - left) / 2);
      const [storedTimestamp, storedValue] = history[middle];

      if (storedTimestamp <= timestamp) {
        answer = storedValue;
        left = middle + 1;
      } else {
        right = middle - 1;
      }
    }

    return answer;
  }
}
```

---

## 4. Binary-search objective

This is not merely a search for exact equality.

We want:

```text
maximum storedTimestamp such that storedTimestamp <= queryTimestamp
```

When `history[middle].timestamp` is valid:

1. save its value as the best answer seen so far;
2. continue right to look for a later valid timestamp.

```javascript
if (storedTimestamp <= timestamp) {
  answer = storedValue;
  left = middle + 1;
}
```

When it is too large, discard it and everything to its right:

```javascript
if (storedTimestamp > timestamp) {
  right = middle - 1;
}
```

---

## 5. Why continue after finding an exact timestamp?

Because `set` timestamps are strictly increasing, an exact match is unique and could be returned immediately.

However, the generic rightmost-valid template remains correct:

```text
timestamp at middle <= query → save it and move right
```

It solves both exact and in-between queries with one consistent rule. An early return on equality is a valid micro-optimization, not a requirement.

---

## 6. Walkthrough

Suppose:

```text
history for "theme":
[(1, "light"), (4, "dark"), (8, "system"), (12, "contrast")]

query timestamp = 10
```

We need timestamp `8`.

### Iteration 1

```text
left = 0, right = 3, middle = 1
timestamp = 4
```

`4 <= 10`, so `"dark"` is valid. Save it and search right.

### Iteration 2

```text
left = 2, right = 3, middle = 2
timestamp = 8
```

`8 <= 10`, so update the answer to `"system"` and search right.

### Iteration 3

```text
left = 3, right = 3, middle = 3
timestamp = 12
```

`12 > 10`, so move left.

The loop ends with `"system"`, the value at the largest timestamp no greater than `10`.

---

## 7. Search invariant

During binary search:

- `answer` stores the value at the greatest valid timestamp encountered so far;
- timestamps strictly left of `left` have already been classified;
- the active range `[left, right]` may still contain a better valid timestamp.

When a midpoint is valid, everything at or left of it is no later than that timestamp, so the only possible improvement lies to the right.

When a midpoint is too large, every later timestamp is also too large, so the search moves left.

At termination, no unexplored timestamp can improve `answer`.

---

## 8. Correctness reasoning

### Storage remains sorted

The problem guarantees increasing `set` timestamps. Appending each pair therefore maintains chronological order for every key.

### Every returned candidate is valid

`answer` is updated only when `storedTimestamp <= queryTimestamp`.

### The returned candidate is the latest valid one

Whenever a valid midpoint is found, search continues to the right. Any later valid timestamp replaces the earlier candidate. When a midpoint is invalid, its entire right side is also invalid because the history is sorted.

Thus, after binary search, `answer` corresponds to the maximum timestamp satisfying the query—or remains `''` if none exists.

---

## 9. Complexity

Let:

- `N` = total number of `set` calls;
- `k` = number of stored values for the queried key.

| Operation | Time | Space contribution |
| --- | ---: | ---: |
| `set` | O(1) amortized | O(1) per stored version |
| `get` | O(log k) | O(1) |

Total storage is **O(N)**.

Using `k` rather than total `N` for `get` is more precise because binary search examines only one key's history.

---

## 10. Why not map each timestamp directly?

We could imagine:

```text
key → map(timestamp → value)
```

That gives fast exact timestamp lookup but does not efficiently answer:

> What is the greatest timestamp less than or equal to this query?

A JavaScript `Map` is not ordered for predecessor search. We would still need to examine timestamps or maintain an additional ordered structure.

An ordered array supports both cheap append and binary-search floor queries.

---

## 11. Why not scan backward?

A backward scan from the latest value can be fast when queries are usually recent, but its worst-case time is O(k).

The required ordered history already supports guaranteed O(log k) search, which is preferable for arbitrary timestamps and large histories.

---

## 12. Alternative binary-search boundary style

We can search for the first timestamp strictly greater than the query. The desired value is immediately before that boundary.

```javascript
class TimeMapUpperBound {
  constructor() {
    this.historyByKey = new Map();
  }

  set(key, value, timestamp) {
    const history = this.historyByKey.get(key) ?? [];
    history.push([timestamp, value]);
    this.historyByKey.set(key, history);
  }

  get(key, timestamp) {
    const history = this.historyByKey.get(key) ?? [];
    let left = 0;
    let right = history.length;

    while (left < right) {
      const middle = left + Math.floor((right - left) / 2);

      if (history[middle][0] <= timestamp) {
        left = middle + 1;
      } else {
        right = middle;
      }
    }

    const answerIndex = left - 1;
    return answerIndex >= 0 ? history[answerIndex][1] : '';
  }
}
```

After the loop, `left` is the insertion position for the first timestamp greater than the query. Therefore, `left - 1` is the rightmost timestamp less than or equal to it.

Both versions are excellent. The explicit `answer` variable is often easier to narrate under interview pressure.

---

## 13. Common mistakes

### Mistake 1: return only exact timestamp matches

The query asks for the most recent value at or before the timestamp.

### Mistake 2: return the first valid timestamp

We need the **rightmost** valid timestamp, not any valid timestamp.

### Mistake 3: move left after finding a valid midpoint

A better, later valid version can exist to the right.

### Mistake 4: sort during every `get`

The timestamp guarantee means the history is already sorted through append-only writes.

### Mistake 5: search across all keys

The outer hash map should first isolate the history for the requested key.

### Mistake 6: return `undefined`

The required missing value is the empty string `''`.

### Mistake 7: use an object without considering key hazards

JavaScript `Map` cleanly supports arbitrary string keys without prototype-name collisions.

---

## 14. Edge cases

- key has never been stored → `''`
- query occurs before the key's first timestamp → `''`
- query exactly matches a timestamp
- query falls between two timestamps
- query occurs after the latest timestamp
- key has only one version
- many independent keys have different history lengths

---

## 15. Production connections

This simplified design resembles:

- configuration history;
- feature flags evaluated at a historical time;
- price or status history;
- versioned records;
- event-sourced state lookup;
- temporal databases and “as of” queries.

Real systems additionally consider persistence, concurrency, deletion, retention, out-of-order events, clock semantics, and distributed consistency.

The interview pattern remains valuable:

```text
partition by key + order by time + predecessor lookup
```

---

## 16. Interview narration

> “I’ll map each key to an array of timestamp-value pairs. Since set timestamps are strictly increasing, appending preserves sorted order and makes writes O(1) amortized. For get, I’ll binary-search that key's history for the rightmost timestamp less than or equal to the query. Whenever a midpoint qualifies, I save it and continue right for a later valid version.”

---

## 17. Pattern recognition

Look for this pattern when a problem asks for:

- the most recent value before a time;
- the greatest value not exceeding a threshold;
- historical lookup by entity or key;
- append-only versioned data.

The search is a general floor query:

```text
rightmost element satisfying element <= target
```

---

## 18. Quick test

```javascript
const timeMap = new TimeMap();

timeMap.set('foo', 'bar', 1);
console.log(timeMap.get('foo', 1)); // "bar"
console.log(timeMap.get('foo', 3)); // "bar"

timeMap.set('foo', 'bar2', 4);
console.log(timeMap.get('foo', 4)); // "bar2"
console.log(timeMap.get('foo', 5)); // "bar2"
console.log(timeMap.get('foo', 0)); // ""
console.log(timeMap.get('none', 9)); // ""
```

---

## 19. Notebook version

### Pattern

**Hash map + sorted per-key history + binary search**

### Structure

```text
key → [[timestamp, value], ...]
```

### Search target

```text
rightmost timestamp <= query timestamp
```

### Valid midpoint action

```javascript
answer = storedValue;
left = middle + 1;
```

### Memory line

> Append history by key; binary-search the latest version not from the future.

### Complexity

```text
set: O(1) amortized
get: O(log k)
total space: O(N)
```
