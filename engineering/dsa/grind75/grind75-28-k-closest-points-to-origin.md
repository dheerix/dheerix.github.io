# Grind 75 — 28: K Closest Points to Origin

**Difficulty:** Medium  
**Primary pattern:** Sorting / bounded max-heap / top-k selection  
**LeetCode:** https://leetcode.com/problems/k-closest-points-to-origin/  
**Target time:** 30 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given points `[x, y]` on a 2D plane, return any `k` points closest to the origin `[0, 0]`.

```text
points = [[1,3], [-2,2]]
k = 1

distance of [1,3]  = √10
distance of [-2,2] = √8

answer = [[-2,2]]
```

The returned points can be in any order. If multiple points tie, any valid selection is accepted.

---

## 2. Distance comparison without square roots

Euclidean distance from `[x, y]` to the origin is:

```text
√(x² + y²)
```

Square root is strictly increasing for non-negative values. Therefore:

```text
√A < √B exactly when A < B
```

We can compare squared distances:

```javascript
x * x + y * y
```

This avoids unnecessary square-root work and preserves the exact ordering.

---

## 3. Fastest JavaScript interview solution: sort

Sort all points by squared distance and return the first `k`.

```javascript
function kClosest(points, k) {
  return [...points]
    .sort((pointA, pointB) => {
      return squaredDistance(pointA) - squaredDistance(pointB);
    })
    .slice(0, k);
}

function squaredDistance([x, y]) {
  return x * x + y * y;
}
```

### Complexity

- Time: **O(n log n)**.
- Extra space: **O(n)** here because `[...points]` protects the input from mutation; sorting space also depends on the engine.

If input mutation is allowed, sort `points` directly and avoid the explicit copy.

### Why this is a strong interview choice

- very short;
- difficult to get wrong;
- easy to explain;
- often satisfies constraints comfortably.

Then mention that a size-`k` heap improves work when `k` is much smaller than `n`.

---

## 4. Why a max-heap for the closest points?

To retain the `k` smallest distances seen so far, we need quick access to the **largest** distance among those retained points.

That largest retained point is the worst current candidate:

```text
new closer point arrives
→ remove the farthest retained point
```

Therefore, use a max-heap of size at most `k`.

This often feels reversed:

```text
k smallest items → maintain a max-heap
k largest items  → maintain a min-heap
```

The heap root should expose the retained item most likely to be evicted.

---

## 5. Size-k heap algorithm

For each point:

1. Compute its squared distance.
2. Push it into a max-heap.
3. If heap size exceeds `k`, remove the maximum-distance point.
4. After all points, the heap contains exactly `k` closest points.

Invariant:

> After processing any prefix, the heap contains the `min(k, processedCount)` closest points from that prefix.

---

## 6. JavaScript max-heap implementation

JavaScript does not have a standard built-in priority queue. To avoid depending on a platform-specific helper, implement a small binary max-heap storing:

```text
{ point, distance }
```

```javascript
class MaxHeap {
  constructor() {
    this.items = [];
  }

  get size() {
    return this.items.length;
  }

  push(item) {
    this.items.push(item);
    this.bubbleUp(this.items.length - 1);
  }

  pop() {
    if (this.items.length === 1) {
      return this.items.pop();
    }

    const maximum = this.items[0];
    this.items[0] = this.items.pop();
    this.bubbleDown(0);
    return maximum;
  }

  bubbleUp(index) {
    while (index > 0) {
      const parentIndex = Math.floor((index - 1) / 2);

      if (
        this.items[parentIndex].distance >=
        this.items[index].distance
      ) {
        break;
      }

      [this.items[parentIndex], this.items[index]] =
        [this.items[index], this.items[parentIndex]];

      index = parentIndex;
    }
  }

  bubbleDown(index) {
    const length = this.items.length;

    while (true) {
      const leftChild = 2 * index + 1;
      const rightChild = 2 * index + 2;
      let largest = index;

      if (
        leftChild < length &&
        this.items[leftChild].distance >
          this.items[largest].distance
      ) {
        largest = leftChild;
      }

      if (
        rightChild < length &&
        this.items[rightChild].distance >
          this.items[largest].distance
      ) {
        largest = rightChild;
      }

      if (largest === index) {
        break;
      }

      [this.items[index], this.items[largest]] =
        [this.items[largest], this.items[index]];

      index = largest;
    }
  }
}
```

---

## 7. O(n log k) heap solution

```javascript
function kClosestWithHeap(points, k) {
  const heap = new MaxHeap();

  for (const point of points) {
    const [x, y] = point;

    heap.push({
      point,
      distance: x * x + y * y,
    });

    if (heap.size > k) {
      heap.pop();
    }
  }

  return heap.items.map(({ point }) => point);
}
```

### Complexity

- Time: **O(n log k)** — each point is pushed, and at most one item is removed while heap size stays near `k`.
- Extra space: **O(k)**.

The heap's internal order is not sorted, but the problem permits any result order.

---

## 8. Heap dry run

```text
points = [[3,3], [5,-1], [-2,4], [1,1]]
k = 2
```

Squared distances:

```text
[3,3]  → 18
[5,-1] → 26
[-2,4] → 20
[1,1]  → 2
```

| Point | Heap retained distances after trimming |
|---|---|
| `[3,3]` | `[18]` |
| `[5,-1]` | `[26,18]` |
| `[-2,4]` | push 20, remove 26 → `[20,18]` |
| `[1,1]` | push 2, remove 20 → `[18,2]` |

Final retained points have squared distances `18` and `2`, the two smallest.

---

## 9. Binary-heap mechanics

A binary heap is stored in an array.

For an item at index `i`:

```text
parent      = floor((i - 1) / 2)
left child  = 2i + 1
right child = 2i + 2
```

Max-heap property:

```text
every parent distance >= child distances
```

### Push

Append at the end, then bubble upward while larger than the parent.

### Pop maximum

Save the root, move the final item to index zero, then bubble downward toward the larger child.

Heap operations take O(log k) because heap height is O(log k).

---

## 10. Correctness reasoning for the heap solution

Assume after processing a prefix that the heap contains its `k` closest points, or all points if fewer than `k` exist.

When a new point arrives, adding it produces at most `k + 1` candidates. If there are more than `k`, the max-heap removes the farthest candidate. The remaining `k` must therefore be the closest `k` among the expanded prefix.

By induction, after all points are processed, the heap contains the `k` closest points in the entire input.

---

## 11. Sort versus heap versus quickselect

| Approach | Time | Extra space | Best use |
|---|---:|---:|---|
| Sort all | O(n log n) | O(n) with copy | Fastest reliable JS coding |
| Size-k max-heap | O(n log k) | O(k) | Small `k`, streaming input |
| Quickselect | O(n) average, O(n²) worst | O(1) in-place average stack varies | Strong selection optimization |

Quickselect partitions points around a pivot until the first `k` positions contain the smallest distances. It is asymptotically attractive on average but more error-prone to implement under interview pressure.

Recommended interview progression:

1. state sorting solution and complexity;
2. implement it if constraints permit or speed matters;
3. mention/implement the size-k heap when the interviewer asks for improvement or streaming behavior.

---

## 12. Why not use a min-heap of size k?

If a size-`k` min-heap stores the currently closest points, its root is the **closest** retained point. When a better candidate arrives, we need to evict the farthest retained point, but that point is not available efficiently at the root.

A max-heap exposes exactly the eviction candidate needed.

An alternative is to put all `n` points into a min-heap and pop `k` times:

- building/pushing: O(n log n), or O(n) with heapify;
- extracting: O(k log n);
- storage: O(n).

The bounded max-heap better exploits small `k`.

---

## 13. JavaScript-specific considerations

### Numeric comparator

Always provide a comparator to `sort`:

```javascript
(a, b) => squaredDistance(a) - squaredDistance(b)
```

Default sort compares string representations.

### Mutation

```text
points.sort(...)
```

mutates the input. Use `[...points]` if mutation is not allowed.

### Squared-distance range

Under official constraints, `x² + y²` is safely representable as a JavaScript number. For arbitrary huge integer coordinates, safe-integer concerns would need clarification.

### Platform priority queues

Some coding platforms expose `MaxPriorityQueue`, but it is not part of standard JavaScript. Confirm availability before relying on it.

---

## 14. Common mistakes

1. **Calling `Math.sqrt` unnecessarily.** Squared distances preserve ordering.
2. **Using Manhattan distance `|x| + |y|`.** The problem specifies Euclidean distance.
3. **Using a min-heap for a bounded `k`-smallest set.** We need fast eviction of the farthest retained point.
4. **Letting the heap grow to `n`.** Trim whenever size exceeds `k`.
5. **Assuming heap contents are sorted.** A heap guarantees only parent-child priority; result order is irrelevant here.
6. **Sorting without a numeric comparator.** JavaScript default sort is lexicographic.
7. **Mutating the input silently.** Copy before sorting if mutation is undesirable.
8. **Returning distances instead of points.** The answer requires original coordinate pairs.
9. **Recomputing distance many times inside a heap.** Store it with the point for simple comparisons.
10. **Claiming heap time is O(n log n).** With maximum heap size `k`, it is O(n log k).

---

## 15. What to say in an interview

Fast implementation answer:

> “I can compare squared distances because square root is monotonic. Sorting the points by `x² + y²` and returning the first `k` gives O(n log n) time. In JavaScript, this is the shortest reliable implementation.”

Optimization:

> “If `k` is much smaller than `n` or points arrive as a stream, I’ll maintain a max-heap of size `k`. Its root is the farthest retained point, so every better point can replace it. That gives O(n log k) time and O(k) space.”

---

## 16. Pattern recognition

Think **top-k selection** when:

- only the best `k` items are required;
- items have a comparable score;
- processing all items into fully sorted order may be unnecessary;
- data may arrive incrementally.

Heap orientation rule:

```text
keep k smallest → max-heap exposes worst retained item
keep k largest  → min-heap exposes worst retained item
```

Memory cue:

> Keep the best `k`; expose the worst among them for eviction.

---

## 17. Edge cases

| Situation | Expected behavior |
|---|---|
| `k = 1` | return one nearest point |
| `k = points.length` | return every point |
| point at origin | squared distance zero |
| negative coordinates | squaring handles signs |
| equal distances | any tied selection/order accepted |
| duplicate points | duplicates remain valid separate entries |

---

## 18. Notebook-ready notes

### 📚 Concept

**K Closest Points — top-k selection**

```text
distance score = x² + y²
No sqrt required

Fast JS approach:
  sort ascending by score
  return first k
  O(n log n)

Optimized:
  max-heap size k
  push each point
  size > k → pop farthest
  O(n log k), O(k) space
```

### 🧠 My understanding

I need only relative distance order, so squared distance is sufficient. For bounded top-k processing, I keep the closest candidates while a max-heap exposes the farthest retained point—the one to evict when a closer point appears.

### 💼 Interview line

> “For `k` smallest items, I use a max-heap so the worst retained item is removable.”

### ⚠️ Traps

- Euclidean score is `x² + y²`.
- JavaScript sort needs a comparator and mutates unless copied.
- A bounded heap for `k` smallest is a max-heap.
- Heap output need not be sorted.

---

## 19. Dheerix Glance

```text
K CLOSEST POINTS

Score:            x² + y²
Why no sqrt:      monotonic transformation
Fast coding:      sort + slice → O(n log n)
Optimized:        size-k max-heap
Heap root:        farthest retained point
On size k+1:      evict maximum distance
Heap time:        O(n log k)
Heap space:       O(k)
Memory cue:       “Keep best k; expose worst retained.”
```

---

## 20. Recall test

Without looking back:

1. Why can square root be omitted?
2. What are the sorting solution's time and mutation trade-offs?
3. Why does retaining the `k` closest require a max-heap?
4. What invariant does the bounded heap maintain?
5. Why is heap time O(n log k)?
6. Does the final heap array need to be sorted?
7. When is sorting preferable to a heap in a JavaScript interview?
8. What JavaScript-specific assumptions should be checked before using a priority queue?
