# Grind 75 — 15: Ransom Note

**Difficulty:** Easy  
**Primary pattern:** Frequency counting / inventory consumption  
**LeetCode:** https://leetcode.com/problems/ransom-note/  
**Target time:** 15 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given two strings, `ransomNote` and `magazine`, determine whether the ransom note can be constructed using characters from the magazine.

Each magazine character can be used at most once.

```text
ransomNote = "aa"
magazine   = "aab"
result     = true
```

```text
ransomNote = "aa"
magazine   = "ab"
result     = false
```

Order does not matter. Available frequency does.

---

## 2. Inventory interpretation

Treat the magazine as an inventory:

```text
character → available quantity
```

Treat the ransom note as a list of requirements. Every note character consumes one matching magazine character.

```text
magazine supplies ≥ ransom note requires
```

The magazine may have unused characters. This is the key difference from Valid Anagram.

---

## 3. Necessary early check

If the ransom note contains more characters than the magazine, construction is impossible:

```javascript
if (ransomNote.length > magazine.length) return false;
```

This is only an early rejection. A longer magazine may still lack the required character types or frequencies.

---

## 4. Approaches considered

### Repeated string search and removal

For each note character, search the magazine and remove one matching occurrence.

This repeatedly scans strings and creates new strings because JavaScript strings are immutable. Worst-case time can become O(nm), making it unsuitable.

### Sorting both strings

After sorting, two pointers can check whether all note characters appear within the magazine counts. Sorting costs O(m log m + n log n) and creates intermediate arrays.

### Frequency counting

Count the magazine once, then consume counts with the ransom note.

- Time: O(m + n)
- Space: O(k), or O(1) for a fixed 26-letter alphabet

This is the preferred approach.

---

## 5. Step-by-step algorithm

1. If `ransomNote` is longer than `magazine`, return `false`.
2. Count every character in `magazine`.
3. For each character in `ransomNote`:
   - read its available count;
   - if the count is zero, return `false`;
   - otherwise decrement the count.
4. Return `true` if all requirements were fulfilled.

We do not require every magazine count to become zero. Surplus inventory is allowed.

---

## 6. General JavaScript solution with `Map`

```javascript
function canConstruct(ransomNote, magazine) {
  if (ransomNote.length > magazine.length) {
    return false;
  }

  const available = new Map();

  for (const character of magazine) {
    available.set(
      character,
      (available.get(character) ?? 0) + 1,
    );
  }

  for (const character of ransomNote) {
    const remaining = available.get(character) ?? 0;

    if (remaining === 0) {
      return false;
    }

    available.set(character, remaining - 1);
  }

  return true;
}
```

---

## 7. Dry run

```text
ransomNote = "aabc"
magazine   = "cabada"
```

Magazine inventory:

```text
a → 3
b → 1
c → 1
d → 1
```

| Required | Before | After |
|---|---:|---:|
| `a` | 3 | 2 |
| `a` | 2 | 1 |
| `b` | 1 | 0 |
| `c` | 1 | 0 |

Every requirement succeeds, so return `true`. The unused `a` and `d` do not matter.

Failure example:

```text
ransomNote = "aabc"
magazine   = "cabd"
```

The second `a` finds an available count of zero, so return `false` immediately.

---

## 8. Code walkthrough

### Why count the magazine?

The magazine is the source of consumable resources. Counting the note instead is possible, but then the magazine traversal must reduce outstanding requirements and track when all are satisfied. The inventory-first direction is the most direct explanation.

### `available.get(character) ?? 0`

A missing map key means no copies are available. Nullish coalescing converts `undefined` to zero explicitly.

### Failure at zero

Zero can mean:

- the magazine never contained the character; or
- earlier note characters consumed all copies.

Both make construction impossible.

### Why not check leftover counts?

The problem asks whether the magazine contains **at least** what the note needs. Extra magazine characters are allowed.

---

## 9. Fixed-array solution for official constraints

The official problem guarantees lowercase English letters, so there are only 26 possible characters.

```javascript
function canConstructLowercase(ransomNote, magazine) {
  if (ransomNote.length > magazine.length) {
    return false;
  }

  const counts = new Array(26).fill(0);
  const codeOfA = 'a'.charCodeAt(0);

  for (let i = 0; i < magazine.length; i++) {
    const index = magazine.charCodeAt(i) - codeOfA;
    counts[index]++;
  }

  for (let i = 0; i < ransomNote.length; i++) {
    const index = ransomNote.charCodeAt(i) - codeOfA;
    counts[index]--;

    if (counts[index] < 0) {
      return false;
    }
  }

  return true;
}
```

This is the strongest solution under the stated constraint:

- Time: **O(m + n)**.
- Extra space: **O(1)** because the array always contains exactly 26 entries.

The decrement-first style detects when demand exceeds supply because a count becomes negative.

---

## 10. Correctness reasoning

Invariant while processing the ransom note:

> `available[c]` equals the number of unused copies of character `c` remaining in the magazine after satisfying the processed note prefix.

The magazine-counting loop establishes the initial inventory. Each note character consumes exactly one matching unit. If no unit exists, no construction can satisfy that occurrence because magazine characters cannot be reused.

If every note character is consumed successfully, the magazine supplies every required occurrence, so the ransom note can be constructed. Unused inventory does not affect correctness.

---

## 11. Complexity

Let:

```text
n = ransomNote.length
m = magazine.length
k = number of distinct magazine characters
```

Map solution:

- **Time: O(n + m)** average.
- **Extra space: O(k)**, up to O(m) for a general character set.

Fixed 26-element array:

- **Time: O(n + m)**.
- **Extra space: O(1)** under lowercase-English constraints.

State the alphabet assumption when claiming constant space.

---

## 12. Ransom Note versus Valid Anagram

| Property | Ransom Note | Valid Anagram |
|---|---|---|
| Relationship | required inventory is a subset | inventories are equal |
| Lengths | note can be shorter | must be equal |
| Extra source characters | allowed | not allowed |
| Count condition | magazine count ≥ note count | counts exactly equal |
| Final zero-count scan | unnecessary | may be required depending on implementation |

Examples:

```text
note="ab", magazine="aabb" → true
s="ab", t="aabb"           → not anagrams
```

Recognizing the exact contract prevents blindly reusing a similar-looking solution incorrectly.

---

## 13. Alternative: count outstanding requirements

Count the ransom note first, then scan the magazine until all required characters are satisfied:

```javascript
function canConstructRequirements(ransomNote, magazine) {
  if (ransomNote.length > magazine.length) return false;

  const needed = new Map();
  let remainingCharacters = ransomNote.length;

  for (const character of ransomNote) {
    needed.set(character, (needed.get(character) ?? 0) + 1);
  }

  for (const character of magazine) {
    const remainingNeed = needed.get(character) ?? 0;

    if (remainingNeed > 0) {
      needed.set(character, remainingNeed - 1);
      remainingCharacters--;

      if (remainingCharacters === 0) {
        return true;
      }
    }
  }

  return remainingCharacters === 0;
}
```

This may return before reading a long magazine. Its worst-case complexity remains O(n + m). The inventory solution is slightly simpler; this variation is useful when the source is large or streamed.

---

## 14. Common mistakes

1. **Using a `Set`.** It cannot represent multiple required copies, such as `"aa"`.
2. **Reusing one magazine character more than once.** Every occurrence is consumable once.
3. **Requiring equal lengths.** The magazine may contain extra characters.
4. **Requiring all magazine counts to reach zero.** Surplus inventory is permitted.
5. **Comparing character order.** Characters can be selected from anywhere in the magazine.
6. **Repeatedly searching and slicing strings.** This can become quadratic and creates immutable-string copies.
7. **Calling general map space O(1).** It is O(k) unless the alphabet is fixed.
8. **Forgetting the early length rejection.** It is not required for correctness with counts, but it avoids needless work and clarifies impossibility.
9. **Confusing this with a subsequence problem.** Magazine character order is irrelevant.

---

## 15. What to say in an interview

> “This is an inventory problem. I’ll count the characters supplied by the magazine, then consume one count for every ransom-note character. If any required count is unavailable, I return false; otherwise all requirements are satisfied. This is O(n + m) time. With a general map, space is O(k), but because the inputs are lowercase English letters, a 26-element array gives O(1) extra space.”

If asked how it differs from an anagram:

> “An anagram requires exact inventory equality; here the magazine only needs to be a sufficient superset.”

---

## 16. Pattern recognition

Think **frequency inventory** when:

- one collection supplies resources;
- another collection consumes them;
- each item has limited multiplicity;
- order does not matter;
- the requirement is “can this be constructed?”

Before coding, identify whether the relationship is:

```text
equality     → same exact frequencies
sufficiency  → supply frequencies at least demand
```

Memory cue:

> Count the supply; consume the demand.

---

## 17. Edge cases

| Ransom note | Magazine | Result | Reason |
|---|---|---:|---|
| `""` | `""` | `true` | Nothing required |
| `""` | `"abc"` | `true` | Empty demand |
| `"a"` | `""` | `false` | No supply |
| `"a"` | `"a"` | `true` | Exact supply |
| `"aa"` | `"a"` | `false` | Insufficient multiplicity |
| `"ab"` | `"ba"` | `true` | Order irrelevant |
| `"abc"` | `"aabbcc"` | `true` | Surplus allowed |

---

## 18. Notebook-ready notes

### 📚 Concept

**Ransom Note — inventory sufficiency**

```text
note longer than magazine → false
count magazine supply
for each note character:
  count zero → false
  otherwise decrement
all requirements consumed → true
```

### 🧠 My understanding

The magazine is a consumable multiset. The note does not need exact equality; it needs no character demand to exceed supply. Therefore, leftover magazine counts are valid and require no final check.

### 💼 Interview line

> “I’ll count the available supply and consume it once per required character.”

### ⚠️ Traps

- Use counts, not a set.
- Extra magazine characters are allowed.
- This is not a subsequence problem.
- Fixed 26-letter input allows O(1) space.

---

## 19. Dheerix Glance

```text
RANSOM NOTE

Model:            supply vs demand
Supply:           magazine characters
Demand:           ransom-note characters
Relationship:     supply count >= demand count
Structure:        frequency map or 26-array
Failure:          required count unavailable
Leftover supply:  allowed
Time:             O(n + m)
Space:            O(k), or O(1) for 26 letters
Memory cue:       “Count supply; consume demand.”
```

---

## 20. Recall test

Without looking back:

1. Why is a `Set` insufficient?
2. Why do the input lengths not need to be equal?
3. What does each stored count represent while processing the note?
4. Why is no final zero-count scan needed?
5. How is this contract different from Valid Anagram?
6. When is the extra space O(k), and when is it O(1)?
7. Why is this not a subsequence problem?
8. State the invariant in one sentence.

