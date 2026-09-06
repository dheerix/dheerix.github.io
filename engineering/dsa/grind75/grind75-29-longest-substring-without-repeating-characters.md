# Grind 75 — 29: Longest Substring Without Repeating Characters

**Difficulty:** Medium  
**Primary pattern:** Sliding window / last-seen index map  
**LeetCode:** https://leetcode.com/problems/longest-substring-without-repeating-characters/  
**Target time:** 30 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given a string, return the length of the longest **contiguous substring** containing no repeated characters.

```text
s = "abcabcbb"
answer = 3
```

Valid longest substrings include `"abc"`, `"bca"`, and `"cab"`.

```text
s = "bbbbb"
answer = 1
```

The problem asks for a substring, not a subsequence. Characters cannot be skipped inside the chosen range.

---

## 2. Brute-force thinking

Try every starting index and extend until a repeated character appears.

```javascript
function lengthOfLongestSubstringBruteForce(s) {
  let longest = 0;

  for (let start = 0; start < s.length; start++) {
    const seen = new Set();

    for (let end = start; end < s.length; end++) {
      if (seen.has(s[end])) {
        break;
      }

      seen.add(s[end]);
      longest = Math.max(longest, end - start + 1);
    }
  }

  return longest;
}
```

- Time: **O(n²)** worst case.
- Extra space: **O(k)** for the temporary set.

The repeated work is rebuilding almost the same valid range from each start position.

---

## 3. Sliding-window insight

Maintain a window:

```text
[left, right]
```

Invariant:

> The current window contains no repeated characters.

The right pointer expands the window one character at a time. If the new character duplicates one already inside the window, move `left` far enough to remove the earlier occurrence.

Then measure:

```text
window length = right - left + 1
```

Both boundaries move only forward, so repeated rescanning is avoided.

---

## 4. Two valid sliding-window implementations

### Set-based window

When a duplicate appears, repeatedly remove characters from the left until it becomes valid.

```javascript
function lengthOfLongestSubstringWithSet(s) {
  const windowCharacters = new Set();
  let left = 0;
  let longest = 0;

  for (let right = 0; right < s.length; right++) {
    while (windowCharacters.has(s[right])) {
      windowCharacters.delete(s[left]);
      left++;
    }

    windowCharacters.add(s[right]);
    longest = Math.max(longest, right - left + 1);
  }

  return longest;
}
```

This is O(n) because each character is added once and removed at most once.

### Last-seen map

Store the most recent index of every character. On a duplicate inside the current window, jump `left` directly past it.

This avoids deleting intermediate characters one at a time and is the preferred solution here.

---

## 5. Optimal JavaScript solution

```javascript
function lengthOfLongestSubstring(s) {
  const lastSeenIndex = new Map();
  let left = 0;
  let longest = 0;

  for (let right = 0; right < s.length; right++) {
    const character = s[right];

    if (lastSeenIndex.has(character)) {
      left = Math.max(
        left,
        lastSeenIndex.get(character) + 1,
      );
    }

    lastSeenIndex.set(character, right);
    longest = Math.max(longest, right - left + 1);
  }

  return longest;
}
```

---

## 6. Dry run

```text
s = "abcabcbb"
```

| `right` | Character | Previous index | `left` after update | Window | Longest |
|---:|---|---:|---:|---|---:|
| 0 | a | — | 0 | `a` | 1 |
| 1 | b | — | 0 | `ab` | 2 |
| 2 | c | — | 0 | `abc` | 3 |
| 3 | a | 0 | 1 | `bca` | 3 |
| 4 | b | 1 | 2 | `cab` | 3 |
| 5 | c | 2 | 3 | `abc` | 3 |
| 6 | b | 4 | 5 | `cb` | 3 |
| 7 | b | 6 | 7 | `b` | 3 |

Return `3`.

---

## 7. The crucial `Math.max`

Consider:

```text
s = "abba"
```

Walkthrough:

```text
right 0: a → left 0
right 1: b → left 0
right 2: b repeated at 1 → left becomes 2
right 3: a was last seen at 0
```

The old `a` lies outside the current window `[2,3]`. If we write:

```javascript
left = lastSeenIndex.get('a') + 1; // becomes 1
```

the left boundary moves backward from `2` to `1`, incorrectly creating `"bba"`.

Correct:

```javascript
left = Math.max(left, previousIndex + 1);
```

Sliding-window boundaries must never move backward.

---

## 8. Code walkthrough

### `lastSeenIndex`

The map stores the latest index seen globally, even if that occurrence is outside the current window. That is why `Math.max` is required.

### Duplicate handling

If the previous occurrence is inside the window, jumping to `previous + 1` removes it and everything before it. The new character can then safely remain at `right`.

If the previous occurrence is outside the window, the maximum leaves `left` unchanged.

### Update the map after adjusting left

The current occurrence becomes the most recent position for future iterations.

### Measure after restoring validity

The length is calculated only after `left` has moved enough to ensure the window has unique characters.

---

## 9. Loop invariant

At the end of each iteration:

1. substring `s[left...right]` contains no repeated characters;
2. `left` is the smallest valid start after resolving the current character's latest conflict;
3. `lastSeenIndex` stores the latest processed index of each character;
4. `longest` is the largest valid-window length observed so far.

This combination of window validity and monotonic boundaries is the foundation of the O(n) runtime.

---

## 10. Correctness reasoning

When processing `s[right]`, only another occurrence of that same character can invalidate the previously valid window. If its latest occurrence is within the window, moving `left` to one position after it removes that duplicate while preserving the longest possible suffix ending at `right`. If it lies before `left`, no move is required.

Thus, after adjustment, `[left, right]` is the longest duplicate-free substring ending at `right`. Taking the maximum length across every right endpoint yields the longest duplicate-free substring anywhere in the string.

---

## 11. Complexity

- **Time: O(n)** average — `right` visits each index once; `left` only moves forward. Map operations are O(1) average.
- **Extra space: O(k)** — `k` is the number of distinct characters encountered, at most O(n).

For a fixed bounded character alphabet, space can be described as O(1), but for general JavaScript strings, O(k) is the safer statement.

The set version's nested `while` loop is also O(n), not O(n²), because each character leaves the window at most once.

---

## 12. Why this is a variable-size sliding window

The window expands by moving `right` every iteration. It shrinks only when the uniqueness constraint is violated.

```text
expand → include new candidate
invalid? → move left until valid
measure valid window
```

This differs from a fixed-size window, where both pointers move to preserve a predetermined length.

General variable-window template:

```javascript
let left = 0;

for (let right = 0; right < items.length; right++) {
  add(items[right]);

  while (windowIsInvalid()) {
    remove(items[left]);
    left++;
  }

  updateAnswer(right - left + 1);
}
```

The last-seen jump is an optimized form of the shrink loop for this exact constraint.

---

## 13. Follow-up: return the substring

Track the start index whenever a longer window appears.

```javascript
function longestUniqueSubstring(s) {
  const lastSeenIndex = new Map();
  let left = 0;
  let bestStart = 0;
  let bestLength = 0;

  for (let right = 0; right < s.length; right++) {
    const character = s[right];

    if (lastSeenIndex.has(character)) {
      left = Math.max(
        left,
        lastSeenIndex.get(character) + 1,
      );
    }

    lastSeenIndex.set(character, right);

    const currentLength = right - left + 1;

    if (currentLength > bestLength) {
      bestLength = currentLength;
      bestStart = left;
    }
  }

  return s.slice(bestStart, bestStart + bestLength);
}
```

The algorithm is unchanged; we retain the provenance of the best length.

---

## 14. JavaScript character note

Indexing a JavaScript string with `s[i]` operates on UTF-16 code units, not full user-perceived characters. For typical LeetCode ASCII inputs, this is fine.

If arbitrary Unicode symbols matter, iterating with `for...of` yields code points but complicates original string indices. Real grapheme clusters can be even more complex. Clarify the character model in production; do not overcomplicate the interview solution unless requirements demand it.

---

## 15. Common mistakes

1. **Moving `left` backward.** Always use `Math.max(left, previous + 1)`.
2. **Updating the answer before removing the duplicate.** Measure only valid windows.
3. **Using a set without removing characters while shrinking.** The set stops matching window contents.
4. **Clearing the entire window on every duplicate.** Only the prefix through the previous occurrence must be discarded.
5. **Confusing substring with subsequence.** The selected range must be contiguous.
6. **Returning the final window length.** The longest window may have appeared earlier.
7. **Using `right - left` instead of `right - left + 1`.** Both endpoints are inclusive.
8. **Claiming O(1) space for arbitrary input characters.** The map can grow to O(k).
9. **Calling the set solution O(n²) because of nested loops.** Pointer movement is monotonic and totals O(n).

---

## 16. What to say in an interview

> “I’ll maintain a duplicate-free sliding window. A map stores each character's latest index. When the right character appeared inside the current window, I move `left` directly past its previous occurrence. I use `Math.max` so `left` never moves backward when the previous occurrence is already outside the window. Then I update the maximum window length. This is O(n) average time and O(k) space.”

If asked for the state:

> “The window `[left, right]` is always the longest valid unique-character suffix ending at `right`.”

---

## 17. Pattern recognition

Think **sliding window** when:

- the answer is a contiguous range;
- a right boundary can expand candidates;
- a constraint can be restored by advancing the left boundary;
- both boundaries move monotonically.

Think **last-seen map** when:

- violation is caused by a repeated element;
- the exact earlier index tells you how far to jump;
- storing only membership would require incremental removal.

Memory cue:

> Expand right; on repetition, jump left beyond the conflict.

---

## 18. Edge cases

| Input | Answer | Reason |
|---|---:|---|
| `""` | 0 | Empty string |
| `"a"` | 1 | One character |
| `"aaaa"` | 1 | Every next character repeats |
| `"abcdef"` | 6 | Entire string unique |
| `"abba"` | 2 | Tests backward-left bug |
| `"pwwkew"` | 3 | `"wke"`; not noncontiguous `"pwke"` |
| `"dvdf"` | 3 | `"vdf"`; do not clear too much |

---

## 19. Notebook-ready notes

### 📚 Concept

**Longest Unique Substring — sliding window + last-seen map**

```text
window = [left, right], always unique
for each right character:
  if seen before:
    left = max(left, previousIndex + 1)
  update last-seen index
  longest = max(longest, right-left+1)
```

### 🧠 My understanding

The right pointer introduces only one possible new conflict: another copy of its character. The previous index tells me exactly which prefix must be discarded. `Math.max` preserves the monotonic left boundary when the previous occurrence is already outside the window.

### 💼 Interview line

> “I’ll keep the longest valid suffix ending at each right boundary.”

### ⚠️ Traps

- `left` never moves backward.
- Measure only after restoring uniqueness.
- Inclusive length is `right - left + 1`.
- Save the global best, not just the final window.

---

## 20. Dheerix Glance

```text
LONGEST SUBSTRING WITHOUT REPEATS

Pattern:          variable sliding window
Window invariant: all characters unique
Map:              character → latest index
On duplicate:     left=max(left, previous+1)
After update:     store current index
Window length:    right-left+1
Time:             O(n) average
Space:            O(k)
Counterexample:   "abba" proves Math.max is required
Memory cue:       “Jump left beyond the conflict—never backward.”
```

---

## 21. Recall test

Without looking back:

1. What does the current window guarantee?
2. Why can only the current right character create a new violation?
3. Why is `Math.max(left, previous + 1)` essential?
4. What does the `"abba"` example expose?
5. Why is the window length `right - left + 1`?
6. Why is the set version still O(n) despite a nested loop?
7. How would you return the substring rather than its length?
8. State the loop invariant in one sentence.

