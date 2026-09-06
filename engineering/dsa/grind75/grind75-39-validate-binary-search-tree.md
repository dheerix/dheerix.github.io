# Grind 75 — 39. Validate Binary Search Tree

## Problem

Given the root of a binary tree, determine whether it is a valid binary search tree (BST).

A valid BST requires that, for **every** node:

- every value in its left subtree is strictly smaller than the node's value;
- every value in its right subtree is strictly greater than the node's value;
- both subtrees are themselves valid BSTs.

Duplicate values are therefore invalid.

---

## 1. The easy misunderstanding

It is tempting to check only each node's immediate children:

```javascript
function isValidBSTIncorrect(root) {
  if (root === null) return true;

  if (root.left !== null && root.left.val >= root.val) return false;
  if (root.right !== null && root.right.val <= root.val) return false;

  return isValidBSTIncorrect(root.left) &&
    isValidBSTIncorrect(root.right);
}
```

That is not enough. Consider:

```text
        5
       / \
      3   7
         / \
        4   8
```

Node `4` is smaller than its parent `7`, so the local relationship looks correct. But `4` lies in the **right subtree of 5**, where every value must be greater than `5`.

The rule is not merely:

```text
left child < node < right child
```

It is:

```text
all left descendants < node < all right descendants
```

---

## 2. Key idea: every node inherits a valid range

The root may initially contain any finite numeric value:

```text
(-Infinity, Infinity)
```

When moving left from a node with value `x`, the upper bound becomes `x`:

```text
(lowerBound, x)
```

When moving right, the lower bound becomes `x`:

```text
(x, upperBound)
```

These bounds carry the restrictions imposed by **all ancestors**, not only the parent.

---

## 3. Recommended JavaScript solution: DFS with bounds

```javascript
function isValidBST(root) {
  function validate(node, lowerBound, upperBound) {
    if (node === null) return true;

    if (node.val <= lowerBound || node.val >= upperBound) {
      return false;
    }

    return validate(node.left, lowerBound, node.val) &&
      validate(node.right, node.val, upperBound);
  }

  return validate(root, -Infinity, Infinity);
}
```

### Meaning of the recursive function

```text
validate(node, lowerBound, upperBound)
```

asks:

> Is this entire subtree valid if every value inside it must fit within the range imposed on its root?

For the current node, the permitted range is **open**:

```text
lowerBound < node.val < upperBound
```

Open boundaries are important because equal values are not allowed.

---

## 4. Walkthrough: valid tree

```text
        8
       / \
      3   10
     / \    \
    1   6    14
```

Important calls:

| Node | Required range | Valid? |
| ---: | --- | --- |
| `8` | `(-∞, ∞)` | Yes |
| `3` | `(-∞, 8)` | Yes |
| `1` | `(-∞, 3)` | Yes |
| `6` | `(3, 8)` | Yes |
| `10` | `(8, ∞)` | Yes |
| `14` | `(10, ∞)` | Yes |

Every node satisfies the restrictions collected from its ancestors, so the result is `true`.

---

## 5. Walkthrough: hidden violation

```text
        5
       / \
      3   7
         /
        4
```

Traversal with ranges:

| Node | Required range | Result |
| ---: | --- | --- |
| `5` | `(-∞, ∞)` | Valid |
| `7` | `(5, ∞)` | Valid |
| `4` | `(5, 7)` | Invalid because `4 <= 5` |

The lower bound `5` came from the grandparent. This is precisely what a parent-only comparison loses.

---

## 6. Correctness reasoning

We maintain this invariant:

> `validate(node, lower, upper)` returns true exactly when every node in this subtree obeys all BST restrictions inherited from its ancestors.

### Base case

An empty subtree contains no violation, so it is valid.

### Current node

If `node.val` does not lie strictly between its bounds, it violates an ancestor constraint and the subtree is invalid.

### Left subtree

Every left descendant must remain above the inherited lower bound and must also be less than the current value. Its range becomes:

```text
(lowerBound, node.val)
```

### Right subtree

Every right descendant must be greater than the current value while remaining below the inherited upper bound. Its range becomes:

```text
(node.val, upperBound)
```

The current node and both subtrees must be valid, so combining the two recursive results with `&&` proves the whole tree valid.

---

## 7. Complexity

Let `n` be the number of nodes and `h` the tree height.

- Time: **O(n)** — each node is checked once.
- Auxiliary space: **O(h)** — recursion stack.
- Balanced tree: **O(log n)** stack space.
- Completely skewed tree: **O(n)** stack space.

---

## 8. Alternative solution: inorder traversal

An inorder traversal of a valid BST produces values in **strictly increasing** order.

```javascript
function isValidBSTInorder(root) {
  let previous = null;
  let hasPrevious = false;

  function inorder(node) {
    if (node === null) return true;

    if (!inorder(node.left)) return false;

    if (hasPrevious && node.val <= previous) {
      return false;
    }

    previous = node.val;
    hasPrevious = true;

    return inorder(node.right);
  }

  return inorder(root);
}
```

This also runs in O(n) time and O(h) auxiliary space.

The bounds solution is usually easier to connect directly to the BST definition. The inorder solution is useful when you recognize the sorted-order property.

---

## 9. Iterative inorder version

JavaScript recursion can overflow the call stack for an extremely deep tree. An explicit stack avoids that runtime limitation.

```javascript
function isValidBSTIterative(root) {
  const stack = [];
  let current = root;
  let previous = null;
  let hasPrevious = false;

  while (current !== null || stack.length > 0) {
    while (current !== null) {
      stack.push(current);
      current = current.left;
    }

    current = stack.pop();

    if (hasPrevious && current.val <= previous) {
      return false;
    }

    previous = current.val;
    hasPrevious = true;
    current = current.right;
  }

  return true;
}
```

---

## 10. Common mistakes

### Mistake 1: checking only direct children

BST constraints apply to entire subtrees, including grandchildren and deeper descendants.

### Mistake 2: allowing equality

Use:

```javascript
node.val <= lowerBound || node.val >= upperBound
```

not only `<` and `>`. The required ordering is strict.

### Mistake 3: resetting both bounds at every level

One boundary comes from the current node; the other may come from a much earlier ancestor and must be preserved.

### Mistake 4: treating a BST as merely a sorted parent-child tree

The structure carries global ordering constraints through each subtree.

### Mistake 5: using a fragile inorder sentinel

Initializing `previous` to a normal number can fail if a node legitimately contains that value. A separate `hasPrevious` flag avoids ambiguity.

---

## 11. Interview narration

> “Checking only a node's children misses violations against earlier ancestors. I’ll pass an allowed open interval down the tree. A left child inherits the same lower bound and uses its parent as the new upper bound; a right child uses its parent as the new lower bound. If any node falls outside its interval, the tree is invalid.”

If asked for an alternative:

> “A BST's inorder traversal must be strictly increasing, so I can also compare every visited value with the previous one.”

---

## 12. Pattern recognition

Use the bounds pattern when:

- descendants inherit restrictions from ancestors;
- checking only local relationships is insufficient;
- recursion can carry contextual state into a subtree.

General form:

```text
DFS(node, inherited constraints)
```

Each recursive call narrows the constraints for its branch.

---

## 13. Quick test

```javascript
function TreeNode(val, left = null, right = null) {
  this.val = val;
  this.left = left;
  this.right = right;
}

const validTree = new TreeNode(
  2,
  new TreeNode(1),
  new TreeNode(3)
);

const invalidTree = new TreeNode(
  5,
  new TreeNode(1),
  new TreeNode(4, new TreeNode(3), new TreeNode(6))
);

console.log(isValidBST(validTree));   // true
console.log(isValidBST(invalidTree)); // false
```

---

## 14. Notebook version

### Pattern

**DFS with inherited lower and upper bounds**

### Core rule

```text
lowerBound < node.val < upperBound
```

### Bound updates

```text
left:  (lowerBound, node.val)
right: (node.val, upperBound)
```

### Memory line

> A BST node must satisfy every ancestor, not only its parent.

### Complexity

```text
time: O(n)
space: O(h)
```

