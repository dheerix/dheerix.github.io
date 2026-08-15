# Grind 75 — 53. Spiral Matrix

## Problem

Given an `m × n` matrix, return all elements in clockwise spiral order.

Example:

```text
matrix:
1 2 3
4 5 6
7 8 9

spiral: [1, 2, 3, 6, 9, 8, 7, 4, 5]
```

---

## 1. Think in layers, not turns

A spiral repeatedly consumes the outer rectangle:

```text
left → right across the top
top → bottom down the right
right → left across the bottom
bottom → top up the left
```

After completing one ring, shrink the rectangle inward and repeat.

Instead of tracking direction changes cell by cell, track the four boundaries of the unvisited rectangle:

```text
top, bottom, left, right
```

---

## 2. Boundary meanings

At every iteration:

```text
top    = first unvisited row
bottom = last unvisited row
left   = first unvisited column
right  = last unvisited column
```

The remaining unvisited area is:

```text
rows    [top, bottom]
columns [left, right]
```

After traversing an edge, move its boundary inward because that edge is finished.

---

## 3. Recommended JavaScript solution

```javascript
function spiralOrder(matrix) {
  if (matrix.length === 0 || matrix[0].length === 0) {
    return [];
  }

  const result = [];
  let top = 0;
  let bottom = matrix.length - 1;
  let left = 0;
  let right = matrix[0].length - 1;

  while (top <= bottom && left <= right) {
    for (let column = left; column <= right; column++) {
      result.push(matrix[top][column]);
    }
    top++;

    for (let row = top; row <= bottom; row++) {
      result.push(matrix[row][right]);
    }
    right--;

    if (top <= bottom) {
      for (let column = right; column >= left; column--) {
        result.push(matrix[bottom][column]);
      }
      bottom--;
    }

    if (left <= right) {
      for (let row = bottom; row >= top; row--) {
        result.push(matrix[row][left]);
      }
      left++;
    }
  }

  return result;
}
```

---

## 4. Why the two guard checks are necessary

After traversing the top and right edges, the boundaries may cross.

This happens in matrices with one remaining row or one remaining column.

Before traversing the bottom edge, confirm:

```javascript
if (top <= bottom) {
  // Traverse the remaining bottom row.
}
```

Before traversing the left edge, confirm:

```javascript
if (left <= right) {
  // Traverse the remaining left column.
}
```

Without these checks, already-visited cells can be appended again.

---

## 5. Walkthrough: 3 × 3 matrix

```text
1 2 3
4 5 6
7 8 9
```

Initial boundaries:

```text
top = 0, bottom = 2, left = 0, right = 2
```

### Outer layer

Top edge:

```text
1, 2, 3
top becomes 1
```

Right edge:

```text
6, 9
right becomes 1
```

Bottom edge:

```text
8, 7
bottom becomes 1
```

Left edge:

```text
4
left becomes 1
```

### Inner layer

Only cell `5` remains. The top traversal adds it, then the boundaries cross and the guards prevent any duplicate traversal.

Final output:

```text
[1,2,3,6,9,8,7,4,5]
```

---

## 6. Walkthrough: rectangular matrix

```text
1  2  3  4
5  6  7  8
9 10 11 12
```

Outer ring:

```text
top:    1, 2, 3, 4
right:  8, 12
bottom: 11, 10, 9
left:   5
```

Remaining rectangle:

```text
6 7
```

Final result:

```text
[1,2,3,4,8,12,11,10,9,5,6,7]
```

The boundary method works for any rectangular dimensions, not only square matrices.

---

## 7. Single-row case

```text
[1, 2, 3, 4]
```

The top traversal adds all values, then `top > bottom`.

The right traversal has no rows to process. The bottom guard fails, preventing the row from being traversed backward and duplicated.

Result:

```text
[1,2,3,4]
```

---

## 8. Single-column case

```text
1
2
3
4
```

The top traversal adds `1`. The right traversal adds `2,3,4`, then `right < left`.

The left-edge guard fails, preventing the same column from being traversed upward again.

Result:

```text
[1,2,3,4]
```

---

## 9. Correctness reasoning

We maintain this invariant:

> Before each loop iteration, every cell outside `[top...bottom] × [left...right]` has been visited exactly once, and every cell inside it remains unvisited.

During one iteration:

1. the top edge is visited and `top` moves down;
2. the right edge of the remaining rectangle is visited and `right` moves left;
3. if a row remains, the bottom edge is visited and `bottom` moves up;
4. if a column remains, the left edge is visited and `left` moves right.

The guards ensure an edge is traversed only if it still belongs to the unvisited rectangle. Thus no cell is duplicated or skipped.

Every iteration removes at least one row or column from the unvisited area. Eventually the boundaries cross, at which point every matrix cell has been visited exactly once in clockwise spiral order.

---

## 10. Complexity

Let the matrix contain `m` rows and `n` columns.

- Time: **O(m × n)**
- Auxiliary space: **O(1)**, excluding the required result
- Output space: **O(m × n)**

Every cell is appended exactly once. Boundary variables use constant space.

---

## 11. Alternative: direction simulation with visited cells

Another approach moves one cell at a time and turns when it reaches a boundary or visited cell.

```javascript
function spiralOrderSimulation(matrix) {
  if (matrix.length === 0 || matrix[0].length === 0) return [];

  const rows = matrix.length;
  const columns = matrix[0].length;
  const visited = Array.from(
    { length: rows },
    () => new Array(columns).fill(false)
  );

  const directions = [
    [0, 1],
    [1, 0],
    [0, -1],
    [-1, 0]
  ];

  const result = [];
  let row = 0;
  let column = 0;
  let direction = 0;

  for (let count = 0; count < rows * columns; count++) {
    result.push(matrix[row][column]);
    visited[row][column] = true;

    let nextRow = row + directions[direction][0];
    let nextColumn = column + directions[direction][1];

    const blocked =
      nextRow < 0 ||
      nextRow >= rows ||
      nextColumn < 0 ||
      nextColumn >= columns ||
      visited[nextRow][nextColumn];

    if (blocked) {
      direction = (direction + 1) % 4;
      nextRow = row + directions[direction][0];
      nextColumn = column + directions[direction][1];
    }

    row = nextRow;
    column = nextColumn;
  }

  return result;
}
```

This is correct but uses O(m × n) visited space and more state. The boundary solution directly models the shrinking geometry and is usually preferable.

---

## 12. Alternative loop using result length

Some implementations perform all four directions unconditionally and stop adding once the result contains every cell. That can work, but boundary guards express the geometric validity more clearly and avoid touching duplicate positions.

Prefer proving each edge is still unvisited rather than appending conditionally after reaching the expected output length.

---

## 13. Common mistakes

### Mistake 1: omit the bottom-row guard

A single remaining row gets added twice.

### Mistake 2: omit the left-column guard

A single remaining column gets added twice.

### Mistake 3: update a boundary before traversing its edge

Traverse the current edge first, then move the boundary inward.

### Mistake 4: use `<` instead of `<=` in traversal loops

Endpoints are part of the current boundary and must be included.

### Mistake 5: assume the matrix is square

Rows and columns have independent bounds.

### Mistake 6: use one loop condition only for rows

Both dimensions must remain valid:

```javascript
while (top <= bottom && left <= right) {
  // Process one layer.
}
```

### Mistake 7: confuse row and column indices

Access cells as `matrix[row][column]` consistently.

---

## 14. Edge cases

- empty matrix
- matrix containing an empty row
- one cell
- one row
- one column
- two rows
- two columns
- rectangular matrix wider than tall
- rectangular matrix taller than wide

These cases are exactly why boundary crossing must be checked mid-layer.

---

## 15. Interview narration

> “I’ll maintain four boundaries around the unvisited rectangle. For each layer, I traverse the top row left to right, the right column top to bottom, then—if the boundaries still describe a row—the bottom right to left, and—if a column remains—the left bottom to top. After each edge I move its boundary inward. Every cell is appended once, so the runtime is O(mn).”

---

## 16. Pattern recognition

Use shrinking boundaries for matrix problems involving:

- spiral traversal;
- spiral generation;
- rotating or processing outer rings;
- layer-by-layer matrix operations;
- perimeter stripping.

General pattern:

```text
process current perimeter
          ↓
shrink its four boundaries
          ↓
repeat on the inner rectangle
```

---

## 17. Quick test

```javascript
console.log(spiralOrder([
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9]
]));
// [1,2,3,6,9,8,7,4,5]

console.log(spiralOrder([[1, 2, 3, 4]]));
// [1,2,3,4]

console.log(spiralOrder([[1], [2], [3], [4]]));
// [1,2,3,4]
```

---

## 18. Notebook version

### Pattern

**Four shrinking matrix boundaries**

### Boundaries

```text
top, bottom, left, right
```

### Direction order

```text
top → right → bottom → left
```

### Critical guards

```text
before bottom: top <= bottom
before left:   left <= right
```

### Memory line

> Peel one rectangular ring, confirm what remains, then move inward.

### Complexity

```text
time: O(m × n)
auxiliary space: O(1)
```

