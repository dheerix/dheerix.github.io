# Grind 75 — 21: Diameter of Binary Tree

**Difficulty:** Easy  
**Primary pattern:** Postorder DFS / subtree height / global maximum  
**LeetCode:** https://leetcode.com/problems/diameter-of-binary-tree/  
**Target time:** 30 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Return the diameter of a binary tree: the number of **edges** in the longest path between any two nodes.

The path may or may not pass through the root.

```text
       1
      / \
     2   3
    / \
   4   5
```

One longest path is:

```text
4 → 2 → 1 → 3
```

It contains three edges, so the diameter is `3`.

---

## 2. The two facts to keep separate

At each node, we need two related but different quantities.

### Height returned upward

The parent can extend a path through only one side of the current node:

```text
height(node) = 1 + max(leftHeight, rightHeight)
```

### Diameter candidate through the current node

A complete path may enter from the deepest node on the left, pass through the current node, and leave toward the deepest node on the right:

```text
diameterThroughNode = leftHeight + rightHeight
```

The helper returns **one branch**, but the global answer considers **both branches together**.

---

## 3. Height convention and why the sum counts edges

Define:

```text
height(null) = 0
height(leaf) = 1
```

This height counts nodes in a downward path beginning at the current node. But at a parent:

- `leftHeight` equals the number of edges from the parent down the longest left path;
- `rightHeight` equals the number of edges from the parent down the longest right path.

Therefore:

```text
leftHeight + rightHeight
```

is exactly the number of edges in a path passing through the current node.

For a leaf:

```text
leftHeight = 0
rightHeight = 0
candidate diameter = 0 edges
```

---

## 4. Why postorder traversal?

The current node cannot calculate its height or diameter candidate until it knows both child heights.

```text
left child → right child → current node
```

That is postorder DFS.

At every node:

1. calculate left height;
2. calculate right height;
3. update the best diameter with their sum;
4. return one plus the larger height.

---

## 5. Optimal JavaScript solution

```javascript
function diameterOfBinaryTree(root) {
  let longestDiameter = 0;

  function height(node) {
    if (node === null) {
      return 0;
    }

    const leftHeight = height(node.left);
    const rightHeight = height(node.right);

    const diameterThroughNode = leftHeight + rightHeight;
    longestDiameter = Math.max(
      longestDiameter,
      diameterThroughNode,
    );

    return 1 + Math.max(leftHeight, rightHeight);
  }

  height(root);
  return longestDiameter;
}
```

---

## 6. Dry run

```text
       1
      / \
     2   3
    / \
   4   5
```

Postorder calculations:

| Node | Left height | Right height | Diameter through node | Returned height |
|---:|---:|---:|---:|---:|
| 4 | 0 | 0 | 0 | 1 |
| 5 | 0 | 0 | 0 | 1 |
| 2 | 1 | 1 | 2 | 2 |
| 3 | 0 | 0 | 0 | 1 |
| 1 | 2 | 1 | 3 | 3 |

Maximum candidate is `3`, so return `3`.

---

## 7. The longest path may avoid the root

```text
          1
         /
        2
       / \
      3   4
     /     \
    5       6
```

The longest path can run from `5` through `3 → 2 → 4` to `6`. It is centered inside the subtree rooted at `2`, not necessarily through the overall root in a more asymmetric example.

Therefore, calculating only:

```javascript
height(root.left) + height(root.right)
```

is insufficient. We must evaluate a diameter candidate at **every node** and retain the maximum.

---

## 8. Code walkthrough

### `let longestDiameter = 0`

The empty tree and single-node tree both have diameter zero edges. This is a correct initial value.

### Nested `height` helper

The helper returns the information the parent needs. The outer variable records information that might be lost when returning only one branch.

### Child-height computation

Calling both children before processing the current node makes the traversal postorder.

### Global update

```javascript
longestDiameter = Math.max(
  longestDiameter,
  leftHeight + rightHeight,
);
```

Every possible longest path has some highest node where its two sides meet. When DFS processes that node, this formula evaluates that path.

### Returned height

The parent cannot use both branches through this child without creating a fork rather than a simple path. It can extend only the longer downward branch, so the helper returns the maximum side plus one.

---

## 9. Local return versus global answer

This distinction appears in many tree problems:

```text
Return value:
  What can one parent legally extend?

Global update:
  What complete answer can be formed at this node?
```

For diameter:

```text
return max(left, right) + 1
update answer with left + right
```

Returning `left + right` would be wrong because a parent cannot extend a path that already branches in two directions.

---

## 10. Correctness reasoning

The helper correctly returns subtree height by induction: null has height zero, and a non-null node extends the longer child path by one node.

Consider any simple path in the tree. It has a highest node relative to the root. At that node, the path consists of at most one downward branch into the left subtree and at most one downward branch into the right subtree. Their maximum possible combined length is `leftHeight + rightHeight`, which the algorithm evaluates.

Because every node is considered as this meeting point and the maximum candidate is retained, the algorithm finds the longest path in the entire tree.

---

## 11. Complexity

Let `n` be the number of nodes and `h` the tree height.

- **Time: O(n)** — each node is visited once and performs constant work.
- **Auxiliary space: O(h)** — recursion depth follows the longest root-to-leaf path.

Tree shape:

- balanced tree: O(log n) call-stack space;
- skewed tree: O(n) call-stack space.

The outer `longestDiameter` variable itself is O(1).

---

## 12. Inefficient O(n²) approach

A tempting implementation calculates subtree heights separately at every node:

```javascript
function diameterSlow(root) {
  if (root === null) return 0;

  const throughRoot =
    subtreeHeight(root.left) + subtreeHeight(root.right);

  return Math.max(
    throughRoot,
    diameterSlow(root.left),
    diameterSlow(root.right),
  );
}

function subtreeHeight(node) {
  if (node === null) return 0;

  return 1 + Math.max(
    subtreeHeight(node.left),
    subtreeHeight(node.right),
  );
}
```

On a skewed tree, heights are recomputed across nearly the same nodes at every level:

```text
n + (n - 1) + ... + 1 = O(n²)
```

The optimal postorder solution computes each height once and uses it immediately for both the local candidate and the parent's return value.

---

## 13. Alternative pair-return solution

Instead of a captured global variable, each recursive call can return both height and best diameter:

```javascript
function diameterOfBinaryTreeWithPair(root) {
  function inspect(node) {
    if (node === null) {
      return { height: 0, diameter: 0 };
    }

    const left = inspect(node.left);
    const right = inspect(node.right);

    return {
      height: 1 + Math.max(left.height, right.height),
      diameter: Math.max(
        left.diameter,
        right.diameter,
        left.height + right.height,
      ),
    };
  }

  return inspect(root).diameter;
}
```

This makes all state explicit and remains O(n) time with O(h) call-stack space. The global-update version is shorter for interviews.

---

## 14. Nodes versus edges

This is the most common off-by-one issue.

For a path:

```text
A → B → C
```

There are:

```text
3 nodes
2 edges
```

The problem requests edges. With `height(null) = 0` and `height(leaf) = 1`, `leftHeight + rightHeight` directly yields edge count through the current node.

If you instead define leaf height as zero edges and null height as `-1`, the formulas can also work. Choose one convention and keep it consistent.

---

## 15. Common mistakes

1. **Assuming the longest path must pass through the root.** It may be entirely inside a subtree.
2. **Returning `leftHeight + rightHeight` to the parent.** A parent can extend only one downward branch.
3. **Counting nodes instead of edges.** Verify single-node and two-node cases.
4. **Computing heights repeatedly.** This can degrade to O(n²).
5. **Updating the global maximum before obtaining both child heights.** The local candidate needs both sides.
6. **Forgetting to call the helper before returning the global result.** The diameter remains zero.
7. **Claiming O(1) space.** Recursive call-stack space is O(h).
8. **Using BST ordering.** Node values and BST properties are irrelevant; this is about shape.
9. **Confusing diameter with tree height.** Height is one downward branch; diameter joins up to two branches.

---

## 16. What to say in an interview

> “I’ll use postorder DFS because each node needs its child heights. The path through a node can use the deepest left branch and deepest right branch, so its diameter candidate is `leftHeight + rightHeight`. I update a global maximum with that value. But the parent can extend only one branch, so I return `1 + max(leftHeight, rightHeight)`. Every node is processed once, giving O(n) time and O(h) recursion space.”

If asked why all nodes are checked:

> “The longest path may be centered below the root, so every node must be considered as the path's meeting point.”

---

## 17. Pattern recognition

Think **postorder + global maximum** when:

- each node returns a value extendable by its parent;
- a complete answer can combine multiple child results locally;
- the best answer may occur anywhere in the tree;
- height-like information feeds path-like answers.

This pattern reappears in:

- binary-tree maximum path sum;
- longest univalue path;
- tree diameter variants;
- path problems where the parent may extend only one branch.

Memory cue:

> Return one branch; score two branches.

---

## 18. Edge cases

| Tree | Diameter | Reason |
|---|---:|---|
| empty | 0 | No path |
| single node | 0 | Zero edges |
| root with one child | 1 | One edge |
| three-node chain | 2 | Two edges end to end |
| root with two leaf children | 2 | Leaf → root → leaf |
| longest path inside subtree | subtree path length | Must update at every node |

Useful sanity relation:

```text
diameter of an n-node tree is at most n - 1 edges
```

---

## 19. Notebook-ready notes

### 📚 Concept

**Diameter of Binary Tree — postorder height + global maximum**

```text
height(null) = 0
left = height(node.left)
right = height(node.right)
global diameter = max(global, left + right)
return 1 + max(left, right)
```

### 🧠 My understanding

The parent can continue through only one child branch, so the helper returns height. But a complete path centered at the current node can join both child heights, so their sum is tested against the global diameter. Checking every node handles paths that avoid the root.

### 💼 Interview line

> “I’ll return the best extendable branch upward and record the best complete two-branch path locally.”

### ⚠️ Traps

- Diameter is counted in edges.
- The path need not pass through the root.
- Return one branch, not the local diameter.
- Recursion space is O(h).

---

## 20. Dheerix Glance

```text
DIAMETER OF BINARY TREE

Traversal:        postorder DFS
Child result:     subtree height
Local candidate:  leftHeight + rightHeight
Global answer:    maximum local candidate
Return to parent: 1 + max(leftHeight, rightHeight)
Units:            edges
Time:             O(n)
Recursive space:  O(h)
Memory cue:       “Return one branch; score two branches.”
```

---

## 21. Recall test

Without looking back:

1. Why is postorder traversal required?
2. What does the helper return?
3. What does `leftHeight + rightHeight` represent?
4. Why can the parent extend only one child branch?
5. Why must the candidate be evaluated at every node?
6. How does the chosen height convention produce edge count?
7. Why can the naive height-at-every-node solution become O(n²)?
8. State the local-return/global-answer distinction in one sentence.

