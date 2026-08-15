# Grind 75 — 05: Valid Palindrome

**Difficulty:** Easy  
**Primary pattern:** Two pointers / string normalization  
**LeetCode:** https://leetcode.com/problems/valid-palindrome/  
**Target time:** 15 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Determine whether a string reads the same forward and backward after:

- converting uppercase letters to lowercase;
- ignoring every character that is not a letter or digit.

```text
Input:  "A man, a plan, a canal: Panama"
Clean:  "amanaplanacanalpanama"
Output: true
```

```text
Input:  "race a car"
Clean:  "raceacar"
Output: false
```

An empty cleaned string is considered a palindrome.

---

## 2. What must be compared?

A palindrome is symmetric:

```text
first meaningful character  ↔ last meaningful character
second meaningful character ↔ second-last meaningful character
...
```

This naturally suggests two pointers:

```text
left →                      ← right
```

The pointers move toward one another. Each pointer skips punctuation and spaces. When both point at alphanumeric characters, compare them case-insensitively.

---

## 3. Simple approach: normalize, reverse, compare

```javascript
function isPalindromeNormalized(s) {
  const cleaned = s.toLowerCase().replace(/[^a-z0-9]/g, '');
  const reversed = cleaned.split('').reverse().join('');

  return cleaned === reversed;
}
```

### Complexity

- Time: **O(n)**.
- Extra space: **O(n)** for the cleaned string, character array, and reversed string.

This is concise and often acceptable. However, it creates several intermediate objects. The two-pointer version performs the comparison directly with O(1) auxiliary space.

---

## 4. Optimal insight: clean logically, not physically

We do not need to construct the cleaned string. We can behave as if it exists:

1. Move `left` forward past non-alphanumeric characters.
2. Move `right` backward past non-alphanumeric characters.
3. Compare the normalized characters.
4. If they differ, return `false`.
5. Otherwise move both inward.
6. If the pointers meet or cross, return `true`.

This is an example of **logical filtering**: ignore unwanted data during traversal rather than copying wanted data elsewhere.

---

## 5. JavaScript character classification

The official LeetCode problem uses English letters and digits. A character is alphanumeric if its character code falls in one of these ranges:

```text
0–9: 48–57
A–Z: 65–90
a–z: 97–122
```

```javascript
function isAlphaNumeric(character) {
  const code = character.charCodeAt(0);

  const isDigit = code >= 48 && code <= 57;
  const isUppercaseLetter = code >= 65 && code <= 90;
  const isLowercaseLetter = code >= 97 && code <= 122;

  return isDigit || isUppercaseLetter || isLowercaseLetter;
}
```

This avoids repeatedly running a regular expression inside the loop and makes the accepted character set explicit.

---

## 6. Dry run

```text
s = "A man, a plan, a canal: Panama"
```

Selected comparisons:

| Left character | Right character | Normalized | Result |
|---|---|---|---|
| `A` | `a` | `a` vs `a` | match |
| `m` | `m` | `m` vs `m` | match |
| `a` | `a` | `a` vs `a` | match |
| `n` | `n` | `n` vs `n` | match |

Spaces, commas, and the colon are skipped independently. Eventually the pointers meet without a mismatch, so the result is `true`.

Invalid example:

```text
"0P"

left  = '0'
right = 'P' → 'p'
'0' !== 'p' → false
```

Digits must not be discarded.

---

## 7. Optimal JavaScript solution

```javascript
function isPalindrome(s) {
  let left = 0;
  let right = s.length - 1;

  while (left < right) {
    while (left < right && !isAlphaNumeric(s[left])) {
      left++;
    }

    while (left < right && !isAlphaNumeric(s[right])) {
      right--;
    }

    if (s[left].toLowerCase() !== s[right].toLowerCase()) {
      return false;
    }

    left++;
    right--;
  }

  return true;
}

function isAlphaNumeric(character) {
  const code = character.charCodeAt(0);

  return (
    (code >= 48 && code <= 57) ||
    (code >= 65 && code <= 90) ||
    (code >= 97 && code <= 122)
  );
}
```

---

## 8. Code walkthrough

### `left = 0`, `right = s.length - 1`

The pointers begin at opposite ends because palindrome symmetry pairs outer characters first.

### Independent skip loops

```javascript
while (left < right && !isAlphaNumeric(s[left])) left++;
while (left < right && !isAlphaNumeric(s[right])) right--;
```

One side may contain several ignored characters while the other already points at a meaningful character. Each pointer must therefore skip independently.

The `left < right` guard prevents a pointer from walking beyond the valid comparison region.

### Case normalization at comparison time

Only the two characters currently being compared are lowercased. The original string remains unchanged and no normalized copy is created.

### Early return

One mismatched symmetric pair proves the whole string is not a palindrome. No later comparison can repair it.

### Pointer convergence

If `left === right`, the pointer is on the unpaired middle character of an odd-length palindrome. A single central character cannot violate symmetry.

---

## 9. Correctness reasoning

Loop invariant:

> Before each comparison, every meaningful character outside the interval `[left, right]` has already been matched with its symmetric counterpart.

The skip loops remove only characters that the problem definition says to ignore. The next alphanumeric characters at the left and right boundaries must correspond in the logically cleaned string. If they differ after case normalization, the string cannot be a palindrome. If they match, moving inward preserves the invariant.

When the pointers meet or cross, every required symmetric pair has matched, so the string is a palindrome.

---

## 10. Complexity

- **Time: O(n)** — each pointer moves in only one direction and crosses each character at most once.
- **Auxiliary space: O(1)** — no cleaned or reversed string grows with the input.

The nested-looking skip loops do **not** make the solution O(n²). Across the entire function, `left` advances at most `n` positions and `right` retreats at most `n` positions.

---

## 11. Common mistakes

1. **Ignoring only spaces.** Punctuation such as commas and colons must also be skipped.
2. **Discarding digits.** Digits are alphanumeric; `"0P"` must return `false`.
3. **Comparing case-sensitively.** `A` and `a` should match.
4. **Moving both pointers when only one points at punctuation.** Skip each side independently.
5. **Forgetting bounds in the skip loops.** A string containing only punctuation must not access beyond its valid range.
6. **Assuming nested loops imply O(n²).** Pointer movement is monotonic and bounded by `n`.
7. **Using `\w` as an exact alphanumeric definition.** In JavaScript regex, `\w` also includes underscore, which this problem does not count as alphanumeric.
8. **Reversing the original uncleaned string.** Normalization rules must be applied before logical comparison.

---

## 12. What to say in an interview

> “A palindrome compares symmetric characters, so I’ll use pointers at both ends. Each pointer skips characters that are not letters or digits. When both point at meaningful characters, I compare their lowercase forms and fail immediately on a mismatch. Otherwise I move inward. Each pointer traverses the string once, giving O(n) time and O(1) auxiliary space.”

If asked why the loops are linear:

> “Neither pointer ever moves backward, so the total number of pointer movements is bounded by twice the string length.”

---

## 13. Pattern recognition

Think **two pointers from opposite ends** when:

- the property is symmetric;
- pairs are formed between the beginning and end;
- the search interval shrinks after each comparison;
- the input can be processed without rearranging it.

Think **logical filtering** when:

- some elements should be ignored;
- building a filtered copy is unnecessary;
- pointers can skip unwanted values during traversal.

Memory cue:

> Skip noise; compare the meaningful outer pair; move inward.

---

## 14. Regex helper alternative

For interview speed, this helper is shorter:

```javascript
function isPalindromeWithRegex(s) {
  let left = 0;
  let right = s.length - 1;
  const isAlphaNumeric = (character) => /[a-z0-9]/i.test(character);

  while (left < right) {
    while (left < right && !isAlphaNumeric(s[left])) left++;
    while (left < right && !isAlphaNumeric(s[right])) right--;

    if (s[left].toLowerCase() !== s[right].toLowerCase()) {
      return false;
    }

    left++;
    right--;
  }

  return true;
}
```

This remains O(n) for fixed-size character tests and is acceptable in most interviews. The character-code version makes the domain and constant-space mechanics more explicit.

---

## 15. Unicode production note

The LeetCode constraints are effectively ASCII-oriented. Real applications may require Unicode-aware normalization:

- accented letters can have multiple representations;
- case conversion can be locale-sensitive;
- letters exist far beyond `A–Z`;
- grapheme clusters may contain multiple code points.

In production, clarify the definition of “alphanumeric” and “same character.” A Unicode-aware regular expression such as `/[\p{L}\p{N}]/u` may be more appropriate, alongside an agreed normalization form. Do not complicate the interview solution unless the interviewer expands the requirements.

---

## 16. Edge cases

| Input | Result | Reason |
|---|---:|---|
| `""` | `true` | Cleaned string is empty |
| `"a"` | `true` | One character |
| `".,"` | `true` | No meaningful characters |
| `"Aa"` | `true` | Case-insensitive match |
| `"0P"` | `false` | Digits participate |
| `"ab_a"` | `true` | `_` is ignored; cleaned string is `aba` |
| `"race a car"` | `false` | Meaningful characters mismatch |

---

## 17. Notebook-ready notes

### 📚 Concept

**Valid Palindrome — opposite-end two pointers**

```text
left at start, right at end
skip non-alphanumeric on each side
compare lowercase characters
mismatch → false
match → move inward
pointers meet/cross → true
```

### 🧠 My understanding

I do not need to build the cleaned string. The two pointers logically filter it by skipping noise. Each meaningful outer pair must match, and pointer convergence proves every required pair has been checked.

### 💼 Interview line

> “I’ll compare the logically normalized string in place using two inward-moving pointers.”

### ⚠️ Traps

- Digits count.
- Skip punctuation independently on both sides.
- Include bounds in skip loops.
- `\w` includes underscore, so it is not the exact rule.

---

## 18. Dheerix Glance

```text
VALID PALINDROME

Signal:          symmetric comparison
Pointers:        left →     ← right
Ignore:          non-alphanumeric characters
Normalize:       case at comparison time
Mismatch:        return false immediately
Finish:          pointers meet or cross
Time:            O(n)
Auxiliary space: O(1)
Memory cue:      “Skip noise, compare symmetry.”
```

---

## 19. Recall test

Without looking back:

1. Why are two pointers a natural fit for a palindrome?
2. Why must the pointers skip independently?
3. Why do the nested skip loops remain O(n)?
4. Why is `\w` not an exact match for the problem's allowed characters?
5. What happens for a string containing only punctuation?
6. What does the loop invariant say?
7. What space is saved compared with normalize-reverse-compare?
