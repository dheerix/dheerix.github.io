# Grind 75 — 23: Maximum Depth of Binary Tree

**Difficulty:** Easy  
**Primary pattern:** Binary tree recursion / DFS  
**LeetCode:** https://leetcode.com/problems/maximum-depth-of-binary-tree/  
**Target time:** 15 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Return the maximum depth of a binary tree.

Maximum depth is the number of nodes on the longest path from the root down to a leaf.

```text
       3
      / \
     9  20
       /  \
      15   7
```

Longest root-to-leaf paths include:

```text
3 → 20 → 15
3 → 20 → 7
```

Each contains three nodes, so the maximum depth is `3`.

---

## 2. Recursive definition

A tree's maximum depth follows directly from its recursive structure:

```text
depth(null) = 0

depth(node) = 1 + max(
  depth(node.left),
  depth(node.right)
)
```

Why add one? The child result counts the path below the current node. The current node contributes one additional level.

Why take the maximum? The problem asks for the longest root-to-leaf path, so only the deeper child branch determines the answer.

---

## 3. Recursive contract

State the helper's promise before writing code:

> `maxDepth(node)` returns the number of nodes on the longest downward path beginning at `node` and ending at a leaf.

This contract makes each line inevitable:

- no node means depth zero;
- ask the left subtree for its answer;
- ask the right subtree for its answer;
- choose the larger one;
- add the current node.

---

## 4. Optimal recursive JavaScript solution

```javascript
function maxDepth(root) {
  if (root === null) {
    return 0;
  }

  const leftDepth = maxDepth(root.left);
  const rightDepth = maxDepth(root.right);

  return 1 + Math.max(leftDepth, rightDepth);
}
```

Compact equivalent:

```javascript
function maxDepthCompact(root) {
  return root === null
    ? 0
    : 1 + Math.max(
        maxDepthCompact(root.left),
        maxDepthCompact(root.right),
      );
}
```

The expanded version is usually easier to debug and narrate in an interview.

---

## 5. Dry run

```text
       1
      / \
     2   3
    /
   4
```

Postorder calculations:

```text
depth(null) = 0

node 4:
  left 0, right 0
  return 1

node 2:
  left 1, right 0
  return 2

node 3:
  left 0, right 0
  return 1

node 1:
  left 2, right 1
  return 3
```

Answer: `3`.

---

## 6. Why this is postorder

The current node's result depends on completed results from its children:

```text
left → right → current
```

That is postorder traversal.

We do not necessarily write an explicit “visit current” statement. The combine step:

```javascript
return 1 + Math.max(leftDepth, rightDepth);
```

is the processing performed at the current node after both child traversals.

---

## 7. Correctness reasoning

Use structural induction.

### Base case

An empty tree contains no nodes, so its maximum depth is zero.

### Inductive step

Assume the recursive calls correctly return the maximum depths of the left and right subtrees. Every root-to-leaf path from the current node must continue into exactly one of those subtrees. The longest such path therefore uses the deeper child subtree, and adding one counts the current node.

Thus the function returns the correct maximum depth for every node, including the root.

---

## 8. Complexity

Let `n` be the number of nodes and `h` the tree height.

- **Time: O(n)** — every node is visited once.
- **Auxiliary space: O(h)** — recursion uses one stack frame per tree level.

Tree shape:

- balanced tree: `h = O(log n)`;
- completely skewed tree: `h = O(n)`.

Do not call the recursive solution O(1) space. Even though it creates no explicit collection, the call stack consumes memory.

---

## 9. Iterative BFS solution

Breadth-first search processes the tree level by level. The number of processed levels is the maximum depth.

```javascript
function maxDepthBfs(root) {
  if (root === null) {
    return 0;
  }

  const queue = [root];
  let front = 0;
  let depth = 0;

  while (front < queue.length) {
    const levelEnd = queue.length;

    while (front < levelEnd) {
      const node = queue[front++];

      if (node.left !== null) {
        queue.push(node.left);
      }

      if (node.right !== null) {
        queue.push(node.right);
      }
    }

    depth++;
  }

  return depth;
}
```

### Why snapshot `levelEnd`?

Children are appended while processing the current level. `levelEnd` records where the current level ends before those new nodes are added.

### Complexity

- Time: **O(n)**.
- Extra space: **O(w)**, where `w` is maximum tree width; worst case O(n).

The queue uses a moving `front` index instead of repeated `shift()` calls.

---

## 10. Iterative DFS solution

Store each node with its depth:

```javascript
function maxDepthIterativeDfs(root) {
  if (root === null) {
    return 0;
  }

  const stack = [[root, 1]];
  let deepest = 0;

  while (stack.length > 0) {
    const [node, depth] = stack.pop();
    deepest = Math.max(deepest, depth);

    if (node.left !== null) {
      stack.push([node.left, depth + 1]);
    }

    if (node.right !== null) {
      stack.push([node.right, depth + 1]);
    }
  }

  return deepest;
}
```

This avoids recursion depth limitations while explicitly storing traversal state.

---

## 11. DFS versus BFS

| Approach | Time | Extra space | Natural interpretation |
|---|---:|---:|---|
| Recursive DFS | O(n) | O(h) | Depth recurrence |
| Iterative DFS | O(n) | O(h) typical/worst O(n) | Track node and depth |
| BFS | O(n) | O(w) | Count levels |

Recursive DFS is the clearest interview solution. BFS is useful when the problem is naturally level-oriented or recursion depth may be unsafe.

---

## 12. Maximum depth versus minimum depth

For maximum depth:

```text
1 + max(left, right)
```

For minimum depth, blindly writing:

```text
1 + min(left, right)
```

is wrong when one child is null. A root with only a left subtree does not have a root-to-leaf path of length one through its missing right child.

Maximum depth has no such complication: a missing child contributes zero, and `max` naturally selects the existing deeper branch.

This comparison shows why formulas should be derived from the path definition rather than memorized.

---

## 13. Common mistakes

1. **Returning `max(left, right)` without adding one.** The current node must be counted.
2. **Returning one for `null`.** Under the node-count convention, empty depth is zero.
3. **Using `min` instead of `max`.** The problem asks for the deepest path.
4. **Counting edges when the problem asks for nodes.** A single-node tree has depth one.
5. **Calling recursive space O(1).** Call-stack space is O(h).
6. **Assuming tree height is always O(log n).** A skewed tree has height O(n).
7. **Using `queue.shift()` repeatedly in JavaScript BFS.** Prefer a front index.
8. **Incrementing BFS depth per node.** Depth increases once per completed level.
9. **Using BST value comparisons.** Maximum depth depends only on structure.

---

## 14. What to say in an interview

> “The maximum depth of a null tree is zero. For any real node, every downward path continues through either its left or right subtree, so the longest path is one for the current node plus the larger child depth. A postorder recursive traversal computes each node once, giving O(n) time and O(h) call-stack space.”

If asked why postorder:

> “The parent cannot compute its depth until both child depths are available.”

---

## 15. Pattern recognition

Think **simple tree recursion** when:

- a subtree answer has the same meaning as the whole-tree answer;
- the current answer combines left and right results;
- the empty tree provides a clean identity/base value;
- traversal state follows the tree's call structure.

Use this three-part design:

```text
1. Define what the function returns for one node.
2. Define the null base case.
3. Define how child results combine at the parent.
```

Memory cue:

> Ask both children, choose the deeper answer, count yourself.

---

## 16. Edge cases

| Tree | Maximum depth |
|---|---:|
| empty | 0 |
| one node | 1 |
| root with one child | 2 |
| three-node chain | 3 |
| root with two leaves | 2 |
| balanced tree with four levels | 4 |

Sanity property:

```text
For a non-empty n-node tree: 1 <= maximum depth <= n
```

---

## 17. Notebook-ready notes

### 📚 Concept

**Maximum Depth — tree recursion**

```text
depth(null) = 0
left = depth(node.left)
right = depth(node.right)
return 1 + max(left, right)
```

### 🧠 My understanding

Every path from the current node chooses exactly one child branch. The longer child path determines maximum depth, and I add one for the current node. Postorder naturally returns these answers from leaves toward the root.

### 💼 Interview line

> “I’ll ask both subtrees for their depth, keep the deeper one, and add the current level.”

### ⚠️ Traps

- Empty depth is zero.
- A single node has depth one.
- Add one for the current node.
- Recursive space is O(h).

---

## 18. Dheerix Glance

```text
MAXIMUM DEPTH OF BINARY TREE

Contract:         longest node-count path from node to leaf
Base:             null → 0
Traversal:        postorder DFS
Combine:          1 + max(leftDepth, rightDepth)
Unit:             nodes/levels
Time:             O(n)
Recursive space:  O(h)
Balanced space:   O(log n)
Worst space:      O(n)
Memory cue:       “Choose deeper child; count current node.”
```

---

## 19. Recall test

Without looking back:

1. What is the exact recursive contract?
2. Why is the null depth zero?
3. Why do we take the maximum child depth?
4. Why must one be added?
5. Why is the traversal postorder?
6. What are the time and recursion-space complexities?
7. How does BFS determine depth by levels?
8. Why is the analogous minimum-depth formula more subtle?

