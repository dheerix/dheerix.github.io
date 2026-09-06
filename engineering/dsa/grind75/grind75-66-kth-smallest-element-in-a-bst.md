# Grind 75 — 66: Kth Smallest Element in a BST

## Problem

Given the root of a Binary Search Tree and an integer `k`, return the `k`th smallest value among all nodes in the tree.

`k` is 1-indexed:

- `k = 1` means the smallest value.
- `k = 2` means the second-smallest value.
- `k = n` means the largest value in a tree with `n` nodes.

Assume `1 <= k <= number of nodes`.

---

## 1. Intuition

A Binary Search Tree gives us an ordering guarantee:

- Every value in a node's left subtree is smaller than the node.
- Every value in its right subtree is larger than the node.

Therefore, an **inorder traversal** visits the values in ascending order:

```text
left subtree -> node -> right subtree
```

If inorder traversal produces:

```text
[1, 2, 3, 4, 5, 6]
```

then the `k`th node visited is exactly the `k`th smallest value.

The real question is not how to sort the BST. It is already structurally sorted. We only need to visit it in the correct order and stop after the `k`th visit.

### Pattern recognition

When a problem says:

- Binary Search Tree, and
- smallest, largest, rank, or sorted order,

immediately consider inorder traversal.

---

## 2. Brute-Force Solution — Collect and Sort Every Value

We can traverse the entire tree, store every value, sort the array, and return index `k - 1`.

```js
function kthSmallest(root, k) {
  const values = [];

  function traverse(node) {
    if (node === null) return;

    values.push(node.val);
    traverse(node.left);
    traverse(node.right);
  }

  traverse(root);
  values.sort((a, b) => a - b);

  return values[k - 1];
}
```

### Why it works

The traversal collects every value. Sorting puts the values in ascending order, so index `k - 1` contains the `k`th smallest value.

### Why it is not optimal

It ignores the BST property. The tree already encodes the values in sorted order, yet this approach sorts them again.

### Complexity

- Time: `O(n log n)` because of sorting.
- Space: `O(n)` for the array, plus traversal stack space.

---

## 3. Better Solution — Full Recursive Inorder Traversal

An inorder traversal of a BST directly creates a sorted array, so explicit sorting is unnecessary.

```js
function kthSmallest(root, k) {
  const values = [];

  function inorder(node) {
    if (node === null) return;

    inorder(node.left);
    values.push(node.val);
    inorder(node.right);
  }

  inorder(root);
  return values[k - 1];
}
```

### Complexity

- Time: `O(n)` because every node is visited.
- Space: `O(n)` for the result array, plus `O(h)` recursion stack space.
- `h` is the height of the tree.

This is simple and correct, but it still visits and stores all `n` nodes even when `k` is small.

---

## 4. Optimal Solution — Iterative Inorder Traversal with Early Stopping

We simulate inorder traversal using a stack. Each time a node is removed from the stack, it is the next-smallest unprocessed node.

We decrement `k` at that moment. When `k` becomes `0`, we return that node's value immediately.

```js
/**
 * Definition for a binary tree node.
 * function TreeNode(val, left, right) {
 *   this.val = val ?? 0;
 *   this.left = left ?? null;
 *   this.right = right ?? null;
 * }
 */

/**
 * Returns the kth smallest value in a Binary Search Tree.
 *
 * @param {TreeNode} root
 * @param {number} k
 * @return {number}
 */
function kthSmallest(root, k) {
  const stack = [];
  let current = root;

  while (current !== null || stack.length > 0) {
    // Reach the smallest unprocessed node.
    while (current !== null) {
      stack.push(current);
      current = current.left;
    }

    // This node is next in ascending order.
    current = stack.pop();
    k--;

    if (k === 0) {
      return current.val;
    }

    // Values in the right subtree come after this node.
    current = current.right;
  }

  // The problem guarantees that k is valid.
  return -1;
}
```

---

## 5. How the Stack Simulates Recursion

Recursive inorder traversal does this:

```text
1. Explore left.
2. Process node.
3. Explore right.
```

The iterative version stores ancestors in `stack` while moving left:

```js
while (current !== null) {
  stack.push(current);
  current = current.left;
}
```

When there is no further left child, the top of the stack is the smallest node not yet processed:

```js
current = stack.pop();
```

After processing it, we explore its right subtree:

```js
current = current.right;
```

The stack means: **these ancestors are waiting to be processed after their left subtrees.**

---

## 6. Walkthrough

Consider this BST with `k = 3`:

```text
        5
       / \
      3   6
     / \
    2   4
   /
  1
```

The inorder order is:

```text
1, 2, 3, 4, 5, 6
```

### Execution

| Step | Action | Stack after action | Visited value | `k` |
| --- | --- | --- | --- | ---: |
| 1 | Push `5`, move left | `[5]` | — | 3 |
| 2 | Push `3`, move left | `[5, 3]` | — | 3 |
| 3 | Push `2`, move left | `[5, 3, 2]` | — | 3 |
| 4 | Push `1`, move left | `[5, 3, 2, 1]` | — | 3 |
| 5 | Pop `1` | `[5, 3, 2]` | `1` | 2 |
| 6 | Pop `2` | `[5, 3]` | `2` | 1 |
| 7 | Pop `3` | `[5]` | `3` | 0 |

When `k` becomes `0`, return `3`.

Notice that nodes `4`, `5`, and `6` are never processed. This is the benefit of early stopping.

---

## 7. Correctness Proof

We prove that the algorithm returns the `k`th smallest value.

### Lemma 1: Inorder traversal visits BST nodes in ascending order

For any node:

- All values in its left subtree are smaller.
- The node is visited after its left subtree.
- All values in its right subtree are larger and are visited afterward.

Applying this rule recursively means the complete inorder traversal is ascending.

### Lemma 2: Each stack pop processes the next value in inorder order

Before popping, the algorithm follows left children as far as possible. Therefore, the popped node has no unprocessed smaller node remaining in its current subtree. After it is processed, the algorithm moves to its right subtree, whose values are larger.

Thus, successive popped nodes appear in ascending order.

### Theorem

The algorithm decreases `k` once for every popped node. By Lemma 2, the first popped node is the smallest, the second is the second-smallest, and so on. Therefore, when `k` becomes `0`, the current node is exactly the original `k`th smallest node.

---

## 8. Complexity

Let:

- `n` be the number of nodes.
- `h` be the height of the tree.

### Time

- General bound: `O(h + k)`.
- Worst case: `O(n)`.

Why `O(h + k)`?

- We may descend up to `h` levels to reach the smallest node.
- We then process nodes in sorted order until the `k`th node is reached.

Each encountered node is pushed and popped at most once.

### Space

- `O(h)` for the explicit stack.
- Balanced BST: `O(log n)`.
- Completely skewed BST: `O(n)`.

There is no `O(n)` result array.

---

## 9. Common Mistakes

### Mistake 1: Using preorder or postorder traversal

Only inorder traversal gives ascending order for a BST.

```text
Inorder = left -> node -> right
```

### Mistake 2: Treating `k` as a zero-based index

`k` is 1-indexed. Decrement it when a node is processed, then return when it reaches `0`.

### Mistake 3: Decrementing `k` when pushing a node

Pushing a node does not mean it has been visited in inorder order. It may still have smaller nodes in its left subtree.

Correct moment:

```js
current = stack.pop();
k--;
```

### Mistake 4: Forgetting the right subtree

After processing a node, continue from:

```js
current = current.right;
```

### Mistake 5: Using only `while (current !== null)`

`current` can become `null` while the stack still contains nodes waiting to be processed.

Correct condition:

```js
while (current !== null || stack.length > 0)
```

### Mistake 6: Saying the space is always `O(log n)`

That is true only for a balanced tree. A skewed BST can have height `n`, making stack space `O(n)`.

### Mistake 7: Traversing and sorting

Sorting works but wastes the ordering property already provided by the BST.

---

## 10. Edge Cases

### Single-node tree

```text
root = [1], k = 1
answer = 1
```

### `k = 1`

Return the leftmost node, which is the minimum value.

### `k` equals the number of nodes

The traversal continues to the final inorder node, which is the maximum value.

### Balanced tree

The stack uses only `O(log n)` space.

### Completely left-skewed tree

All ancestors are pushed before the smallest node is processed, so the stack may use `O(n)` space.

### Completely right-skewed tree

The traversal processes one node and then moves right repeatedly.

### Negative values

The algorithm depends on BST ordering, not on values being positive.

---

## 11. Interview Explanation

> Because this is a BST, an inorder traversal visits nodes in ascending order. I can therefore return the `k`th node visited instead of collecting and sorting every value. I’ll perform inorder traversal iteratively with a stack: push the left path, pop the next-smallest node, decrement `k`, and return when `k` reaches zero. Then I move into that node’s right subtree. This takes `O(h + k)` time with early stopping and `O(h)` stack space, where `h` is the tree height.

### If the interviewer asks why not recursion

Recursion is valid, but an iterative traversal makes early stopping straightforward and avoids relying on the language call stack. Both approaches use `O(h)` traversal space.

### If the interviewer asks about frequent updates and queries

If nodes are inserted or deleted frequently and `kthSmallest` is queried many times, augment every node with its subtree size.

For a node:

```text
leftSize = number of nodes in its left subtree
```

Then:

- If `k === leftSize + 1`, the current node is the answer.
- If `k <= leftSize`, search the left subtree.
- Otherwise, search the right subtree for `k - leftSize - 1`.

In a balanced augmented BST, a query takes `O(log n)`, while insertions and deletions must update subtree sizes along their paths.

---

## 12. Notebook Version

### Problem

Find the `k`th smallest value in a BST.

### Core observation

```text
BST inorder traversal = ascending order
```

### Algorithm

1. Create an empty stack.
2. Push the complete left path.
3. Pop one node; it is the next-smallest value.
4. Decrement `k`.
5. If `k === 0`, return the node's value.
6. Move to its right child and repeat.

### JavaScript

```js
function kthSmallest(root, k) {
  const stack = [];
  let current = root;

  while (current || stack.length) {
    while (current) {
      stack.push(current);
      current = current.left;
    }

    current = stack.pop();

    if (--k === 0) return current.val;

    current = current.right;
  }
}
```

### Complexity

```text
Time:  O(h + k), worst O(n)
Space: O(h)
```

### Important invariant

Every node popped from the stack is the smallest node that has not yet been processed.

---

## 13. Memory Line

**A BST is already sorted—walk it inorder and stop on the `k`th pop.**

