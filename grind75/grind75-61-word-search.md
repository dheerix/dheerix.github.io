# Grind 75 — 61. Word Search

## Problem

Given an `m × n` grid of characters and a string `word`, return `true` if the word can be formed in the grid.

The word must be constructed from letters in horizontally or vertically adjacent cells. A cell cannot be used more than once in the same word path.

Example:

```text
board = [
  ["A", "B", "C", "E"],
  ["S", "F", "C", "S"],
  ["A", "D", "E", "E"]
]

"ABCCED" → true
"SEE"    → true
"ABCB"   → false
```

---

## Core intuition

We do not know where the word begins, so every cell is a possible starting point.

Once a starting cell matches the first character, the rest of the word may continue in four directions:

```text
             up
              ↑
      left ← cell → right
              ↓
             down
```

At every step we make a temporary choice:

1. use the current cell;
2. search its neighbors for the next character;
3. restore the cell when returning.

That is grid DFS combined with backtracking.

> DFS explores a path. Backtracking restores the board so other paths can be explored independently.

---

## Why a normal graph `visited` set is different here

In many graph problems, a node is marked visited permanently because it never needs to be processed again.

Here, visitation is **path-specific**:

- a cell cannot appear twice in one candidate path;
- the same cell may be needed in a different candidate path.

Therefore, we mark before descending and unmark when returning.

```text
choose → mark
explore → recurse
undo → restore
```

---

## Brute-force shape

The unavoidable outer search tries every grid cell as a possible starting point. From each start, DFS explores possible paths matching the word.

We cannot greedily choose the first matching neighbor because it may lead to a dead end while another matching neighbor succeeds.

Example idea:

```text
current letter has two neighbors containing the required next letter
first branch → dead end
second branch → complete word
```

Backtracking preserves both possibilities.

---

## Optimal interview solution: modify and restore the board

```javascript
function exist(board, word) {
  const rows = board.length;
  const cols = board[0].length;

  function dfs(row, col, index) {
    if (index === word.length) return true;

    if (
      row < 0 ||
      row >= rows ||
      col < 0 ||
      col >= cols ||
      board[row][col] !== word[index]
    ) {
      return false;
    }

    const original = board[row][col];
    board[row][col] = "#";

    const found =
      dfs(row + 1, col, index + 1) ||
      dfs(row - 1, col, index + 1) ||
      dfs(row, col + 1, index + 1) ||
      dfs(row, col - 1, index + 1);

    board[row][col] = original;
    return found;
  }

  for (let row = 0; row < rows; row++) {
    for (let col = 0; col < cols; col++) {
      if (dfs(row, col, 0)) return true;
    }
  }

  return false;
}
```

The problem's constraints contain alphabetic board characters, so `"#"` is a safe temporary marker.

---

## Understanding the recursive state

```text
row, col = current grid location
index    = character of word that this cell must match
```

The invariant is:

> On entry to `dfs(row, col, index)`, we are asking whether `word[index...]` can be formed beginning at `board[row][col]`, without reusing a cell already chosen in the current path.

We do not need to pass the partial string. `index` already tells us how much of the word has matched.

---

## Base case order

```javascript
if (index === word.length) return true;
```

This comes before boundary checks because reaching `index === word.length` means the last required character was matched in the previous call. The word is complete; the new coordinates no longer matter.

Then reject invalid states:

```javascript
if (
  row < 0 || row >= rows ||
  col < 0 || col >= cols ||
  board[row][col] !== word[index]
) {
  return false;
}
```

This single guard handles:

- coordinates outside the board;
- a character mismatch;
- a previously used cell, because it currently contains `"#"`.

---

## The backtracking step

### Choose and mark

```javascript
const original = board[row][col];
board[row][col] = "#";
```

The marker prevents a recursive descendant from selecting this cell again.

### Explore

```javascript
const found =
  dfs(row + 1, col, index + 1) ||
  dfs(row - 1, col, index + 1) ||
  dfs(row, col + 1, index + 1) ||
  dfs(row, col - 1, index + 1);
```

JavaScript's `||` short-circuits. Once one direction returns `true`, the remaining directions are not evaluated.

### Undo

```javascript
board[row][col] = original;
```

Restoration must happen before returning both success and failure. Storing `found`, restoring, and then returning avoids an early-return bug that could leave the board corrupted.

---

## Walkthrough: finding `"ABCCED"`

```text
A B C E
S F C S
A D E E
```

Start from the top-left `A`:

| Step | Required | Chosen cell | Partial path |
|---:|:---:|:---:|:---|
| 0 | A | `(0,0)` | A |
| 1 | B | `(0,1)` | AB |
| 2 | C | `(0,2)` | ABC |
| 3 | C | `(1,2)` | ABCC |
| 4 | E | `(2,2)` | ABCCE |
| 5 | D | `(2,1)` | ABCCED |

After matching `D`, the next recursive call has `index === word.length`, so it returns `true`.

As recursion unwinds, every temporarily marked cell is restored.

---

## Why `"ABCB"` is false

```text
A → B → C
```

The apparent final `B` would require returning to the `B` cell already used earlier in that same path. Since that cell is marked, DFS rejects it.

Another starting point does not produce the full sequence, so the outer loops eventually return `false`.

---

## Correctness argument

We prove that the algorithm returns `true` exactly when the word exists.

### If the algorithm returns `true`, a valid path exists

DFS advances `index` only after the current cell equals `word[index]`. Each recursive move goes to a horizontal or vertical neighbor. Chosen cells are marked, so no cell can be reused within that path. Reaching `index === word.length` therefore represents a valid path spelling the entire word.

### If a valid path exists, the algorithm returns `true`

The outer loops try every cell, including the path's starting cell. At each matched character, DFS tries all four adjacent directions, including the direction taken by the valid path. Because that path uses no cell twice, its next cell is never blocked by the current path's markers. DFS can therefore follow the entire valid path and reach the successful base case.

Thus the result is correct.

---

## Complexity

Let:

- `R` = number of rows;
- `C` = number of columns;
- `L` = length of `word`.

There are `R × C` possible starting cells. The first step may inspect four directions, but after that we cannot immediately return to the cell we came from, so a tighter branching estimate is roughly `3` per level.

```text
time:  O(R × C × 3^L)
space: O(L) recursion depth
```

A looser but commonly accepted upper bound is `O(R × C × 4^L)`.

The in-place marker avoids an additional `O(R × C)` visited structure. Restoring the board means the caller sees the original board after the function finishes.

---

## Common mistakes

### 1. Forgetting the outer loops

The word may start anywhere, not only at `(0, 0)`.

### 2. Allowing diagonal moves

Only four directions are valid: up, down, left, and right.

### 3. Reusing a cell in the same path

Mark the current cell before exploring neighbors.

### 4. Never restoring the cell

A permanent marker incorrectly prevents later starting points and sibling paths from using that cell.

### 5. Returning before restoration

This is dangerous:

```javascript
board[row][col] = "#";
if (dfs(row + 1, col, index + 1)) return true;
```

The successful early return skips restoration. Compute `found`, restore, and then return.

### 6. Using a global permanent `visited`

Visited status belongs to the current path, not the entire search.

### 7. Building strings at every step

Passing `current + board[row][col]` creates unnecessary strings. Track the word position with `index` instead.

### 8. Checking neighbors after the word is already complete

Once `index === word.length`, return `true` immediately.

---

## Useful safe pruning

The standard solution is enough, but an interview follow-up may ask for small optimizations.

### Reject an impossible length

```javascript
if (word.length > rows * cols) return false;
```

A path cannot contain more cells than the board.

### Reject insufficient character counts

If the word contains more copies of any character than the board, it is impossible. This costs `O(R × C + L)` preprocessing.

### Start from the rarer end

If the word's last character occurs less often than its first, reverse the word and search from that end. This does not change correctness but may reduce failed starting searches.

These are optimizations, not replacements for the backtracking logic.

---

## Alternative: explicit visited set

```javascript
function existWithSet(board, word) {
  const rows = board.length;
  const cols = board[0].length;
  const visited = new Set();

  function dfs(row, col, index) {
    if (index === word.length) return true;

    const key = `${row},${col}`;

    if (
      row < 0 || row >= rows ||
      col < 0 || col >= cols ||
      visited.has(key) ||
      board[row][col] !== word[index]
    ) {
      return false;
    }

    visited.add(key);

    const found =
      dfs(row + 1, col, index + 1) ||
      dfs(row - 1, col, index + 1) ||
      dfs(row, col + 1, index + 1) ||
      dfs(row, col - 1, index + 1);

    visited.delete(key);
    return found;
  }

  for (let row = 0; row < rows; row++) {
    for (let col = 0; col < cols; col++) {
      if (dfs(row, col, 0)) return true;
    }
  }

  return false;
}
```

This makes path-specific visitation explicit but uses up to `O(L)` additional set entries and creates coordinate strings. The in-place version is usually preferred.

---

## Interview walkthrough

Say this before coding:

> Every cell could be the first letter, so I’ll try each cell as a starting point. From a matching cell, I’ll run DFS in four directions for the next character. I need path-specific visitation because a cell cannot be reused within one path but may be used by another path. I’ll temporarily replace the current character with a sentinel, explore, and restore it before returning.

State the invariant:

> `dfs(row, col, index)` asks whether the suffix beginning at `word[index]` can be formed starting from this cell without reusing any cell already selected in the current path.

Complexity statement:

> There are `R × C` possible starts. Each path has depth at most `L` and, after the first move, at most roughly three forward choices, giving `O(R × C × 3^L)` time and `O(L)` recursion space.

---

## Notebook version

```javascript
function exist(board, word) {
  const rows = board.length;
  const cols = board[0].length;

  function dfs(row, col, index) {
    if (index === word.length) return true;

    if (
      row < 0 || row >= rows ||
      col < 0 || col >= cols ||
      board[row][col] !== word[index]
    ) return false;

    const char = board[row][col];
    board[row][col] = "#";

    const found =
      dfs(row + 1, col, index + 1) ||
      dfs(row - 1, col, index + 1) ||
      dfs(row, col + 1, index + 1) ||
      dfs(row, col - 1, index + 1);

    board[row][col] = char;
    return found;
  }

  for (let row = 0; row < rows; row++) {
    for (let col = 0; col < cols; col++) {
      if (dfs(row, col, 0)) return true;
    }
  }

  return false;
}
```

### Notebook bullets

- Try every cell as a starting point.
- DFS matches one word character per recursion level.
- Mark before exploring so a path cannot reuse the cell.
- Restore after exploring so other paths remain valid.
- Store the recursive result before restoration; then return it.
- Time `O(R × C × 3^L)`; stack `O(L)`.

### Memory line

> Match, mark, move, restore.

### Pattern connection

Letter Combinations explored a pure decision tree. Word Search adds three constraints:

1. choices depend on grid position;
2. invalid branches must be rejected early;
3. mutable state must be restored for sibling paths.

The underlying backtracking skeleton remains:

```text
choose → explore → undo
```
