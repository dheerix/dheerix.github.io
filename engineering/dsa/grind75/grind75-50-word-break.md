# Grind 75 — 50. Word Break

## Problem

Given a string `s` and a dictionary `wordDict`, return `true` if `s` can be segmented into a space-separated sequence of one or more dictionary words.

Dictionary words may be reused.

Examples:

```text
s = "leetcode"
wordDict = ["leet", "code"]
answer = true

s = "catsandog"
wordDict = ["cats", "dog", "sand", "and", "cat"]
answer = false
```

---

## 1. Why greedy matching fails

Choosing the longest or shortest available word first is not reliable.

For example, a locally valid prefix can lead to a dead end while a different earlier split succeeds. We need to consider multiple split positions without recomputing the same suffixes repeatedly.

This is a sign of dynamic programming:

- overlapping subproblems: the same prefix/suffix boundaries are reconsidered;
- optimal structure is not needed, but a boolean feasibility result is;
- a larger valid prefix can be built from a smaller valid prefix plus one dictionary word.

---

## 2. Define the DP state precisely

Let:

```text
dp[i] = whether the first i characters of s can be segmented
```

JavaScript substring boundaries are end-exclusive, so:

```text
s.slice(j, i)
```

contains characters from index `j` through `i - 1`.

To make `dp[i]` true, we need some split point `j` such that:

```text
dp[j] is true
and
s.slice(j, i) is in the dictionary
```

Transition:

```text
dp[i] = OR over j < i of
        dp[j] && dictionary.has(s.slice(j, i))
```

---

## 3. Why `dp[0] = true`?

`dp[0]` represents the empty prefix.

The empty string is considered successfully segmented using zero words. This seed allows a dictionary word beginning at index zero to form the first reachable prefix.

For example, if `s.slice(0, 4) === "leet"`:

```text
dp[0] = true + "leet" in dictionary → dp[4] = true
```

Without the empty-prefix base case, no segmentation could ever begin.

---

## 4. Recommended JavaScript solution

```javascript
function wordBreak(s, wordDict) {
  const dictionary = new Set(wordDict);
  const dp = new Array(s.length + 1).fill(false);

  dp[0] = true;

  for (let end = 1; end <= s.length; end++) {
    for (let start = 0; start < end; start++) {
      const word = s.slice(start, end);

      if (dp[start] && dictionary.has(word)) {
        dp[end] = true;
        break;
      }
    }
  }

  return dp[s.length];
}
```

---

## 5. Why use a `Set`?

With an array, checking whether a substring is a dictionary word can take O(k), where `k` is the dictionary size.

```javascript
wordDict.includes(word)
```

A `Set` provides average O(1) membership lookup:

```javascript
dictionary.has(word)
```

This leaves split enumeration as the main algorithmic work.

---

## 6. Walkthrough: `"leetcode"`

```text
s = "leetcode"
dictionary = {"leet", "code"}
```

The DP array has length `9` because indices represent prefix lengths from `0` through `8`.

Initial state:

```text
index: 0 1 2 3 4 5 6 7 8
dp:    T F F F F F F F F
```

### End position `4`

At split `start = 0`:

```text
dp[0] = true
s.slice(0,4) = "leet"
```

`"leet"` is in the dictionary, so:

```text
dp[4] = true
```

### End position `8`

At split `start = 4`:

```text
dp[4] = true
s.slice(4,8) = "code"
```

So:

```text
dp[8] = true
```

Final state includes:

```text
dp[0] = true
dp[4] = true
dp[8] = true
```

Return `dp[8]`, which is `true`.

---

## 7. Walkthrough: failure with valid partial prefixes

```text
s = "catsandog"
dictionary = {"cats", "dog", "sand", "and", "cat"}
```

Reachable prefixes include:

```text
"cat"     → dp[3] = true
"cats"    → dp[4] = true
"catsand" → dp[7] = true
```

But the remaining suffix is `"og"`, which cannot be formed from the dictionary.

Therefore:

```text
dp[9] = false
```

The DP correctly preserves several possible prefixes without committing greedily to only one split.

---

## 8. Why `break` is safe

Once any split proves `dp[end] = true`, the state is settled. The problem asks only whether segmentation exists, not how many segmentations exist.

Continuing to test other split points cannot change `true` back to `false`, so breaking avoids unnecessary work.

---

## 9. Correctness reasoning

We prove that `dp[i]` is true exactly when `s[0...i)` can be segmented.

### Base case

`dp[0] = true` correctly represents the empty prefix.

### If the algorithm sets `dp[i] = true`

It found a split `j` where:

- `dp[j]` is true, so the prefix `s[0...j)` can be segmented;
- `s[j...i)` is a dictionary word.

Appending that word gives a valid segmentation of `s[0...i)`.

### If `s[0...i)` can be segmented

Consider the final word in a valid segmentation. Let it begin at index `j`. The earlier prefix `s[0...j)` is valid, so by induction `dp[j]` is true, and the final substring `s[j...i)` is in the dictionary. The loop considers that split and sets `dp[i] = true`.

Therefore, `dp[s.length]` exactly answers whether the whole string can be segmented.

---

## 10. Complexity

Let `n` be the string length.

There are O(n²) `(start, end)` pairs.

In JavaScript, `s.slice(start, end)` creates a substring whose cost can be proportional to its length. Therefore, a precise worst-case analysis is:

- Time: **O(n³)** including substring construction
- DP space: **O(n)**
- Dictionary storage: proportional to total dictionary characters

Many interview explanations state O(n²) time assuming substring extraction/hash lookup is treated as O(1) or bounded by a maximum word length. It is good to state the assumption explicitly.

With `L` as the maximum dictionary word length, we can restrict split checks and describe the work as roughly O(n × L²) with copied substrings, or O(n × L) under constant-time substring lookup assumptions.

---

## 11. Optimization using maximum word length

No candidate substring longer than the longest dictionary word can match.

```javascript
function wordBreakBounded(s, wordDict) {
  const dictionary = new Set(wordDict);
  const dp = new Array(s.length + 1).fill(false);
  const maxWordLength = wordDict.reduce(
    (maximum, word) => Math.max(maximum, word.length),
    0
  );

  dp[0] = true;

  for (let end = 1; end <= s.length; end++) {
    const earliestStart = Math.max(0, end - maxWordLength);

    for (let start = earliestStart; start < end; start++) {
      if (
        dp[start] &&
        dictionary.has(s.slice(start, end))
      ) {
        dp[end] = true;
        break;
      }
    }
  }

  return dp[s.length];
}
```

Also notice that `dp[start]` is checked before creating the substring. JavaScript's `&&` short-circuits, avoiding substring work from unreachable prefixes.

---

## 12. Top-down memoization alternative

Define a recursive question:

> Can the suffix beginning at index `start` be segmented?

```javascript
function wordBreakTopDown(s, wordDict) {
  const dictionary = new Set(wordDict);
  const memo = new Map();

  function canBreak(start) {
    if (start === s.length) return true;
    if (memo.has(start)) return memo.get(start);

    for (let end = start + 1; end <= s.length; end++) {
      if (
        dictionary.has(s.slice(start, end)) &&
        canBreak(end)
      ) {
        memo.set(start, true);
        return true;
      }
    }

    memo.set(start, false);
    return false;
  }

  return canBreak(0);
}
```

Memoization ensures each starting index is solved once. Without memoization, unsuccessful suffixes are recomputed along many recursion paths, causing exponential time.

The bottom-up version avoids JavaScript recursion-depth concerns and makes prefix reachability visible.

---

## 13. Graph/BFS interpretation

String indices can be viewed as graph nodes:

```text
0, 1, 2, ..., n
```

Add a directed edge from `start` to `end` when:

```text
s.slice(start, end) is a dictionary word
```

The problem becomes:

> Is index `n` reachable from index `0`?

The DP marks reachable indices in increasing order. This interpretation helps connect dynamic programming to graph reachability.

---

## 14. Common mistakes

### Mistake 1: greedily choose the longest matching word

A locally attractive word can leave an impossible suffix.

### Mistake 2: use plain recursion without memoization

The same suffix is solved repeatedly, leading to exponential behavior.

### Mistake 3: forget `dp[0] = true`

No first word can establish a reachable prefix.

### Mistake 4: check only dictionary membership

A substring can be a word but must begin after a prefix that is itself segmentable. Both conditions are required.

### Mistake 5: off-by-one substring boundaries

`dp[i]` represents the first `i` characters, and `slice(start, end)` excludes `end`.

### Mistake 6: use repeated array lookup for the dictionary

Convert it to a `Set`.

### Mistake 7: generate every sentence

This problem asks only for a boolean. “Word Break II” requires sentence generation and has much larger output complexity.

### Mistake 8: claim O(n²) without discussing substring cost

Clarify the cost model, especially in JavaScript.

---

## 15. Edge cases

- empty string → `true` under the DP definition
- dictionary contains the entire string
- one-character words
- repeated reuse of one word
- several valid segmentations
- valid prefixes but impossible final suffix
- dictionary words longer than the string
- empty dictionary with non-empty string → `false`

---

## 16. Interview narration

> “I’ll define `dp[i]` as whether the first `i` characters can be segmented. I seed `dp[0]` as true for the empty prefix. For each ending position, I try earlier split points. If the prefix before a split is reachable and the substring after it is in a dictionary set, then that ending position is reachable. The final answer is `dp[s.length]`.”

---

## 17. Pattern recognition

This is **prefix dynamic programming**.

Look for it when:

- a sequence must be partitioned into valid pieces;
- validity at position `i` depends on an earlier valid boundary `j`;
- the question asks whether, how many ways, or the minimum cost to reach the end.

General transition:

```text
dp[end] depends on dp[start] + validity/cost of segment [start, end)
```

Related problems include decoding strings, palindrome partitioning, minimum word segmentation, and path reachability through sequence boundaries.

---

## 18. Quick test

```javascript
console.log(wordBreak('leetcode', ['leet', 'code']));
// true

console.log(wordBreak('applepenapple', ['apple', 'pen']));
// true

console.log(
  wordBreak('catsandog', ['cats', 'dog', 'sand', 'and', 'cat'])
);
// false

console.log(wordBreak('', ['anything']));
// true
```

---

## 19. Notebook version

### Pattern

**One-dimensional prefix DP**

### State

```text
dp[i] = first i characters can be segmented
```

### Base case

```text
dp[0] = true
```

### Transition

```text
dp[end] = true when some start satisfies:
dp[start] && dictionary.has(s.slice(start, end))
```

### Memory line

> A prefix is reachable if a reachable earlier prefix can append one valid word.

### Complexity

```text
DP states/splits: O(n²)
JavaScript substring-aware worst case: O(n³)
DP space: O(n)
```

