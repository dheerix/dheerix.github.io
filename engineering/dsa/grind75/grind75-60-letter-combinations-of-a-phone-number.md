# Grind 75 — 60. Letter Combinations of a Phone Number

## Problem

Given a string containing digits from `2` through `9`, return every possible letter combination that those digits could represent on a telephone keypad.

```text
2 → abc    3 → def
4 → ghi    5 → jkl    6 → mno
7 → pqrs   8 → tuv    9 → wxyz
```

Example:

```text
input:  "23"
output: ["ad", "ae", "af", "bd", "be", "bf", "cd", "ce", "cf"]
```

The output order is usually not important. For an empty input, return an empty array.

---

## What is this problem really asking?

Each digit offers a set of choices. We must select exactly one letter from each digit.

For `"23"`:

```text
first position:  a, b, or c
second position: d, e, or f
```

This creates a decision tree:

```text
                     ""
              /       |       \
             a        b        c
           / | \    / | \    / | \
          ad ae af  bd be bf  cd ce cf
```

Every root-to-leaf path is one answer. This is the central signal for **backtracking**:

> Build one candidate through a sequence of choices, record it when complete, and explore every alternative choice.

---

## Pattern recognition

Think of backtracking when the question asks for:

- all combinations;
- all permutations;
- all valid arrangements;
- every path satisfying some rule;
- a result formed by making one choice at each position.

Here, digit index `i` is the current decision position, and `keypad[digits[i]]` contains its choices.

---

## Straightforward approach: nested loops

For exactly two digits, two loops would work:

```javascript
for (const first of keypad[digits[0]]) {
  for (const second of keypad[digits[1]]) {
    combinations.push(first + second);
  }
}
```

But the input length is not fixed. Three digits require three loops, four digits require four loops, and so on.

Recursion supplies a dynamic number of nested loops: one recursive level per input digit.

---

## Optimal solution: depth-first backtracking

```javascript
function letterCombinations(digits) {
  if (digits.length === 0) return [];

  const keypad = {
    2: "abc",
    3: "def",
    4: "ghi",
    5: "jkl",
    6: "mno",
    7: "pqrs",
    8: "tuv",
    9: "wxyz"
  };

  const combinations = [];

  function backtrack(index, current) {
    if (index === digits.length) {
      combinations.push(current);
      return;
    }

    const letters = keypad[digits[index]];

    for (const letter of letters) {
      backtrack(index + 1, current + letter);
    }
  }

  backtrack(0, "");
  return combinations;
}
```

---

## Line-by-line reasoning

### 1. Handle empty input

```javascript
if (digits.length === 0) return [];
```

There are no digits from which to form a combination. The required answer is `[]`, not `[""]`.

### 2. Store the keypad mapping

```javascript
const keypad = {
  2: "abc",
  3: "def",
  4: "ghi",
  5: "jkl",
  6: "mno",
  7: "pqrs",
  8: "tuv",
  9: "wxyz"
};
```

When JavaScript uses `digits[index]`, it produces a string such as `"2"`. Object keys are strings internally, so `keypad["2"]` correctly retrieves `"abc"`.

### 3. Define the recursive state

```text
index   = digit currently being processed
current = letters chosen for all earlier digits
```

This state answers two questions:

- Where am I in the input?
- What have I built so far?

### 4. Recognize a complete candidate

```javascript
if (index === digits.length) {
  combinations.push(current);
  return;
}
```

When `index` reaches the input length, one letter has been chosen for every digit. `current` is now a complete answer.

### 5. Explore every choice at this position

```javascript
const letters = keypad[digits[index]];

for (const letter of letters) {
  backtrack(index + 1, current + letter);
}
```

For each possible letter:

1. choose that letter with `current + letter`;
2. move to the next digit with `index + 1`;
3. return and allow the loop to try the next letter.

---

## Where is the “undo” step?

The traditional backtracking template is:

```text
choose → recurse → undo
```

In this solution, `current` is a JavaScript string. Strings are immutable, so `current + letter` creates a new string for the recursive call. The caller's `current` is never changed; the undo happens naturally when that call returns.

With a shared mutable array, the undo would be explicit:

```javascript
path.push(letter);           // choose
backtrack(index + 1);        // recurse
path.pop();                  // undo
```

Both styles are valid. The immutable-string version is especially readable for this problem.

---

## Walkthrough: `digits = "23"`

Start:

```text
backtrack(0, "")
digit 2 offers: a, b, c
```

Choose `a`:

```text
backtrack(1, "a")
digit 3 offers: d, e, f

choose d → backtrack(2, "ad") → record "ad"
choose e → backtrack(2, "ae") → record "ae"
choose f → backtrack(2, "af") → record "af"
```

Return to the first level and choose `b`:

```text
record "bd", "be", "bf"
```

Then choose `c`:

```text
record "cd", "ce", "cf"
```

Final result:

```text
["ad", "ae", "af", "bd", "be", "bf", "cd", "ce", "cf"]
```

---

## Correctness argument

We need to show that the algorithm returns every valid combination exactly once.

### Every generated result is valid

At recursion level `i`, the algorithm appends exactly one letter from the mapping for `digits[i]`. A string is recorded only after all input digits have been processed. Therefore every recorded string has one valid letter for every digit.

### Every valid result is generated

For each digit, the loop visits every mapped letter. Recursion explores every choice for the next digit beneath every earlier choice. Therefore every possible sequence containing one letter per digit corresponds to a root-to-leaf path and will be visited.

### No result is duplicated

Each root-to-leaf path represents a unique sequence of letter choices. Two different paths differ at least at one position, so they cannot produce the same string.

Thus the algorithm returns all and only the valid combinations, exactly once.

---

## Complexity

Let:

- `n` be the number of digits;
- `M` be the number of generated combinations.

Each digit contributes either 3 or 4 choices, so:

```text
3^n ≤ M ≤ 4^n
```

Creating each output string requires `O(n)` characters. Therefore:

```text
time:  O(M × n), worst case O(n × 4^n)
space: O(n) recursion depth, excluding the required output
output: O(M × n)
```

You may hear the time stated as `O(4^n)`. That counts decision-tree nodes but ignores the cost of materializing strings. `O(n × 4^n)` is the more complete bound for producing the output.

This exponential runtime is unavoidable: the function must actually return exponentially many combinations.

---

## Common mistakes

### 1. Returning `[""]` for empty input

The recursive base case would naturally record an empty string if recursion were started immediately. Handle empty input before recursion so the result is `[]`.

### 2. Stopping one level too early

The complete condition is:

```javascript
index === digits.length
```

At that point, all digit positions have already contributed a letter.

### 3. Pushing partial combinations

Only push `current` at the base case. Pushing during every recursive call would include incomplete strings such as `"a"` for input `"23"`.

### 4. Forgetting to undo a mutable path

If using an array for `path`, every `push` must have a matching `pop`. Otherwise choices leak into sibling branches.

### 5. Treating `0` and `1` as normal keys

The standard problem guarantees digits `2` through `9`. Do not invent mappings unless the interviewer changes the specification.

### 6. Claiming constant space

The output is exponential, and the recursion stack has depth `n`. Auxiliary space is `O(n)`, excluding output.

---

## Edge cases

```text
digits = ""    → []
digits = "2"   → ["a", "b", "c"]
digits = "7"   → ["p", "q", "r", "s"]
digits = "79"  → 16 combinations because both digits have 4 letters
```

---

## Interview walkthrough

Say this before coding:

> Each digit creates a set of letter choices, and I need every sequence containing one choice per digit. That forms a decision tree, so I’ll use backtracking. My recursive state will be the current digit index and the partial string. When the index reaches the input length, the string is complete and I’ll record it. Because JavaScript strings are immutable, passing `current + letter` naturally isolates sibling branches.

If asked why backtracking is necessary:

> The number of nested choice levels depends on the number of digits. Recursion acts like a dynamic number of nested loops and systematically explores their Cartesian product.

If asked about complexity:

> There can be up to `4^n` answers, and each answer has length `n`, so producing the full output takes `O(n × 4^n)` time in the worst case. The recursion depth is `O(n)`, excluding output storage.

---

## Reusable backtracking template

```javascript
function backtrack(position, path) {
  if (isComplete(position, path)) {
    result.push(copyOf(path));
    return;
  }

  for (const choice of choicesAt(position)) {
    makeChoice(path, choice);
    backtrack(position + 1, path);
    undoChoice(path, choice);
  }
}
```

For this problem:

```text
position             → index
choicesAt(position)  → keypad[digits[index]]
path                 → current
complete             → index === digits.length
```

---

## Notebook version

```javascript
function letterCombinations(digits) {
  if (!digits.length) return [];

  const map = {
    2: "abc", 3: "def", 4: "ghi", 5: "jkl",
    6: "mno", 7: "pqrs", 8: "tuv", 9: "wxyz"
  };

  const result = [];

  function dfs(index, current) {
    if (index === digits.length) {
      result.push(current);
      return;
    }

    for (const letter of map[digits[index]]) {
      dfs(index + 1, current + letter);
    }
  }

  dfs(0, "");
  return result;
}
```

### Notebook bullets

- Each digit is one decision level.
- Each mapped letter is one branch.
- Base case: one letter has been chosen for every digit.
- Strings are immutable, so sibling paths do not share mutations.
- Worst case: `O(n × 4^n)` time and `O(n)` auxiliary stack space.

### Memory line

> One digit, one level; one letter, one branch.

### Pattern connection

This is the cleanest introduction to backtracking. Later problems add constraints and pruning, but the skeleton remains:

```text
choose → explore → undo
```
