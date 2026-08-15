# Grind 75 — 20: Add Binary

**Difficulty:** Easy  
**Primary pattern:** Digit-by-digit simulation / carry  
**LeetCode:** https://leetcode.com/problems/add-binary/  
**Target time:** 15 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given two strings representing binary numbers, return their sum as a binary string.

```text
a = "11"   (3 in decimal)
b = "1"    (1 in decimal)

result = "100" (4 in decimal)
```

The inputs may have different lengths. We should add them directly as strings rather than relying on built-in numeric conversion, because interview constraints can exceed safe integer limits and the problem is testing carry simulation.

---

## 2. Binary addition rules

Binary digits are only `0` and `1`.

```text
0 + 0 = 0
0 + 1 = 1
1 + 0 = 1
1 + 1 = 10  → write 0, carry 1
1 + 1 + 1 = 11 → write 1, carry 1
```

At each column:

```text
sum = digitA + digitB + carry
result digit = sum % 2
next carry   = floor(sum / 2)
```

These formulas are the base-2 version of ordinary decimal addition.

---

## 3. Why traverse from right to left?

The rightmost characters are the least significant bits. Addition begins there because the carry produced by a lower position flows toward the higher position on its left.

```text
  1011
+  110
------
```

Use two indices:

```text
i → current digit in a
j → current digit in b
```

Each moves left after one column is processed.

If one string ends earlier, treat its missing higher digits as zero.

---

## 4. Step-by-step algorithm

1. Set `i` and `j` to the last indices of `a` and `b`.
2. Set `carry = 0`.
3. While either string has a digit remaining, or carry is nonzero:
   - read `a[i]` if available, otherwise zero;
   - read `b[j]` if available, otherwise zero;
   - calculate `sum = digitA + digitB + carry`;
   - append `sum % 2` to a reversed result;
   - update `carry = Math.floor(sum / 2)`;
   - decrement both indices.
4. Reverse the collected digits and join them.

Including `carry > 0` in the loop condition handles a final overflow bit automatically.

---

## 5. Optimal JavaScript solution

```javascript
function addBinary(a, b) {
  let i = a.length - 1;
  let j = b.length - 1;
  let carry = 0;
  const reversedDigits = [];

  while (i >= 0 || j >= 0 || carry > 0) {
    const digitA = i >= 0 ? Number(a[i]) : 0;
    const digitB = j >= 0 ? Number(b[j]) : 0;
    const sum = digitA + digitB + carry;

    reversedDigits.push(sum % 2);
    carry = Math.floor(sum / 2);

    i--;
    j--;
  }

  return reversedDigits.reverse().join('');
}
```

---

## 6. Dry run

```text
a = "1011"
b = "110"
```

```text
  1011
+ 0110
------
 10001
```

| Column from right | `digitA` | `digitB` | Carry in | Sum | Output digit | Carry out |
|---:|---:|---:|---:|---:|---:|---:|
| 0 | 1 | 0 | 0 | 1 | 1 | 0 |
| 1 | 1 | 1 | 0 | 2 | 0 | 1 |
| 2 | 0 | 1 | 1 | 2 | 0 | 1 |
| 3 | 1 | 0 | 1 | 2 | 0 | 1 |
| final | 0 | 0 | 1 | 1 | 1 | 0 |

Digits are collected as:

```text
[1, 0, 0, 0, 1]
```

This example happens to read the same reversed, but generally we reverse before joining. The result is `"10001"`.

---

## 7. Code walkthrough

### Indices begin at the end

```javascript
let i = a.length - 1;
let j = b.length - 1;
```

The strings' least significant bits are their last characters.

### Loop condition

```javascript
i >= 0 || j >= 0 || carry > 0
```

Continue if either input still has digits or a final carry still needs to be written.

Using `&&` instead of `||` would stop when the shorter string ends and lose remaining digits from the longer string.

### Character-to-number conversion

```javascript
Number(a[i])
```

This converts `'0'` and `'1'` into numeric digits. We convert one character at a time, not the entire potentially large binary value.

An alternative is:

```javascript
a.charCodeAt(i) - '0'.charCodeAt(0)
```

but `Number` is clearer for interview code.

### Modulo and division

The largest possible sum is `3`, so:

| Sum | `sum % 2` | `floor(sum / 2)` |
|---:|---:|---:|
| 0 | 0 | 0 |
| 1 | 1 | 0 |
| 2 | 0 | 1 |
| 3 | 1 | 1 |

### Result collection

We discover digits from least significant to most significant, so they are appended in reverse order. Using an array and reversing once avoids repeatedly prepending to an immutable string.

---

## 8. Correctness reasoning

Loop invariant:

> Before each iteration, `carry` is exactly the carry produced by the already processed lower-order columns, and `reversedDigits` contains the correct result bits for those columns from least significant to most significant.

At each column, `digitA + digitB + carry` accounts for every contribution at that binary position. Modulo two yields the correct bit for the current position, while integer division by two yields the carry for the next higher position.

The loop continues until all input digits and any final carry are consumed. Reversing the collected low-to-high digits produces the correct high-to-low binary representation.

---

## 9. Complexity

Let:

```text
n = a.length
m = b.length
```

- **Time: O(max(n, m))** — one iteration per digit of the longer string, plus at most one final carry iteration.
- **Auxiliary space: O(max(n, m))** for the output digits.

If output storage is excluded from auxiliary-space accounting, the working state besides the result is O(1).

In JavaScript, `reverse()` and `join()` are linear, so the overall time remains O(max(n, m)).

---

## 10. Why not parse the whole strings?

This tempting solution is unsafe:

```javascript
parseInt(a, 2) + parseInt(b, 2)
```

JavaScript `Number` exactly represents integers only through `Number.MAX_SAFE_INTEGER` (`2^53 - 1`). Long binary strings can lose precision.

`BigInt` could represent arbitrary integers:

```javascript
(BigInt(`0b${a}`) + BigInt(`0b${b}`)).toString(2)
```

But that bypasses the intended algorithm, may be disallowed, and does not demonstrate carry handling. Use digit simulation in interviews.

---

## 11. Alternative without reversing an array

We can write result bits from right to left into a preallocated array, but the output length may be `max(n, m) + 1`, requiring additional index handling.

Another concise version prepends:

```javascript
result = bit + result;
```

However, JavaScript strings are immutable, so repeated prepending can create many intermediate strings and potentially lead to quadratic copying behavior. Append to an array and reverse once for predictable linear construction.

---

## 12. Common mistakes

1. **Starting from the left.** Carry flows from right to left.
2. **Using `&&` in the loop condition.** The longer string's remaining digits are lost.
3. **Forgetting the final carry.** `"1" + "1"` must produce `"10"`.
4. **Appending numeric sum directly.** Sum `2` means result bit `0` with carry `1`, not digit `2`.
5. **Forgetting to reverse collected digits.** They are generated least significant first.
6. **Parsing the entire input into `Number`.** Large inputs can lose precision.
7. **Treating string characters as numbers implicitly.** Explicit conversion makes addition rather than concatenation reliable.
8. **Prepending to a string repeatedly.** This may create avoidable repeated copies.
9. **Calling working space O(1) without explaining output storage.** The returned string necessarily contains O(max(n,m)) characters.

---

## 13. What to say in an interview

> “I’ll simulate manual binary addition from right to left. Two indices read the current bits, with missing digits treated as zero. At each column, the output bit is `sum % 2` and the next carry is `floor(sum / 2)`. I’ll collect digits in reverse and reverse once at the end. This is O(max(n,m)) time and output space, with O(1) working state besides the result.”

If asked why not parse:

> “The strings may exceed JavaScript's safe integer range, and direct conversion bypasses the carry algorithm the problem is testing.”

---

## 14. Pattern recognition

Think **digit simulation with carry** when:

- numbers are represented as strings or linked lists;
- values may exceed native numeric limits;
- arithmetic must be performed digit by digit;
- operands can have different lengths.

The same framework applies to:

- adding decimal strings;
- adding linked-list numbers;
- multiplication by digits;
- arbitrary-base addition.

For base `B`:

```text
output digit = sum % B
carry        = floor(sum / B)
```

Memory cue:

> Add from the least significant side; emit remainder, carry quotient.

---

## 15. Edge cases

| `a` | `b` | Result | Key behavior |
|---|---|---|---|
| `"0"` | `"0"` | `"0"` | No carry |
| `"1"` | `"0"` | `"1"` | Simple unequal digit |
| `"1"` | `"1"` | `"10"` | Final carry |
| `"101"` | `"1"` | `"110"` | Different lengths |
| `"111"` | `"1"` | `"1000"` | Carry propagates repeatedly |
| very long strings | exact string result | No native-number conversion |

---

## 16. Notebook-ready notes

### 📚 Concept

**Add Binary — right-to-left carry simulation**

```text
i = end of a, j = end of b, carry = 0
while i valid OR j valid OR carry:
  digitA = available ? value : 0
  digitB = available ? value : 0
  sum = digitA + digitB + carry
  append sum % 2
  carry = floor(sum / 2)
reverse and join result
```

### 🧠 My understanding

Each binary column produces one output bit and at most one carry. The carry is the only information that must move into the next higher column. Different input lengths are handled by treating missing digits as zero.

### 💼 Interview line

> “I’ll reproduce manual addition: remainder becomes the current bit, quotient becomes the carry.”

### ⚠️ Traps

- Traverse from right to left.
- Continue for either input or remaining carry.
- Convert character digits explicitly.
- Reverse the collected output.

---

## 17. Dheerix Glance

```text
ADD BINARY

Direction:        right → left
Pointers:         end of each string
Missing digit:    0
Column sum:       digitA + digitB + carry
Output bit:       sum % 2
Next carry:       floor(sum / 2)
Loop:             either digit remains OR carry remains
Construction:     append reversed, then reverse once
Time:             O(max(n,m))
Memory cue:       “Remainder is bit; quotient is carry.”
```

---

## 18. Recall test

Without looking back:

1. Why does addition begin at the rightmost character?
2. What are the formulas for the output bit and next carry?
3. Why does the loop condition use OR rather than AND?
4. How are different input lengths handled?
5. Why must a final carry be included in the loop?
6. Why is whole-string `Number` conversion unsafe?
7. Why append to an array and reverse rather than repeatedly prepend?
8. State the loop invariant in one sentence.

