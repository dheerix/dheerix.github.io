# Grind 75 — 17: Longest Palindrome

**Difficulty:** Easy  
**Primary pattern:** Frequency parity / greedy counting  
**LeetCode:** https://leetcode.com/problems/longest-palindrome/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given a string, rearrange some or all of its characters to form the longest possible palindrome. Return only that maximum length.

Characters are case-sensitive:

```text
"a" and "A" are different characters
```

Example:

```text
s = "abccccdd"

One longest palindrome: "dccaccd"
Length: 7
```

You do not need to return the palindrome itself.

---

## 2. Structural property of palindromes

Every character away from the center must have a matching copy on the opposite side.

```text
left half | optional center | mirrored right half
```

Therefore:

- non-center characters are used in pairs;
- every pair contributes `2` to the length;
- at most one unpaired character may occupy the center.

Examples:

```text
even-length palindrome: abccba
odd-length palindrome:  abcxcba
                            ↑ one center
```

There can be many characters with odd frequencies in the input, but only one leftover odd unit can be used as the palindrome center.

---

## 3. Frequency-based derivation

For a character occurring `count` times:

```text
largest usable even amount = count,     if count is even
                             count - 1, if count is odd
```

This can be written as:

```javascript
count - (count % 2)
```

After taking all possible pairs, if any odd frequency existed, add exactly one center character.

Formula:

```text
answer = sum(largest even part of every count)
         + 1 if any odd count exists
```

---

## 4. Dry run with counts

```text
s = "abccccdd"
```

Frequencies:

```text
a → 1
b → 1
c → 4
d → 2
```

| Character | Count | Paired contribution | Leftover |
|---|---:|---:|---:|
| `a` | 1 | 0 | 1 |
| `b` | 1 | 0 | 1 |
| `c` | 4 | 4 | 0 |
| `d` | 2 | 2 | 0 |

Paired length is `6`. At least one odd leftover exists, so one character can be placed in the center:

```text
6 + 1 = 7
```

We cannot use both leftover `a` and leftover `b`, because a palindrome has only one center position.

---

## 5. Frequency-map solution

```javascript
function longestPalindromeWithCounts(s) {
  const frequencies = new Map();

  for (const character of s) {
    frequencies.set(
      character,
      (frequencies.get(character) ?? 0) + 1,
    );
  }

  let length = 0;
  let hasOddCount = false;

  for (const count of frequencies.values()) {
    length += count - (count % 2);

    if (count % 2 === 1) {
      hasOddCount = true;
    }
  }

  return length + (hasOddCount ? 1 : 0);
}
```

- Time: **O(n)**.
- Extra space: **O(k)** for `k` distinct characters.

This solution mirrors the mathematical derivation directly.

---

## 6. Optimal one-pass pairing insight

We do not need final frequencies. We only need to know whether each incoming character completes a pair.

Maintain a set of currently unpaired characters:

```text
character not in set → add it as unmatched
character in set     → remove it; a pair is completed
```

Every completed pair adds `2` to the answer.

At the end:

- empty set: no leftover character is available for a center;
- non-empty set: at least one leftover can occupy the center.

The set does **not** lose necessary multiplicity here. It tracks only the parity—odd or even—of the number of occurrences seen so far.

---

## 7. Optimal JavaScript solution

```javascript
function longestPalindrome(s) {
  const unpaired = new Set();
  let length = 0;

  for (const character of s) {
    if (unpaired.has(character)) {
      unpaired.delete(character);
      length += 2;
    } else {
      unpaired.add(character);
    }
  }

  if (unpaired.size > 0) {
    length += 1;
  }

  return length;
}
```

---

## 8. One-pass dry run

```text
s = "abccccdd"
```

| Character read | Unpaired before | Action | Length | Unpaired after |
|---|---|---|---:|---|
| `a` | `{}` | add | 0 | `{a}` |
| `b` | `{a}` | add | 0 | `{a,b}` |
| `c` | `{a,b}` | add | 0 | `{a,b,c}` |
| `c` | `{a,b,c}` | complete pair | 2 | `{a,b}` |
| `c` | `{a,b}` | add | 2 | `{a,b,c}` |
| `c` | `{a,b,c}` | complete pair | 4 | `{a,b}` |
| `d` | `{a,b}` | add | 4 | `{a,b,d}` |
| `d` | `{a,b,d}` | complete pair | 6 | `{a,b}` |

Two unmatched character types remain. Add only one center:

```text
length = 6 + 1 = 7
```

---

## 9. Code walkthrough

### `unpaired` represents parity

After processing a prefix:

```text
character in set     → seen an odd number of times not yet paired
character not in set → seen an even number of times, fully paired
```

The set toggles membership on every occurrence.

### Pair completion

If the character is already unpaired, the new occurrence forms a pair with it. Remove the pending character and add two to the palindrome length.

### Center decision

```javascript
if (unpaired.size > 0) length += 1;
```

The number of odd character types does not matter beyond zero versus nonzero. A palindrome has at most one center.

### Case sensitivity

JavaScript `Set` keys distinguish `'a'` from `'A'`, matching the problem definition.

---

## 10. Correctness reasoning

Every time the algorithm sees a second unmatched copy of a character, it forms a pair. Any palindrome can use characters outside its center only in such equal pairs, so every `+2` contribution is valid.

The algorithm forms all possible pairs for every character: a character with count `c` produces `floor(c / 2)` pairs. Therefore no solution can use more non-center characters.

If any unpaired character remains, one can be placed at the center, adding one. No palindrome can use more than one unpaired center character. Thus the returned length is achievable and maximal.

---

## 11. Complexity

- **Time: O(n)** average — scan the string once; set operations are O(1) average.
- **Extra space: O(k)** — `k` is the number of distinct characters with odd current frequency, at most the number of distinct input characters and at most `n`.

If the character alphabet is fixed and bounded, space can be treated as O(1). For a general string, state O(k).

---

## 12. Alternative arithmetic shortcut

With frequencies, another common expression is:

```javascript
function longestPalindromeArithmetic(s) {
  const counts = new Map();

  for (const character of s) {
    counts.set(character, (counts.get(character) ?? 0) + 1);
  }

  let length = 0;

  for (const count of counts.values()) {
    length += Math.floor(count / 2) * 2;
  }

  return length < s.length ? length + 1 : length;
}
```

Why does `length < s.length` mean an odd count exists? `length` includes every paired character. If it is smaller than the total input length, at least one character was left unpaired and can be used as the center.

This is concise, though an explicit `hasOddCount` may be easier to explain.

---

## 13. Why greedy pairing is optimal

Could using fewer pairs of one character somehow allow a longer palindrome? No.

Every pair contributes two positions and does not compete with pairs of other character types. Taking a pair never prevents taking another pair. All pairs can coexist symmetrically around the same optional center.

Therefore, greedily using every available pair is globally optimal.

---

## 14. Common mistakes

1. **Trying to find a palindromic substring.** Characters may be rearranged; this is not Longest Palindromic Substring.
2. **Using only distinct-character count.** Exact frequencies and parity matter.
3. **Adding one for every odd frequency.** At most one odd leftover can occupy the center.
4. **Discarding all of an odd count.** A count of five contributes four paired characters plus possibly one center.
5. **Ignoring case sensitivity.** `'a'` and `'A'` cannot form a pair.
6. **Returning the constructed string.** The problem requests only maximum length.
7. **Claiming the general set solution is O(1) space.** It is O(k) unless the alphabet is fixed.
8. **Saying a `Set` always loses duplicate information.** Here it intentionally stores parity, not full frequency.
9. **Confusing “odd count exists” with “odd number of odd counts.”** Any nonzero number of odd counts permits exactly one center.

---

## 15. What to say in an interview

> “Every non-center character in a palindrome must appear as a mirrored pair. I’ll greedily use every possible pair. A set can track frequency parity: the first unmatched copy is added; the next copy removes it and contributes two characters. After processing the string, if any unpaired character remains, exactly one can occupy the center. This is O(n) average time and O(k) space.”

If asked why the set is sufficient:

> “The answer needs only the number of completed pairs and whether any odd leftover exists, not the exact final frequencies.”

---

## 16. Pattern recognition

Think **frequency parity** when:

- symmetric construction requires equal pairs;
- only odd/even occurrence status matters;
- one exceptional center or leftover is permitted;
- characters may be rearranged.

Before selecting an approach, distinguish:

```text
palindrome validation  → compare an existing order
palindrome construction→ count available pairs
palindromic substring   → preserve contiguous order
```

Memory cue:

> Take every pair; spend one leftover on the center.

---

## 17. Edge cases

| Input | Result | Reason |
|---|---:|---|
| `""` | 0 | No characters |
| `"a"` | 1 | One center |
| `"aa"` | 2 | One pair |
| `"ab"` | 1 | Only one can be center |
| `"aaa"` | 3 | One pair plus center |
| `"aaaa"` | 4 | Two pairs |
| `"Aa"` | 1 | Case-sensitive, no pair |
| `"abccccdd"` | 7 | Three pairs plus center |

---

## 18. Notebook-ready notes

### 📚 Concept

**Longest Palindrome — character pairs + one optional center**

```text
Every pair contributes 2
Track currently unpaired characters
Second copy completes a pair
If any unpaired remains, add 1 center
```

### 🧠 My understanding

A palindrome's two sides consume characters in identical pairs. I should use every available pair because pairs do not conflict. After that, no matter how many odd leftovers exist, only one can occupy the single center position.

### 💼 Interview line

> “I’ll maximize mirrored pairs, then use at most one leftover character as the center.”

### ⚠️ Traps

- Rearrangement is allowed; substring logic is irrelevant.
- Use the even portion of every odd count.
- Add at most one total center.
- Character comparison is case-sensitive.

---

## 19. Dheerix Glance

```text
LONGEST PALINDROME

Structure:        mirrored pairs + optional center
Pair value:       2 characters
Track:            characters with odd current count
On second copy:   remove from set, length += 2
At end:           non-empty set → length += 1
Greedy reason:    pairs do not compete
Time:             O(n) average
Space:            O(k)
Memory cue:       “All pairs, one leftover.”
```

---

## 20. Recall test

Without looking back:

1. Why must non-center characters be used in pairs?
2. What does membership in the `unpaired` set mean?
3. Why does completing a pair add exactly two?
4. Why can only one odd leftover be used?
5. Why is greedily taking every pair optimal?
6. How does this differ from Longest Palindromic Substring?
7. When is the space O(k), and when can it be treated as O(1)?
8. State the invariant in one sentence.

