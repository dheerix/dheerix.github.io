# Grind 75 — 55. Binary Tree Right Side View

## Problem

Given the root of a binary tree, imagine standing on its right side. Return the value of the node visible at each depth, from top to bottom.

Example:

```text
        1
       / \
      2   3
       \   \
        5   4

right side view = [1, 3, 4]
```

---

## 1. What does “visible from the right” mean?

At every depth, exactly one node is visible: the rightmost existing node on that level.

This does **not** mean following only `.right` pointers.

Consider:

```text
      1
     /
    2
     \
      5
```

The right-side view is:

```text
[1, 2, 5]
```

Even left-subtree nodes can be visible when no node lies farther right at the same depth.

The problem is fundamentally about tree levels, not a single right-child path.

---

## 2. BFS insight

Breadth-first search naturally processes the tree one depth at a time.

If children are enqueued left before right, the final node processed in each level is the rightmost node.

Therefore:

```text
process one level
      ↓
record its last node
      ↓
repeat for the next level
```

---

## 3. Recommended JavaScript solution: level-order BFS

```javascript
function rightSideView(root) {
  if (root === null) return [];

  const result = [];
  const queue = [root];
  let head = 0;

  while (head < queue.length) {
    const levelSize = queue.length - head;

    for (let i = 0; i < levelSize; i++) {
      const node = queue[head++];

      if (node.left !== null) {
        queue.push(node.left);
      }

      if (node.right !== null) {
        queue.push(node.right);
      }

      if (i === levelSize - 1) {
        result.push(node.val);
      }
    }
  }

  return result;
}
```

---

## 4. Why capture `levelSize` before the loop?

At the beginning of one level:

```javascript
const levelSize = queue.length - head;
```

counts exactly the unprocessed nodes currently belonging to that depth.

While processing them, their children are appended to the queue. Those children belong to the next depth and must not be processed in the current level loop.

Freezing `levelSize` separates the queue into logical layers even as its physical length grows.

---

## 5. JavaScript queue detail

Avoid repeated:

```javascript
queue.shift();
```

Removing the first array item may require reindexing the remaining elements, making each dequeue O(n).

Use a head pointer:

```javascript
const node = queue[head++];
```

This gives O(1) dequeue behavior for the traversal.

---

## 6. Walkthrough

Tree:

```text
        1
       / \
      2   3
       \   \
        5   4
```

### Level 0

```text
queue level = [1]
last node = 1
result = [1]
```

Enqueue `2`, then `3`.

### Level 1

```text
queue level = [2, 3]
last node = 3
result = [1, 3]
```

Enqueue `5` from node `2`, then `4` from node `3`.

### Level 2

```text
queue level = [5, 4]
last node = 4
result = [1, 3, 4]
```

Return `[1,3,4]`.

---

## 7. Correctness reasoning

We maintain this invariant:

> At the beginning of each outer-loop iteration, the next `levelSize` unprocessed queue entries are exactly the nodes at one depth, ordered from left to right.

This is true initially because the queue contains only the root.

While processing a level, every node's left child is enqueued before its right child, and parents themselves are processed left to right. Therefore, children enter the queue in left-to-right order for the next level.

The node at index `levelSize - 1` is consequently the rightmost existing node at that depth. Recording it gives the correct visible node.

Every tree node is eventually processed once, so the result contains exactly one correct value per depth.

---

## 8. Complexity

Let `n` be the number of nodes and `w` the maximum tree width.

- Time: **O(n)**
- Queue space: **O(w)** conceptually
- Result space: **O(h)**, where `h` is the tree height

With the JavaScript head-index array implementation, processed queue entries remain in the array until the function ends, so the physical array may hold O(n) references. The algorithmic BFS frontier is O(w).

---

## 9. DFS alternative: visit right first

Depth-first search can also solve the problem.

If we visit the right subtree before the left subtree, the first node reached at each depth is the rightmost visible node.

```javascript
function rightSideViewDFS(root) {
  const result = [];

  function visit(node, depth) {
    if (node === null) return;

    if (depth === result.length) {
      result.push(node.val);
    }

    visit(node.right, depth + 1);
    visit(node.left, depth + 1);
  }

  visit(root, 0);
  return result;
}
```

---

## 10. Why `depth === result.length` works

Initially:

```text
result.length = 0
```

The first node reached at depth `0` is recorded. Then the result length becomes `1`.

Because DFS visits right before left, the first node encountered at every new depth is the rightmost available node. Therefore:

```javascript
if (depth === result.length) {
  result.push(node.val);
}
```

records exactly one node per newly discovered level.

Any later node at that same depth sees `depth < result.length` and is ignored.

---

## 11. BFS versus DFS

| BFS | DFS |
| --- | --- |
| Directly models levels | Directly models first node per depth |
| Record last node of each level | Visit right first and record first node |
| Frontier space O(w) | Recursion space O(h) |
| No recursion-depth risk | Concise but deep trees can overflow JS call stack |

Both take O(n) time. BFS is often the easiest explanation because the prompt explicitly asks for one node per depth.

---

## 12. Alternative BFS: enqueue right first

If each level is traversed right to left, record the first node instead of the last.

```javascript
function rightSideViewRightFirstBFS(root) {
  if (root === null) return [];

  const result = [];
  const queue = [root];
  let head = 0;

  while (head < queue.length) {
    const levelSize = queue.length - head;

    for (let i = 0; i < levelSize; i++) {
      const node = queue[head++];

      if (i === 0) result.push(node.val);

      if (node.right !== null) queue.push(node.right);
      if (node.left !== null) queue.push(node.left);
    }
  }

  return result;
}
```

The traversal order and recording rule must agree:

```text
left-to-right level → record last
right-to-left level → record first
```

---

## 13. Common mistakes

### Mistake 1: follow only right children

A left-descendant can be visible when the right subtree is absent or shallower.

### Mistake 2: let the level loop use the growing queue length

Children appended during the loop would be mixed into the current level.

### Mistake 3: record the first node while enqueuing left first

That produces the left-side view.

### Mistake 4: use `shift()` repeatedly in JavaScript

It can degrade queue performance.

### Mistake 5: DFS left before right while recording first visit

That records the left-side view instead.

### Mistake 6: return `[null]` for an empty tree

The correct result is `[]`.

---

## 14. Edge cases

- empty tree → `[]`
- one node
- completely left-skewed tree
- completely right-skewed tree
- right subtree ends early and a left-subtree node becomes visible
- irregular sparse tree

The algorithm selects the rightmost **existing** node, not necessarily a node reached through only right edges.

---

## 15. Interview narration

> “The right-side view contains the rightmost node at each depth. I’ll run level-order BFS, freezing the number of nodes currently in each level before processing it. Since I enqueue left child before right child, the last processed node in that level is the rightmost one, so I add its value to the result.”

DFS alternative:

> “If I traverse right before left, the first node I reach at every new depth is visible from the right.”

---

## 16. Pattern recognition

Whenever a tree problem asks for one result per depth, consider level-order BFS.

Examples:

- right or left side view;
- average per level;
- maximum per level;
- zigzag traversal;
- minimum depth;
- level width.

Reusable level template:

```javascript
while (head < queue.length) {
  const levelSize = queue.length - head;

  for (let i = 0; i < levelSize; i++) {
    const node = queue[head++];
    // Process node within this level.
  }
}
```

---

## 17. Quick test

```javascript
function TreeNode(val, left = null, right = null) {
  this.val = val;
  this.left = left;
  this.right = right;
}

const root = new TreeNode(
  1,
  new TreeNode(2, null, new TreeNode(5)),
  new TreeNode(3, null, new TreeNode(4))
);

console.log(rightSideView(root)); // [1, 3, 4]
console.log(rightSideView(null)); // []
```

---

## 18. Notebook version

### Pattern

**Level-order BFS / one answer per depth**

### Core rule

```text
left-to-right BFS → record the last node of each level
```

### Level boundary

```javascript
const levelSize = queue.length - head;
```

### Memory line

> Freeze the level; the final node in it is visible from the right.

### Complexity

```text
time: O(n)
frontier space: O(w)
```

