# Grind 75 — 58. Construct Binary Tree from Preorder and Inorder Traversal

## Problem

Given two traversals of the same binary tree:

- `preorder`: root → left subtree → right subtree
- `inorder`: left subtree → root → right subtree

construct and return the original binary tree.

All node values are unique.

Example:

```text
preorder = [3, 9, 20, 15, 7]
inorder  = [9, 3, 15, 20, 7]

tree:
        3
       / \
      9  20
         / \
        15  7
```

---

## 1. What information does each traversal provide?

Preorder always lists the root of a subtree first:

```text
[root, left subtree..., right subtree...]
```

Inorder tells us where that root divides the subtree:

```text
[left subtree..., root, right subtree...]
```

Together they answer both necessary questions:

1. Which value is the current root?
2. Which values belong to its left and right subtrees?

---

## 2. First recursive split

For:

```text
preorder = [3, 9, 20, 15, 7]
inorder  = [9, 3, 15, 20, 7]
```

The first preorder value is `3`, so `3` is the root.

Find `3` in inorder:

```text
[9] | 3 | [15, 20, 7]
 left       right
```

Therefore:

- the left subtree contains inorder range `[9]`;
- the right subtree contains inorder range `[15,20,7]`.

The next unused preorder value belongs to the left subtree because preorder processes the entire left subtree before the right subtree.

---

## 3. Avoid repeated searches

A naive recursive solution uses:

```javascript
inorder.indexOf(rootValue);
```

Searching inorder costs O(n) per node, producing O(n²) time in a skewed tree.

Build a map once:

```text
node value → inorder index
```

Then every root split is found in O(1) average time.

---

## 4. Recommended JavaScript solution

LeetCode provides the `TreeNode` constructor.

```javascript
function buildTree(preorder, inorder) {
  const inorderIndex = new Map();

  for (let i = 0; i < inorder.length; i++) {
    inorderIndex.set(inorder[i], i);
  }

  let preorderIndex = 0;

  function build(inorderLeft, inorderRight) {
    if (inorderLeft > inorderRight) {
      return null;
    }

    const rootValue = preorder[preorderIndex++];
    const root = new TreeNode(rootValue);
    const splitIndex = inorderIndex.get(rootValue);

    root.left = build(inorderLeft, splitIndex - 1);
    root.right = build(splitIndex + 1, inorderRight);

    return root;
  }

  return build(0, inorder.length - 1);
}
```

---

## 5. Meaning of the recursive function

```javascript
build(inorderLeft, inorderRight)
```

means:

> Construct the subtree containing exactly the values in this inclusive inorder range, using the next unused preorder value as its root.

The inorder range determines the subtree's boundaries. The shared `preorderIndex` determines which root comes next.

---

## 6. Why a single preorder pointer works

Preorder visits nodes in construction order:

```text
current root
then every left-subtree node
then every right-subtree node
```

Our recursion follows the same order:

```javascript
root.left = build(inorderLeft, splitIndex - 1);
root.right = build(splitIndex + 1, inorderRight);
```

Therefore, incrementing one `preorderIndex` each time a node is created always selects the correct next root.

No preorder slicing or separate preorder boundary calculation is required.

---

## 7. Why build the left subtree first?

After consuming the current root, the next preorder values describe the left subtree before the right subtree.

If we built the right subtree first while still advancing preorder from left to right, the next value would be incorrectly assigned to the right side.

Traversal order and recursive construction order must match.

---

## 8. Complete walkthrough

```text
preorder = [3, 9, 20, 15, 7]
inorder  = [9, 3, 15, 20, 7]
```

### Build range `[0,4]`

- next preorder root: `3`
- inorder split: index `1`
- left range: `[0,0]`
- right range: `[2,4]`

### Build left range `[0,0]`

- next root: `9`
- split: `0`
- its left range `[0,-1]` is empty
- its right range `[1,0]` is empty

Return leaf `9`.

### Build right range `[2,4]`

- next root: `20`
- split: `3`
- left range: `[2,2]`
- right range: `[4,4]`

### Build `[2,2]`

Next root is `15`, producing a leaf.

### Build `[4,4]`

Next root is `7`, producing a leaf.

The completed tree is:

```text
        3
       / \
      9  20
         / \
        15  7
```

---

## 9. Base case

```javascript
if (inorderLeft > inorderRight) {
  return null;
}
```

Crossed boundaries mean the inorder range contains no values, so that child does not exist.

For a leaf, both recursive child ranges cross immediately.

---

## 10. Correctness reasoning

We prove that `build(left, right)` constructs exactly the subtree described by `inorder[left...right]`.

### Empty range

If `left > right`, the range has no nodes, so returning `null` is correct.

### Root selection

Preorder lists the current subtree's root before all its descendants. Because recursive calls consume preorder in preorder order, the next unused value is exactly this subtree's root.

### Subtree partition

The root's inorder position divides the range uniquely:

- values to its left belong to the left subtree;
- values to its right belong to the right subtree.

### Recursive construction

The algorithm constructs the left range first, matching preorder's left-before-right order, then constructs the right range. By induction, each recursive call builds its correct subtree.

Thus the returned node connects the correct root, left subtree, and right subtree. The initial full-range call reconstructs the original tree.

---

## 11. Complexity

Let `n` be the number of nodes.

- Building the index map: O(n)
- Creating all nodes: O(n)
- Each map lookup: O(1) average
- Total time: **O(n)**
- Map space: **O(n)**
- Recursion stack: **O(h)**

Total auxiliary space is O(n), with recursion depth O(log n) for a balanced tree and O(n) for a skewed tree.

---

## 12. Why uniqueness matters

The map assumes each value has one unambiguous inorder index:

```text
value → index
```

With duplicate values, traversals alone may not uniquely identify the tree, and one map entry per value is insufficient. The problem's unique-value guarantee makes reconstruction deterministic.

---

## 13. Why preorder alone is insufficient

Preorder tells us which node comes first but not where one subtree ends and the next begins.

For example, several different tree shapes can produce the same preorder sequence.

Inorder supplies the structural partition around every root. With unique values, preorder plus inorder uniquely determines the tree.

---

## 14. Slicing version: intuitive but less efficient

```javascript
function buildTreeWithSlices(preorder, inorder) {
  if (preorder.length === 0) return null;

  const rootValue = preorder[0];
  const root = new TreeNode(rootValue);
  const splitIndex = inorder.indexOf(rootValue);

  const leftInorder = inorder.slice(0, splitIndex);
  const rightInorder = inorder.slice(splitIndex + 1);

  root.left = buildTreeWithSlices(
    preorder.slice(1, 1 + leftInorder.length),
    leftInorder
  );

  root.right = buildTreeWithSlices(
    preorder.slice(1 + leftInorder.length),
    rightInorder
  );

  return root;
}
```

This mirrors the conceptual partitions, but repeated `indexOf()` and `slice()` calls can lead to O(n²) time and substantial array allocation.

The index-range solution represents subarrays with two integers instead of copying them.

---

## 15. Alternative with explicit preorder ranges

Some interviews prefer avoiding shared mutable state. We can pass both traversal ranges.

```javascript
function buildTreeWithRanges(preorder, inorder) {
  const inorderIndex = new Map();

  for (let i = 0; i < inorder.length; i++) {
    inorderIndex.set(inorder[i], i);
  }

  function build(preLeft, preRight, inLeft, inRight) {
    if (preLeft > preRight) return null;

    const rootValue = preorder[preLeft];
    const root = new TreeNode(rootValue);
    const split = inorderIndex.get(rootValue);
    const leftSize = split - inLeft;

    root.left = build(
      preLeft + 1,
      preLeft + leftSize,
      inLeft,
      split - 1
    );

    root.right = build(
      preLeft + leftSize + 1,
      preRight,
      split + 1,
      inRight
    );

    return root;
  }

  return build(
    0,
    preorder.length - 1,
    0,
    inorder.length - 1
  );
}
```

This remains O(n) but has more boundary arithmetic. The shared preorder pointer is simpler because preorder consumption naturally follows recursion.

---

## 16. Common mistakes

### Mistake 1: repeatedly call `indexOf`

This can degrade the runtime to O(n²). Build an index map once.

### Mistake 2: use array slicing in every recursive call

It copies data repeatedly and complicates complexity.

### Mistake 3: construct the right subtree before the left

That conflicts with the order of preorder consumption.

### Mistake 4: use the wrong base condition

Inclusive inorder bounds are empty when `left > right`, not only when they are equal.

### Mistake 5: fail to increment `preorderIndex`

The same root value would be reused indefinitely.

### Mistake 6: calculate left-subtree size incorrectly

With explicit ranges:

```text
leftSize = splitIndex - inorderLeft
```

### Mistake 7: assume duplicates are supported

The O(1) index lookup relies on unique node values.

---

## 17. Edge cases

- empty traversals → `null`
- one node
- completely left-skewed tree
- completely right-skewed tree
- balanced tree
- root has only one child

The recursive range logic handles all shapes without separate structural cases.

---

## 18. Interview narration

> “Preorder gives me each subtree's root first, while inorder tells me which nodes belong to its left and right sides. I’ll map every inorder value to its index for constant-time splits and maintain one pointer to the next unused preorder value. For each inorder range, I create that next root, recursively build the left range first to match preorder order, then build the right range.”

---

## 19. Pattern recognition

This is **reconstruction from complementary traversals**.

Look for:

- one sequence identifying the root order;
- another sequence defining structural partitions;
- recursive subarray ranges;
- a map replacing repeated searches.

Related reconstruction problems include:

- inorder + postorder;
- preorder + postorder under additional constraints;
- rebuilding expression trees from notation;
- parsing recursive hierarchical sequences.

---

## 20. Quick test

```javascript
function TreeNode(val, left = null, right = null) {
  this.val = val;
  this.left = left;
  this.right = right;
}

const root = buildTree(
  [3, 9, 20, 15, 7],
  [9, 3, 15, 20, 7]
);

console.log(root.val);             // 3
console.log(root.left.val);        // 9
console.log(root.right.val);       // 20
console.log(root.right.left.val);  // 15
console.log(root.right.right.val); // 7
```

---

## 21. Notebook version

### Pattern

**Recursive reconstruction + traversal index map**

### Traversal roles

```text
preorder → next subtree root
inorder  → left/right boundary split
```

### Recursive state

```text
build(inorderLeft, inorderRight)
```

### Core order

```text
consume root → build left → build right
```

### Memory line

> Preorder names the root; inorder draws the border.

### Complexity

```text
time: O(n)
space: O(n)
recursion: O(h)
```
