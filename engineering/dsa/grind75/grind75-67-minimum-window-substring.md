# Grind 75 — 67: Minimum Window Substring

**Difficulty:** Hard  
**Primary pattern:** Variable-size sliding window + frequency map  
**LeetCode:** 76  
**Target interview time:** 30 minutes  
**Language:** JavaScript

## Problem

Given strings `s` and `t`, return the shortest substring of `s` containing every character from `t`, including duplicate occurrences. Return `""` if no such substring exists.

Example:

```text
s = "ADOBECODEBANC"
t = "ABC"

answer = "BANC"
```

The word **including duplicates** is essential. If `t = "AABC"`, a valid window must contain at least two `A`s, one `B`, and one `C`.

---

## 1. Intuition

We need a contiguous window that satisfies a frequency requirement.

Two opposing goals exist:

1. Expand the right boundary until the window contains everything required.
2. Once valid, move the left boundary inward to make the window as small as possible.

This is the variable-size sliding-window pattern:

```text
invalid window -> expand right
valid window   -> shrink left and record improvements
```

The difficult part is checking efficiently whether the current window contains all required characters. Recounting every character after every movement would be too slow.

Instead, maintain:

- `required`: frequency of each character in `t`.
- `windowCounts`: frequency inside the current window.
- `requiredKinds`: number of distinct characters whose requirements must be satisfied.
- `formed`: number of distinct characters whose required frequencies are currently satisfied.

The window is valid exactly when:

```js
formed === requiredKinds
```

### Why count satisfied character kinds rather than total characters?

Suppose:

```text
t = "AABC"
required = { A: 2, B: 1, C: 1 }
requiredKinds = 3
```

`A` becomes satisfied only when the window contains the second `A`. Extra copies do not increase `formed` again.

---

## 2. Brute Force — Test Every Substring

Generate every substring and check whether it contains the required frequencies.

```js
function minWindow(s, t) {
  const required = new Map();

  for (const char of t) {
    required.set(char, (required.get(char) || 0) + 1);
  }

  let answer = "";

  for (let start = 0; start < s.length; start++) {
    const counts = new Map();

    for (let end = start; end < s.length; end++) {
      const char = s[end];
      counts.set(char, (counts.get(char) || 0) + 1);

      if (containsAll(counts, required)) {
        const candidate = s.slice(start, end + 1);

        if (answer === "" || candidate.length < answer.length) {
          answer = candidate;
        }

        break;
      }
    }
  }

  return answer;
}

function containsAll(counts, required) {
  for (const [char, needed] of required) {
    if ((counts.get(char) || 0) < needed) return false;
  }

  return true;
}
```

### Complexity

Let `m = s.length`, `n = t.length`, and `u` be the number of distinct characters in `t`.

- Time: up to `O(m² × u)`.
- Space: `O(u)` to `O(m)`, depending on which characters are counted.

The repeated work is the problem: overlapping substrings are recounted again and again.

---

## 3. Optimal Solution — Sliding Window

```js
/**
 * Returns the shortest substring of s containing every character of t,
 * including duplicate occurrences.
 *
 * @param {string} s
 * @param {string} t
 * @return {string}
 */
function minWindow(s, t) {
  if (t.length === 0 || s.length < t.length) return "";

  const required = new Map();

  for (const char of t) {
    required.set(char, (required.get(char) || 0) + 1);
  }

  const windowCounts = new Map();
  const requiredKinds = required.size;
  let formed = 0;
  let left = 0;

  let bestStart = 0;
  let bestLength = Infinity;

  for (let right = 0; right < s.length; right++) {
    const addedChar = s[right];

    if (required.has(addedChar)) {
      const newCount = (windowCounts.get(addedChar) || 0) + 1;
      windowCounts.set(addedChar, newCount);

      if (newCount === required.get(addedChar)) {
        formed++;
      }
    }

    while (formed === requiredKinds) {
      const currentLength = right - left + 1;

      if (currentLength < bestLength) {
        bestLength = currentLength;
        bestStart = left;
      }

      const removedChar = s[left];

      if (required.has(removedChar)) {
        const oldCount = windowCounts.get(removedChar);

        if (oldCount === required.get(removedChar)) {
          formed--;
        }

        windowCounts.set(removedChar, oldCount - 1);
      }

      left++;
    }
  }

  return bestLength === Infinity
    ? ""
    : s.slice(bestStart, bestStart + bestLength);
}
```

---

## 4. What Each Variable Means

| Variable | Meaning |
| --- | --- |
| `required` | Frequencies demanded by `t` |
| `windowCounts` | Relevant frequencies in `s[left...right]` |
| `requiredKinds` | Number of distinct required characters |
| `formed` | Number of distinct characters currently meeting their required counts |
| `left` | Left boundary of the current window |
| `right` | Right boundary of the current window |
| `bestStart` | Beginning of the smallest valid window found |
| `bestLength` | Length of the smallest valid window found |

### Central invariant

For every relevant character, `windowCounts` equals its frequency inside the current inclusive window `[left, right]`.

`formed` equals the number of required characters `c` for which:

```text
windowCounts[c] >= required[c]
```

---

## 5. Why Equality Checks Matter

### When adding a character

```js
if (newCount === required.get(addedChar)) {
  formed++;
}
```

Increment `formed` only when the count first reaches the requirement.

If `A` is needed twice:

```text
count 1 -> not satisfied
count 2 -> satisfied; increment formed
count 3 -> still satisfied; do not increment again
```

### When removing a character

```js
if (oldCount === required.get(removedChar)) {
  formed--;
}
```

Check before decrementing the count. If the old count exactly meets the requirement, removing one copy makes that character deficient.

```text
required A = 2

old count 3 -> new count 2: still satisfied
old count 2 -> new count 1: no longer satisfied
```

This threshold-crossing logic keeps `formed` accurate in constant time.

---

## 6. Walkthrough

```text
s = "ADOBECODEBANC"
t = "ABC"
required = { A: 1, B: 1, C: 1 }
requiredKinds = 3
```

### First valid window

Expand `right`:

```text
A D O B E C
0         5
```

At `right = 5`, the window `"ADOBEC"` contains `A`, `B`, and `C`.

```text
formed = 3
```

Record length `6`, then shrink from the left:

- Removing `A` makes its count insufficient.
- The window becomes invalid.
- Resume expanding `right`.

### Later valid window

Eventually the window reaches:

```text
"CODEBA"
```

It is valid, so shrink it until removing another required character would invalidate it.

### Final improvement

Near the end:

```text
"BANC"
```

It contains all required characters and has length `4`. Further shrinking would remove `B`, so it is the smallest valid window found.

Answer:

```text
"BANC"
```

---

## 7. Correctness Proof

We prove that the algorithm returns the minimum valid window.

### Lemma 1: The validity test is correct

`formed` counts the distinct required characters whose window frequency meets or exceeds the required frequency. Therefore, `formed === requiredKinds` exactly when every required character has enough occurrences in the current window.

### Lemma 2: For each `right`, the shrinking loop examines the shortest valid window ending at `right`

Whenever the window is valid, the algorithm repeatedly advances `left`. Every valid window encountered is recorded before its leftmost character is removed. Shrinking ends only when the removal of a character makes the window invalid. Thus, the last valid window considered for that `right` is the shortest valid window ending there.

### Lemma 3: No possible ending position is skipped

The `for` loop advances `right` through every index of `s`. For each ending position that can form a valid window, Lemma 2 shows that its shortest valid window is considered.

### Theorem

Every candidate for the globally shortest valid window has some right endpoint. The algorithm examines the shortest valid window for every possible right endpoint and retains the shortest among them. Therefore, it returns the minimum window containing all characters of `t`. If no window becomes valid, it correctly returns `""`.

---

## 8. Complexity

Let `m = s.length` and `n = t.length`.

### Time

```text
O(m + n)
```

- Building `required` takes `O(n)`.
- `right` moves across `s` once.
- `left` also moves across `s` at most once.

Although there is a `while` loop inside a `for` loop, this is not `O(m²)`. Neither pointer ever moves backward, so there are at most `2m` pointer movements.

### Space

```text
O(u)
```

where `u` is the number of distinct characters in `t`. We store counts only for required characters.

Under a fixed-size character alphabet, this can also be described as `O(1)` auxiliary space.

---

## 9. Common Mistakes

### Mistake 1: Using a `Set`

A set loses duplicate requirements. For `t = "AABC"`, knowing only that `A` exists is insufficient.

Use frequency counts.

### Mistake 2: Comparing only distinct-character presence

The window must satisfy required quantities, not merely contain each distinct character once.

### Mistake 3: Incrementing `formed` for every matching copy

`formed` counts satisfied character kinds, not matched characters.

Increment only when a count reaches its required threshold.

### Mistake 4: Decrementing `formed` after lowering the count with the wrong comparison

Check whether the old count exactly met the requirement before removing the character.

### Mistake 5: Recording a window only after shrinking

Record the current valid window before removing `s[left]`; the removal may invalidate it.

### Mistake 6: Shrinking only once

Use `while`, not `if`. Once valid, shrink repeatedly to find the smallest valid window for the current `right`.

### Mistake 7: Off-by-one window length

Both endpoints are inclusive:

```js
const currentLength = right - left + 1;
```

### Mistake 8: Returning the wrong slice

JavaScript's second `slice` index is exclusive:

```js
s.slice(bestStart, bestStart + bestLength)
```

### Mistake 9: Calling the nested loops quadratic

Explain amortized pointer movement: each pointer traverses the string at most once.

---

## 10. Edge Cases

### No possible window

```text
s = "a"
t = "aa"
answer = ""
```

The early check `s.length < t.length` handles this immediately.

### Exact match

```text
s = "ABC"
t = "ABC"
answer = "ABC"
```

### One-character target

```text
s = "a"
t = "a"
answer = "a"
```

### Duplicate target characters

```text
s = "AAABBC"
t = "AABC"
answer = "AABBC"
```

### Irrelevant characters

Characters not present in `t` may lie inside the answer, but they do not need to be stored in `windowCounts`.

### Case sensitivity

`A` and `a` are different characters.

### Empty target

Return `""`. Although the standard problem constrains `t` to be non-empty, handling it prevents the shrinking loop from behaving incorrectly.

---

## 11. Interview Explanation

> This is a minimum contiguous segment satisfying frequency requirements, so I’ll use a variable-size sliding window. I first count each required character in `t`. As I expand the right boundary, I update relevant window counts. `formed` tracks how many distinct required characters currently meet their exact frequency requirement, so the window is valid when `formed` equals the number of distinct required characters. Whenever it is valid, I record its length and repeatedly move the left boundary to minimize it. If removing a character drops its count below the requirement, I decrement `formed` and resume expanding. Each pointer moves only forward across `s`, giving `O(|s| + |t|)` time and `O(u)` space.

### Questions to clarify aloud

1. Is matching case-sensitive?
2. Can `t` contain duplicate characters?
3. What should be returned when no window exists?

For the standard problem: yes, duplicates matter, and return `""` when impossible.

---

## 12. Notebook Version

### Recognition

```text
Shortest contiguous window satisfying counts
=> variable-size sliding window
```

### State

```text
required      = counts from t
windowCounts  = relevant counts in current window
requiredKinds = required.size
formed        = kinds currently meeting their count
```

### Algorithm

1. Build required frequencies.
2. Expand `right`.
3. When an added count reaches its requirement, increment `formed`.
4. While all kinds are formed:
   - record the window;
   - remove `s[left]`;
   - if a satisfied count becomes deficient, decrement `formed`;
   - increment `left`.
5. Return the best recorded slice or `""`.

### JavaScript

```js
function minWindow(s, t) {
  if (!t.length || s.length < t.length) return "";

  const need = new Map();
  for (const char of t) {
    need.set(char, (need.get(char) || 0) + 1);
  }

  const have = new Map();
  let formed = 0;
  let left = 0;
  let bestStart = 0;
  let bestLength = Infinity;

  for (let right = 0; right < s.length; right++) {
    const added = s[right];

    if (need.has(added)) {
      have.set(added, (have.get(added) || 0) + 1);
      if (have.get(added) === need.get(added)) formed++;
    }

    while (formed === need.size) {
      const length = right - left + 1;

      if (length < bestLength) {
        bestLength = length;
        bestStart = left;
      }

      const removed = s[left++];

      if (need.has(removed)) {
        if (have.get(removed) === need.get(removed)) formed--;
        have.set(removed, have.get(removed) - 1);
      }
    }
  }

  return bestLength === Infinity
    ? ""
    : s.slice(bestStart, bestStart + bestLength);
}
```

### Complexity

```text
Time:  O(|s| + |t|)
Space: O(distinct characters in t)
```

### Invariant

`formed === need.size` if and only if the current window contains every required frequency.

---

## 13. Memory Line

**Expand until complete; shrink until one requirement breaks.**

