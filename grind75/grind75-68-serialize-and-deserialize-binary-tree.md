# Grind 75 — 68: Serialize and Deserialize Binary Tree

**Difficulty:** Hard  
**Primary pattern:** Tree DFS + encoding/decoding protocol  
**LeetCode:** 297  
**Target interview time:** 40 minutes  
**Language:** JavaScript

## Problem

Design two functions:

- `serialize(root)` converts a binary tree into a string.
- `deserialize(data)` reconstructs the same binary tree from that string.

There is no required encoding format. The essential contract is:

```text
deserialize(serialize(tree)) reconstructs tree
```

The reconstructed tree must preserve both:

- every node value;
- the exact tree structure.

---

## 1. Intuition

A traversal containing only node values is not enough to uniquely identify a binary tree.

For example, preorder values `1,2` could represent either:

```text
    1          1
   /            \
  2              2
```

The missing information is where the absent children are.

Add an explicit marker such as `#` for every null child. Then preorder traversal becomes structurally complete:

```text
node -> left subtree -> right subtree
```

Examples:

```text
left-child tree:  1,2,#,#,#
right-child tree: 1,#,2,#,#
```

Now the encodings are different and unambiguous.

### Core idea

Serialization writes one token for every node position:

- a number for a real node;
- `#` for a missing child.

Deserialization reads those tokens in the same preorder sequence. Each recursive call consumes exactly the tokens belonging to one subtree.

---

## 2. Brute-Force / Fragile Approach — Store Only Values

One tempting solution serializes preorder values but skips null children.

```js
function serialize(root) {
  const values = [];

  function dfs(node) {
    if (node === null) return;

    values.push(String(node.val));
    dfs(node.left);
    dfs(node.right);
  }

  dfs(root);
  return values.join(",");
}
```

### Why it fails

It loses structural information. Multiple different trees can produce the same preorder sequence.

```text
Tree A:           Tree B:
    1                 1
   /                   \
  2                     2

Preorder A: 1,2
Preorder B: 1,2
```

No deserializer can determine which original structure was intended.

### Lesson

Serialization is not merely traversal. It is a protocol, and the protocol must encode enough information to reverse the operation uniquely.

---

## 3. Optimal Solution — Preorder DFS with Null Markers

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
 * Encodes a tree to a single string.
 *
 * @param {TreeNode|null} root
 * @return {string}
 */
function serialize(root) {
  const tokens = [];

  function dfs(node) {
    if (node === null) {
      tokens.push("#");
      return;
    }

    tokens.push(String(node.val));
    dfs(node.left);
    dfs(node.right);
  }

  dfs(root);
  return tokens.join(",");
}

/**
 * Decodes the encoded data back into a tree.
 *
 * @param {string} data
 * @return {TreeNode|null}
 */
function deserialize(data) {
  const tokens = data.split(",");
  let index = 0;

  function buildTree() {
    const token = tokens[index++];

    if (token === "#") {
      return null;
    }

    const node = new TreeNode(Number(token));
    node.left = buildTree();
    node.right = buildTree();

    return node;
  }

  return buildTree();
}
```

---

## 4. The Encoding Protocol

The format uses:

```text
Traversal: preorder
Separator: ,
Null marker: #
Value format: decimal string
```

For every subtree, its encoding is recursively defined as:

```text
null subtree:
#

non-null subtree:
value, serialization(left), serialization(right)
```

This shared protocol is what makes the two functions compatible. Changing the traversal order, separator, or null marker in one function requires the same change in the other.

---

## 5. Walkthrough

Consider:

```text
        1
       / \
      2   3
         / \
        4   5
```

### Serialization

Preorder DFS visits:

```text
1
2
#   left child of 2
#   right child of 2
3
4
#   left child of 4
#   right child of 4
5
#   left child of 5
#   right child of 5
```

Serialized string:

```text
1,2,#,#,3,4,#,#,5,#,#
```

### Deserialization

| Token | Action |
| --- | --- |
| `1` | Create node `1`; next build its left subtree |
| `2` | Create node `2`; next build its left subtree |
| `#` | Set `2.left = null` |
| `#` | Set `2.right = null`; node `2` is complete |
| `3` | Create node `3`; next build its left subtree |
| `4` | Create node `4` |
| `#`, `#` | Complete node `4` with null children |
| `5` | Create node `5` |
| `#`, `#` | Complete node `5` with null children |

Each invocation of `buildTree()` consumes the first token of its subtree and recursively consumes exactly its left and right subtree encodings.

---

## 6. Why a Shared Index Works

During deserialization:

```js
let index = 0;
```

Every `buildTree()` call consumes one token immediately:

```js
const token = tokens[index++];
```

- `#` finishes that subtree immediately.
- A number creates a node, after which the next tokens must describe its left subtree and then its right subtree.

The recursive calls naturally advance the shared index to the first unconsumed token. There is no need to search for subtree boundaries or slice arrays.

### Why not use `tokens.shift()`?

`shift()` removes the first array element and may require reindexing the remaining array, making repeated shifts potentially `O(n²)` in JavaScript.

An index gives constant-time token consumption:

```js
tokens[index++];
```

---

## 7. Correctness Proof

We prove that deserializing the output of `serialize` reconstructs the original tree.

### Claim

For every binary subtree `T`, `buildTree()` reconstructs `T` from its serialized token sequence and consumes exactly that sequence.

### Base case

If `T` is null, serialization writes `#`. Deserialization reads `#` and returns `null`. The subtree is reconstructed correctly, and exactly one token is consumed.

### Inductive step

Assume the claim holds for the left and right subtrees of a non-null tree `T`.

Serialization writes:

1. `T`'s root value;
2. the serialization of `T.left`;
3. the serialization of `T.right`.

Deserialization reads the root value and creates an equivalent node. By the induction hypothesis, the first recursive call reconstructs and consumes exactly the left subtree encoding. The next recursive call therefore starts at the right subtree encoding and reconstructs it correctly. The returned node has the same value, left subtree, and right subtree as `T`.

### Conclusion

By structural induction, `deserialize(serialize(root))` reconstructs every node value and every null-child position of the original tree. Therefore, it reconstructs the exact original tree.

---

## 8. Complexity

Let `n` be the number of real nodes and `h` be the tree height.

### Serialization

- Time: `O(n)`.
- Output storage: `O(n)` tokens.
- Recursion stack: `O(h)`.

### Deserialization

- Splitting and processing tokens: `O(n)`.
- Reconstructed tree: `O(n)`.
- Recursion stack: `O(h)`.

Why are null markers still `O(n)`?

A binary tree with `n` real nodes has `n + 1` null child references. Therefore, the total number of tokens is:

```text
n real-node tokens + (n + 1) null tokens = 2n + 1
```

That is still linear.

For a balanced tree, `h = O(log n)`. For a skewed tree, `h = O(n)`.

---

## 9. Common Mistakes

### Mistake 1: Omitting null markers

Values alone do not uniquely preserve tree shape.

### Mistake 2: Using inconsistent traversal orders

If serialization writes preorder, deserialization must consume preorder.

### Mistake 3: Forgetting to convert strings back to numbers

```js
new TreeNode(Number(token))
```

Without conversion, node values become strings.

### Mistake 4: Using a truthy check for tokens

The value `0` is valid. Compare explicitly with the null marker:

```js
if (token === "#")
```

### Mistake 5: Using `shift()` repeatedly

Use a shared index to avoid possible repeated array reindexing.

### Mistake 6: Building only one child

For every real node, the protocol always contains both a left-subtree encoding and a right-subtree encoding—even when either is `#`.

### Mistake 7: Confusing serialized space with auxiliary space

The output itself is `O(n)`. Separately, recursive traversal uses `O(h)` call-stack space.

### Mistake 8: Assuming values are always positive

`Number("-12")` handles negative node values correctly.

### Mistake 9: Serializing with ambiguous concatenation

Without delimiters, values such as `1,23` and `12,3` could become indistinguishable. Use a clear separator or a length-prefixed encoding.

---

## 10. Edge Cases

### Empty tree

```text
serialize(null) = "#"
deserialize("#") = null
```

### Single node

```text
Tree: 7
Encoding: "7,#,#"
```

### Only left children

Null markers distinguish the structure from a right-skewed tree.

### Only right children

The first child token after each node is `#`, followed by the right child.

### Zero value

```text
"0,#,#"
```

Zero must not be mistaken for null.

### Negative values

```text
"-1,-2,#,#,3,#,#"
```

The comma separator keeps negative signs unambiguous.

### Duplicate values

Duplicate values do not cause ambiguity because null markers preserve structure and tokens are consumed positionally.

### Deeply skewed tree

The recursive solution may reach `O(n)` call-stack depth. In production JavaScript, an iterative encoding/decoding strategy may be safer for extremely deep untrusted input.

---

## 11. Alternative — Level-Order Serialization

Breadth-first search can also encode the tree using null markers:

```text
1,2,3,#,#,4,5,#,#,#,#
```

This is valid, but deserialization requires a queue and explicit child assignment. Preorder DFS is usually easier to explain and implement because the recursive grammar of the encoding mirrors the recursive tree structure.

The important choice is not DFS versus BFS. The important requirement is that the format be unambiguous and that both functions follow the same format.

---

## 12. Interview Explanation

> A traversal containing only values cannot preserve the shape of a binary tree, so I’ll use preorder DFS and write an explicit `#` token for every null child. Serialization records `node, left, right`. During deserialization, I keep a shared token index. A `#` returns null; otherwise I create the node, recursively build its left subtree, then its right subtree. Because each recursive call consumes exactly one complete subtree encoding, the original structure and values are reconstructed uniquely. Both operations take `O(n)` time, use `O(n)` serialized data, and require `O(h)` recursion depth.

### Clarifications worth stating

1. Node values are integers, so comma can safely separate them.
2. The serialized representation is private to the two methods unless an external format is required.
3. The empty tree is encoded as `#`.

### Production follow-up

For a persistent or network protocol, also consider:

- versioning the format;
- validating malformed input;
- limiting input size and depth;
- escaping delimiters for non-integer payloads;
- using an iterative parser to prevent call-stack exhaustion.

---

## 13. Notebook Version

### Recognition

```text
Need values + exact shape
=> traversal + null markers
```

### Protocol

```text
preorder: node, left, right
null: #
separator: ,
```

### JavaScript

```js
function serialize(root) {
  const tokens = [];

  function dfs(node) {
    if (!node) {
      tokens.push("#");
      return;
    }

    tokens.push(String(node.val));
    dfs(node.left);
    dfs(node.right);
  }

  dfs(root);
  return tokens.join(",");
}

function deserialize(data) {
  const tokens = data.split(",");
  let index = 0;

  function build() {
    const token = tokens[index++];
    if (token === "#") return null;

    const node = new TreeNode(Number(token));
    node.left = build();
    node.right = build();
    return node;
  }

  return build();
}
```

### Complexity

```text
Serialize:   O(n) time, O(n) output, O(h) stack
Deserialize: O(n) time, O(n) tree,   O(h) stack
```

### Invariant

Each `build()` call consumes exactly one complete subtree encoding and returns that subtree.

---

## 14. Memory Line

**Values preserve content; null markers preserve shape.**

