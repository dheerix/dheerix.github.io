# Grind 75 — 27: 01 Matrix

**Difficulty:** Medium  
**Primary pattern:** Multi-source BFS / shortest distance in an unweighted grid  
**LeetCode:** https://leetcode.com/problems/01-matrix/  
**Target time:** 30 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given a matrix containing only `0` and `1`, return a matrix where each cell contains its distance to the nearest zero.

Movement is allowed only up, down, left, and right. Each move has cost one.

```text
Input:
0 0 0
0 1 0
1 1 1

Output:
0 0 0
0 1 0
1 2 1
```

The center cell on the last row is two moves from its nearest zero.

---

## 2. Grid-as-graph model

Translate the matrix into a graph:

```text
cell                    → node
orthogonal adjacency    → edge
each edge cost          → 1
distance to nearest zero→ shortest-path distance to any source
```

Because every edge has equal cost, breadth-first search computes shortest distances.

---

## 3. Slow idea: BFS from every `1`

For every `1` cell, run BFS until a zero is found.

There can be O(mn) starting cells, and each BFS can inspect O(mn) cells:

```text
O((mn)²)
```

This repeats nearly the same searches many times.

The question should be reversed:

> Instead of making every cell search for a zero, can every zero spread its distance to nearby cells?

---

## 4. Multi-source BFS insight

Ordinary BFS begins from one source. Multi-source BFS begins with **all sources in the queue at distance zero**.

For this problem:

```text
every zero cell = source
```

Then BFS expands in synchronized layers:

```text
layer 0 → all zeros
layer 1 → cells one move from some zero
layer 2 → cells two moves from their nearest zero
...
```

The first source wave to reach a cell must be the nearest zero because BFS processes cells in nondecreasing distance order.

---

## 5. Distance matrix as visited state

Create a result matrix initialized to `-1`:

```text
-1 → distance not assigned yet
0+ → visited; value is shortest known distance
```

During initialization:

- set every zero cell's distance to `0`;
- enqueue every zero cell.

During BFS:

- visit only neighbors whose distance is still `-1`;
- assign `current distance + 1` before enqueuing.

The result matrix therefore doubles as a visited structure.

---

## 6. Optimal JavaScript solution

```javascript
function updateMatrix(mat) {
  const rows = mat.length;
  const columns = mat[0].length;

  const distances = Array.from(
    { length: rows },
    () => new Array(columns).fill(-1),
  );

  const queue = [];
  let front = 0;

  // Every zero is an initial BFS source at distance zero.
  for (let row = 0; row < rows; row++) {
    for (let column = 0; column < columns; column++) {
      if (mat[row][column] === 0) {
        distances[row][column] = 0;
        queue.push([row, column]);
      }
    }
  }

  const directions = [
    [-1, 0],
    [1, 0],
    [0, -1],
    [0, 1],
  ];

  while (front < queue.length) {
    const [row, column] = queue[front++];

    for (const [rowChange, columnChange] of directions) {
      const nextRow = row + rowChange;
      const nextColumn = column + columnChange;

      const isInsideMatrix =
        nextRow >= 0 &&
        nextRow < rows &&
        nextColumn >= 0 &&
        nextColumn < columns;

      if (
        isInsideMatrix &&
        distances[nextRow][nextColumn] === -1
      ) {
        distances[nextRow][nextColumn] =
          distances[row][column] + 1;

        queue.push([nextRow, nextColumn]);
      }
    }
  }

  return distances;
}
```

---

## 7. Dry run

```text
mat:
0 0 0
0 1 0
1 1 1
```

### Initialization

All zeros enter the queue with distance zero:

```text
distances:
 0  0  0
 0 -1  0
-1 -1 -1
```

### First expansion layer

Zero cells discover adjacent unvisited cells:

```text
distances:
0 0 0
0 1 0
1 -1 1
```

### Second expansion layer

Cells at distance one discover the remaining center cell:

```text
distances:
0 0 0
0 1 0
1 2 1
```

Every cell receives the distance of the earliest wave that reaches it.

---

## 8. Why mark before enqueueing?

Suppose two processed cells share an unvisited neighbor. If that neighbor remains `-1` until it is dequeued, both parents can enqueue it.

Instead:

```javascript
distances[nextRow][nextColumn] = currentDistance + 1;
queue.push([nextRow, nextColumn]);
```

Marking at discovery guarantees each cell enters the queue only once.

This is a standard BFS rule:

> Mark when enqueuing, not when dequeuing.

---

## 9. Why the first assigned distance is optimal

All sources begin at distance zero. FIFO order processes every distance-`d` cell before any distance-`d+1` cell.

When a cell is first discovered from a distance-`d` cell, it receives distance `d + 1`. Any alternative path discovered later must have length at least `d + 1`, because BFS has not skipped an earlier layer.

Therefore, no distance needs relaxation or later improvement. One assignment per cell is sufficient.

---

## 10. Correctness reasoning

Initially, every zero cell has correct distance zero and is placed in the queue.

Inductively, assume every dequeued cell has its correct nearest-zero distance `d`. Each unvisited neighbor has a path of length `d + 1` through that cell. Because BFS processes all shorter-distance layers first, no shorter path to the neighbor can exist without having discovered it already. Assigning `d + 1` is therefore correct.

The graph is connected through grid edges as applicable, and the problem guarantees at least one zero, so repeated expansion reaches every cell. Thus the returned matrix contains every nearest-zero distance.

---

## 11. Complexity

Let `m` be rows and `n` be columns.

- **Time: O(mn)** — initialization scans all cells, and BFS enqueues and processes each cell at most once. Each cell checks four directions.
- **Space: O(mn)** — the output matrix and queue can each contain O(mn) entries.

If output storage is excluded, the queue still requires O(mn) auxiliary space in the worst case.

The four-neighbor loop is constant work, so O(4mn) simplifies to O(mn).

---

## 12. JavaScript matrix-construction trap

Do not initialize a 2D array like this:

```javascript
const distances = new Array(rows).fill(
  new Array(columns).fill(-1),
);
```

Every row would reference the same inner array. Updating one row would update all rows at that column.

Correct:

```javascript
const distances = Array.from(
  { length: rows },
  () => new Array(columns).fill(-1),
);
```

The callback creates a distinct inner array for every row.

---

## 13. JavaScript queue implementation

Avoid repeatedly calling:

```javascript
queue.shift()
```

Removing the first array element may reindex the remaining elements.

Use:

```javascript
let front = 0;
const item = queue[front++];
```

The consumed values remain in the array until the function ends, but dequeue work stays constant-time and the total queue storage remains O(mn).

---

## 14. Dynamic-programming alternative

Nearest-zero distance can also be calculated with two matrix passes.

First pass, top-left to bottom-right, uses distances from top and left. Second pass, bottom-right to top-left, uses bottom and right.

```javascript
function updateMatrixDp(mat) {
  const rows = mat.length;
  const columns = mat[0].length;
  const infinity = rows + columns;

  const distance = Array.from(
    { length: rows },
    () => new Array(columns).fill(infinity),
  );

  for (let row = 0; row < rows; row++) {
    for (let column = 0; column < columns; column++) {
      if (mat[row][column] === 0) {
        distance[row][column] = 0;
      } else {
        if (row > 0) {
          distance[row][column] = Math.min(
            distance[row][column],
            distance[row - 1][column] + 1,
          );
        }

        if (column > 0) {
          distance[row][column] = Math.min(
            distance[row][column],
            distance[row][column - 1] + 1,
          );
        }
      }
    }
  }

  for (let row = rows - 1; row >= 0; row--) {
    for (let column = columns - 1; column >= 0; column--) {
      if (row < rows - 1) {
        distance[row][column] = Math.min(
          distance[row][column],
          distance[row + 1][column] + 1,
        );
      }

      if (column < columns - 1) {
        distance[row][column] = Math.min(
          distance[row][column],
          distance[row][column + 1] + 1,
        );
      }
    }
  }

  return distance;
}
```

This is also O(mn). Multi-source BFS is more directly reusable for unweighted shortest-distance-to-nearest-source problems, especially with obstacles or irregular graphs.

---

## 15. Why DFS is not the natural choice

DFS can reach a cell through a long path before a shorter path is explored. It would need repeated relaxation and revisitation to correct distances.

BFS processes equal-cost edges in distance order, so the first visit is optimal. Use traversal according to the question:

```text
reachability/component → DFS or BFS
shortest unweighted path → BFS
weighted shortest path → Dijkstra or another weighted algorithm
```

---

## 16. Common mistakes

1. **Running BFS separately from every `1`.** This repeats work and can become O((mn)²).
2. **Starting from one zero only.** Distance must be measured to the nearest among all zeros.
3. **Using DFS and assuming first visit is shortest.** DFS does not traverse by distance layers.
4. **Marking visited only when dequeuing.** A cell can enter the queue multiple times.
5. **Using diagonal directions.** Only four orthogonal moves are allowed.
6. **Using `queue.shift()` repeatedly.** Prefer a front index in JavaScript.
7. **Creating aliased matrix rows with `.fill(innerArray)`.** Use `Array.from` with a row factory.
8. **Confusing row and column bounds.** Compare rows with `mat.length` and columns with `mat[0].length`.
9. **Calling the extra space O(1).** The queue can hold O(mn) cells.
10. **Re-enqueueing cells to improve distance unnecessarily.** First discovery in multi-source BFS is already optimal.

---

## 17. What to say in an interview

> “This is shortest distance in an unweighted grid. Running a search from every one repeats work, so I’ll reverse the perspective and start BFS from all zero cells simultaneously. They enter the queue at distance zero. Each unvisited neighbor receives its parent's distance plus one and is marked when enqueued. BFS layers guarantee the first assigned value is the distance to the nearest zero. The solution is O(mn) time and O(mn) space.”

If asked why multiple sources work:

> “Initializing all sources at distance zero is equivalent to adding a virtual super-source connected to every zero with zero-cost initialization.”

---

## 18. Pattern recognition

Think **multi-source BFS** when:

- every cell needs distance to the nearest member of a source set;
- edges have equal cost;
- influence spreads simultaneously from many starting points;
- running one search per destination would repeat work.

Common forms:

- distance to nearest zero/gate/facility;
- spread of infection or fire;
- rotting oranges;
- nearest special node in an unweighted graph.

Memory cue:

> Put every source in layer zero; let the nearest wave arrive first.

---

## 19. Edge cases

| Matrix shape/content | Expected behavior |
|---|---|
| single zero | result `[[0]]` |
| one row | distances expand left/right |
| one column | distances expand up/down |
| all zeros | all distances remain zero |
| one zero in corner | distances form Manhattan-distance gradient |
| many zeros | their waves meet at nearest boundaries |

The official problem guarantees at least one zero. Without that guarantee, decide how unreachable distance should be represented.

---

## 20. Notebook-ready notes

### 📚 Concept

**01 Matrix — multi-source BFS**

```text
All zero cells:
  distance = 0
  enqueue as sources

All other cells:
  distance = -1 (unvisited)

BFS:
  for each four-direction neighbor:
    in bounds and unvisited:
      distance = current distance + 1
      mark before enqueue
```

### 🧠 My understanding

Instead of making each one search independently for a zero, I start one shared BFS from every zero. BFS expands in distance layers, so the first wave to reach a cell comes from its nearest zero. The distance matrix also records visitation.

### 💼 Interview line

> “I’ll reverse the search direction and let all zero sources expand together.”

### ⚠️ Traps

- Enqueue all zeros initially.
- Mark neighbors when enqueued.
- Use four directions only.
- Avoid aliased JavaScript matrix rows and `queue.shift()`.

---

## 21. Dheerix Glance

```text
01 MATRIX

Model:            unweighted grid graph
Goal:             nearest distance to any zero
Technique:        multi-source BFS
Initial queue:    every zero
Initial distance: zeros=0, others=-1
Neighbor distance:current + 1
Visited timing:   mark before enqueue
Why correct:      BFS waves arrive in distance order
Time:             O(mn)
Space:            O(mn)
Memory cue:       “All sources at zero; nearest wave wins.”
```

---

## 22. Recall test

Without looking back:

1. How does the matrix become an unweighted graph?
2. Why is BFS from every `1` inefficient?
3. Why should all zeros be inserted into the queue initially?
4. Why is a cell's first assigned distance optimal?
5. Why must visitation be marked before enqueueing?
6. What dual purpose does the distance matrix serve?
7. Why is DFS not the natural shortest-distance traversal?
8. What JavaScript-specific matrix and queue traps should you avoid?
9. State the BFS invariant in one sentence.

