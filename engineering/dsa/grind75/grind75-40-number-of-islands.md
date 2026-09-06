# Grind 75 — 40. Number of Islands

## Problem

Given an `m × n` grid containing:

- `'1'` for land
- `'0'` for water

return the number of islands.

An island is a group of horizontally or vertically connected land cells. Diagonal cells are **not** connected.

---

## 1. Intuition: the grid is a graph

Treat every land cell as a graph node. Two land cells have an edge when they touch in one of four directions:

```text
        up
         ↑
left ← cell → right
         ↓
       down
```

Each island is therefore one **connected component** of this implicit graph.

The task becomes:

> Count the connected components made of land.

We do not need to construct an adjacency list. A cell's row and column already let us calculate its neighbors.

---

## 2. Core strategy

Scan every cell in the grid.

When an unvisited land cell is found:

1. increment the island count;
2. run DFS or BFS from that cell;
3. mark every connected land cell as visited.

Why increment only once?

The first discovered cell represents a new island. The flood fill consumes the entire island, so none of its remaining cells can start another count later.

---

## 3. Recommended JavaScript solution: DFS flood fill

This version marks a visited land cell by changing it from `'1'` to `'0'`.

```javascript
function numIslands(grid) {
  if (grid.length === 0) return 0;

  const rows = grid.length;
  const columns = grid[0].length;
  let islandCount = 0;

  function sinkIsland(row, column) {
    const outsideGrid =
      row < 0 ||
      row >= rows ||
      column < 0 ||
      column >= columns;

    if (outsideGrid || grid[row][column] !== '1') {
      return;
    }

    grid[row][column] = '0';

    sinkIsland(row - 1, column); // up
    sinkIsland(row + 1, column); // down
    sinkIsland(row, column - 1); // left
    sinkIsland(row, column + 1); // right
  }

  for (let row = 0; row < rows; row++) {
    for (let column = 0; column < columns; column++) {
      if (grid[row][column] === '1') {
        islandCount++;
        sinkIsland(row, column);
      }
    }
  }

  return islandCount;
}
```

The name `sinkIsland` expresses the mutation clearly: after discovering an island, the DFS converts all of its land to water.

---

## 4. Walkthrough

Input:

```text
1 1 0 0 0
1 1 0 0 0
0 0 1 0 0
0 0 0 1 1
```

### First discovery

The scan reaches `(0, 0)`:

- it is land;
- count becomes `1`;
- DFS sinks `(0,0)`, `(0,1)`, `(1,0)`, and `(1,1)`.

Grid afterward:

```text
0 0 0 0 0
0 0 0 0 0
0 0 1 0 0
0 0 0 1 1
```

### Second discovery

The scan reaches `(2, 2)`:

- it is still land;
- count becomes `2`;
- DFS sinks that one-cell island.

### Third discovery

The scan reaches `(3, 3)`:

- count becomes `3`;
- DFS also reaches `(3, 4)` and sinks both.

Final answer: `3`.

Notice that `(2,2)` and `(3,3)` touch only diagonally, so they belong to different islands.

---

## 5. Why marking visited is essential

Without a visited marker, DFS can move back and forth forever:

```text
A visits B → B visits A → A visits B → ...
```

Mark the cell **before** exploring its neighbors:

```javascript
grid[row][column] = '0';
```

This ensures each cell is processed at most once.

---

## 6. Correctness reasoning

We rely on two facts.

### Every real island is counted

Consider any island. During the full grid scan, eventually the scan reaches one of its cells. If the island has not already been visited, that cell is still `'1'`, so the algorithm increments the count.

### No island is counted more than once

After the first cell of an island is discovered, flood fill reaches every land cell connected to it and marks each as visited. Later, the outer scan sees those cells as `'0'`, so it cannot count the same island again.

Therefore, the count is exactly the number of islands.

---

## 7. Complexity

Let:

- `m` = number of rows
- `n` = number of columns

Each cell is scanned once and processed by DFS at most once.

- Time: **O(m × n)**
- Recursive stack space: **O(m × n)** in the worst case
- Separate visited structure: **O(1)** because the grid itself is mutated

The worst recursion depth occurs when one island contains most or all cells.

---

## 8. Important JavaScript concern: recursion depth

JavaScript engines have a limited call stack. A very large connected island can cause a stack-overflow error even though the algorithm is theoretically correct.

For production-sized or adversarial grids, an iterative DFS is safer.

```javascript
function numIslandsIterative(grid) {
  if (grid.length === 0) return 0;

  const rows = grid.length;
  const columns = grid[0].length;
  const directions = [
    [-1, 0],
    [1, 0],
    [0, -1],
    [0, 1]
  ];

  let islandCount = 0;

  for (let row = 0; row < rows; row++) {
    for (let column = 0; column < columns; column++) {
      if (grid[row][column] !== '1') continue;

      islandCount++;
      grid[row][column] = '0';

      const stack = [[row, column]];

      while (stack.length > 0) {
        const [currentRow, currentColumn] = stack.pop();

        for (const [rowChange, columnChange] of directions) {
          const nextRow = currentRow + rowChange;
          const nextColumn = currentColumn + columnChange;

          const insideGrid =
            nextRow >= 0 &&
            nextRow < rows &&
            nextColumn >= 0 &&
            nextColumn < columns;

          if (insideGrid && grid[nextRow][nextColumn] === '1') {
            grid[nextRow][nextColumn] = '0';
            stack.push([nextRow, nextColumn]);
          }
        }
      }
    }
  }

  return islandCount;
}
```

Mark a cell when adding it to the stack, not when removing it. Otherwise, several neighbors may add the same cell repeatedly.

---

## 9. Non-mutating version

If the caller expects the input grid to remain unchanged, maintain a separate visited set.

```javascript
function numIslandsWithoutMutation(grid) {
  if (grid.length === 0) return 0;

  const rows = grid.length;
  const columns = grid[0].length;
  const visited = new Set();
  let islandCount = 0;

  const key = (row, column) => `${row},${column}`;

  function visit(row, column) {
    const outsideGrid =
      row < 0 || row >= rows || column < 0 || column >= columns;

    if (outsideGrid || grid[row][column] !== '1') return;

    const cellKey = key(row, column);
    if (visited.has(cellKey)) return;

    visited.add(cellKey);

    visit(row - 1, column);
    visit(row + 1, column);
    visit(row, column - 1);
    visit(row, column + 1);
  }

  for (let row = 0; row < rows; row++) {
    for (let column = 0; column < columns; column++) {
      if (grid[row][column] === '1' && !visited.has(key(row, column))) {
        islandCount++;
        visit(row, column);
      }
    }
  }

  return islandCount;
}
```

This preserves the input but requires O(m × n) additional space in the worst case.

---

## 10. DFS versus BFS

Both traverse one connected component completely.

| DFS | BFS |
| --- | --- |
| Uses recursion or an explicit stack | Uses a queue |
| Often shortest to write recursively | Avoids recursive call-stack limits |
| Natural for component discovery | Useful when distance or levels matter |

For counting islands, neither is asymptotically faster. Choose the traversal you can implement clearly and safely.

In JavaScript BFS, avoid repeated `queue.shift()` on large inputs because removing the first array item is O(n). Use a head index instead.

---

## 11. Common mistakes

### Mistake 1: counting every land cell

Count only when discovering a new component, then consume that entire component.

### Mistake 2: including diagonal neighbors

The problem defines connectivity through four directions only.

### Mistake 3: forgetting boundary checks

Check coordinates before reading `grid[row][column]`.

### Mistake 4: marking visited too late

Mark before recursive calls or immediately when adding a cell to a worklist.

### Mistake 5: comparing with the number `1`

LeetCode supplies character values:

```javascript
grid[row][column] === '1'
```

### Mistake 6: mutating without acknowledging it

Mutation is convenient and accepted for this problem, but in production code confirm whether the input must be preserved.

---

## 12. Interview narration

> “I’ll treat the grid as an implicit graph where land cells are nodes connected in four directions. During a full scan, every unvisited land cell begins a new connected component, so I increment the answer and flood-fill the entire island. Because each cell is visited at most once, the runtime is O(mn).”

If discussing mutation:

> “I’m reusing the grid as the visited structure by turning visited land into water. If input preservation is required, I’ll use a separate set or boolean matrix.”

---

## 13. Pattern recognition

This is the standard **grid connected-components** pattern:

```text
scan all cells
    ↓
find unvisited target cell
    ↓
count one component
    ↓
DFS/BFS to mark the whole component
```

Related problems include:

- Flood Fill
- Max Area of Island
- Surrounded Regions
- Pacific Atlantic Water Flow
- Rotting Oranges, with multi-source BFS

---

## 14. Quick test

```javascript
const grid = [
  ['1', '1', '0', '0', '0'],
  ['1', '1', '0', '0', '0'],
  ['0', '0', '1', '0', '0'],
  ['0', '0', '0', '1', '1']
];

console.log(numIslands(grid)); // 3
```

---

## 15. Notebook version

### Pattern

**Grid traversal + connected components + flood fill**

### Trigger

Count separated groups of cells connected by allowed directions.

### Core move

```text
When an unvisited land cell is found:
count++ → DFS/BFS → mark the entire island visited
```

### Memory line

> Count the first cell; consume the whole island.

### Complexity

```text
time: O(m × n)
space: O(m × n) worst case
```

