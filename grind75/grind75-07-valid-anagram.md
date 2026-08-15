# Grind 75 — 07: Valid Anagram

**Difficulty:** Easy  
**Primary pattern:** Frequency counting / hash map  
**LeetCode:** https://leetcode.com/problems/valid-anagram/  
**Target time:** 15 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given two strings `s` and `t`, determine whether `t` is an anagram of `s`.

An anagram uses exactly the same characters with exactly the same frequencies, but possibly in a different order.

```text
s = "anagram"
t = "nagaram"
result = true
```

```text
s = "rat"
t = "car"
result = false
```

Order does not matter. Character multiplicity does.

```text
"aab" and "abb" are not anagrams
```

Both contain `a` and `b`, but their counts differ.

---

## 2. First necessary check: lengths

If two strings contain exactly the same characters with the same counts, they must have the same length.

```javascript
if (s.length !== t.length) return false;
```

This is not the whole solution—equal length does not imply anagram—but it rejects impossible cases immediately and makes later accounting simpler.

---

## 3. Approaches considered

### Approach A: sort both strings

If two strings are anagrams, their sorted forms are identical.

```javascript
function isAnagramBySorting(s, t) {
  if (s.length !== t.length) return false;

  const sortedS = [...s].sort().join('');
  const sortedT = [...t].sort().join('');

  return sortedS === sortedT;
}
```

Complexity for length `n`:

- Time: **O(n log n)** due to sorting.
- Extra space: **O(n)** in typical JavaScript implementations because strings are converted to arrays and sorted copies are created.

This is concise, but frequency counting avoids sorting.

### Approach B: count frequencies

Record how many times each character appears in `s`, then consume those counts using `t`.

- Time: **O(n)** average.
- Extra space: **O(k)**, where `k` is the number of distinct characters.

This is the preferred general solution.

---

## 4. Optimal insight: inventory and consumption

Treat the first string as inventory:

```text
character → available count
```

Then process the second string as requests against that inventory:

1. If a requested character has no remaining count, return `false`.
2. Otherwise decrement its count.
3. If every request succeeds and lengths were equal, return `true`.

The initial length check means we do not need a final loop to verify all counts are zero. If `t` successfully consumes exactly `s.length` characters, it has consumed the entire inventory.

---

## 5. Dry run

```text
s = "aacc"
t = "ccac"
```

Counts from `s`:

```text
a → 2
c → 2
```

Consume `t`:

| Character | Count before | Action | Count after |
|---|---:|---|---:|
| `c` | 2 | consume | 1 |
| `c` | 1 | consume | 0 |
| `a` | 2 | consume | 1 |
| `c` | 0 | unavailable | return `false` |

Even though both strings have length four and use the same character types, their frequencies differ.

---

## 6. Optimal JavaScript solution

```javascript
function isAnagram(s, t) {
  if (s.length !== t.length) {
    return false;
  }

  const frequencies = new Map();

  for (const character of s) {
    const previousCount = frequencies.get(character) ?? 0;
    frequencies.set(character, previousCount + 1);
  }

  for (const character of t) {
    const availableCount = frequencies.get(character) ?? 0;

    if (availableCount === 0) {
      return false;
    }

    frequencies.set(character, availableCount - 1);
  }

  return true;
}
```

---

## 7. Code walkthrough

### `s.length !== t.length`

Anagrams must contain the same total number of characters. Rejecting unequal lengths avoids unnecessary work.

### `new Map()`

The key is a character and the value is its available count. `Map` avoids plain-object key coercion and inherited-property concerns.

### `frequencies.get(character) ?? 0`

`Map.get()` returns `undefined` for a missing key. Nullish coalescing converts only `null` or `undefined` to zero.

Using `??` expresses missing-count handling precisely. `|| 0` also works here because zero should become zero, but `??` is semantically clearer.

### Early failure while consuming `t`

If the available count is zero, either:

- the character never appeared in `s`, or
- `t` uses it more times than `s`.

Either case proves the strings are not anagrams.

### Why no final count scan?

Both strings have equal length. If every character in `t` successfully consumes one character from `s`, exactly the full inventory has been consumed.

---

## 8. One-map balance alternative

We can increment for `s` and decrement for `t` in a single indexed loop:

```javascript
function isAnagramBalanced(s, t) {
  if (s.length !== t.length) return false;

  const balance = new Map();

  for (let i = 0; i < s.length; i++) {
    balance.set(s[i], (balance.get(s[i]) ?? 0) + 1);
    balance.set(t[i], (balance.get(t[i]) ?? 0) - 1);
  }

  for (const count of balance.values()) {
    if (count !== 0) return false;
  }

  return true;
}
```

This is also O(n) time and O(k) space. The inventory-and-consumption version can fail early and is usually easier to narrate.

---

## 9. Fixed alphabet optimization

The official problem says `s` and `t` contain lowercase English letters. Therefore, a fixed array of 26 counts is sufficient:

```javascript
function isAnagramLowercaseEnglish(s, t) {
  if (s.length !== t.length) return false;

  const counts = new Array(26).fill(0);
  const codeOfA = 'a'.charCodeAt(0);

  for (let i = 0; i < s.length; i++) {
    counts[s.charCodeAt(i) - codeOfA]++;
    counts[t.charCodeAt(i) - codeOfA]--;
  }

  return counts.every((count) => count === 0);
}
```

Complexity:

- Time: **O(n)**.
- Extra space: **O(1)** because the array always contains 26 entries.

This version is more space-efficient under the lowercase-English constraint. The `Map` solution generalizes more naturally to a larger character set.

Interview judgment:

> Start from the stated constraint. Mention the map as the general form and use the 26-element array when lowercase English letters are guaranteed.

---

## 10. Correctness reasoning

Invariant after processing part of `t`:

> For every character, its stored count equals how many copies from `s` remain after consuming the processed prefix of `t`.

The first loop establishes the full inventory of `s`. Each character from `t` consumes one matching unit. Encountering zero means `t` requests a unit that does not exist, proving the strings differ in composition.

If the entire equal-length string `t` is consumed without failure, it has used exactly all characters supplied by `s`, so the strings are anagrams.

---

## 11. Complexity

For the `Map` solution:

- **Time: O(n)** average — both equal-length strings are scanned once, and map operations are O(1) average.
- **Extra space: O(k)** — `k` is the number of distinct characters in `s`; worst case O(n) for an unbounded alphabet.

Under the official 26-letter constraint, `k ≤ 26`, so the space can be described as O(1). State the assumption explicitly rather than giving complexity without context.

For the fixed-array solution:

- **Time: O(n)**.
- **Extra space: O(1)**.

---

## 12. Common mistakes

1. **Checking only whether the same character types appear.** Frequencies must match too.
2. **Forgetting the length check.** A prefix could consume successfully while extra inventory remains.
3. **Using a `Set`.** A set tracks existence, not multiplicity; `aab` and `abb` defeat it.
4. **Comparing characters position by position.** Anagrams may reorder characters.
5. **Claiming sorting is O(n).** Comparison sorting is O(n log n).
6. **Calling map space O(1) without stating a fixed alphabet.** For general characters, it is O(k), up to O(n).
7. **Using `if (!frequencies.get(character))` without understanding it.** Zero and missing both become falsy. That happens to express “unavailable” here, but an explicit `availableCount === 0` is clearer.
8. **Ignoring Unicode requirements in production.** JavaScript iteration and normalization rules may need clarification for real human-language text.

---

## 13. What to say in an interview

> “Anagrams require equal lengths and equal character frequencies. I’ll count every character in the first string, then consume those counts using the second. If a character is missing or its available count reaches zero before consumption, I return false. Otherwise equal length guarantees the full inventory was consumed. This is O(n) average time and O(k) space for k distinct characters.”

Under the lowercase-English constraint:

> “Since there are only 26 possible characters, I can replace the map with a 26-element count array, making auxiliary space O(1).”

---

## 14. Pattern recognition

Think **frequency counting** when:

- order does not matter;
- multiplicity does matter;
- two collections must have the same composition;
- the question asks whether items can be rearranged into another form.

Related signals:

- anagrams;
- permutations;
- character inventories;
- counting pairs;
- grouping equivalent strings;
- comparing multisets.

Memory cue:

> Ignore order; balance the inventory.

---

## 15. Unicode production note

The interview problem constrains input to lowercase English letters. Real text may require decisions about:

- case sensitivity;
- whitespace and punctuation;
- composed versus decomposed accents;
- Unicode normalization such as NFC;
- whether grapheme clusters or code points count as “characters.”

For example, visually identical accented text can have different underlying code-point sequences. Clarify and normalize according to the product's definition before counting. Do not introduce this complexity into the LeetCode solution unless requirements demand it.

---

## 16. Edge cases

| `s` | `t` | Result | Reason |
|---|---|---:|---|
| `""` | `""` | `true` | Both inventories empty |
| `"a"` | `"a"` | `true` | Same single character |
| `"a"` | `"b"` | `false` | Different character |
| `"ab"` | `"a"` | `false` | Different lengths |
| `"aab"` | `"aba"` | `true` | Same frequencies |
| `"aab"` | `"abb"` | `false` | Frequencies differ |
| `"abc"` | `"cba"` | `true` | Order is irrelevant |

---

## 17. Notebook-ready notes

### 📚 Concept

**Valid Anagram — frequency map**

```text
Different lengths → false
Count every character in s
Consume counts using t
Unavailable character → false
All consumed → true
```

### 🧠 My understanding

An anagram is equality of character inventories, not equality of order. I count what `s` supplies and let `t` consume it. Equal length plus successful consumption proves exact frequency equality.

### 💼 Interview line

> “Because order is irrelevant but multiplicity matters, I’ll compare character frequencies.”

### ⚠️ Traps

- A `Set` loses duplicate counts.
- General map space is O(k), not automatically O(1).
- With exactly 26 lowercase letters, a fixed count array gives O(1) space.

---

## 18. Dheerix Glance

```text
VALID ANAGRAM

Signal:          same items, order irrelevant
Requirement:     equal character frequencies
Early check:     equal lengths
Structure:       character → remaining count
Process s:       add inventory
Process t:       consume inventory
Failure:         requested count is zero
Time:            O(n)
Space:           O(k), or O(1) for fixed 26 letters
Memory cue:      “Ignore order; balance inventory.”
```

---

## 19. Recall test

Without looking back:

1. Why is a `Set` insufficient?
2. Why is equal length necessary but not sufficient?
3. What does the frequency count represent while processing `t`?
4. Why can the inventory solution skip a final zero-count scan?
5. When is space O(k), and when can it be called O(1)?
6. What is the time complexity of the sorting solution?
7. State the correctness invariant in one sentence.

