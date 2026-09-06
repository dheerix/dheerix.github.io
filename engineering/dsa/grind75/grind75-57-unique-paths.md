# Grind 75 — 57. Unique Paths

## Problem

A robot starts in the top-left cell of an `m × n` grid and wants to reach the bottom-right cell.

It may move only:

- right;
- down.

Return the number of distinct paths to the destination.

Example:

```text
m = 3, n = 7
answer = 28
```

---

## 1. Start from the destination cell's predecessors

How can the robot enter a cell `(row, column)`?

Only from:

```text
(row - 1, column) → from above
(row, column - 1) → from the left
```

These two groups of paths are disjoint because their final moves differ.

Therefore:

```text
paths[row][column]
  = paths[row - 1][column]
  + paths[row][column - 1]
```

This local recurrence builds the answer for the entire grid.

---

## 2. Two-dimensional DP definition

Let:

```text
dp[row][column] = number of paths from the start to this cell
```

The starting cell has one path:

```text
dp[0][0] = 1
```

Every cell in the first row has exactly one path: keep moving right.

Every cell in the first column has exactly one path: keep moving down.

All interior cells sum the counts from above and left.

---

## 3. Clear 2D JavaScript solution

```javascript
function uniquePaths2D(m, n) {
  const dp = Array.from(
    { length: m },
    () => new Array(n).fill(1)
  );

  for (let row = 1; row < m; row++) {
    for (let column = 1; column < n; column++) {
      dp[row][column] =
        dp[row - 1][column] +
        dp[row][column - 1];
    }
  }

  return dp[m - 1][n - 1];
}
```

Initializing the grid with ones handles the first row and first column automatically.

---

## 4. Space optimization insight

To calculate one row, we need only:

- the value above, currently stored at `dp[column]`;
- the value to the left, already updated at `dp[column - 1]`.

Thus one array can represent the current row.

Before update:

```text
dp[column] = paths from above
```

After update:

```text
dp[column] = above + left
```

---

## 5. Recommended JavaScript solution: 1D DP

```javascript
function uniquePaths(m, n) {
  const columns = Math.min(m, n);
  const rows = Math.max(m, n);
  const dp = new Array(columns).fill(1);

  for (let row = 1; row < rows; row++) {
    for (let column = 1; column < columns; column++) {
      dp[column] += dp[column - 1];
    }
  }

  return dp[columns - 1];
}
```

Using the smaller grid dimension as the DP-array length reduces space to:

```text
O(min(m, n))
```

The grid is symmetric: swapping its dimensions does not change the number of right/down path sequences.

---

## 6. Why initialize the array with ones?

At the beginning, the 1D array represents the first row:

```text
[1, 1, 1, ..., 1]
```

There is exactly one way to reach every cell in that row—move right repeatedly.

When processing subsequent rows, `dp[0]` remains `1`, correctly representing the first column.

---

## 7. Walkthrough: 3 × 4 grid

Start with the first row:

```text
[1, 1, 1, 1]
```

### Process second row

```text
column 1: 1 above + 1 left = 2
column 2: 1 above + 2 left = 3
column 3: 1 above + 3 left = 4
```

```text
[1, 2, 3, 4]
```

### Process third row

```text
column 1: 2 above + 1 left = 3
column 2: 3 above + 3 left = 6
column 3: 4 above + 6 left = 10
```

```text
[1, 3, 6, 10]
```

The final cell contains `10` unique paths.

---

## 8. Why update left to right?

The transition needs:

```text
old dp[column]     → above
new dp[column - 1] → left
```

Left-to-right iteration guarantees `dp[column - 1]` already represents the current row, while `dp[column]` still represents the previous row.

Updating in the opposite direction would combine the wrong states.

This is the same broader lesson seen in knapsack DP: loop direction encodes which version of a state—old or newly updated—you intend to use.

---

## 9. Correctness reasoning

We maintain this invariant during the 1D algorithm:

> After processing a cell at `column`, `dp[column]` equals the number of paths to that cell in the current row. Unprocessed positions still contain counts from the previous row.

### Base row

Each entry starts as `1`, which is correct because the top row is reachable only by moving right.

### First column

`dp[0]` stays `1`, which is correct because each first-column cell is reachable only by moving down.

### Interior transition

Before updating `dp[column]`:

- it contains the path count from above;
- `dp[column - 1]` contains the path count from the left.

Every path to the current cell ends with exactly one of these two moves, so their sum is precisely the number of unique paths to the cell.

After all cells are processed, the last DP entry represents the bottom-right destination.

---

## 10. Complexity

For the straightforward 2D solution:

- Time: O(m × n)
- Space: O(m × n)

For the optimized solution:

- Time: **O(m × n)**
- Auxiliary space: **O(min(m, n))**

---

## 11. Top-down memoization alternative

A recursive formulation asks for the number of paths from one cell to the destination.

```javascript
function uniquePathsTopDown(m, n) {
  const memo = new Map();

  function count(row, column) {
    if (row === m - 1 && column === n - 1) {
      return 1;
    }

    if (row >= m || column >= n) {
      return 0;
    }

    const key = `${row},${column}`;
    if (memo.has(key)) return memo.get(key);

    const paths =
      count(row + 1, column) +
      count(row, column + 1);

    memo.set(key, paths);
    return paths;
  }

  return count(0, 0);
}
```

Memoization reduces repeated recursion to O(m × n) states. Bottom-up DP avoids recursion-depth and function-call overhead.

---

## 12. Combinatorics alternative

Every valid path makes exactly:

```text
m - 1 downward moves
n - 1 rightward moves
```

Total moves:

```text
m + n - 2
```

Choose which positions contain the downward moves:

```text
C(m + n - 2, m - 1)
```

or equivalently choose the rightward moves.

```javascript
function uniquePathsCombinatorics(m, n) {
  const totalMoves = m + n - 2;
  const chosenMoves = Math.min(m - 1, n - 1);
  let result = 1;

  for (let i = 1; i <= chosenMoves; i++) {
    result =
      result * (totalMoves - chosenMoves + i) / i;
  }

  return Math.round(result);
}
```

This runs in O(min(m,n)) time and O(1) space.

For larger dimensions outside the problem constraints, floating-point precision and integer range must be considered. `BigInt` can support exact larger values with an adapted formula.

---

## 13. Why plain recursion is inefficient

Without memoization:

```text
count(row, column)
  = count(down) + count(right)
```

recomputes the same cells through many different paths. Its recursion tree grows exponentially even though there are only `m × n` distinct cell states.

Dynamic programming collapses repeated subproblems into one calculation per cell.

---

## 14. Common mistakes

### Mistake 1: initialize DP with zeros

Without seeding the starting boundary, no path counts can propagate.

### Mistake 2: add from below or right

With top-left-to-bottom-right iteration, predecessor states are above and left.

### Mistake 3: update the 1D array right to left

The left state would still belong to the previous row instead of the current row.

### Mistake 4: use DFS without memoization

This repeats subproblems exponentially.

### Mistake 5: confuse cells with moves

An `m × n` path uses `m - 1` down moves and `n - 1` right moves, not `m` and `n`.

### Mistake 6: allocate O(mn) space without noticing compression

Only the previous row is needed, and it can be updated in place.

---

## 15. Edge cases

- `1 × 1` grid → `1`
- one row → `1`
- one column → `1`
- square grid
- very wide grid
- very tall grid

With only one row or column, there is exactly one possible path.

---

## 16. Interview narration

> “Every cell can be reached only from above or from the left, so its path count is the sum of those two predecessor counts. I’ll use a one-dimensional DP array initialized to ones for the first row. As I scan each later row left to right, `dp[column]` still contains the count from above and `dp[column - 1]` contains the updated count from the left. I can use the smaller dimension for O(min(m,n)) space.”

---

## 17. Pattern recognition

Use grid DP when:

- movement is limited to directions that form an acyclic dependency order;
- each cell's result depends on nearby predecessor cells;
- the problem asks for path count, minimum cost, maximum reward, or reachability.

General transition:

```text
state at cell = combine(states from permitted predecessors)
```

Examples include:

- Unique Paths with Obstacles;
- Minimum Path Sum;
- maximal squares;
- counting grid routes;
- sequence alignment tables.

---

## 18. Quick test

```javascript
console.log(uniquePaths(3, 7)); // 28
console.log(uniquePaths(3, 2)); // 3
console.log(uniquePaths(1, 1)); // 1
console.log(uniquePaths(1, 8)); // 1
console.log(uniquePaths(8, 1)); // 1
```

---

## 19. Notebook version

### Pattern

**Grid DP compressed to one row**

### State

```text
dp[column] = paths to current cell
```

### Transition

```javascript
dp[column] += dp[column - 1];
```

Before update, `dp[column]` is above. After updating left to right, `dp[column - 1]` is left.

### Memory line

> Paths into a cell come from above plus left; one row remembers both.

### Complexity

```text
time: O(m × n)
space: O(min(m, n))
```

