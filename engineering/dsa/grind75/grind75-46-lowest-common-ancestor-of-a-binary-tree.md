# Grind 75 — 46. Lowest Common Ancestor of a Binary Tree

## Problem

Given a binary tree and two nodes `p` and `q`, return their lowest common ancestor (LCA).

The LCA is the lowest node in the tree that has both `p` and `q` as descendants. A node is allowed to be a descendant of itself.

Example:

```text
        3
       / \
      5   1
     / \ / \
    6  2 0  8
      / \
     7   4
```

- LCA of `5` and `1` is `3`.
- LCA of `5` and `4` is `5`, because a node may be its own ancestor.

---

## 1. The recursive insight

Ask each subtree:

> Did you find `p`, `q`, or an already-established lowest common ancestor?

For a node:

1. search the left subtree;
2. search the right subtree;
3. combine their answers.

If both sides return a non-null node, then one target was found on each side. The current node is where their paths first meet, so it is the LCA.

If only one side returns a non-null node, propagate that result upward.

If the current node itself is `p` or `q`, return it immediately.

---

## 2. Recommended JavaScript solution

```javascript
function lowestCommonAncestor(root, p, q) {
  if (root === null || root === p || root === q) {
    return root;
  }

  const leftResult = lowestCommonAncestor(root.left, p, q);
  const rightResult = lowestCommonAncestor(root.right, p, q);

  if (leftResult !== null && rightResult !== null) {
    return root;
  }

  return leftResult !== null ? leftResult : rightResult;
}
```

The entire solution comes from giving the return value a precise meaning.

---

## 3. Meaning of the return value

For a call on `root`, the returned value means:

- `null`: this subtree contains neither target;
- `p` or `q`: this subtree contains that target, and no lower split has been found;
- another node: this subtree has already found the LCA.

This allows partial information discovered below to flow upward until it can be combined.

---

## 4. The four cases at each node

After recursive calls return:

| Left result | Right result | Meaning | Return |
| --- | --- | --- | --- |
| `null` | `null` | Neither target found | `null` |
| non-null | `null` | Target/LCA found on left | left result |
| `null` | non-null | Target/LCA found on right | right result |
| non-null | non-null | Targets found on different sides | current node |

The base case `root === p || root === q` also handles the case where one target is an ancestor of the other.

---

## 5. Walkthrough: targets on opposite sides

Find the LCA of `5` and `1`:

```text
        3
       / \
      5   1
```

At node `3`:

- the left recursive call reaches `5` and returns node `5`;
- the right recursive call reaches `1` and returns node `1`;
- both results are non-null.

Therefore, node `3` is the split point and is returned as the LCA.

---

## 6. Walkthrough: one target is an ancestor

Find the LCA of `5` and `4`:

```text
      5
     / \
    6   2
       / \
      7   4
```

When recursion reaches node `5`, it matches `p`, so the function returns `5` immediately.

This is correct even though `4` lies below it: by definition, a node can be a descendant of itself, and `5` is the lowest node that is an ancestor of both `5` and `4`.

The original problem guarantees both nodes exist, so no additional verification is required.

---

## 7. Walkthrough: propagating a partial result

Suppose a subtree contains only `p`.

Calls below it return `null` until the recursion reaches `p`, which returns itself. Ancestors above that point receive:

```text
one non-null result + one null result
```

They propagate `p` upward unchanged. If another branch later reports `q`, the first node combining both non-null results becomes the LCA.

---

## 8. Why postorder-style recursion fits

The current node cannot decide whether it is the LCA until it knows what both subtrees contain.

That requires this order:

```text
left subtree → right subtree → current decision
```

This is the essence of postorder reasoning: children compute information first, and the parent combines it.

---

## 9. Correctness reasoning

We prove the recursive function returns the LCA for its subtree when both targets exist in the overall tree.

### Base cases

- An empty subtree contains no target, so return `null`.
- If the current node is `p` or `q`, return it. It may be the target being propagated upward or the ancestor of the other target.

### Both recursive results are non-null

The left subtree contains one relevant target/result and the right subtree contains the other. Therefore, the current node is a common ancestor. No descendant of the current node can contain both because the findings are split across different child subtrees. Thus, the current node is the lowest common ancestor.

### Exactly one result is non-null

All relevant information discovered in this subtree lies on that side. Returning it preserves either the found target or an LCA already discovered lower down.

### Both results are null

Neither subtree contains a target, so this subtree contributes no answer.

By combining these cases at every node, the root call returns the correct LCA.

---

## 10. Complexity

Let `n` be the number of nodes and `h` the height of the tree.

- Time: **O(n)** in the worst case
- Auxiliary space: **O(h)** for recursion
- Balanced tree: **O(log n)** stack space
- Skewed tree: **O(n)** stack space

Each node is visited at most once.

---

## 11. Why node identity matters

Compare nodes themselves:

```javascript
root === p
```

not only their values:

```javascript
root.val === p.val
```

Tree nodes are objects. Even if the problem happens to use unique values, the function is conceptually given node references, and identity is the precise comparison.

---

## 12. This is not the BST-specific LCA algorithm

For a binary search tree, value ordering lets us decide whether both targets lie left, both lie right, or split at the current node.

This problem gives an ordinary binary tree, so there is no ordering relationship to exploit. We must search the structure.

Do not use logic such as:

```javascript
if (p.val < root.val && q.val < root.val) {
  return lowestCommonAncestor(root.left, p, q);
}
```

unless the tree is explicitly guaranteed to be a BST.

---

## 13. Alternative: parent pointers and ancestor set

We can first build a parent map, then walk upward from each target.

```javascript
function lowestCommonAncestorWithParents(root, p, q) {
  const parent = new Map([[root, null]]);
  const stack = [root];

  while (!parent.has(p) || !parent.has(q)) {
    const node = stack.pop();

    if (node.left !== null) {
      parent.set(node.left, node);
      stack.push(node.left);
    }

    if (node.right !== null) {
      parent.set(node.right, node);
      stack.push(node.right);
    }
  }

  const ancestors = new Set();

  while (p !== null) {
    ancestors.add(p);
    p = parent.get(p);
  }

  while (!ancestors.has(q)) {
    q = parent.get(q);
  }

  return q;
}
```

This approach is iterative and intuitive:

1. remember every parent;
2. collect all ancestors of `p`;
3. move upward from `q` until finding the first shared ancestor.

It uses O(n) additional space, while the recursive solution uses only O(h) call-stack space.

---

## 14. What if one target might be missing?

The standard concise solution relies on the problem guarantee that both `p` and `q` exist.

If existence is not guaranteed, returning `p` alone does not prove that `q` was found beneath it. A production-ready variant can return both a candidate and a found count.

```javascript
function lowestCommonAncestorVerified(root, p, q) {
  function search(node) {
    if (node === null) {
      return { ancestor: null, found: 0 };
    }

    const left = search(node.left);
    if (left.ancestor !== null && left.found === 2) return left;

    const right = search(node.right);
    if (right.ancestor !== null && right.found === 2) return right;

    const selfFound = node === p || node === q ? 1 : 0;
    const found = left.found + right.found + selfFound;

    return {
      ancestor: found === 2
        ? node
        : left.ancestor ?? right.ancestor ?? (selfFound ? node : null),
      found
    };
  }

  const result = search(root);
  return result.found === 2 ? result.ancestor : null;
}
```

This is not necessary for the LeetCode constraints, but it demonstrates how guarantees affect algorithm design.

---

## 15. Common mistakes

### Mistake 1: search only immediate children

Targets can appear at any depth, so subtree results must be propagated upward.

### Mistake 2: return the root whenever either side is non-null

The current node is the LCA only when **both** sides are non-null. With one side non-null, propagate that result.

### Mistake 3: forget `root === p || root === q`

This breaks the case where one target is an ancestor of the other.

### Mistake 4: compare values instead of node references

Use object identity to identify the given nodes.

### Mistake 5: apply BST ordering to an ordinary binary tree

There is no guarantee that smaller values are left or larger values are right.

### Mistake 6: assume the concise solution verifies both nodes exist

It does not; it relies on the stated problem guarantee.

---

## 16. Edge cases

- `p` and `q` are direct children of the root
- both targets lie in the same subtree
- one target is the root
- one target is an ancestor of the other
- the LCA is deep in the tree
- the tree is highly skewed

The standard problem uses two different nodes and guarantees both are present.

---

## 17. Interview narration

> “I’ll use postorder recursion. A subtree returns null if it found neither target, otherwise it returns a found target or an LCA already discovered below. If the left and right calls both return non-null, the targets split at the current node, making it their lowest common ancestor. If only one side returns a node, I propagate it upward. I also return immediately when the current node is `p` or `q`, which handles the ancestor case.”

---

## 18. Pattern recognition

This is a **tree information aggregation** pattern:

```text
children return partial information
              ↓
parent combines the information
              ↓
parent returns a summary upward
```

Use it when the answer depends on where special nodes or conditions appear across subtrees.

Related tree questions ask for:

- diameter;
- balanced-tree status;
- subtree sums;
- maximum path values;
- matching descendants;
- common ancestors.

---

## 19. Quick test

```javascript
function TreeNode(val, left = null, right = null) {
  this.val = val;
  this.left = left;
  this.right = right;
}

const node5 = new TreeNode(5);
const node1 = new TreeNode(1);
const node4 = new TreeNode(4);

node5.right = new TreeNode(2, null, node4);
const root = new TreeNode(3, node5, node1);

console.log(lowestCommonAncestor(root, node5, node1).val); // 3
console.log(lowestCommonAncestor(root, node5, node4).val); // 5
```

---

## 20. Notebook version

### Pattern

**Postorder DFS + combine subtree results**

### Base case

```javascript
if (root === null || root === p || root === q) return root;
```

### Combine rule

```text
left and right found → current node is LCA
only one found       → return that result
neither found        → return null
```

### Memory line

> One answer from each side means the paths meet here.

### Complexity

```text
time: O(n)
space: O(h)
```

