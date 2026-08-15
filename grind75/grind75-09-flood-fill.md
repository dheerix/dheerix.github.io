# Grind 75 — 09: Flood Fill

**Difficulty:** Easy  
**Primary pattern:** Grid traversal / DFS / connected component  
**LeetCode:** https://leetcode.com/problems/flood-fill/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

You are given a 2D image represented by an integer matrix. Starting from cell `(sr, sc)`, change the color of:

- the starting cell;
- every cell connected to it through up, down, left, or right moves;
- only while those cells have the starting cell's original color.

Diagonal cells are not directly connected.

```text
image = [
  [1, 1, 1],
  [1, 1, 0],
  [1, 0, 1]
]

start = (1, 1)
new color = 2

result = [
  [2, 2, 2],
  [2, 2, 0],
  [2, 0, 1]
]
```

The bottom-right `1` remains unchanged because it is connected only diagonally to the filled region.

---

## 2. Reframe the grid as a graph

Treat:

```text
each cell          → graph node
up/down/left/right → graph edges
same original color→ eligible nodes
```

The task becomes:

> Starting at one node, visit its entire eligible connected component and recolor every visited node.

That is a standard graph traversal. Either depth-first search (DFS) or breadth-first search (BFS) works.

---

## 3. What defines membership in the component?

Save the color at the starting position:

```javascript
const originalColor = image[sr][sc];
```

A cell belongs to the fill only if:

1. its row is inside the image;
2. its column is inside the image;
3. its current value equals `originalColor`;
4. it is reachable from the starting cell through eligible neighbors.

It is not enough to recolor every occurrence of `originalColor` in the matrix. Disconnected regions must remain unchanged.

---

## 4. The crucial edge case: same old and new color

Suppose:

```text
originalColor === color
```

If recoloring is also being used to mark cells as visited, recoloring makes no visible change. A neighboring call sees the same color and returns to the previous cell indefinitely.

Therefore:

```javascript
if (originalColor === color) return image;
```

This is both an optimization and, for this in-place visitation technique, a correctness requirement that prevents infinite recursion or repeated queue insertion.

---

## 5. In-place visitation

We could keep a separate `visited` set. But when `originalColor !== color`, changing a cell to the new color also marks it as processed:

```text
original color → unvisited and eligible
new color      → already visited or originally ineligible
```

This reuses the output matrix as traversal state and avoids O(mn) extra visited storage.

Important ordering:

> Recolor the cell before visiting its neighbors.

Otherwise a neighbor can immediately recurse back into the current cell while it still appears unvisited.

---

## 6. Step-by-step DFS algorithm

1. Store `originalColor = image[sr][sc]`.
2. If it already equals the new color, return immediately.
3. Define `fill(row, column)`:
   - stop if the coordinates are outside the grid;
   - stop if the cell does not have `originalColor`;
   - recolor the cell, marking it visited;
   - recursively visit its four neighbors.
4. Call `fill(sr, sc)`.
5. Return the mutated image.

---

## 7. Optimal recursive DFS solution

```javascript
function floodFill(image, sr, sc, color) {
  const rows = image.length;
  const columns = image[0].length;
  const originalColor = image[sr][sc];

  if (originalColor === color) {
    return image;
  }

  function fill(row, column) {
    const isOutsideImage =
      row < 0 ||
      row >= rows ||
      column < 0 ||
      column >= columns;

    if (isOutsideImage || image[row][column] !== originalColor) {
      return;
    }

    // Recolor first so this cell also acts as visited.
    image[row][column] = color;

    fill(row - 1, column); // up
    fill(row + 1, column); // down
    fill(row, column - 1); // left
    fill(row, column + 1); // right
  }

  fill(sr, sc);
  return image;
}
```

---

## 8. Code walkthrough

### `rows` and `columns`

Grid boundaries are:

```text
0 ≤ row < rows
0 ≤ column < columns
```

The official constraints guarantee a non-empty rectangular image. In production code, an empty matrix would need a guard before reading `image[0]`.

### Save `originalColor` before mutation

Once the starting cell is recolored, reading it again would lose the criterion that decides which neighboring cells belong to the original component.

### Bounds check before matrix access

JavaScript short-circuit evaluation ensures that when `isOutsideImage` is true, the second side of:

```javascript
isOutsideImage || image[row][column] !== originalColor
```

is not evaluated. This prevents invalid indexing from being used as though it were a real cell.

### Recolor before recursive calls

The new color is the visited marker. By changing the current cell first, calls from adjacent cells will not process it again.

### Four recursive calls

Only orthogonal adjacency is permitted. Adding diagonal directions would solve a different connectivity definition.

---

## 9. Dry run

```text
image = [
  [1, 1, 0],
  [1, 1, 0],
  [0, 0, 1]
]

start = (0, 0), color = 2
```

```text
Visit (0,0): recolor to 2
  Visit (-1,0): outside → stop
  Visit (1,0): recolor to 2
    Visit (1,1): recolor to 2
      Visit (0,1): recolor to 2
      Other paths reach 0, boundary, or already-colored 2 → stop
```

Result:

```text
[
  [2, 2, 0],
  [2, 2, 0],
  [0, 0, 1]
]
```

The `1` at `(2,2)` is disconnected and therefore unchanged.

---

## 10. Correctness reasoning

We must show both that every recolored cell should be recolored and every eligible cell is eventually recolored.

### Safety

The function recolors a cell only after verifying that it is inside the grid and has `originalColor`. It reaches cells only through a chain of orthogonal neighbor calls starting at `(sr, sc)`. Therefore, every recolored cell belongs to the starting cell's eligible connected component.

### Completeness

Consider any cell in that component. By definition, there is an orthogonal path of original-colored cells from the start to it. DFS explores all four directions from every processed cell, so it follows that path. Recoloring prevents repeated work but does not block an unvisited original-colored neighbor. Therefore, every eligible connected cell is eventually recolored.

---

## 11. Complexity

Let `m` be the number of rows and `n` the number of columns.

- **Time: O(mn)** worst case — every cell may belong to the connected component and be processed once.
- **Auxiliary space: O(mn)** worst case for the recursive call stack.

Although no separate visited set is used, recursion still consumes space. A long snake-shaped component can produce O(mn) recursion depth.

If only `k` cells belong to the filled component, a tighter description is O(k) time and O(k) worst-case traversal space, with `k ≤ mn`.

---

## 12. Iterative BFS solution

```javascript
function floodFillBfs(image, sr, sc, color) {
  const rows = image.length;
  const columns = image[0].length;
  const originalColor = image[sr][sc];

  if (originalColor === color) return image;

  const directions = [
    [-1, 0],
    [1, 0],
    [0, -1],
    [0, 1],
  ];

  const queue = [[sr, sc]];
  let front = 0;
  image[sr][sc] = color;

  while (front < queue.length) {
    const [row, column] = queue[front++];

    for (const [rowChange, columnChange] of directions) {
      const nextRow = row + rowChange;
      const nextColumn = column + columnChange;

      const isInsideImage =
        nextRow >= 0 &&
        nextRow < rows &&
        nextColumn >= 0 &&
        nextColumn < columns;

      if (
        isInsideImage &&
        image[nextRow][nextColumn] === originalColor
      ) {
        // Mark when enqueuing, not when dequeuing, to avoid duplicates.
        image[nextRow][nextColumn] = color;
        queue.push([nextRow, nextColumn]);
      }
    }
  }

  return image;
}
```

Why mark when enqueuing? Two neighboring cells might discover the same unvisited cell before it is dequeued. Marking immediately guarantees it enters the queue only once.

The queue uses a `front` index rather than repeated `shift()` calls.

---

## 13. DFS versus BFS

| Property | DFS | BFS |
|---|---|---|
| Traversal order | Deep path first | Layer by layer |
| Main structure | Recursion/stack | Queue |
| Correct for flood fill | Yes | Yes |
| Worst-case extra space | O(mn) | O(mn) |
| JavaScript concern | Deep recursion can overflow stack | Explicit queue avoids recursion depth |

Flood fill does not require shortest paths, so either traversal is valid. Recursive DFS is the most concise explanation; iterative BFS is safer for very large connected regions in JavaScript.

---

## 14. Common mistakes

1. **Recoloring every cell with the same value.** Only the connected component from the start should change.
2. **Including diagonal neighbors.** The problem defines four-directional adjacency.
3. **Forgetting the `originalColor === color` guard.** In-place color marking would fail to distinguish visited cells.
4. **Marking after recursion/enqueue.** Cycles can cause repeated processing or infinite recursion.
5. **Reading outside the matrix before checking bounds.** Validate coordinates first.
6. **Losing the original color after mutating the starting cell.** Save it before traversal.
7. **Claiming O(1) space because no visited set exists.** DFS uses call-stack space; BFS uses queue space.
8. **Using `queue.shift()` repeatedly.** Prefer a moving front index in JavaScript.
9. **Confusing row and column boundaries.** Rows compare with `image.length`; columns compare with `image[0].length`.

---

## 15. What to say in an interview

> “I’ll treat the matrix as a graph where each cell connects to its four orthogonal neighbors. Starting from `(sr, sc)`, DFS visits only cells with the original starting color. I’ll recolor a cell before exploring its neighbors, so the new color doubles as the visited marker. If the original and new colors are equal, I return immediately. The traversal is O(mn) time and O(mn) worst-case stack space.”

If asked why no visited set is needed:

> “Because old and new colors differ, recoloring a cell permanently distinguishes it from unvisited eligible cells.”

---

## 16. Pattern recognition

Think **grid traversal** when:

- cells are connected through specified directions;
- a region/component must be explored;
- the problem says contiguous, adjacent, island, region, or connected;
- an action spreads from a starting location.

Translate grid language into graph language:

```text
cell      → node
direction → edge
boundary  → invalid neighbor
visited   → traversal state
region    → connected component
```

Memory cue:

> Define eligibility, mark immediately, explore every allowed direction.

---

## 17. Edge cases

| Situation | Expected behavior |
|---|---|
| One-cell image | Recolor that cell unless color is unchanged |
| New color equals original | Return immediately |
| Starting cell isolated | Recolor only the start |
| Same color appears diagonally | Do not cross diagonal-only connection |
| Same color appears in disconnected region | Leave that region unchanged |
| Entire image has one color | Recolor every cell |

---

## 18. Notebook-ready notes

### 📚 Concept

**Flood Fill — grid DFS / connected component**

```text
Save original starting color
If original === new → return
DFS(cell):
  invalid boundary or wrong color → stop
  recolor now (marks visited)
  explore up, down, left, right
```

### 🧠 My understanding

The image is a graph. The answer is not every matching color; it is the matching-color component reachable from the start. Recoloring before exploring prevents cycles and replaces a separate visited set.

### 💼 Interview line

> “I’ll traverse the starting color's connected component and use the new color as the visited marker.”

### ⚠️ Traps

- Guard when old color equals new color.
- Mark before visiting neighbors.
- Use four directions only.
- Recursion space is not O(1).

---

## 19. Dheerix Glance

```text
FLOOD FILL

Model:            grid as graph
Start:            (sr, sc)
Eligibility:      cell color === originalColor
Edges:            up/down/left/right
Visited marker:   replace with new color
Critical guard:   originalColor === newColor → return
Mark timing:      before exploring neighbors
Time:             O(mn) worst case
Traversal space:  O(mn) worst case
Memory cue:       “Mark, then spread through eligible neighbors.”
```

---

## 20. Recall test

Without looking back:

1. How does a grid become a graph?
2. Why do disconnected cells of the same color remain unchanged?
3. Why must the original color be saved before traversal?
4. Why is the same-color guard necessary?
5. Why should a cell be marked before exploring its neighbors?
6. Why is recursive space O(mn) in the worst case?
7. When might iterative BFS be safer in JavaScript?
8. State the DFS eligibility condition in one sentence.

