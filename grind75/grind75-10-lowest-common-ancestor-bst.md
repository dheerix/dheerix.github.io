# Grind 75 — 10: Lowest Common Ancestor of a BST

**Difficulty:** Easy  
**Primary pattern:** Binary search tree / ordered traversal  
**LeetCode:** https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-search-tree/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given a Binary Search Tree (BST) and two nodes `p` and `q`, return their **lowest common ancestor**.

An ancestor of a node includes the node itself. The lowest common ancestor (LCA) is the deepest node that is an ancestor of both targets.

```text
          6
        /   \
       2     8
      / \   / \
     0   4 7   9
        / \
       3   5
```

```text
p = 2, q = 8 → LCA = 6
p = 2, q = 4 → LCA = 2
p = 3, q = 5 → LCA = 4
```

For `p = 2` and `q = 4`, node `2` is an ancestor of itself and of `4`, so it is the answer.

---

## 2. The BST property

For every node:

```text
all values in left subtree  < node.val
all values in right subtree > node.val
```

The problem guarantees unique values. Therefore, the current node's value tells us where both targets must be.

At a current node:

```text
p and q both smaller → both are in the left subtree
p and q both larger  → both are in the right subtree
otherwise            → they split here, or one is current
```

The first node where the targets no longer lie strictly on the same side is their lowest common ancestor.

---

## 3. What does “lowest” mean operationally?

Start at the root and move downward while both targets are guaranteed to be in the same child subtree.

Every such move proves the current node is a common ancestor but not the lowest possible one. A lower common ancestor may still exist on that shared side.

Stop when:

- `p` and `q` lie on opposite sides; or
- the current node equals `p`; or
- the current node equals `q`.

At that point, no single child subtree can contain both targets. The current node is therefore the deepest common ancestor reachable along their shared path.

---

## 4. Step-by-step algorithm

Starting at `root`:

1. If both target values are smaller, move to `root.left`.
2. Else if both target values are larger, move to `root.right`.
3. Otherwise, return the current node.

The “otherwise” case includes both splitting and equality:

```text
p < root < q  → split
q < root < p  → split
p === root    → root is ancestor of itself and q
q === root    → root is ancestor of itself and p
```

---

## 5. Optimal iterative JavaScript solution

```javascript
function lowestCommonAncestor(root, p, q) {
  let current = root;

  while (current !== null) {
    if (p.val < current.val && q.val < current.val) {
      current = current.left;
    } else if (p.val > current.val && q.val > current.val) {
      current = current.right;
    } else {
      return current;
    }
  }

  return null;
}
```

The official problem guarantees that both targets exist in the tree, so the loop will return a node before reaching `null`. The final return makes the function safe and complete for a broader contract.

---

## 6. Dry run: targets split

```text
p = 2, q = 8
```

Start at `6`:

```text
2 < 6 and 8 > 6
```

The targets lie on opposite sides. Return `6` immediately.

Why is it the lowest? Any descendant of `6` belongs entirely to either the left or right subtree, so no descendant can be an ancestor of both `2` and `8`.

---

## 7. Dry run: both targets begin on one side

```text
p = 3, q = 5
```

| Current | Relationship | Decision |
|---:|---|---|
| 6 | both `< 6` | move left to 2 |
| 2 | both `> 2` | move right to 4 |
| 4 | `3 < 4 < 5` | split; return 4 |

The root `6` is a common ancestor, but it is not the **lowest** one. The BST comparisons let us descend along the targets' shared route before returning.

---

## 8. Dry run: one target is the ancestor

```text
p = 2, q = 4
```

At `6`, both values are smaller, so move left to `2`.

At `2`:

- `p.val === current.val`;
- the “both smaller” condition is false;
- the “both larger” condition is false;
- the `else` branch returns `2`.

This correctly handles the rule that a node is its own ancestor.

---

## 9. Code walkthrough

### `let current = root`

The tree itself is not modified. `current` is simply the node being examined along one root-to-descendant path.

### Both-smaller condition

```javascript
p.val < current.val && q.val < current.val
```

BST ordering proves that both targets lie in the left subtree. No node on the right can be relevant.

### Both-larger condition

The symmetric argument moves right.

### The `else` branch

If the targets are not strictly together on the left and not strictly together on the right, the current node is their divergence point or one of the targets. In both cases, it is the LCA.

### Why compare values rather than node identity?

The BST ordering is defined by values, and the problem guarantees unique node values. Equality with the current value identifies the same target node under this contract.

---

## 10. Correctness reasoning

Loop invariant:

> At the beginning of each iteration, `current` is a common ancestor of `p` and `q`, and their lowest common ancestor lies within the subtree rooted at `current`.

If both target values are smaller than `current.val`, BST ordering puts both nodes in the left subtree. Moving left preserves the invariant and discards a current node that cannot be the lowest if a deeper common path exists. The same reasoning applies to the right.

When the targets are not on the same strict side, they diverge into separate subtrees or one equals `current`. No descendant can then be an ancestor of both, while `current` is an ancestor of both. Therefore, `current` is their lowest common ancestor.

---

## 11. Complexity

Let `h` be the tree height.

- **Time: O(h)** — the algorithm follows a single path downward.
- **Auxiliary space: O(1)** — the iterative version stores one current-node reference.

Tree-shape interpretation:

- balanced BST: `h = O(log n)`;
- skewed BST: `h = O(n)`.

Do not claim O(log n) without assuming the BST is balanced. “BST” means ordered; it does not automatically mean balanced.

---

## 12. Recursive alternative

```javascript
function lowestCommonAncestorRecursive(root, p, q) {
  if (p.val < root.val && q.val < root.val) {
    return lowestCommonAncestorRecursive(root.left, p, q);
  }

  if (p.val > root.val && q.val > root.val) {
    return lowestCommonAncestorRecursive(root.right, p, q);
  }

  return root;
}
```

Complexity:

- Time: **O(h)**.
- Call-stack space: **O(h)**.

The recursive solution closely mirrors the reasoning. The iterative version achieves the same traversal with O(1) auxiliary space and avoids call-stack limits.

---

## 13. General binary tree comparison

Without the BST ordering, node values cannot tell us which subtree contains each target. A general binary-tree LCA solution must search both sides:

```javascript
function lowestCommonAncestorBinaryTree(root, p, q) {
  if (root === null || root === p || root === q) {
    return root;
  }

  const leftResult = lowestCommonAncestorBinaryTree(root.left, p, q);
  const rightResult = lowestCommonAncestorBinaryTree(root.right, p, q);

  if (leftResult !== null && rightResult !== null) {
    return root;
  }

  return leftResult ?? rightResult;
}
```

This takes O(n) time because the targets could be anywhere. The BST-specific solution is faster because ordering lets us choose only one path.

Do not use the general solution first when the problem explicitly gives a BST; interviewers expect you to exploit the stronger invariant.

---

## 14. Common mistakes

1. **Ignoring the BST property.** Searching the whole tree works but wastes the main source of leverage.
2. **Requiring strict opposite sides only.** If one target equals the current node, the current node is also the LCA.
3. **Moving left when only one target is smaller.** Move left only when both are strictly smaller.
4. **Moving right when only one target is larger.** Both must be strictly larger.
5. **Claiming O(log n) for every BST.** A skewed BST has height O(n).
6. **Confusing LCA with the numerically closest value.** LCA is defined by ancestry, not numeric distance.
7. **Returning the root immediately because it is a common ancestor.** Descend while both targets remain on the same side to find the lowest one.
8. **Adding traversal storage unnecessarily.** The iterative BST solution needs neither a stack nor a visited set.

---

## 15. What to say in an interview

> “I’ll exploit the BST ordering. If both target values are smaller than the current node, their LCA must be in the left subtree; if both are larger, it must be in the right subtree. Otherwise they split around the current node, or one target is the current node, making it the LCA. I follow only one path, so time is O(h) and the iterative solution uses O(1) extra space.”

If asked about balance:

> “That is O(log n) for a balanced BST, but O(n) in the worst case for a skewed BST.”

---

## 16. Pattern recognition

Think **BST-guided traversal** when:

- values are unique and ordered by subtree;
- comparisons can identify the only relevant branch;
- two search paths share a prefix and then diverge;
- you need a split point, range boundary, predecessor, or successor.

The LCA is the final node on the common prefix of the root-to-`p` and root-to-`q` search paths.

Memory cue:

> Together left, go left. Together right, go right. Otherwise, stop.

---

## 17. Min/max simplification

The two target values can be normalized:

```javascript
function lowestCommonAncestorWithRange(root, p, q) {
  const lower = Math.min(p.val, q.val);
  const upper = Math.max(p.val, q.val);
  let current = root;

  while (current !== null) {
    if (current.val < lower) {
      current = current.right;
    } else if (current.val > upper) {
      current = current.left;
    } else {
      return current;
    }
  }

  return null;
}
```

The answer is the first node whose value falls inside the inclusive range `[lower, upper]` while following the BST search path.

This form is compact, but the explicit “both smaller/both larger” version often communicates the LCA reasoning more directly.

---

## 18. Edge cases

| Situation | Result |
|---|---|
| `p` and `q` are in opposite root subtrees | root |
| `p` is ancestor of `q` | `p` |
| `q` is ancestor of `p` | `q` |
| both lie deep in left subtree | descend left until split |
| both lie deep in right subtree | descend right until split |
| `p` and `q` are direct siblings | their parent |

The official problem guarantees both nodes exist. If existence were not guaranteed, the simple BST traversal could return a split node even when one target is missing. A broader contract would require presence verification.

---

## 19. Notebook-ready notes

### 📚 Concept

**LCA in BST — find the split point**

```text
both values < current → go left
both values > current → go right
otherwise             → current is LCA
```

### 🧠 My understanding

The root-to-target search paths stay together while both targets are on the same side. I keep following that shared path. The first node where they separate—or one target equals the node—is the deepest node that can contain both.

### 💼 Interview line

> “The LCA is the split point of the two BST search paths.”

### ⚠️ Traps

- Equality belongs in the answer case.
- Move to one side only when both targets lie there.
- Complexity is O(h), not automatically O(log n).

---

## 20. Dheerix Glance

```text
LOWEST COMMON ANCESTOR — BST

Leverage:        left < node < right
Both smaller:    move left
Both larger:     move right
Otherwise:       split/equality → return current
Meaning:         first divergence of search paths
Time:            O(h)
Iterative space: O(1)
Balanced time:   O(log n)
Worst time:      O(n)
Memory cue:      “Together, descend. Split, stop.”
```

---

## 21. Recall test

Without looking back:

1. What does the BST property let us avoid?
2. Why do we keep descending while both targets are on the same side?
3. Why does the first split point give the lowest common ancestor?
4. How does the algorithm handle one target being the ancestor of the other?
5. Why is the complexity O(h) rather than always O(log n)?
6. What extra space do the iterative and recursive versions use?
7. Why would the general binary-tree solution be O(n)?
8. State the loop invariant in one sentence.

