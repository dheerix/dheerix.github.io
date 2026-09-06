# Grind 75 — 63. Minimum Height Trees

## Problem

You are given an undirected tree with `n` nodes labeled `0` through `n - 1` and `n - 1` edges.

Choose any node as the root. The tree's height is the maximum number of edges from that root to any leaf.

Return every node that produces the minimum possible height. These nodes are called the tree's **centers**.

Example:

```text
n = 4
edges = [[1,0], [1,2], [1,3]]

    0
    |
2 — 1 — 3

answer = [1]
```

Rooting at `1` gives height `1`. Rooting at any outer node gives height `2`.

---

## What makes this problem deceptive?

The problem says “try each node as the root,” which naturally suggests:

1. root the tree at node `0` and measure its height;
2. root it at node `1` and measure its height;
3. repeat for every node;
4. return the roots with the smallest height.

That works logically, but it repeats a full traversal from every node.

The better question is:

> What structural property must an optimal root have?

An optimal root must be as central as possible. Nodes on the outside are poor roots because they are far from the opposite side of the tree.

---

## Brute force: calculate height from every root

```javascript
function findMinHeightTreesBruteForce(n, edges) {
  const graph = Array.from({ length: n }, () => []);

  for (const [a, b] of edges) {
    graph[a].push(b);
    graph[b].push(a);
  }

  let minimumHeight = Infinity;
  const answer = [];

  for (let root = 0; root < n; root++) {
    const queue = [[root, -1, 0]];
    let front = 0;
    let height = 0;

    while (front < queue.length) {
      const [node, parent, depth] = queue[front++];
      height = Math.max(height, depth);

      for (const neighbor of graph[node]) {
        if (neighbor !== parent) {
          queue.push([neighbor, node, depth + 1]);
        }
      }
    }

    if (height < minimumHeight) {
      minimumHeight = height;
      answer.length = 0;
      answer.push(root);
    } else if (height === minimumHeight) {
      answer.push(root);
    }
  }

  return answer;
}
```

Each of the `n` candidate roots traverses `n` nodes:

```text
time:  O(n²)
space: O(n)
```

For large trees, this is too slow.

---

## Central insight: trim leaves layer by layer

A **leaf** is a node with degree `1`: it has only one neighbor.

Leaves form the outermost layer of a tree. Remove all current leaves simultaneously, and their neighbors may become the next layer of leaves.

Repeat until only one or two nodes remain:

```text
outside layer → remove
next layer    → remove
...
center        → remain
```

The last remaining node or nodes are exactly the roots of minimum-height trees.

This is analogous to topological sorting:

- topological sort repeatedly removes indegree-`0` nodes from a directed acyclic graph;
- here we repeatedly remove degree-`1` nodes from an undirected tree.

---

## Why can there be at most two answers?

Consider a longest path in the tree—the tree's **diameter**.

The optimal root must be at the middle of this path:

- if the diameter has an even number of edges, it has one middle node;
- if it has an odd number of edges, it has two middle nodes.

```text
0 — 1 — 2 — 3 — 4
        ↑
     one center

0 — 1 — 2 — 3
    ↑   ↑
   two centers
```

Moving away from the diameter's middle makes one end farther away, increasing the height. Therefore a tree has either one or two minimum-height roots.

Leaf trimming removes both ends of every longest path at the same rate, eventually exposing that middle.

---

## Optimal solution: leaf trimming

```javascript
function findMinHeightTrees(n, edges) {
  if (n === 1) return [0];

  const graph = Array.from({ length: n }, () => []);
  const degree = new Array(n).fill(0);

  for (const [a, b] of edges) {
    graph[a].push(b);
    graph[b].push(a);
    degree[a]++;
    degree[b]++;
  }

  let leaves = [];

  for (let node = 0; node < n; node++) {
    if (degree[node] === 1) leaves.push(node);
  }

  let remainingNodes = n;

  while (remainingNodes > 2) {
    remainingNodes -= leaves.length;
    const nextLeaves = [];

    for (const leaf of leaves) {
      for (const neighbor of graph[leaf]) {
        degree[neighbor]--;

        if (degree[neighbor] === 1) {
          nextLeaves.push(neighbor);
        }
      }
    }

    leaves = nextLeaves;
  }

  return leaves;
}
```

---

## Data structures

### Adjacency list

```javascript
const graph = Array.from({ length: n }, () => []);
```

Because edges are undirected, store both directions:

```javascript
graph[a].push(b);
graph[b].push(a);
```

### Degree array

```text
degree[node] = number of currently untrimmed neighbors
```

Initially it is the node's ordinary graph degree. As leaves are removed, we decrement their neighbors' degrees.

We do not physically delete edges from the adjacency list. The degree array represents the shrinking tree more efficiently.

### Current leaf layer

`leaves` contains all nodes being removed in the same round. `nextLeaves` collects nodes whose degree becomes `1` because of that round.

---

## Why leaves must be removed simultaneously

Suppose we modify and reuse one queue without respecting layers. A node that becomes a leaf during the current round might be removed immediately before other leaves at the same distance from the center are processed.

Conceptually, all nodes in one outer layer must disappear together.

Using `leaves` and `nextLeaves` makes the boundary explicit:

```text
current layer: leaves
next layer:    nextLeaves
```

This preserves symmetry and makes `remainingNodes` accurate.

---

## Walkthrough: two centers

```text
n = 6
edges = [[3,0], [3,1], [3,2], [3,4], [5,4]]

    0
    |
1 — 3 — 4 — 5
    |
    2
```

Initial degrees:

```text
node:    0  1  2  3  4  5
degree:  1  1  1  4  2  1
```

Initial leaves:

```text
[0, 1, 2, 5]
```

Remove those four nodes:

```text
remainingNodes = 6 - 4 = 2
```

Updates:

- removing `0`, `1`, and `2` reduces node `3` from degree `4` to `1`;
- removing `5` reduces node `4` from degree `2` to `1`.

Next leaves:

```text
[3, 4]
```

Only two nodes remain, so stop. Both `3` and `4` are minimum-height roots.

---

## Walkthrough: one center

```text
0 — 1 — 2 — 3 — 4
```

Layer 1:

```text
leaves = [0, 4]
remaining after removal = 3
```

Layer 2:

```text
leaves = [1, 3]
remaining after removal = 1
```

The new leaf is `[2]`. Stop because one node remains. Node `2` is the unique center.

---

## The `n === 1` edge case

```javascript
if (n === 1) return [0];
```

A single node has degree `0`, not degree `1`, so it would never enter the initial leaf list. Handle it explicitly.

For `n === 2`, both nodes have degree `1`. The loop condition `remainingNodes > 2` is already false, so both are correctly returned.

---

## Why the condition is `remainingNodes > 2`

The final center may contain either:

- one node;
- two adjacent nodes.

If we continued until one node remained, a two-center tree would have both final nodes removed together, losing the answer.

Stop once at most two nodes remain:

```text
while (remainingNodes > 2)
```

---

## Correctness argument

We prove that the last one or two remaining nodes are exactly the minimum-height roots.

### Leaves cannot be optimal unless the tree has at most two nodes

In a tree with more than two nodes, a leaf has only one direction into the rest of the tree. Moving the root from that leaf to its neighbor decreases the distance to every node beyond that neighbor and does not introduce a farther branch behind the leaf. Therefore the leaf cannot have smaller height than its inward neighbor.

So removing all leaves does not remove a unique optimal center while more than two nodes remain.

### Trimming preserves the center

Removing every leaf shortens all longest outside-to-outside paths symmetrically by one edge at each end. Their middle node or middle edge does not change. Therefore the original tree and the trimmed tree have the same center.

### The process ends at the center

Every finite tree with more than two nodes has at least two leaves, so each round makes progress. A tree's center contains one node or two adjacent nodes. Repeated symmetric trimming eventually removes every outer layer and leaves exactly this center.

Therefore the returned nodes are precisely all minimum-height tree roots.

---

## Complexity

Building the adjacency list and degrees processes every edge twice, once from each endpoint.

During trimming, each node becomes a leaf at most once and each adjacency entry is examined a constant number of times.

```text
time:  O(n)
space: O(n)
```

A tree has `n - 1` edges, so `O(n + edges)` simplifies to `O(n)`.

---

## Common mistakes

### 1. Running BFS or DFS from every root

It is correct but costs `O(n²)`. Use the tree-center property.

### 2. Treating edges as directed

Add both `a → b` and `b → a` to the adjacency list.

### 3. Forgetting `n === 1`

The only node has degree zero and will not be discovered as a normal leaf.

### 4. Stopping only when one node remains

Some trees have two valid centers. Stop at `remainingNodes <= 2`.

### 5. Removing only one leaf per round

The algorithm peels layers. All current leaves must be processed together.

### 6. Adding a neighbor as a leaf when degree is `<= 1`

Use exactly:

```text
if (degree[neighbor] === 1)
```

This ensures each node is added once, at the moment it becomes a leaf.

### 7. Physically deleting edges unnecessarily

An adjacency list plus mutable degrees is simpler and remains linear.

### 8. Using `Array.shift()` for a large queue

Repeated `shift()` can be costly in JavaScript because it reindexes the array. This layered solution iterates arrays directly and replaces the layer reference.

---

## Edge cases

```text
n = 1, edges = []
answer = [0]

n = 2, edges = [[0,1]]
answer = [0,1]

star centered at 0
answer = [0]

path with 5 nodes
answer = [2]

path with 4 nodes
answer = [1,2]
```

The problem guarantees a valid tree: connected, acyclic, and containing exactly `n - 1` edges. In production code without that guarantee, validate the input first because the trimming logic assumes a tree.

---

## Alternative solution: find the diameter

Another linear-time strategy is:

1. run BFS/DFS from any node to find a farthest endpoint `A`;
2. run BFS/DFS from `A` to find the farthest endpoint `B`, recording parents;
3. reconstruct the diameter path from `B` back to `A`;
4. return its one or two middle nodes.

This also runs in `O(n)` time and space. Leaf trimming is usually shorter for this problem and directly demonstrates the center structure. Diameter finding is valuable when the interviewer also asks for the longest path.

---

## Interview walkthrough

Say this before coding:

> Trying every node as a root would require a traversal per node, or `O(n²)`. The minimum-height roots are the tree's centers. I can find them by repeatedly removing all degree-one leaves, which peels the tree symmetrically from the outside. When one or two nodes remain, those nodes are the centers and therefore all minimum-height roots.

State the invariant:

> Before each round, `leaves` contains exactly the degree-one nodes of the remaining untrimmed tree, and the original tree's center is still present.

Complexity statement:

> Every node is removed once and every edge is processed a constant number of times, so the algorithm takes `O(n)` time and `O(n)` space.

If asked why only one or two nodes remain:

> A tree's centers are the middle of its diameter. A path has either one middle node or two adjacent middle nodes.

---

## Notebook version

```javascript
function findMinHeightTrees(n, edges) {
  if (n === 1) return [0];

  const graph = Array.from({ length: n }, () => []);
  const degree = new Array(n).fill(0);

  for (const [a, b] of edges) {
    graph[a].push(b);
    graph[b].push(a);
    degree[a]++;
    degree[b]++;
  }

  let leaves = [];

  for (let node = 0; node < n; node++) {
    if (degree[node] === 1) leaves.push(node);
  }

  let remaining = n;

  while (remaining > 2) {
    remaining -= leaves.length;
    const nextLeaves = [];

    for (const leaf of leaves) {
      for (const neighbor of graph[leaf]) {
        degree[neighbor]--;
        if (degree[neighbor] === 1) {
          nextLeaves.push(neighbor);
        }
      }
    }

    leaves = nextLeaves;
  }

  return leaves;
}
```

### Notebook bullets

- Minimum-height roots are tree centers.
- Degree `1` means current leaf.
- Remove every leaf in the current layer.
- A neighbor becomes a new leaf when its degree reaches exactly `1`.
- Stop when at most two nodes remain.
- Special case: `n === 1`.
- Time `O(n)`; space `O(n)`.

### Memory line

> Peel the tree until its center is exposed.

### Pattern connection

This resembles BFS by layers and Kahn's topological sort, but the removal rule is undirected degree `1` rather than directed indegree `0`.

```text
outside leaves → inner leaves → center
```
