# Grind 75 — 65. LRU Cache

## Problem

Design a data structure that follows the **Least Recently Used (LRU)** cache policy.

Implement:

```text
LRUCache(capacity)
get(key)       → return value, or -1 if missing
put(key,value) → insert or update the key
```

Both operations should run in average `O(1)` time.

When an insertion exceeds the capacity, evict the key that has gone unused for the longest time.

Example:

```text
cache = new LRUCache(2)

put(1, 1)      cache: [1]
put(2, 2)      cache: [1, 2]
get(1) → 1     cache: [2, 1]   // 1 becomes most recent
put(3, 3)      cache: [1, 3]   // evict 2
get(2) → -1
put(4, 4)      cache: [3, 4]   // evict 1
```

In the order displays above:

```text
left  = least recently used
right = most recently used
```

---

## What does “used” mean?

A key becomes most recently used when:

- `get(key)` successfully reads it;
- `put(key, value)` inserts it;
- `put(key, value)` updates its value.

A failed `get` does not affect recency because the key is not present.

The cache is therefore maintaining two things simultaneously:

1. key → value lookup;
2. oldest → newest ordering.

---

## Why one ordinary data structure is not enough

### Hash map only

A hash map provides average `O(1)` lookup, insertion, and deletion, but a normal unordered map does not identify the least recently used key.

### Array only

An array can store keys from least to most recent. Removing the oldest item is easy, but finding an arbitrary key or moving it to the end costs `O(n)`.

### Queue only

A queue knows the oldest item, but accessing an arbitrary key and moving it to the newest position is not `O(1)`.

The canonical language-independent design combines:

```text
hash map + doubly linked list
```

- map: find a cache node in `O(1)`;
- list: remove a node and move it to the front in `O(1)`;
- list tail: identify the least recently used node in `O(1)`.

---

## JavaScript advantage: ordered `Map`

JavaScript's `Map` iterates entries in insertion order.

We can define:

```text
first Map key = least recently used
last Map key  = most recently used
```

Important behavior:

- `map.set(existingKey, value)` updates the value but does **not** move the key;
- deleting the key and inserting it again moves it to the end.

Therefore, refreshing recency is:

```javascript
const value = this.cache.get(key);
this.cache.delete(key);
this.cache.set(key, value);
```

And the oldest key is:

```javascript
const leastRecentKey = this.cache.keys().next().value;
```

---

## Concise JavaScript solution

```javascript
class LRUCache {
  constructor(capacity) {
    this.capacity = capacity;
    this.cache = new Map();
  }

  get(key) {
    if (!this.cache.has(key)) return -1;

    const value = this.cache.get(key);

    this.cache.delete(key);
    this.cache.set(key, value);

    return value;
  }

  put(key, value) {
    if (this.cache.has(key)) {
      this.cache.delete(key);
    }

    this.cache.set(key, value);

    if (this.cache.size > this.capacity) {
      const leastRecentKey = this.cache.keys().next().value;
      this.cache.delete(leastRecentKey);
    }
  }
}
```

---

## State invariant

After every operation:

1. every cached key appears exactly once in `this.cache`;
2. its associated value is current;
3. iteration order is least recently used to most recently used;
4. `this.cache.size <= this.capacity`.

Every method preserves this invariant.

---

## Understanding `get`

```text
get(key) {
  if (!this.cache.has(key)) return -1;

  const value = this.cache.get(key);
  this.cache.delete(key);
  this.cache.set(key, value);

  return value;
}
```

### Missing key

Return `-1` immediately. The ordering remains unchanged.

### Existing key

Read its value, remove its old position, and reinsert it at the end. This records that it is now the most recently used key.

Why use `has` instead of testing the value?

```text
if (!this.cache.get(key))
```

would incorrectly treat valid falsy values such as `0`, `false`, or `""` as missing. Membership and stored value are separate questions.

---

## Understanding `put`

```text
put(key, value) {
  if (this.cache.has(key)) {
    this.cache.delete(key);
  }

  this.cache.set(key, value);

  if (this.cache.size > this.capacity) {
    const leastRecentKey = this.cache.keys().next().value;
    this.cache.delete(leastRecentKey);
  }
}
```

### New key

Insert it at the end, making it most recent.

### Existing key

Delete its old position and reinsert it with the new value. Updating counts as use, so the key becomes most recent.

### Capacity exceeded

The first key in iteration order is least recent. Delete it.

Eviction happens **after** insertion. That keeps the logic uniform for both new and updated keys.

---

## Detailed walkthrough

Capacity is `2`.

### `put(1, 1)`

```text
Map order: [1]
LRU = 1
MRU = 1
```

### `put(2, 2)`

```text
Map order: [1, 2]
LRU = 1
MRU = 2
```

### `get(1)`

Read `1`, then delete and reinsert key `1`:

```text
before: [1, 2]
after:  [2, 1]
return: 1
```

Now key `2` is least recent.

### `put(3, 3)`

Insert `3`:

```text
[2, 1, 3]
```

Size `3` exceeds capacity `2`, so remove the first key, `2`:

```text
[1, 3]
```

### `get(2)`

Key `2` is absent, so return `-1`. Order stays `[1, 3]`.

### `put(4, 4)`

```text
insert: [1, 3, 4]
evict:  [3, 4]
```

Key `1` was least recent and is removed.

---

## Correctness argument for the `Map` solution

We prove that each operation returns the correct value and evicts the correct key.

### The order represents recency

Initially the map is empty, so the invariant holds. Whenever a key is successfully accessed or written, the algorithm deletes and reinserts it, placing it last. No other key changes relative position. Therefore the map remains ordered from least to most recent.

### `get` is correct

If the key is absent, returning `-1` matches the specification. If present, the map supplies its current value. Reinserting the key updates recency without changing the value, so both the return value and cache state are correct.

### `put` is correct

The algorithm removes any old occurrence, then inserts exactly one entry containing the new value at the most-recent position. If capacity is exceeded, the first key is least recent by the ordering invariant, so deleting it performs the required eviction.

Thus all operations satisfy the LRU policy.

---

## Complexity

JavaScript `Map` operations `has`, `get`, `set`, and `delete` are expected to run in average constant time. Obtaining the first iterator value is also constant-time in normal implementations.

```text
get: O(1) average
put: O(1) average
space: O(capacity)
```

As with hash tables generally, the guarantee is average or expected `O(1)`, not a mathematical worst-case bound for every engine implementation.

---

## Canonical interview design: map + doubly linked list

Some interviewers do not want a language-specific ordered-map shortcut. The standard design stores each entry in a doubly linked node.

```text
head ⇄ most recent ⇄ ... ⇄ least recent ⇄ tail
```

`head` and `tail` are dummy sentinel nodes. They eliminate special cases when adding or removing at the ends.

```javascript
class ListNode {
  constructor(key = 0, value = 0) {
    this.key = key;
    this.value = value;
    this.prev = null;
    this.next = null;
  }
}

class LRUCacheWithList {
  constructor(capacity) {
    this.capacity = capacity;
    this.nodes = new Map();

    this.head = new ListNode();
    this.tail = new ListNode();
    this.head.next = this.tail;
    this.tail.prev = this.head;
  }

  remove(node) {
    node.prev.next = node.next;
    node.next.prev = node.prev;
  }

  addMostRecent(node) {
    const first = this.head.next;

    node.prev = this.head;
    node.next = first;
    this.head.next = node;
    first.prev = node;
  }

  moveToMostRecent(node) {
    this.remove(node);
    this.addMostRecent(node);
  }

  get(key) {
    if (!this.nodes.has(key)) return -1;

    const node = this.nodes.get(key);
    this.moveToMostRecent(node);
    return node.value;
  }

  put(key, value) {
    if (this.nodes.has(key)) {
      const node = this.nodes.get(key);
      node.value = value;
      this.moveToMostRecent(node);
      return;
    }

    const node = new ListNode(key, value);
    this.nodes.set(key, node);
    this.addMostRecent(node);

    if (this.nodes.size > this.capacity) {
      const leastRecent = this.tail.prev;
      this.remove(leastRecent);
      this.nodes.delete(leastRecent.key);
    }
  }
}
```

---

## How the doubly linked list achieves `O(1)`

### Why not a singly linked list?

If the map points to a node in the middle of a singly linked list, removing it also requires finding its predecessor, which can take `O(n)`.

A doubly linked node stores both neighbors:

```text
node.prev ⇄ node ⇄ node.next
```

Removal is four pointer assignments:

```javascript
node.prev.next = node.next;
node.next.prev = node.prev;
```

### Why store the key inside the node?

When evicting the tail node, we must also delete the corresponding map entry:

```javascript
this.nodes.delete(leastRecent.key);
```

The node needs both key and value so eviction can update both structures in `O(1)`.

### Why use sentinel nodes?

Without dummy head and tail nodes, removing the only item or adding to an empty list requires separate boundary logic. Sentinels guarantee that every real node always has both a previous and next node.

---

## Doubly linked list invariants

After every operation:

1. `head.next` is the most recently used real node, or `tail` when empty;
2. `tail.prev` is the least recently used real node, or `head` when empty;
3. every map entry points to exactly one node in the list;
4. every real list node has exactly one map entry;
5. adjacent `prev` and `next` pointers agree;
6. the number of real nodes never exceeds capacity.

These invariants are useful during debugging. Most LRU bugs are broken correspondence between the map and list, or incorrect pointer rewiring.

---

## Common mistakes

### 1. Not refreshing recency on `get`

A successful read counts as use. The key must become most recent.

### 2. Updating a value without refreshing recency

`put` on an existing key also counts as use.

### 3. Assuming `Map.set` moves an existing key

It does not. Delete first, then set.

### 4. Using a value test instead of `has`

Falsy values may be valid. Use membership checks to determine whether a key exists.

### 5. Evicting the newest key

With the ordered-Map solution, the first key is least recent and the last is most recent. Be explicit about your chosen orientation.

### 6. Letting the cache temporarily remain oversized

After inserting a new key, immediately evict if `size > capacity`.

### 7. Forgetting to delete the evicted node from the map

In the linked-list design, removal must update both the list and map.

### 8. Forgetting to store the key in linked nodes

Without it, tail eviction cannot efficiently identify which map entry to remove.

### 9. Using an array and `splice`

Finding and removing arbitrary entries costs `O(n)`, violating the requirement.

### 10. Reusing detached linked-list pointers incorrectly

Centralize pointer manipulation in small helper methods such as `remove` and `addMostRecent` rather than duplicating it across `get` and `put`.

---

## Edge cases

```text
capacity = 1
put(1,1), put(2,2)
→ key 1 is immediately evicted

update existing key
put(1,1), put(1,9)
→ size remains 1, value becomes 9, key becomes most recent

failed lookup
get(999)
→ returns -1 and changes nothing

stored zero
put(1,0), get(1)
→ returns 0, not -1

access changes eviction
put(1,1), put(2,2), get(1), put(3,3)
→ key 2 is evicted
```

The LeetCode problem guarantees positive capacity. If designing a production API, define behavior for capacity zero and invalid capacities explicitly.

---

## Production engineering connection

An LRU cache limits memory while retaining recently valuable data, but a production cache usually needs more than this interview structure:

- time-to-live expiration;
- memory measured in bytes rather than entry count;
- concurrency control;
- cache hit/miss and eviction metrics;
- explicit invalidation;
- loading and refresh policy;
- protection against cache stampedes;
- alternative policies such as LFU, ARC, or size-aware eviction.

JavaScript's ordered `Map` is convenient for in-process caches. For high-throughput or concurrent systems, use a tested cache library rather than rebuilding synchronization and expiration behavior around this interview implementation.

---

## Interview walkthrough

Start with the data-structure requirement:

> I need `O(1)` lookup by key and `O(1)` recency updates. The canonical combination is a hash map pointing to nodes in a doubly linked list: the map finds nodes, the list maintains most-to-least-recent order, and the tail identifies the eviction candidate.

For JavaScript, add:

> Since JavaScript `Map` preserves insertion order, I can use its first key as the least recent key. On every successful access or update, I’ll delete and reinsert the key to move it to the newest position. This gives a concise implementation with average `O(1)` operations.

If the interviewer wants the language-independent design, implement the doubly linked list version.

Complexity statement:

> Every get, set, delete, pointer removal, and pointer insertion is constant time on average, so `get` and `put` are average `O(1)`, with `O(capacity)` space.

---

## Notebook version

```javascript
class LRUCache {
  constructor(capacity) {
    this.capacity = capacity;
    this.cache = new Map();
  }

  get(key) {
    if (!this.cache.has(key)) return -1;

    const value = this.cache.get(key);
    this.cache.delete(key);
    this.cache.set(key, value);
    return value;
  }

  put(key, value) {
    if (this.cache.has(key)) {
      this.cache.delete(key);
    }

    this.cache.set(key, value);

    if (this.cache.size > this.capacity) {
      const lru = this.cache.keys().next().value;
      this.cache.delete(lru);
    }
  }
}
```

### Notebook bullets

- Need lookup + recency order.
- JavaScript `Map` order: oldest insertion → newest insertion.
- Successful `get`: delete + reinsert.
- Existing `put`: delete + reinsert with new value.
- If oversized, delete the first key.
- Canonical general design: map + doubly linked list.
- `get`/`put`: average `O(1)`; space `O(capacity)`.

### Memory line

> Touch it, move it to newest; overflow, remove the oldest.

### Design card

```text
lookup:   hash map
ordering: doubly linked list or JavaScript ordered Map
MRU:      newest end
LRU:      oldest end
```
