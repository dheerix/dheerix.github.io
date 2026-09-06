# Grind 75 — 11: Balanced Binary Tree

**Difficulty:** Easy  
**Primary pattern:** Binary tree / postorder DFS / sentinel return  
**LeetCode:** https://leetcode.com/problems/balanced-binary-tree/  
**Target time:** 15 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Determine whether a binary tree is **height-balanced**.

A tree is height-balanced when, at **every node**, the heights of its left and right subtrees differ by at most one.

```text
abs(left height - right height) <= 1
```

Balanced:

```text
       3
      / \
     9  20
       /  \
      15   7
```

Unbalanced:

```text
       1
      /
     2
    /
   3
```

The condition must hold at every node, not only at the root.

---

## 2. Height definition

We will define height as the number of nodes on the longest downward path from a node to a leaf.

```text
height(null) = 0
height(leaf) = 1
height(node) = 1 + max(height(left), height(right))
```

Using edge count instead would also work if applied consistently. The balance difference is unchanged because both child heights use the same definition.

---

## 3. Straightforward but inefficient approach

At every node:

1. calculate the full height of the left subtree;
2. calculate the full height of the right subtree;
3. verify their difference;
4. recursively check whether both child subtrees are balanced.

```javascript
function isBalancedSlow(root) {
  if (root === null) return true;

  const difference = Math.abs(
    height(root.left) - height(root.right),
  );

  return (
    difference <= 1 &&
    isBalancedSlow(root.left) &&
    isBalancedSlow(root.right)
  );
}

function height(root) {
  if (root === null) return 0;
  return 1 + Math.max(height(root.left), height(root.right));
}
```

### Why can this become O(n²)?

In a skewed tree, the root computes height across almost all nodes. Its child computes height across almost all remaining nodes, and so on:

```text
n + (n - 1) + (n - 2) + ... + 1 = O(n²)
```

The same subtree heights are recomputed repeatedly.

---

## 4. Optimal insight: one function, two pieces of information

A parent needs two facts about each child subtree:

1. Is the subtree balanced?
2. If it is balanced, what is its height?

We can encode both in one return value:

```text
non-negative number → subtree is balanced; value is its height
-1                  → subtree is unbalanced
```

The helper contract becomes:

> Return the subtree's height if it is balanced; otherwise return `-1`.

This is a **sentinel return value**. It lets a failure deep in the tree travel upward without calculating irrelevant heights.

---

## 5. Why postorder traversal?

The current node cannot determine its height or balance until it knows the results from both children.

Order:

```text
left subtree → right subtree → current node
```

That is postorder traversal.

At each node:

1. get the left result;
2. stop if the left subtree is unbalanced;
3. get the right result;
4. stop if the right subtree is unbalanced;
5. compare the two heights;
6. return `-1` if their difference exceeds one;
7. otherwise return the current height.

---

## 6. Optimal JavaScript solution

```javascript
function isBalanced(root) {
  function balancedHeight(node) {
    if (node === null) {
      return 0;
    }

    const leftHeight = balancedHeight(node.left);

    if (leftHeight === -1) {
      return -1;
    }

    const rightHeight = balancedHeight(node.right);

    if (rightHeight === -1) {
      return -1;
    }

    if (Math.abs(leftHeight - rightHeight) > 1) {
      return -1;
    }

    return 1 + Math.max(leftHeight, rightHeight);
  }

  return balancedHeight(root) !== -1;
}
```

---

## 7. Code walkthrough

### Base case: `null → 0`

An empty subtree has height zero and is balanced. Returning zero gives its parent the height information needed for comparison.

### Compute left result first

If the left subtree returns `-1`, the entire current subtree is already known to be unbalanced. There is no need to traverse the right subtree merely to calculate a height that cannot change the final answer.

### Compute right result

The symmetric failure propagation applies.

### Local balance check

```javascript
Math.abs(leftHeight - rightHeight) > 1
```

This evaluates the balance requirement at the current node after both child subtrees have been proven balanced.

### Return current height

```javascript
1 + Math.max(leftHeight, rightHeight)
```

The parent needs only the longest downward path through this subtree.

### Final conversion to boolean

```javascript
balancedHeight(root) !== -1
```

The helper returns rich structural information; the public function converts it to the boolean requested by the problem.

---

## 8. Dry run: balanced tree

```text
       3
      / \
     9  20
       /  \
      15   7
```

Postorder results:

```text
node 9:  left 0, right 0 → height 1
node 15: left 0, right 0 → height 1
node 7:  left 0, right 0 → height 1
node 20: left 1, right 1 → height 2
node 3:  left 1, right 2 → difference 1 → height 3
```

The root returns height `3`, not `-1`, so the tree is balanced.

---

## 9. Dry run: imbalance propagation

```text
       1
      /
     2
    /
   3
```

```text
node 3 → height 1
node 2 → left 1, right 0 → height 2
node 1 → left 2, right 0 → difference 2 → return -1
```

For a deeper tree, if any descendant returns `-1`, every ancestor returns `-1` immediately. Failure becomes contagious upward because an unbalanced subtree makes every containing tree unbalanced.

---

## 10. Correctness reasoning

Prove the helper contract by structural induction.

### Base case

For `null`, the helper returns `0`. The empty tree is balanced and has height zero, so the contract holds.

### Inductive step

Assume the helper correctly reports both child subtrees. If either child returns `-1`, that child is unbalanced, so the current subtree must also be unbalanced and returning `-1` is correct.

Otherwise both returned values are correct child heights. If their difference exceeds one, the current node violates the balance condition, so return `-1`. If the difference is at most one, both children are balanced and the current node is locally balanced; therefore the current subtree is balanced, and `1 + max(leftHeight, rightHeight)` is its correct height.

Thus the helper contract holds for every node, and the root result correctly determines the answer.

---

## 11. Complexity

Let `n` be the number of nodes and `h` the tree height.

- **Time: O(n)** — each visited node performs constant work, and no subtree height is recomputed.
- **Auxiliary space: O(h)** — recursion depth follows the longest root-to-leaf path.

Tree shape:

- balanced tree: O(log n) call-stack space;
- skewed tree: O(n) call-stack space.

Early failure may visit fewer than `n` nodes, but O(n) remains the worst-case bound.

---

## 12. Alternative return shape: pair of values

Instead of a sentinel, return both facts explicitly:

```javascript
function isBalancedWithPair(root) {
  function inspect(node) {
    if (node === null) {
      return { balanced: true, height: 0 };
    }

    const left = inspect(node.left);
    if (!left.balanced) return left;

    const right = inspect(node.right);
    if (!right.balanced) return right;

    const balanced = Math.abs(left.height - right.height) <= 1;

    return {
      balanced,
      height: 1 + Math.max(left.height, right.height),
    };
  }

  return inspect(root).balanced;
}
```

This makes the two pieces of information explicit and can be clearer in production code. The `-1` sentinel is concise and safe because valid heights are never negative.

Both solutions are O(n) time and O(h) call-stack space.

---

## 13. Why `-1` is a safe sentinel

A sentinel must not overlap with a valid result.

Valid subtree heights under our definition are:

```text
0, 1, 2, 3, ...
```

Therefore, `-1` cannot be confused with a legitimate height. If the valid domain included negative values, a different representation—such as an object, tuple, or `null`—would be safer.

This pattern appears often:

> Return the normal computed value, but reserve one impossible value to signal failure.

---

## 14. Common mistakes

1. **Checking balance only at the root.** Every node must satisfy the height condition.
2. **Recomputing heights at every node.** This can degrade to O(n²).
3. **Returning only a boolean from the helper.** The parent still needs child heights, often causing repeated traversal.
4. **Forgetting to propagate `-1`.** An unbalanced descendant makes the whole containing subtree unbalanced.
5. **Calculating current height before validating child results.** `-1` is a failure signal, not a real height.
6. **Using `leftHeight - rightHeight > 1` without `Math.abs`.** Either side can be taller.
7. **Claiming O(1) space.** Recursive call-stack space is O(h).
8. **Assuming a BST.** This is a binary-tree shape property; node values and BST ordering are irrelevant.
9. **Confusing “balanced” with “complete” or “perfect.”** A balanced tree need not have every level filled.

---

## 15. What to say in an interview

> “A naive solution recomputes subtree heights at many nodes and can become O(n²). I’ll use postorder DFS so each child returns its height to its parent. I’ll reserve `-1` as a signal that a subtree is already unbalanced. If either child returns `-1`, or their heights differ by more than one, I propagate `-1`; otherwise I return the current height. Each node is processed once, so time is O(n), with O(h) recursion space.”

If asked why postorder:

> “The current node's answer depends on completed height and balance information from both children.”

---

## 16. Pattern recognition

Think **postorder DFS** when:

- a parent depends on results computed from its children;
- information must flow from leaves upward;
- the task asks for height, diameter, subtree validity, or aggregated subtree state.

Think **sentinel propagation** when:

- a recursive helper normally returns a computed value;
- one impossible value can also signal failure;
- detecting failure early should short-circuit ancestors.

Memory cue:

> Children report height—or report failure.

---

## 17. Distinguish related tree terms

| Term | Meaning |
|---|---|
| Height-balanced | At every node, child-height difference is at most one |
| Full | Every node has zero or two children |
| Complete | All levels except possibly the last are full; last fills left to right |
| Perfect | Every internal node has two children and all leaves share a depth |

A height-balanced tree does not have to be full, complete, or perfect.

---

## 18. Edge cases

| Tree | Result | Reason |
|---|---:|---|
| empty | `true` | Empty tree is balanced |
| one node | `true` | Both child heights are zero |
| root with one child | `true` | Height difference is one |
| chain of three nodes | `false` at top | Height difference becomes two |
| root balanced, deeper node unbalanced | `false` | Condition applies everywhere |
| perfect tree | `true` | Equal subtree heights throughout |

---

## 19. Notebook-ready notes

### 📚 Concept

**Balanced Binary Tree — postorder height with failure sentinel**

```text
helper(node):
  null → 0
  leftHeight = helper(left)
  left -1 → return -1
  rightHeight = helper(right)
  right -1 → return -1
  abs(left-right) > 1 → return -1
  else → return 1 + max(left,right)

balanced iff helper(root) !== -1
```

### 🧠 My understanding

The parent needs both balance and height from each child. A non-negative return carries a valid height; `-1` carries failure. Postorder computes each subtree once and lets imbalance propagate upward immediately.

### 💼 Interview line

> “I’ll combine height calculation and balance validation in one postorder traversal.”

### ⚠️ Traps

- Check every subtree, not only the root.
- Propagate `-1` before treating it as a height.
- Use absolute height difference.
- Recursive space is O(h).

---

## 20. Dheerix Glance

```text
BALANCED BINARY TREE

Definition:       abs(leftHeight-rightHeight) <= 1 at every node
Traversal:        postorder
Normal return:    subtree height
Failure return:   -1
Base:             null → 0
Local failure:    height difference > 1
Propagation:      child -1 → parent -1
Time:             O(n)
Recursive space:  O(h)
Memory cue:       “Return height, or return failure.”
```

---

## 21. Recall test

Without looking back:

1. Why is checking only the root insufficient?
2. Why can the straightforward solution become O(n²)?
3. What is the helper function's exact contract?
4. Why is `-1` a safe sentinel?
5. Why is postorder the natural traversal?
6. When can the right subtree traversal be skipped?
7. What are the time and space complexities?
8. How is height-balanced different from complete or perfect?
9. State the correctness argument in two sentences.

