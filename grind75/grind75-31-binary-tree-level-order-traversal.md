# Grind 75 — 31: Binary Tree Level Order Traversal

**Difficulty:** Medium  
**Primary pattern:** Breadth-first search / queue / level boundaries  
**LeetCode:** https://leetcode.com/problems/binary-tree-level-order-traversal/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Return the values of a binary tree grouped by depth, from top to bottom and left to right.

```text
       3
      / \
     9  20
       /  \
      15   7
```

Output:

```javascript
[
  [3],
  [9, 20],
  [15, 7],
]
```

Each inner array represents one tree level.

---

## 2. Why breadth-first search fits

Breadth-first search visits nodes by distance from the root:

```text
distance 0 → root
distance 1 → root's children
distance 2 → grandchildren
...
```

Tree depth is exactly unweighted distance from the root. A FIFO queue naturally processes all earlier-depth nodes before later-depth nodes.

Depth-first search can also group nodes by depth, but BFS directly matches the required output order.

---

## 3. Queue invariant

At the start of each outer-loop iteration:

> The unprocessed front section of the queue contains every node in the next level, ordered from left to right.

While processing those nodes, their children are appended behind them. Those children form the following level.

The central challenge is separating the current level from the children being added during its processing.

---

## 4. Snapshot the level boundary

Before processing a level, record:

```javascript
const levelEnd = queue.length;
```

With a moving `front` index, current-level nodes occupy:

```text
queue[front ... levelEnd - 1]
```

Children are appended at indices `levelEnd` and beyond. Processing only until `front === levelEnd` prevents next-level nodes from leaking into the current output array.

---

## 5. Optimal JavaScript solution

```javascript
function levelOrder(root) {
  if (root === null) {
    return [];
  }

  const result = [];
  const queue = [root];
  let front = 0;

  while (front < queue.length) {
    const levelEnd = queue.length;
    const currentLevel = [];

    while (front < levelEnd) {
      const node = queue[front++];
      currentLevel.push(node.val);

      if (node.left !== null) {
        queue.push(node.left);
      }

      if (node.right !== null) {
        queue.push(node.right);
      }
    }

    result.push(currentLevel);
  }

  return result;
}
```

---

## 6. Dry run

Tree:

```text
       3
      / \
     9  20
       /  \
      15   7
```

### Level 0

```text
queue = [3]
front = 0
levelEnd = 1
```

Process node `3`, append children `9` and `20`:

```text
currentLevel = [3]
queue = [3, 9, 20]
front = 1
```

Stop because `front === levelEnd`. Save `[3]`.

### Level 1

```text
levelEnd = 3
process queue indices 1 and 2 → nodes 9 and 20
```

Append children `15` and `7`. Save `[9,20]`.

### Level 2

Process `15` and `7`. Save `[15,7]`.

Final result:

```javascript
[[3], [9, 20], [15, 7]]
```

---

## 7. Code walkthrough

### Empty-tree guard

An absent root has no levels, so return an empty outer array.

### FIFO queue

Nodes are enqueued left child before right child. FIFO processing therefore preserves left-to-right order within every level.

### `front` index instead of `shift()`

Repeated `queue.shift()` removes from the beginning of a JavaScript array and may reindex remaining elements. A monotonic front index makes dequeue work constant-time.

### `levelEnd` versus level size

Many implementations store:

```javascript
const levelSize = queue.length - front;
```

and loop that many times. That is equivalent. `levelEnd` directly records the exclusive array index where the current level stops.

### Append children after reading node value

The precise order does not affect grouping as long as children are appended during the current node's processing. Left before right preserves required horizontal order.

---

## 8. Level-size variant

```javascript
function levelOrderWithSize(root) {
  if (root === null) return [];

  const result = [];
  const queue = [root];
  let front = 0;

  while (front < queue.length) {
    const levelSize = queue.length - front;
    const currentLevel = [];

    for (let i = 0; i < levelSize; i++) {
      const node = queue[front++];
      currentLevel.push(node.val);

      if (node.left !== null) queue.push(node.left);
      if (node.right !== null) queue.push(node.right);
    }

    result.push(currentLevel);
  }

  return result;
}
```

Both versions are correct. The important rule is to freeze the count or ending position before children are appended.

---

## 9. Correctness reasoning

Initially, the queue contains only the root, which is exactly level zero in left-to-right order.

Assume the queue's current front segment contains exactly one tree level. The algorithm records that segment boundary, processes each node in order, and appends its left child then right child. Those children are exactly all nodes in the next level, also in left-to-right order.

Thus, by induction, every outer iteration produces one correct level. Every node is enqueued once, so after the queue is exhausted, the result contains all levels exactly once.

---

## 10. Complexity

Let `n` be the number of tree nodes and `w` the maximum tree width.

- **Time: O(n)** — every node is enqueued, dequeued, and recorded once.
- **Traversal space: O(n)** with this front-index array implementation because processed entries remain in the array; conceptually, an ideal queue needs O(w) live elements.
- **Output space: O(n)** — every node value appears in the result.

Interview convention often states BFS auxiliary space as O(w), worst-case O(n). In JavaScript with a simple array and front index, the backing array retains O(n) references until the function returns. It is accurate to mention both the abstract queue bound and implementation detail.

---

## 11. DFS alternative

Depth-first search can pass the current depth and create an output bucket when first reaching a new level.

```javascript
function levelOrderDfs(root) {
  const result = [];

  function traverse(node, depth) {
    if (node === null) return;

    if (result.length === depth) {
      result.push([]);
    }

    result[depth].push(node.val);
    traverse(node.left, depth + 1);
    traverse(node.right, depth + 1);
  }

  traverse(root, 0);
  return result;
}
```

- Time: **O(n)**.
- Call-stack space: **O(h)**.

Preorder left-before-right preserves left-to-right ordering within depth buckets. BFS remains the more natural answer because the requested output is level-oriented.

---

## 12. Why not process until `front === queue.length` for one level?

`queue.length` grows as children are appended. If the inner loop uses the live queue length:

```javascript
while (front < queue.length) {
  // append children
}
```

it will consume children in the same loop, then grandchildren, flattening the entire tree into one level.

Snapshotting `levelEnd` or `levelSize` before processing prevents this moving-target bug.

---

## 13. Common mistakes

1. **Forgetting the empty-tree guard.** Starting a queue with `null` leads to property access errors.
2. **Not freezing the current level boundary.** Children get mixed into their parent's level.
3. **Incrementing level after every node.** One level ends only after all its nodes are processed.
4. **Enqueuing right before left.** This reverses horizontal order.
5. **Using a stack instead of a queue.** LIFO traversal does not naturally preserve breadth order.
6. **Using `queue.shift()` repeatedly without considering cost.** Prefer a front index in JavaScript.
7. **Returning a flat array.** The output must group values by depth.
8. **Pushing node objects into the result.** The problem asks for node values.
9. **Calling traversal space O(h) for BFS.** BFS is governed by width, not height; the simple JS backing array may retain O(n).

---

## 14. What to say in an interview

> “The output is grouped by depth, so I’ll use BFS. The queue initially contains the root. Before processing each level, I snapshot its ending queue position. I process exactly those nodes, append their values, and enqueue left then right children, which forms the next level in order. Every node is processed once, giving O(n) time and O(w) conceptual queue space, worst-case O(n).”

If asked why the snapshot matters:

> “The queue grows while I process a level; freezing its boundary prevents newly added children from being consumed as part of the same level.”

---

## 15. Pattern recognition

Think **level-order BFS** when:

- results are grouped by depth;
- work proceeds in waves or layers;
- nearest-distance processing matters;
- siblings should be handled before descendants.

Common variations:

- right-side view;
- zigzag level order;
- average of each level;
- minimum tree depth;
- connect next-right pointers;
- infection/spread by time steps.

Memory cue:

> Freeze the level, process it, enqueue the next.

---

## 16. Follow-up transformations

Once level boundaries are correct, many variations are small changes:

### Right-side view

Record the final node processed in each level.

### Average per level

Accumulate the current level's sum and divide by its size.

### Zigzag traversal

Reverse every second level's value array, or fill it in opposite index order.

### Minimum depth

Return the current depth when the first leaf is encountered; BFS guarantees it is shallowest.

The hard reusable part is reliable layer separation.

---

## 17. Edge cases

| Tree | Output |
|---|---|
| empty | `[]` |
| single node `1` | `[[1]]` |
| left-only chain `1→2→3` | `[[1],[2],[3]]` |
| right-only chain | one value per level |
| root with two children | `[[root],[left,right]]` |
| uneven tree | existing nodes grouped by actual depth |

---

## 18. Notebook-ready notes

### 📚 Concept

**Binary Tree Level Order — BFS with frozen level boundary**

```text
empty root → []
queue = [root], front = 0
while queue not exhausted:
  freeze levelEnd = queue.length
  currentLevel = []
  process until front === levelEnd:
    read node
    collect value
    enqueue left, then right
  append currentLevel to result
```

### 🧠 My understanding

The queue front holds the current level, while children are appended behind it as the next level. Because the queue grows during processing, I must freeze the current boundary before adding children. FIFO order and left-before-right enqueueing preserve output order.

### 💼 Interview line

> “I’ll snapshot each BFS layer before its nodes enqueue the next one.”

### ⚠️ Traps

- Handle a null root.
- Freeze level size/end before processing.
- Enqueue left before right.
- Avoid repeated `shift()` in JavaScript.

---

## 19. Dheerix Glance

```text
LEVEL ORDER TRAVERSAL

Technique:        BFS
Structure:        FIFO queue
Initial queue:    root
Level boundary:   snapshot queue.length
Process:          only nodes before frozen boundary
Children order:   left, then right
Output:           one array per level
Time:             O(n)
Queue space:      O(w), worst O(n)
Memory cue:       “Freeze level; process; build next.”
```

---

## 20. Recall test

Without looking back:

1. Why does BFS naturally produce levels?
2. What does the queue contain at the start of an outer iteration?
3. Why must `levelEnd` or `levelSize` be frozen?
4. What happens if the inner loop uses the growing `queue.length` directly?
5. Why enqueue left before right?
6. What are time, output-space, and queue-space complexities?
7. How can DFS also group values by depth?
8. How would this template change for a right-side view?

