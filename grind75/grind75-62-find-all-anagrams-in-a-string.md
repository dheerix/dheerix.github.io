# Grind 75 — 62. Find All Anagrams in a String

## Problem

Given two strings `s` and `p`, return the starting indices of every substring of `s` that is an anagram of `p`.

An anagram uses exactly the same characters with exactly the same frequencies, although their order may differ.

Example:

```text
s = "cbaebabacd"
p = "abc"

answer = [0, 6]
```

Why?

```text
s[0..2] = "cba" → anagram of "abc"
s[6..8] = "bac" → anagram of "abc"
```

---

## Core observation

Every anagram of `p` has exactly `p.length` characters.

Therefore, we only need to examine windows of one fixed size:

```text
window size = p.length
```

A brute-force solution rebuilds or sorts every window. A sliding window reuses the counts from the previous window:

```text
previous window → remove its left character
next window     → add its new right character
```

Only two character counts change when the window moves.

---

## Pattern recognition

Use a **fixed-size sliding window** when the problem asks about:

- every substring of length `k`;
- a maximum or minimum among length-`k` windows;
- whether a permutation or anagram occurs;
- frequency conditions inside equal-length substrings.

The key signal here is not merely “substring.” It is:

> Every valid candidate has a known, identical length.

---

## Brute force 1: sort every substring

For every substring of length `m = p.length`:

1. extract it;
2. sort it;
3. compare it with sorted `p`.

```javascript
function findAnagramsBySorting(s, p) {
  const result = [];
  const sortedPattern = [...p].sort().join("");

  for (let start = 0; start + p.length <= s.length; start++) {
    const candidate = s
      .slice(start, start + p.length)
      .split("")
      .sort()
      .join("");

    if (candidate === sortedPattern) result.push(start);
  }

  return result;
}
```

If `n = s.length` and `m = p.length`, sorting each window costs `O(m log m)`:

```text
time:  O((n - m + 1) × m log m)
space: O(m)
```

This repeats almost the same work for heavily overlapping windows.

---

## Better direction: maintain what is still needed

Create a frequency array for `p`:

```text
needed[character] = copies of that character still needed
```

Also maintain:

```text
remaining = total pattern characters still unmatched
```

For `p = "aabc"`:

```text
needed[a] = 2
needed[b] = 1
needed[c] = 1
remaining = 4
```

When a character enters the window:

- if `needed[char] > 0`, it satisfies a missing requirement, so decrement `remaining`;
- always decrement `needed[char]` because the window now contains one more copy.

When a character leaves:

- increment `needed[char]` to undo its presence;
- if the new value is positive, a genuinely required copy was removed, so increment `remaining`.

Negative counts are meaningful: they represent extra copies inside the current window.

---

## Optimal solution

The standard problem uses lowercase English letters, so a 26-element array is sufficient.

```javascript
function findAnagrams(s, p) {
  if (p.length > s.length) return [];

  const needed = new Array(26).fill(0);
  const result = [];
  const codeA = "a".charCodeAt(0);

  for (const char of p) {
    needed[char.charCodeAt(0) - codeA]++;
  }

  let left = 0;
  let remaining = p.length;

  for (let right = 0; right < s.length; right++) {
    const entering = s.charCodeAt(right) - codeA;

    if (needed[entering] > 0) remaining--;
    needed[entering]--;

    if (right - left + 1 > p.length) {
      const leaving = s.charCodeAt(left) - codeA;
      needed[leaving]++;

      if (needed[leaving] > 0) remaining++;
      left++;
    }

    if (remaining === 0) result.push(left);
  }

  return result;
}
```

---

## Window invariant

After processing index `right` and shrinking if necessary:

1. the window is `s[left..right]`;
2. its length is at most `p.length`;
3. `needed[x]` equals pattern frequency minus window frequency for character `x`;
4. `remaining` is the number of pattern-character copies not yet satisfied by the window.

Once the window has reached `p.length`, `remaining === 0` means every required character count is satisfied. Since the window and pattern have equal total length, there can be no extra character without some missing character. Therefore the window is an anagram.

---

## Why the entering logic checks before decrementing

```javascript
if (needed[entering] > 0) remaining--;
needed[entering]--;
```

Suppose the pattern needs one `a`.

First `a` enters:

```text
needed[a] before = 1
this copy is useful
remaining decreases
needed[a] becomes 0
```

Second `a` enters:

```text
needed[a] before = 0
this copy is extra
remaining does not change
needed[a] becomes -1
```

Checking after decrementing would lose the distinction between required and extra copies.

---

## Why the leaving logic checks after incrementing

```javascript
needed[leaving]++;
if (needed[leaving] > 0) remaining++;
```

Removing a character reverses the entering operation.

If `needed[char]` changes from `-1` to `0`, we removed an extra copy; nothing becomes missing.

If it changes from `0` to `1`, we removed a copy that was satisfying the pattern; one character is now missing, so `remaining` increases.

---

## Walkthrough

```text
s = "cbaebabacd"
p = "abc"
window size = 3
```

Initially:

```text
needed: a=1, b=1, c=1
remaining=3
```

| Right | Enters | Window after resize | Remaining | Result |
|---:|:---:|:---:|---:|:---|
| 0 | c | `c` | 2 | — |
| 1 | b | `cb` | 1 | — |
| 2 | a | `cba` | 0 | add `0` |
| 3 | e | `bae` | 1 | — |
| 4 | b | `aeb` | 1 | — |
| 5 | a | `eba` | 1 | — |
| 6 | b | `bab` | 1 | — |
| 7 | a | `aba` | 1 | — |
| 8 | c | `bac` | 0 | add `6` |
| 9 | d | `acd` | 1 | — |

Final answer:

```text
[0, 6]
```

---

## Correctness argument

We prove that the algorithm records exactly the anagram starting indices.

### The maintained counts are accurate

The frequency array begins with the pattern counts. Every entering window character decrements its count, and every leaving character increments it. Thus at all times:

```text
needed[x] = count of x in p - count of x in current window
```

`remaining` decreases only when an entering character fills an unmet requirement and increases only when a leaving character creates a requirement. It therefore equals the number of unsatisfied pattern-character copies.

### Every recorded window is an anagram

An index is recorded only when `remaining === 0`. At that point all required pattern copies occur in the window. The maintained window has exactly `p.length` characters once a complete match is possible, so it cannot contain additional characters beyond the pattern's multiset. It is an anagram.

### Every anagram window is recorded

For any substring whose character frequencies equal `p`, all requirements are satisfied when its right boundary is processed. Therefore `remaining === 0`, and the algorithm records that window's `left` index.

Thus the algorithm is correct.

---

## Complexity

Each character enters the window once and leaves at most once.

```text
time:  O(n + m)
space: O(1)
```

Here, `n = s.length` and `m = p.length`. The frequency array always has 26 entries, so its size is constant under the lowercase-English-letter constraint.

If the alphabet were unbounded Unicode characters, a map would use `O(k)` space for the number of distinct tracked characters.

---

## Alternative: compare two frequency arrays

This version maintains pattern and window counts and compares all 26 entries for every complete window.

```javascript
function findAnagramsByComparison(s, p) {
  if (p.length > s.length) return [];

  const patternCount = new Array(26).fill(0);
  const windowCount = new Array(26).fill(0);
  const result = [];
  const codeA = "a".charCodeAt(0);

  for (const char of p) {
    patternCount[char.charCodeAt(0) - codeA]++;
  }

  for (let right = 0; right < s.length; right++) {
    windowCount[s.charCodeAt(right) - codeA]++;

    if (right >= p.length) {
      windowCount[s.charCodeAt(right - p.length) - codeA]--;
    }

    if (
      right >= p.length - 1 &&
      patternCount.every((count, index) => count === windowCount[index])
    ) {
      result.push(right - p.length + 1);
    }
  }

  return result;
}
```

Because 26 is constant, this is still asymptotically `O(n + m)`. The `remaining` version avoids comparing 26 positions for every window and teaches a useful incremental-count invariant.

---

## Common mistakes

### 1. Using a variable-size window

An anagram must have the same length as `p`. Keep the window at exactly that length once it fills.

### 2. Checking only whether characters exist

Frequencies matter. Pattern `"aab"` is not matched by window `"abb"`.

### 3. Resetting the frequency map for every index

That discards the advantage of overlapping windows and can lead to `O(n × m)` work.

### 4. Shrinking at the wrong time

After adding the right character, shrink when:

```javascript
right - left + 1 > p.length
```

Then evaluate the current fixed-size window.

### 5. Mishandling extra copies

Counts may become negative. A negative count means the window contains more copies than the pattern requires; it is not itself an error.

### 6. Updating `remaining` in the wrong order

- entering: check `needed[char] > 0` **before** decrementing;
- leaving: increment first, then check `needed[char] > 0`.

### 7. Returning the substrings

The problem asks for starting indices, not the anagram strings.

### 8. Forgetting overlapping matches

For `s = "abab"` and `p = "ab"`, the result is `[0, 1, 2]`. Sliding one position at a time naturally preserves overlaps.

---

## Edge cases

```text
s = "a",    p = "ab" → []
s = "abab", p = "ab" → [0, 1, 2]
s = "aaaa", p = "aa" → [0, 1, 2]
s = "baa",  p = "aa" → [1]
s = "abc",  p = "cba" → [0]
```

The standard constraints make both strings non-empty. If empty patterns were allowed, clarify the expected behavior with the interviewer.

---

## Interview walkthrough

Say this before coding:

> Every anagram has the same length as the pattern, so I’ll use a fixed-size sliding window. I’ll store how many copies of each pattern character are still needed and a `remaining` count for total unmatched characters. When a character enters, I’ll satisfy a requirement only if its current needed count is positive. When the window becomes too large, I’ll undo the character leaving from the left. Whenever `remaining` reaches zero, the current window is an anagram.

State the invariant:

> For each character, `needed` equals its pattern frequency minus its current-window frequency, and `remaining` counts the still-unsatisfied pattern copies.

Complexity statement:

> Each character enters and leaves the window at most once, so the time is `O(n + m)`. The 26-element array is constant auxiliary space.

---

## Notebook version

```javascript
function findAnagrams(s, p) {
  if (p.length > s.length) return [];

  const needed = new Array(26).fill(0);
  const answer = [];
  const A = "a".charCodeAt(0);

  for (const char of p) {
    needed[char.charCodeAt(0) - A]++;
  }

  let left = 0;
  let remaining = p.length;

  for (let right = 0; right < s.length; right++) {
    const inIndex = s.charCodeAt(right) - A;
    if (needed[inIndex] > 0) remaining--;
    needed[inIndex]--;

    if (right - left + 1 > p.length) {
      const outIndex = s.charCodeAt(left) - A;
      needed[outIndex]++;
      if (needed[outIndex] > 0) remaining++;
      left++;
    }

    if (remaining === 0) answer.push(left);
  }

  return answer;
}
```

### Notebook bullets

- Anagram length is fixed → fixed sliding window.
- `needed = pattern count - window count`.
- Enter: useful only when count was positive.
- Leave: missing only when restored count becomes positive.
- `remaining === 0` → record `left`.
- Time `O(n + m)`; space `O(1)` for 26 lowercase letters.

### Memory line

> Add right, remove left, preserve the counts.

### Pattern connection

Unlike a variable window that expands until a condition is met and shrinks while invalid, this problem has a predetermined window size. The movement rule is mechanical:

```text
add right → if oversized, remove left → evaluate
```
