# Grind 75 — 41. Rotting Oranges

## Problem

You are given a grid where:

- `0` means an empty cell;
- `1` means a fresh orange;
- `2` means a rotten orange.

Every minute, each rotten orange makes its horizontally and vertically adjacent fresh oranges rotten.

Return the minimum number of minutes required until no fresh orange remains. Return `-1` if some fresh orange can never become rotten.

---

## 1. What pattern is hidden here?

The grid is an implicit graph:

- each orange is a node;
- edges connect horizontal and vertical neighbors;
- rot spreads across one edge per minute.

The question asks for the shortest time needed for a spreading process to reach all reachable targets.

That suggests **breadth-first search** because BFS explores an unweighted graph one distance layer at a time.

But there may be several rotten oranges initially. They all begin spreading at minute zero, so we must start BFS from **all of them simultaneously**.

This is **multi-source BFS**.

---

## 2. Why a normal single-source traversal is wrong

Suppose we process one rotten orange completely, then begin from another. That models the first orange spreading while the others wait, which is not how the problem works.

In reality:

```text
minute 0: all initially rotten oranges are active
minute 1: all of their fresh neighbors rot
minute 2: all newly rotten oranges spread further
```

Putting every initial rotten orange into the queue before BFS begins creates one shared wavefront and models simultaneous spread correctly.

---

## 3. Recommended JavaScript solution

```javascript
function orangesRotting(grid) {
  const rows = grid.length;
  const columns = grid[0].length;
  const queue = [];
  let head = 0;
  let freshCount = 0;

  for (let row = 0; row < rows; row++) {
    for (let column = 0; column < columns; column++) {
      if (grid[row][column] === 2) {
        queue.push([row, column]);
      } else if (grid[row][column] === 1) {
        freshCount++;
      }
    }
  }

  if (freshCount === 0) return 0;

  const directions = [
    [-1, 0],
    [1, 0],
    [0, -1],
    [0, 1]
  ];

  let minutes = 0;

  while (head < queue.length && freshCount > 0) {
    const levelSize = queue.length - head;

    for (let i = 0; i < levelSize; i++) {
      const [row, column] = queue[head++];

      for (const [rowChange, columnChange] of directions) {
        const nextRow = row + rowChange;
        const nextColumn = column + columnChange;

        const insideGrid =
          nextRow >= 0 &&
          nextRow < rows &&
          nextColumn >= 0 &&
          nextColumn < columns;

        if (insideGrid && grid[nextRow][nextColumn] === 1) {
          grid[nextRow][nextColumn] = 2;
          freshCount--;
          queue.push([nextRow, nextColumn]);
        }
      }
    }

    minutes++;
  }

  return freshCount === 0 ? minutes : -1;
}
```

---

## 4. The three pieces of state

### Queue

The queue contains oranges that are rotten and still need to spread rot to their neighbors.

All initially rotten oranges enter first.

### `freshCount`

Instead of rescanning the grid at the end, maintain the number of fresh oranges as they become rotten.

This also tells us when the BFS can stop early.

### `minutes`

One complete BFS level represents one minute of simultaneous spreading.

We increment the time only after processing the entire current level.

---

## 5. Walkthrough

Input:

```text
2 1 1
1 1 0
0 1 1
```

Initial state:

- queue: `[(0,0)]`
- fresh oranges: `6`
- minutes: `0`

### Minute 1

The orange at `(0,0)` rots `(0,1)` and `(1,0)`:

```text
2 2 1
2 1 0
0 1 1
```

Fresh count becomes `4`.

### Minute 2

The current wave rots `(0,2)` and `(1,1)`:

```text
2 2 2
2 2 0
0 1 1
```

Fresh count becomes `2`.

### Minute 3

The wave reaches `(2,1)`:

```text
2 2 2
2 2 0
0 2 1
```

Fresh count becomes `1`.

### Minute 4

The wave reaches `(2,2)`:

```text
2 2 2
2 2 0
0 2 2
```

Fresh count becomes `0`, so the answer is `4`.

---

## 6. Why BFS gives the minimum time

BFS processes cells by their shortest distance from the nearest starting source.

Because every initial rotten orange begins in the queue at distance zero:

- cells processed in the first expansion are one minute away from some source;
- cells processed in the next expansion are two minutes away;
- and so on.

Therefore, each fresh orange becomes rotten at the earliest minute any rotten source can reach it. The final BFS level is the minimum time required to reach all reachable fresh oranges.

---

## 7. Correctness reasoning

We maintain this invariant:

> At the beginning of each BFS level, the queue segment for that level contains exactly the oranges that became rotten at the previous minute and can spread during the current minute.

Initially, every rotten orange is active at minute zero.

During one level, each active orange converts every adjacent fresh orange. Those newly rotten oranges are appended behind the current level and therefore do not spread until the next level—the next minute.

Each fresh orange is marked rotten immediately when discovered, so it enters the queue only once.

When BFS ends:

- `freshCount === 0` means every fresh orange was reached, and `minutes` is the minimum elapsed time;
- `freshCount > 0` means remaining oranges are separated by empty cells or boundaries and can never be reached, so the answer is `-1`.

---

## 8. Complexity

Let the grid contain `m` rows and `n` columns.

- Time: **O(m × n)**
- Space: **O(m × n)** in the worst case for the queue

The initialization scans every cell once. Each orange enters the queue at most once, and each queued cell checks four neighbors.

---

## 9. JavaScript queue detail

Avoid this on large inputs:

```javascript
const cell = queue.shift();
```

Removing the first array element requires the remaining elements to be reindexed and can take O(n).

Use a head pointer instead:

```javascript
const cell = queue[head++];
```

This keeps dequeue operations O(1), while the consumed entries remain in the array until the function finishes.

---

## 10. Why mark an orange rotten immediately?

This line belongs at discovery time:

```javascript
grid[nextRow][nextColumn] = 2;
```

If we wait until the orange is removed from the queue, several rotten neighbors could all enqueue the same fresh orange. Immediate marking serves as the visited operation and guarantees one queue entry per orange.

---

## 11. Edge cases

### No fresh oranges

```text
2 0
0 2
```

Return `0`; no time is needed.

### Fresh oranges but no rotten source

```text
1 1
1 1
```

The queue begins empty, fresh oranges remain, and the answer is `-1`.

### Unreachable fresh orange

```text
2 1 1
0 1 1
1 0 1
```

The bottom-left orange is isolated by empty cells, so return `-1`.

### Several initial rotten oranges

All must be placed into the initial queue to create simultaneous wavefronts.

### One rotten orange and no fresh oranges

Return `0`, not `1`.

---

## 12. Common mistakes

### Mistake 1: running BFS separately from every rotten orange

This does not model simultaneous spreading and repeats work.

### Mistake 2: using DFS and counting recursion depth

DFS can reach cells, but it does not naturally guarantee the earliest arrival time when several paths and sources compete.

### Mistake 3: incrementing time per orange

One minute corresponds to an entire BFS layer, not one queue item.

### Mistake 4: starting the clock at one

Initial rotten oranges exist at minute zero. If no fresh oranges exist, the correct result is zero.

### Mistake 5: forgetting the impossible case

After BFS, check whether any fresh oranges remain.

### Mistake 6: including diagonals

Only four-directional adjacency spreads rot.

---

## 13. Alternative: store time in each queue item

Instead of explicitly processing levels, store the minute with every coordinate.

```javascript
function orangesRottingWithTimestamps(grid) {
  const rows = grid.length;
  const columns = grid[0].length;
  const queue = [];
  let head = 0;
  let freshCount = 0;
  let minutes = 0;

  for (let row = 0; row < rows; row++) {
    for (let column = 0; column < columns; column++) {
      if (grid[row][column] === 2) queue.push([row, column, 0]);
      if (grid[row][column] === 1) freshCount++;
    }
  }

  const directions = [[-1, 0], [1, 0], [0, -1], [0, 1]];

  while (head < queue.length) {
    const [row, column, time] = queue[head++];
    minutes = Math.max(minutes, time);

    for (const [rowChange, columnChange] of directions) {
      const nextRow = row + rowChange;
      const nextColumn = column + columnChange;

      const insideGrid =
        nextRow >= 0 && nextRow < rows &&
        nextColumn >= 0 && nextColumn < columns;

      if (insideGrid && grid[nextRow][nextColumn] === 1) {
        grid[nextRow][nextColumn] = 2;
        freshCount--;
        queue.push([nextRow, nextColumn, time + 1]);
      }
    }
  }

  return freshCount === 0 ? minutes : -1;
}
```

Both approaches are correct. Level-order BFS makes the “one level equals one minute” relationship especially visible.

---

## 14. Interview narration

> “This is shortest-time spreading on an unweighted grid, and every initially rotten orange spreads simultaneously. I’ll enqueue all rotten oranges first and run multi-source BFS. Each BFS level represents one minute. I’ll also count fresh oranges, decrementing the count when they become rotten, so I can return the elapsed time if it reaches zero or `-1` if BFS ends first.”

---

## 15. Pattern recognition

Use multi-source BFS when:

- several sources begin at the same time;
- influence spreads one edge per time unit;
- you need the nearest source or minimum time for all targets.

General template:

```text
enqueue every source at distance 0
             ↓
process one BFS level
             ↓
enqueue newly reached nodes for the next level
```

Related problems include walls and gates, distance to nearest zero, fire spread, infection spread, and nearest-facility calculations.

---

## 16. Quick test

```javascript
const grid = [
  [2, 1, 1],
  [1, 1, 0],
  [0, 1, 1]
];

console.log(orangesRotting(grid)); // 4
```

---

## 17. Notebook version

### Pattern

**Multi-source BFS on a grid**

### Trigger

Several sources spread simultaneously, one edge per unit of time.

### Initialization

```text
enqueue every rotten orange
count every fresh orange
```

### Core invariant

```text
one complete BFS level = one minute
```

### Final condition

```text
freshCount === 0 ? minutes : -1
```

### Memory line

> Put every source in the queue before starting the clock.

### Complexity

```text
time: O(m × n)
space: O(m × n)
```

