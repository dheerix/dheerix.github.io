# Grind 75 — 32: Clone Graph

**Difficulty:** Medium  
**Primary pattern:** Graph traversal / hash map / deep copy  
**LeetCode:** https://leetcode.com/problems/clone-graph/  
**Target time:** 25 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given a reference to a node in a connected undirected graph, return a deep copy of the entire graph.

Each node contains:

```javascript
function Node(val, neighbors = []) {
  this.val = val;
  this.neighbors = neighbors;
}
```

A deep clone requires:

- every original node has a distinct cloned node;
- cloned values match original values;
- cloned edges match original edges;
- no clone points back to an original node;
- shared references and cycles are preserved structurally.

---

## 2. Why this is harder than copying a tree

Trees have no cycles and every non-root node has exactly one parent. A recursive tree copy naturally reaches each node once through a unique path.

Graphs may contain:

- cycles;
- multiple paths to the same node;
- a node appearing in several neighbor lists;
- self-loops.

Naive recursion without visited state can loop forever:

```text
1 → 2 → 1 → 2 → ...
```

Creating a fresh clone every time a node is encountered also duplicates what should be one shared node.

---

## 3. The essential map

Maintain:

```text
original node object → cloned node object
```

This map serves two roles:

1. **Visited tracking:** if an original is already a key, it has been discovered.
2. **Identity preservation:** every edge to the same original points to the same clone.

The graph's values are not safe visited keys. Node values may not be unique under general graph contracts, and graph identity is about objects and edges, not labels.

---

## 4. Recursive contract

Define:

> `clone(node)` returns the unique cloned node corresponding to `node`, with its reachable neighbor structure cloned.

Cases:

1. If `node` already exists in the map, return the existing clone.
2. Otherwise create an empty clone and put it in the map **before** exploring neighbors.
3. Clone each neighbor recursively and append it to the clone's neighbor list.
4. Return the clone.

---

## 5. Why map before recursion?

Suppose two connected nodes refer to each other:

```text
1 ↔ 2
```

While cloning node `1`, recursion begins cloning node `2`. Node `2` then encounters node `1` again.

If node `1` was entered into the map before recursing, node `2` retrieves its existing partial clone and closes the cycle.

If mapping is delayed until after neighbors are cloned, recursion never sees node `1` as visited and repeats forever.

General graph-copy rule:

> Allocate and register the clone before traversing outgoing references.

---

## 6. Optimal recursive DFS solution

```javascript
function cloneGraph(node) {
  if (node === null) {
    return null;
  }

  const cloneByOriginal = new Map();

  function clone(original) {
    if (cloneByOriginal.has(original)) {
      return cloneByOriginal.get(original);
    }

    const copy = new Node(original.val);
    cloneByOriginal.set(original, copy);

    for (const neighbor of original.neighbors) {
      copy.neighbors.push(clone(neighbor));
    }

    return copy;
  }

  return clone(node);
}
```

---

## 7. Dry run on a cycle

```text
1 — 2
|   |
4 — 3
```

Start `clone(1)`:

1. Create `1'`; map `1 → 1'`.
2. Visit neighbor `2`.
3. Create `2'`; map `2 → 2'`.
4. Node `2` sees neighbor `1`.
5. Map already contains `1`, so return `1'` instead of recursing again.
6. Continue discovering `3`, then `4`; mapped clones close every returning edge.

At completion:

```text
original graph: 1,2,3,4
clone graph:    1',2',3',4'
```

The topology is identical, but node objects are distinct.

---

## 8. Code walkthrough

### Null input

An empty graph has no node to clone, so return `null`.

### Map keys are node objects

JavaScript `Map` compares object keys by reference identity. That is exactly what graph cloning requires.

### Create an empty neighbor list first

```javascript
const copy = new Node(original.val);
```

The clone exists before its edges are known. Its neighbor list is populated as traversal discovers the graph.

### Existing-map return

This handles both cycles and shared neighbors. It does not mean the clone is necessarily fully populated yet; returning the same object reference is enough because its neighbor list will be completed by the original call that created it.

### Preserve neighbor order

Iterating original neighbors and pushing clones in that order reproduces the provided adjacency-list order, though graph correctness generally depends on connectivity rather than display order.

---

## 9. Correctness reasoning

For every discovered original node, the algorithm creates exactly one clone because creation occurs only when the original is absent from the map, followed immediately by registration.

For each original edge from `u` to neighbor `v`, the loop appends `clone(v)` to `clone(u).neighbors`. The map guarantees this is the unique clone of `v`, so all original adjacencies and shared identities are preserved.

No clone neighbor references an original because every appended object comes from `clone(...)`. Since traversal visits every node reachable from the connected starting node, the entire graph is copied. Thus the result is a structurally identical deep clone.

---

## 10. Complexity

Let:

```text
V = number of nodes
E = number of edges
```

- **Time: O(V + E)** — every node is created once and every adjacency-list entry is processed once. In an undirected graph, each edge appears in two neighbor lists, which is still O(E).
- **Extra space: O(V)** for the original-to-clone map, plus O(V) worst-case recursion stack.
- **Clone output space: O(V + E)**.

The recursion depth depends on the DFS traversal shape and can reach O(V).

---

## 11. Iterative BFS solution

```javascript
function cloneGraphBfs(node) {
  if (node === null) {
    return null;
  }

  const cloneByOriginal = new Map();
  cloneByOriginal.set(node, new Node(node.val));

  const queue = [node];
  let front = 0;

  while (front < queue.length) {
    const original = queue[front++];
    const copy = cloneByOriginal.get(original);

    for (const neighbor of original.neighbors) {
      if (!cloneByOriginal.has(neighbor)) {
        cloneByOriginal.set(
          neighbor,
          new Node(neighbor.val),
        );
        queue.push(neighbor);
      }

      copy.neighbors.push(cloneByOriginal.get(neighbor));
    }
  }

  return cloneByOriginal.get(node);
}
```

This also runs in O(V + E) time and O(V) auxiliary space. It avoids recursion depth limits and uses a front index rather than repeated `shift()` calls.

---

## 12. DFS versus BFS

| Property | Recursive DFS | Iterative BFS |
|---|---|---|
| Traversal structure | Call stack | Explicit queue |
| Original→clone map | Required | Required |
| Time | O(V+E) | O(V+E) |
| Extra space | O(V) map + stack | O(V) map + queue |
| JavaScript concern | Deep graph may overflow call stack | More code, avoids recursion limit |

The map—not traversal order—is the essential cloning mechanism.

---

## 13. Shallow copy versus deep copy

This is not sufficient:

```javascript
const copy = new Node(node.val, node.neighbors);
```

The neighbor array and its node references still point into the original graph. Mutating the clone could affect or expose original structure.

A deep clone requires a new node for every original node and edges exclusively among those cloned nodes.

Useful validation:

```text
clone !== original
clone.val === original.val
same reachable topology
no cloned node === any original node
```

---

## 14. Why node values cannot identify clones

Even if this LeetCode problem uses convenient unique labels, a reusable graph clone should map original object identity.

Consider two different nodes both valued `1`:

```text
nodeA.val = 1
nodeB.val = 1
```

Mapping `1 → clone` would collapse them into one node and corrupt the topology. Mapping `nodeA → cloneA` and `nodeB → cloneB` preserves identity.

Choose keys according to entity identity, not display data.

---

## 15. Common mistakes

1. **Recursing without visited state.** Cycles cause infinite recursion.
2. **Mapping after cloning neighbors.** Back-edges revisit the current node before it is registered.
3. **Using node values as map keys.** Different nodes can share a value in general.
4. **Creating a new clone on every encounter.** Shared nodes become duplicated.
5. **Copying the original neighbor array directly.** That is a shallow copy pointing to originals.
6. **Appending original neighbors to clone neighbors.** Every edge in the result must target a clone.
7. **Using only a visited set.** You also need a way to retrieve each corresponding clone; the map provides both.
8. **Cloning only immediate neighbors.** The entire reachable graph must be traversed.
9. **Calling time O(V).** Adjacency processing contributes O(E).
10. **Using `queue.shift()` repeatedly in JavaScript BFS.** Prefer a front index.

---

## 16. What to say in an interview

> “Because the graph can contain cycles and shared neighbors, I need an original-node-to-clone map. My DFS helper returns the unique clone for an original node. If it already exists, I reuse it. Otherwise I create and register the clone before recursing, then append the clone of every neighbor. Registering first closes cycles safely. Every node and edge is processed once, so time is O(V+E), with O(V) map space plus recursion stack.”

If asked why a map rather than set:

> “A set can tell me a node was visited, but the map also gives me the exact clone object to use when rebuilding edges.”

---

## 17. Pattern recognition

Think **graph clone / object-graph copy** when:

- objects reference one another;
- cycles or shared references are possible;
- identity relationships must be preserved;
- a deep copy must contain no references to originals.

General pattern:

```text
if original already mapped → return mapped copy
create blank copy
map original → copy immediately
recursively/iteratively clone referenced objects
attach cloned references
```

This applies to graphs, random-pointer linked lists, dependency networks, and cyclic object models.

Memory cue:

> Create, register, then connect.

---

## 18. Edge cases

| Graph | Expected clone behavior |
|---|---|
| null input | return null |
| one isolated node | new node, same value, empty neighbors |
| two nodes connected | two clones connected to each other |
| cycle | cycle reproduced without recursion loop |
| self-loop | clone points to itself, not original |
| shared neighbor | all cloned incoming edges point to one clone |
| repeated values | distinct original identities remain distinct clones |

---

## 19. Notebook-ready notes

### 📚 Concept

**Clone Graph — DFS/BFS + original→clone map**

```text
clone(node):
  already mapped → return existing clone
  create empty clone
  map original → clone immediately
  for each original neighbor:
    clone.neighbors.push(clone(neighbor))
  return clone
```

### 🧠 My understanding

The map gives every original exactly one cloned identity. Registering a clone before following its neighbors lets back-edges find the partial clone and close cycles instead of recursing forever. Every reconstructed edge points through the map to a clone, never to an original.

### 💼 Interview line

> “The map is both my visited structure and my identity-preserving clone registry.”

### ⚠️ Traps

- Register before recursion.
- Map node objects, not values.
- Never copy original neighbor references.
- Complexity includes both vertices and edges.

---

## 20. Dheerix Glance

```text
CLONE GRAPH

Challenge:        cycles + shared references
Essential state:  original node → clone node
If mapped:        reuse clone
If new:           create clone, map immediately
Then:             clone every neighbor and attach
Traversal:        DFS or BFS
Time:             O(V + E)
Auxiliary space:  O(V) plus traversal stack/queue
Deep-copy rule:   no clone points to an original
Memory cue:       “Create, register, connect.”
```

---

## 21. Recall test

Without looking back:

1. Why does naive recursion fail on a graph?
2. What two roles does the map perform?
3. Why must a clone be mapped before its neighbors are traversed?
4. Why should map keys be original node objects rather than values?
5. What makes a copy shallow instead of deep?
6. How are shared neighbors preserved rather than duplicated?
7. What are the time and space complexities in terms of V and E?
8. How does iterative BFS avoid JavaScript recursion-depth concerns?

