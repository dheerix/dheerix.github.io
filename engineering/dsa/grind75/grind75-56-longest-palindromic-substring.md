# Grind 75 — 56. Longest Palindromic Substring

## Problem

Given a string `s`, return its longest palindromic substring.

A palindrome reads the same forward and backward.

Examples:

```text
"babad" → "bab" or "aba"
"cbbd"  → "bb"
```

The answer must be a contiguous substring, not a subsequence.

---

## 1. Brute-force idea

Generate every substring and check whether it is a palindrome.

There are O(n²) substrings, and checking one can take O(n), giving:

```text
O(n³) time
```

We can do better by using the symmetry of palindromes directly.

---

## 2. Every palindrome has a center

A palindrome expands symmetrically from its middle.

There are two center types.

### Odd length

One character is the center:

```text
"racecar"
    ↑
```

Initialize:

```text
left = center
right = center
```

### Even length

The center lies between two characters:

```text
"abba"
   ↑
```

Initialize:

```text
left = center
right = center + 1
```

Trying both center forms at every index covers every possible palindrome.

---

## 3. Recommended JavaScript solution

```javascript
function longestPalindrome(s) {
  if (s.length < 2) return s;

  let bestStart = 0;
  let bestLength = 1;

  function expand(left, right) {
    while (
      left >= 0 &&
      right < s.length &&
      s[left] === s[right]
    ) {
      left--;
      right++;
    }

    const start = left + 1;
    const length = right - left - 1;

    if (length > bestLength) {
      bestStart = start;
      bestLength = length;
    }
  }

  for (let center = 0; center < s.length; center++) {
    expand(center, center);
    expand(center, center + 1);
  }

  return s.slice(bestStart, bestStart + bestLength);
}
```

---

## 4. Why the length formula looks unusual

The expansion loop stops only after:

- an index moves outside the string, or
- the two characters no longer match.

Therefore, after the loop:

```text
left  is one position before the palindrome
right is one position after the palindrome
```

The true palindrome boundaries are:

```text
start = left + 1
end   = right - 1
```

Inclusive length:

```text
(right - 1) - (left + 1) + 1
= right - left - 1
```

This is a classic off-by-one point worth understanding rather than memorizing blindly.

---

## 5. Walkthrough: `"babad"`

### Center at index 0: `b`

Only `"b"` is found.

### Center at index 1: `a`

Expand:

```text
left 0 = 'b'
right 2 = 'b'
```

They match, producing:

```text
"bab"
```

The next comparison goes out or mismatches, so best becomes `"bab"`.

### Center at index 2: `b`

Expanding produces:

```text
"aba"
```

It ties the current best. Since the code updates only on strictly greater length, `"bab"` remains the result. Either answer is valid.

---

## 6. Walkthrough: even palindrome `"cbbd"`

Single-character centers find only length-one palindromes.

For the gap between indices `1` and `2`:

```text
s[1] = 'b'
s[2] = 'b'
```

They match, so expansion finds `"bb"`.

The next outer characters are `c` and `d`, which do not match. The answer becomes `"bb"`.

This example shows why checking only odd centers is insufficient.

---

## 7. Correctness reasoning

### Every palindrome is considered

Every palindrome has exactly one geometric center:

- a character for odd length;
- a gap between adjacent characters for even length.

The algorithm tries both center types at every index, so it tries the center of every possible palindrome.

### Expansion finds the longest palindrome for one center

Starting at a center, it repeatedly includes one matching character from each side. It stops precisely when further expansion is impossible. Therefore, it finds the maximum palindrome associated with that center.

### The global maximum is returned

The algorithm compares the maximum palindrome from every center and stores the longest. Since the true answer's center is included, its length is considered and cannot be missed.

Thus the returned substring is a longest palindromic substring.

---

## 8. Complexity

There are `2n - 1` meaningful centers:

- `n` character centers;
- `n - 1` gaps.

Each expansion can examine O(n) character pairs.

- Time: **O(n²)**
- Auxiliary space: **O(1)**
- Returned substring: O(n) storage in JavaScript because `slice()` creates a new string

The algorithm stores only the best start index and length during the search.

---

## 9. Why store indices instead of the substring repeatedly?

Inside every expansion, creating a new substring would allocate and copy characters many times.

Instead, track:

```text
bestStart
bestLength
```

and call `slice()` only once at the end. This reduces unnecessary allocations while keeping constant working space.

---

## 10. Dynamic programming alternative

Define:

```text
dp[left][right] = whether s[left...right] is a palindrome
```

A substring is a palindrome when:

```text
s[left] === s[right]
and
the inside substring is a palindrome
```

For lengths one and two, handle the interior boundary directly.

```javascript
function longestPalindromeDP(s) {
  if (s.length < 2) return s;

  const n = s.length;
  const dp = Array.from(
    { length: n },
    () => new Array(n).fill(false)
  );

  let bestStart = 0;
  let bestLength = 1;

  for (let left = n - 1; left >= 0; left--) {
    for (let right = left; right < n; right++) {
      const insideIsPalindrome =
        right - left < 2 || dp[left + 1][right - 1];

      if (s[left] === s[right] && insideIsPalindrome) {
        dp[left][right] = true;

        const length = right - left + 1;

        if (length > bestLength) {
          bestStart = left;
          bestLength = length;
        }
      }
    }
  }

  return s.slice(bestStart, bestStart + bestLength);
}
```

Complexity:

- Time: O(n²)
- Space: O(n²)

Center expansion achieves the same time bound with much less space, making it the preferred interview solution.

---

## 11. Why the DP loop goes backward on `left`

State `dp[left][right]` depends on:

```text
dp[left + 1][right - 1]
```

Therefore, states with larger `left` values—the inner substrings—must already be computed. Iterating `left` from right to left satisfies this dependency order.

This is an example of deriving loop order from DP dependencies rather than guessing it.

---

## 12. Common mistakes

### Mistake 1: check only one center type

Odd centers miss even palindromes such as `"bb"`; even centers miss odd palindromes such as `"aba"`.

### Mistake 2: compute length as `right - left + 1` after the loop

At that point both pointers are already one step outside the valid palindrome. Use `right - left - 1`.

### Mistake 3: slice with an inclusive end

JavaScript `slice(start, end)` excludes `end`, so use:

```javascript
s.slice(bestStart, bestStart + bestLength)
```

### Mistake 4: generate every substring

That leads to O(n³) time when each substring is checked separately.

### Mistake 5: confuse substring with subsequence

The palindrome must occupy consecutive positions.

### Mistake 6: repeatedly save substrings during expansion

Store boundaries and create the final substring once.

### Mistake 7: use `>=` without considering tie behavior

Either longest palindrome is acceptable. `>` keeps the earliest maximum encountered; `>=` may replace it with a later tie.

---

## 13. Edge cases

- empty string → `""`
- one character
- two equal characters
- two different characters
- entire string is a palindrome
- all characters equal
- several longest palindromes tied
- no palindrome longer than one character

Every non-empty string has at least a one-character palindrome.

---

## 14. Unicode note for JavaScript

JavaScript string indexing works with UTF-16 code units. Most LeetCode inputs use simple English characters, so this is fine.

For production text containing characters represented by surrogate pairs, user-perceived characters may occupy two code units. A grapheme-aware implementation would need a different representation, such as segmentation into Unicode grapheme clusters.

---

## 15. Interview narration

> “Every palindrome expands around a center. I’ll try both an odd center at `(i,i)` and an even center at `(i,i+1)` for every index. While the two characters match, I expand outward. Once expansion stops, the valid palindrome lies between `left + 1` and `right - 1`, with length `right - left - 1`. I’ll retain the longest boundaries and slice once at the end.”

---

## 16. Pattern recognition

Expand-around-center is useful for:

- longest palindromic substring;
- counting palindromic substrings;
- testing palindromes around known centers;
- symmetric runs in sequences.

General template:

```javascript
while (
  left >= 0 &&
  right < sequence.length &&
  sequence[left] === sequence[right]
) {
  left--;
  right++;
}
```

The same center expansion can count every palindrome by incrementing a counter on each successful comparison.

---

## 17. Quick test

```javascript
console.log(longestPalindrome('babad')); // "bab" or "aba"
console.log(longestPalindrome('cbbd'));  // "bb"
console.log(longestPalindrome('a'));     // "a"
console.log(longestPalindrome(''));      // ""
console.log(longestPalindrome('aaaa'));  // "aaaa"
```

---

## 18. Notebook version

### Pattern

**Expand around every center**

### Center types

```text
odd:  (i, i)
even: (i, i + 1)
```

### After expansion stops

```text
start  = left + 1
length = right - left - 1
```

### Memory line

> Every palindrome owns a center; expand until symmetry breaks.

### Complexity

```text
time: O(n²)
auxiliary space: O(1)
```

