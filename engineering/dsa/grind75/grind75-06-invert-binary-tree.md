# Grind 75 — 06: Invert Binary Tree

**Difficulty:** Easy  
**Primary pattern:** Binary tree traversal / recursion  
**LeetCode:** https://leetcode.com/problems/invert-binary-tree/  
**Target time:** 15 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given the root of a binary tree, mirror the tree across its vertical axis and return the root.

At every node:

```text
left child ↔ right child
```

Example:

```text
Before:                 After:

       4                       4
     /   \                   /   \
    2     7                 7     2
   / \   / \               / \   / \
  1   3 6   9             9   6 3   1
```

The node values do not change. Only the child references are rearranged.

The typical LeetCode node definition is:

```javascript
function TreeNode(val, left = null, right = null) {
  this.val = val;
  this.left = left;
  this.right = right;
}
```

---

## 2. Recursive structure of the problem

A binary tree is recursively defined:

```text
A tree is either:
- empty, or
- a node with a left subtree and a right subtree.
```

Therefore, inverting a tree means:

1. swap the current node's left and right children;
2. invert the two child subtrees using the same rule.

The whole transformation is built from one small local operation repeated at every node.

---

## 3. Define the recursive contract

Before writing recursion, state what the function promises:

> `invertTree(node)` returns the root of the fully inverted tree that originally began at `node`.

Base case:

```text
An empty tree is already inverted.
```

Recursive case:

```text
Swap the two children.
Invert each resulting subtree.
Return the current node.
```

Returning `root` is important because the caller needs the root reference of the transformed subtree.

---

## 4. Optimal recursive JavaScript solution

```javascript
function invertTree(root) {
  if (root === null) {
    return null;
  }

  // Mirror the current node by swapping its child references.
  [root.left, root.right] = [root.right, root.left];

  // Apply the same transformation to both subtrees.
  invertTree(root.left);
  invertTree(root.right);

  return root;
}
```

---

## 5. Code walkthrough

### `if (root === null) return null`

This is the recursion stopping condition. An absent child has nothing to swap, and returning `null` preserves the child reference expected by its parent.

### `[root.left, root.right] = [root.right, root.left]`

JavaScript destructuring swaps both references safely without a temporary variable.

Equivalent explicit code:

```javascript
const temporary = root.left;
root.left = root.right;
root.right = temporary;
```

### Recursive calls after the swap

After swapping, `root.left` refers to the subtree that used to be on the right, and `root.right` refers to the subtree that used to be on the left. Both still need to be mirrored internally.

### `return root`

The algorithm mutates the tree in place, but returning the subtree root makes the function composable and matches the required method contract.

---

## 6. Dry run

```text
       2
      / \
     1   3
```

Call `invertTree(2)`:

1. Node `2` is not null.
2. Swap children: `3` becomes left, `1` becomes right.
3. Invert subtree rooted at `3`: it has two null children, so nothing changes.
4. Invert subtree rooted at `1`: it has two null children, so nothing changes.
5. Return node `2`.

```text
       2
      / \
     3   1
```

For a larger tree, exactly the same local rule runs at each node.

---

## 7. Preorder vs postorder

Two recursive orders work.

### Swap first, then recurse: preorder-style

```javascript
[root.left, root.right] = [root.right, root.left];
invertTree(root.left);
invertTree(root.right);
```

### Recurse first, then assign swapped results: postorder-style

```javascript
function invertTreePostorder(root) {
  if (root === null) return null;

  const invertedLeft = invertTreePostorder(root.left);
  const invertedRight = invertTreePostorder(root.right);

  root.left = invertedRight;
  root.right = invertedLeft;

  return root;
}
```

Both are correct because every original subtree is inverted exactly once and assigned to the opposite side. The first version is shorter; the second makes the recursive return contract especially visible.

Do not swap first and then recurse using saved **old** child references incorrectly, or recurse into one subtree twice. Track which references represent the current children.

---

## 8. Correctness reasoning

Use structural induction.

### Base case

If `root` is `null`, the empty tree is already its own mirror, so returning `null` is correct.

### Inductive step

Assume the function correctly inverts any subtree smaller than the current tree. At the current node, swapping the child references places the original right subtree on the left and the original left subtree on the right. The recursive calls correctly mirror both of those smaller subtrees. Therefore, the entire tree rooted at the current node is inverted.

By this reasoning, the function correctly inverts every finite binary tree.

---

## 9. Complexity

Let `n` be the number of nodes and `h` the tree height.

- **Time: O(n)** — every node is visited once and performs O(1) work.
- **Auxiliary space: O(h)** — recursion uses one call-stack frame per level.

Shape-specific space:

- balanced tree: `h = O(log n)`;
- completely skewed tree: `h = O(n)`.

The algorithm mutates nodes in place, but in-place mutation does not eliminate recursion-stack space.

---

## 10. Iterative breadth-first solution

```javascript
function invertTreeBfs(root) {
  if (root === null) return null;

  const queue = [root];
  let front = 0;

  while (front < queue.length) {
    const node = queue[front++];

    [node.left, node.right] = [node.right, node.left];

    if (node.left !== null) queue.push(node.left);
    if (node.right !== null) queue.push(node.right);
  }

  return root;
}
```

### Why use a `front` index?

JavaScript's `shift()` removes from the beginning of an array and may reindex remaining elements. Keeping a `front` index gives efficient queue behavior.

### Complexity

- Time: **O(n)**.
- Auxiliary space: **O(w)**, where `w` is the maximum number of nodes stored at one tree level; worst case O(n).

Use recursion for the clearest solution unless tree depth or recursion limits are a concern.

---

## 11. In-place versus creating a new tree

The primary solution mutates the input tree:

```text
same node objects, changed left/right references
```

If the original tree must remain unchanged, construct a new mirrored tree:

```javascript
function invertedCopy(root) {
  if (root === null) return null;

  return new TreeNode(
    root.val,
    invertedCopy(root.right),
    invertedCopy(root.left),
  );
}
```

This still takes O(n) time, but it uses O(n) space for the new nodes plus O(h) recursion stack. Clarify mutation expectations in real code.

---

## 12. Common mistakes

1. **Swapping only the root's children.** Every subtree must also be inverted.
2. **Forgetting the null base case.** Recursion would access properties of `null`.
3. **Swapping node values instead of child references.** The tree structure, not the values, must be mirrored.
4. **Returning the wrong reference.** Return the current root after transformation.
5. **Calling recursion on the same child twice after swapping.** Ensure both current subtrees are processed exactly once.
6. **Claiming O(1) space because mutation is in place.** Recursive call-stack space is O(h).
7. **Using `queue.shift()` repeatedly in JavaScript.** Prefer a front index for predictable queue efficiency.
8. **Assuming the tree is balanced.** Worst-case recursion depth is O(n).

---

## 13. What to say in an interview

> “A tree is recursively composed of two subtrees. To mirror the tree, I swap the current node's left and right references, then apply the same operation to both children. The null node is the base case. Each node is visited once, so time is O(n), and recursive space is O(h), where h is the tree height—O(log n) when balanced and O(n) when skewed.”

If asked whether it is in place:

> “Yes, it reuses the existing nodes and changes only child references, although recursion still consumes O(h) call-stack space.”

---

## 14. Pattern recognition

Think **tree recursion** when:

- the same operation applies to every subtree;
- the result at a node depends on transformed child subtrees;
- the problem can be stated as “solve left, solve right, combine.”

Ask three questions:

1. What does my recursive function promise for one node?
2. What is the empty-tree base case?
3. What local work combines the child results?

Memory cue:

> One node swaps locally; recursion spreads the rule globally.

---

## 15. Edge cases

| Tree | Result |
|---|---|
| empty tree | `null` |
| single node | same node |
| root with only left child | child moves to right |
| root with only right child | child moves to left |
| balanced tree | complete mirror |
| skewed left chain | becomes skewed right chain |

A useful property for testing:

```text
invert(invert(tree)) = original tree structure
```

Inversion is an **involution**: applying it twice restores the original arrangement.

---

## 16. Notebook-ready notes

### 📚 Concept

**Invert Binary Tree — recursive traversal**

```text
Base: root === null → return null
Local work: swap root.left and root.right
Recursive work: invert both subtrees
Return: root
```

### 🧠 My understanding

The mirror operation is identical at every node. One call handles one node, while recursive calls guarantee that both child subtrees receive the same transformation. The tree is modified through references, not by changing values.

### 💼 Interview line

> “I’ll swap locally at each node and let recursion propagate the mirror operation through both subtrees.”

### ⚠️ Traps

- Process the entire tree, not just the root.
- Return `root` but stop on `null`.
- In-place nodes still require O(h) recursion space.

---

## 17. Dheerix Glance

```text
INVERT BINARY TREE

Signal:          same transformation at every node
Base case:       null → null
Local action:    swap left and right references
Recursive action:invert both children
Return:          root
Time:            O(n)
Recursive space: O(h)
Balanced height: O(log n)
Worst height:    O(n)
Test property:   invert twice → original
Memory cue:      “Swap here; recurse everywhere.”
```

---

## 18. Recall test

Without looking back:

1. What is the recursive function's contract?
2. Why is `null` the correct base case?
3. Are node values or references changed?
4. Why is time O(n)?
5. Why is recursive space O(h), not always O(log n)?
6. How does the BFS solution implement an efficient JavaScript queue?
7. What does applying inversion twice do?
8. State the correctness argument in two sentences.

