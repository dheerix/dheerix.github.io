# Grind 75 — 74: Merge k Sorted Lists

**Difficulty:** Hard  
**Primary pattern:** Min-heap / k-way merge  
**LeetCode:** 23  
**Target interview time:** 30 minutes  
**Language:** JavaScript

## Problem

Given an array of `k` sorted linked lists, merge them into one sorted linked list and return its head.

Example:

```text
lists = [
  1 -> 4 -> 5,
  1 -> 3 -> 4,
  2 -> 6
]

result:
1 -> 1 -> 2 -> 3 -> 4 -> 4 -> 5 -> 6
```

Each input list is sorted in nondecreasing order.

---

## 1. Intuition

In one sorted list, the smallest remaining value is always at its current head.

Across `k` sorted lists, the next output node must therefore be the smallest among the `k` current heads.

We repeatedly need this operation:

```text
find the smallest current head
remove it
add that node's successor as a new candidate
```

A min-heap is designed for exactly this:

- `peek/pop` gives the smallest head;
- inserting the popped node's successor keeps the candidate set current;
- the heap contains at most one node from each list, so its size is at most `k`.

This is the standard **k-way merge** pattern used for sorted lists, sorted arrays, external files, and streaming data.

---

## 2. Brute Force — Collect Values and Sort

Traverse all lists, collect every value, sort the values, and build a new linked list.

```js
function mergeKLists(lists) {
  const values = [];

  for (let node of lists) {
    while (node !== null) {
      values.push(node.val);
      node = node.next;
    }
  }

  values.sort((a, b) => a - b);

  const dummy = new ListNode(0);
  let tail = dummy;

  for (const value of values) {
    tail.next = new ListNode(value);
    tail = tail.next;
  }

  return dummy.next;
}
```

Let `N` be the total number of nodes across all lists.

### Complexity

- Time: `O(N log N)`.
- Extra space: `O(N)` for values and newly allocated nodes.

It ignores the fact that each list is already sorted.

---

## 3. Better Solution — Merge Lists One at a Time

Reuse the standard two-list merge repeatedly.

```js
function mergeKLists(lists) {
  let merged = null;

  for (const list of lists) {
    merged = mergeTwoLists(merged, list);
  }

  return merged;
}

function mergeTwoLists(first, second) {
  const dummy = new ListNode(0);
  let tail = dummy;

  while (first !== null && second !== null) {
    if (first.val <= second.val) {
      tail.next = first;
      first = first.next;
    } else {
      tail.next = second;
      second = second.next;
    }

    tail = tail.next;
  }

  tail.next = first ?? second;
  return dummy.next;
}
```

### Why it can be slow

If lists have similar lengths, nodes from early lists are traversed again whenever another list is merged.

### Complexity

- Time: up to `O(Nk)`.
- Auxiliary space: `O(1)` when nodes are relinked.

---

## 4. Optimal Solution — Min-Heap of Current Heads

JavaScript environments do not universally provide a built-in priority queue, so this solution includes a compact min-heap.

```js
class MinHeap {
  constructor(compare) {
    this.values = [];
    this.compare = compare;
  }

  size() {
    return this.values.length;
  }

  push(value) {
    this.values.push(value);
    this.#bubbleUp(this.values.length - 1);
  }

  pop() {
    if (this.values.length === 0) return null;
    if (this.values.length === 1) return this.values.pop();

    const smallest = this.values[0];
    this.values[0] = this.values.pop();
    this.#bubbleDown(0);

    return smallest;
  }

  #bubbleUp(index) {
    while (index > 0) {
      const parent = Math.floor((index - 1) / 2);

      if (!this.compare(this.values[index], this.values[parent])) break;

      [this.values[index], this.values[parent]] =
        [this.values[parent], this.values[index]];

      index = parent;
    }
  }

  #bubbleDown(index) {
    const length = this.values.length;

    while (true) {
      const left = index * 2 + 1;
      const right = index * 2 + 2;
      let smallest = index;

      if (
        left < length &&
        this.compare(this.values[left], this.values[smallest])
      ) {
        smallest = left;
      }

      if (
        right < length &&
        this.compare(this.values[right], this.values[smallest])
      ) {
        smallest = right;
      }

      if (smallest === index) break;

      [this.values[index], this.values[smallest]] =
        [this.values[smallest], this.values[index]];

      index = smallest;
    }
  }
}

/**
 * Definition for singly-linked list.
 * function ListNode(val, next) {
 *   this.val = val ?? 0;
 *   this.next = next ?? null;
 * }
 */

/**
 * @param {Array<ListNode|null>} lists
 * @return {ListNode|null}
 */
function mergeKLists(lists) {
  const minHeap = new MinHeap((first, second) => first.val < second.val);

  for (const head of lists) {
    if (head !== null) {
      minHeap.push(head);
    }
  }

  const dummy = new ListNode(0);
  let tail = dummy;

  while (minHeap.size() > 0) {
    const smallestNode = minHeap.pop();

    tail.next = smallestNode;
    tail = tail.next;

    if (smallestNode.next !== null) {
      minHeap.push(smallestNode.next);
    }
  }

  return dummy.next;
}
```

---

## 5. Why Only One Node per List Is Needed

Suppose a list is:

```text
2 -> 6 -> 9
```

While `2` remains unprocessed, `6` cannot be the smallest available value from this list. The sorted order guarantees:

```text
2 <= 6 <= 9
```

Therefore, only the current head can compete for the next output position.

After popping `2`, expose `6` by pushing it into the heap. This keeps the heap small and ensures no node is considered before its predecessor.

### Heap invariant

The heap contains exactly the first unmerged node of every non-exhausted list.

Consequently, its root is the smallest unmerged node across all lists.

---

## 6. Walkthrough

```text
L1: 1 -> 4 -> 5
L2: 1 -> 3 -> 4
L3: 2 -> 6
```

Initial heap contains the heads:

```text
[1(L1), 1(L2), 2(L3)]
```

| Step | Pop | Push successor | Output |
| ---: | --- | --- | --- |
| 1 | `1(L1)` | `4(L1)` | `1` |
| 2 | `1(L2)` | `3(L2)` | `1 -> 1` |
| 3 | `2(L3)` | `6(L3)` | `1 -> 1 -> 2` |
| 4 | `3(L2)` | `4(L2)` | `... -> 3` |
| 5 | `4(L1)` | `5(L1)` | `... -> 4` |
| 6 | `4(L2)` | none | `... -> 4` |
| 7 | `5(L1)` | none | `... -> 5` |
| 8 | `6(L3)` | none | `... -> 6` |

Final list:

```text
1 -> 1 -> 2 -> 3 -> 4 -> 4 -> 5 -> 6
```

---

## 7. Correctness Proof

We prove that the algorithm returns one sorted list containing every input node exactly once.

### Invariant

Before each iteration, the heap contains the first unmerged node from every non-empty remaining list.

### Initialization

The algorithm inserts every non-null list head. Thus, the invariant holds before the first iteration.

### Maintenance

The heap root has the smallest value among all current list heads. Because every remaining node in a list is greater than or equal to that list's head, no hidden node can be smaller than the minimum current head. Therefore, the popped node is the globally smallest unmerged node and is safe to append next.

If the popped node has a successor, that successor becomes the first unmerged node of its list and is inserted. Every other list's first unmerged node remains in the heap. Thus, the invariant is preserved.

### Sortedness

Every appended node is the smallest unmerged node, so output values are appended in nondecreasing order.

### Completeness and uniqueness

Every node enters the heap exactly once: a head enters initially, and every other node enters when its predecessor is popped. Every heap entry is popped and appended exactly once. Therefore, all nodes appear exactly once.

When the heap becomes empty, every list is exhausted. The returned list is therefore complete and sorted.

---

## 8. Complexity

Let:

- `k` be the number of input lists;
- `N` be the total number of nodes across all lists.

### Time

```text
O(N log k)
```

Every node is pushed and popped once. The heap contains at most `k` nodes, so each heap operation costs `O(log k)`.

### Auxiliary space

```text
O(k)
```

The heap stores at most one current node per list. The output reuses existing linked-list nodes, apart from one dummy node.

---

## 9. Equally Optimal Alternative — Divide and Conquer

Merge lists in balanced pairs:

```text
round 1: merge pairs of individual lists
round 2: merge pairs of 2-list results
round 3: merge pairs of 4-list results
...
```

```js
function mergeKLists(lists) {
  if (lists.length === 0) return null;

  let interval = 1;

  while (interval < lists.length) {
    for (let i = 0; i + interval < lists.length; i += interval * 2) {
      lists[i] = mergeTwoLists(lists[i], lists[i + interval]);
    }

    interval *= 2;
  }

  return lists[0];
}
```

### Complexity

- Time: `O(N log k)`.
- Auxiliary merge space: `O(1)` with iterative two-list merging.

### Heap versus divide and conquer

- Heap: natural k-way streaming solution; easy to generalize when lists arrive as iterators.
- Divide and conquer: simpler if `mergeTwoLists` is already available; no custom heap required.

Both are optimal under the comparison model.

---

## 10. Common Mistakes

### Mistake 1: Pushing every node into the heap initially

That makes heap size `N`, producing `O(N log N)` time and `O(N)` heap space. Push only list heads, then one successor at a time.

### Mistake 2: Pushing null heads

Skip empty lists before heap insertion.

### Mistake 3: Forgetting to push the popped node's successor

Then the rest of that list disappears from consideration.

### Mistake 4: Creating new nodes unnecessarily

Relink the existing nodes unless the problem requires preserving the inputs.

### Mistake 5: Losing the head of the result

Use a dummy node and return `dummy.next`.

### Mistake 6: Advancing `tail` incorrectly

After linking the smallest node:

```js
tail.next = smallestNode;
tail = tail.next;
```

### Mistake 7: Saying heap operations cost `O(log N)`

The heap holds at most `k` candidates, so the tighter cost is `O(log k)`.

### Mistake 8: Sequentially merging without analyzing repeated work

Repeatedly merging a growing list with one more list can take `O(Nk)`. Balanced merging avoids this.

### Mistake 9: Incorrect JavaScript heap comparator

For nodes in a min-heap:

```js
(first, second) => first.val < second.val
```

---

## 11. Edge Cases

### No lists

```text
[] -> null
```

### All lists empty

```text
[null, null] -> null
```

### One list

The same nodes are returned in their existing order.

### Some empty lists

Only non-null heads are inserted.

### Duplicate values

Any equal-valued node may be chosen first; nondecreasing order remains valid.

### Negative values

The numeric comparator handles them normally.

### Lists with very different lengths

Heap size still remains at most `k`, independent of individual list length.

### `k` is large but most lists are empty

The actual heap size equals the number of non-empty lists, which may be much smaller than `k`.

---

## 12. Interview Explanation

> Since every input list is sorted, the next global output node must be the smallest among the current list heads. I place each non-null head into a min-heap. Repeatedly, I pop the smallest node, append it to the result, and push that node's successor if it exists. The heap invariant is that it contains the first unmerged node of every non-exhausted list, so its root is always the globally smallest remaining node. With `N` total nodes and at most `k` heap entries, the solution takes `O(N log k)` time and `O(k)` auxiliary space while reusing the original nodes.

### Clarify aloud

1. May I reuse and relink input nodes?
2. Are individual lists guaranteed sorted?
3. Can `lists` or its entries be empty?
4. Should duplicate values be preserved? Yes.

### Follow-up: lists are streams too large for memory

The heap approach still works if each source exposes only its current item and a way to advance. It stores one item per source rather than loading all values.

---

## 13. Notebook Version

### Recognition

```text
k sorted sources
next output = minimum current head
=> min-heap of size at most k
```

### Algorithm

1. Push every non-null list head.
2. Pop the smallest node.
3. Append it to the output.
4. Push its successor if present.
5. Repeat until heap is empty.

### Core JavaScript

```js
function mergeKLists(lists) {
  const heap = new MinHeap((a, b) => a.val < b.val);

  for (const head of lists) {
    if (head) heap.push(head);
  }

  const dummy = new ListNode(0);
  let tail = dummy;

  while (heap.size()) {
    const node = heap.pop();
    tail.next = node;
    tail = node;

    if (node.next) heap.push(node.next);
  }

  return dummy.next;
}
```

### Complexity

```text
Time:  O(N log k)
Space: O(k)
```

### Invariant

The heap contains the first unmerged node from every non-exhausted list.

---

## 14. Memory Line

**Keep one candidate per sorted list; pop the smallest and expose its successor.**

