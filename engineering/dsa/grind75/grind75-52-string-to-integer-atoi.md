# Grind 75 — 52. String to Integer (`atoi`)

## Problem

Implement a function that converts a string to a 32-bit signed integer using these rules:

1. Ignore leading spaces.
2. Read one optional `+` or `-` sign.
3. Read consecutive decimal digits.
4. Stop at the first non-digit after parsing begins.
5. If no digits are read, return `0`.
6. Clamp the result to the signed 32-bit range:

```text
[-2³¹, 2³¹ - 1]
=
[-2147483648, 2147483647]
```

Examples:

```text
"42"             → 42
"   -042"        → -42
"1337c0d3"       → 1337
"words and 987"  → 0
"91283472332"    → 2147483647
```

---

## 1. This is a parsing-order problem

The individual operations are simple. Most mistakes come from performing them in the wrong order or accepting characters in an invalid state.

The parser moves through these phases once:

```text
leading spaces
      ↓
optional sign
      ↓
consecutive digits
      ↓
stop permanently
```

Once digit parsing stops, we do not resume later in the string.

For example:

```text
"12-34" → 12
```

The minus sign is not valid after digits have begun.

---

## 2. Recommended JavaScript solution

This version detects overflow **before** appending the next digit.

```javascript
function myAtoi(s) {
  const INT_MAX = 2 ** 31 - 1;
  const INT_MIN = -(2 ** 31);
  const MAX_DIVIDED_BY_10 = Math.floor(INT_MAX / 10);

  let index = 0;
  let sign = 1;
  let magnitude = 0;

  while (index < s.length && s[index] === ' ') {
    index++;
  }

  if (s[index] === '+' || s[index] === '-') {
    sign = s[index] === '-' ? -1 : 1;
    index++;
  }

  while (index < s.length) {
    const digit = s.charCodeAt(index) - 48;

    if (digit < 0 || digit > 9) {
      break;
    }

    const finalAllowedDigit = sign === 1 ? 7 : 8;

    if (
      magnitude > MAX_DIVIDED_BY_10 ||
      (
        magnitude === MAX_DIVIDED_BY_10 &&
        digit > finalAllowedDigit
      )
    ) {
      return sign === 1 ? INT_MAX : INT_MIN;
    }

    magnitude = magnitude * 10 + digit;
    index++;
  }

  return sign * magnitude;
}
```

---

## 3. Why accumulate the magnitude separately?

We build a non-negative number:

```text
magnitude = magnitude × 10 + digit
```

and apply `sign` only at the end.

This makes digit accumulation uniform for positive and negative inputs. The only sign-specific difference is the final boundary:

```text
positive maximum magnitude: 2147483647
negative maximum magnitude: 2147483648
```

The negative side allows one extra unit because the signed 32-bit range is asymmetric.

---

## 4. Digit conversion without `parseInt`

ASCII/Unicode code points for decimal digits are consecutive:

```text
'0' → 48
'1' → 49
...
'9' → 57
```

Therefore:

```javascript
const digit = s.charCodeAt(index) - 48;
```

produces a value from `0` through `9` for an ASCII digit.

Then:

```javascript
const isDigit = digit >= 0 && digit <= 9;
```

If `isDigit` is false, the parsing loop stops at that character.

This makes the accepted character set explicit and avoids loose conversion behavior.

---

## 5. Building a decimal number

Suppose the parsed digits are `4`, `2`, and `7`.

```text
start: 0
read 4: 0 × 10 + 4 = 4
read 2: 4 × 10 + 2 = 42
read 7: 42 × 10 + 7 = 427
```

Each multiplication shifts existing decimal digits left by one place; the new digit occupies the ones place.

---

## 6. Overflow check derivation

Before performing:

```text
next = magnitude × 10 + digit
```

we ask whether the result would exceed the permitted magnitude.

For positive values:

```text
limit = 2147483647
```

The last safe prefix is:

```text
floor(limit / 10) = 214748364
```

Therefore overflow occurs when:

```text
magnitude > 214748364
```

or when:

```text
magnitude === 214748364
and digit > 7
```

For a negative result, magnitude `2147483648` is allowed, so the final digit threshold is `8` instead of `7`.

---

## 7. Walkthrough: `"   -042"`

### Skip leading spaces

Index moves to `'-'`.

### Read sign

```text
sign = -1
```

### Read digits

```text
'0' → magnitude = 0
'4' → magnitude = 4
'2' → magnitude = 42
```

### Apply sign

```text
-1 × 42 = -42
```

Leading zeros do not require special handling.

---

## 8. Walkthrough: `"4193 with words"`

```text
read 4 → 4
read 1 → 41
read 9 → 419
read 3 → 4193
read space → stop
```

Return `4193`. Characters after the first invalid character are irrelevant.

---

## 9. Walkthrough: overflow

Input:

```text
"91283472332"
```

As the parser approaches the boundary, the current magnitude eventually exceeds the safe prefix or equals it with an excessive final digit.

The function immediately returns:

```text
2147483647
```

For:

```text
"-91283472332"
```

it returns:

```text
-2147483648
```

---

## 10. Why JavaScript still needs explicit 32-bit handling

JavaScript's `Number` is an IEEE-754 floating-point value, not a signed 32-bit integer. It can represent all 32-bit integers exactly, but it does not automatically enforce this problem's range.

Avoid bitwise coercion such as:

```javascript
result | 0
```

Bitwise conversion wraps overflow instead of clamping it. The problem explicitly requires saturation at `INT_MIN` or `INT_MAX`.

---

## 11. Simpler clamp-after-append version

Because the input constraints are manageable and 32-bit values are far below JavaScript's safe-integer limit, this version is also accepted:

```javascript
function myAtoiClampAfter(s) {
  const INT_MAX = 2 ** 31 - 1;
  const INT_MIN = -(2 ** 31);
  let index = 0;
  let sign = 1;
  let result = 0;

  while (s[index] === ' ') index++;

  if (s[index] === '+' || s[index] === '-') {
    sign = s[index] === '-' ? -1 : 1;
    index++;
  }

  while (index < s.length && s[index] >= '0' && s[index] <= '9') {
    result = result * 10 + Number(s[index]);

    const signedResult = sign * result;

    if (signedResult <= INT_MIN) return INT_MIN;
    if (signedResult >= INT_MAX) return INT_MAX;

    index++;
  }

  return sign * result;
}
```

The pre-check version more directly demonstrates overflow reasoning and avoids constructing values outside the target range.

---

## 12. State-machine interpretation

The parser can be viewed as a small deterministic state machine:

| State | Space | Sign | Digit | Other |
| --- | --- | --- | --- | --- |
| Start | stay/start | sign state | digit state | stop with `0` |
| Sign read | stop | stop | digit state | stop with `0` |
| Digits | stop | stop | stay/digits | stop with value |

For this problem, direct procedural code is shorter. The state-machine model becomes useful when parsing rules grow more complex.

---

## 13. Important edge cases

### Only spaces

```text
"   " → 0
```

### Sign without digits

```text
"+"  → 0
"-"  → 0
```

### Two signs

```text
"+-12" → 0
"--12" → 0
```

After consuming one sign, the next sign is not a digit, so parsing stops before any number is formed.

### Decimal point

```text
"3.14159" → 3
```

### Leading text

```text
"words 123" → 0
```

### Digits followed by text

```text
"123words" → 123
```

### Exact boundaries

```text
"2147483647"  → 2147483647
"2147483648"  → 2147483647
"-2147483648" → -2147483648
"-2147483649" → -2147483648
```

### Spaces after a sign

```text
"- 12" → 0
```

Only leading spaces before the optional sign are skipped.

---

## 14. Common mistakes

### Mistake 1: use `Number(s)`

It follows JavaScript conversion rules, not the exact parsing rules required here.

### Mistake 2: use `parseInt(s)` as the whole solution

It hides the algorithm, may differ on edge semantics, and does not automatically clamp to the specified 32-bit range.

### Mistake 3: skip spaces after reading the sign

Spaces are permitted only before the sign. `"- 12"` must return `0`.

### Mistake 4: allow several signs

Only one optional sign is valid.

### Mistake 5: continue searching for digits after an invalid character

Parsing stops permanently at the first non-digit after the optional prefix.

### Mistake 6: use symmetric positive and negative final digits

The negative magnitude can end in `8`; the positive maximum ends in `7`.

### Mistake 7: use bitwise operators for clamping

They wrap into signed 32-bit values instead of saturating.

### Mistake 8: use a broad whitespace test without checking the specification

The problem describes the space character `' '`. Production parsers may deliberately accept tabs and other whitespace, but that is a different contract.

---

## 15. Correctness reasoning

The algorithm follows the required grammar in order:

1. The first loop consumes exactly the allowed leading spaces.
2. The sign condition consumes at most one valid sign.
3. The digit loop consumes exactly the maximal consecutive digit sequence following that prefix.
4. The accumulation recurrence constructs the decimal magnitude represented by those digits.
5. The pre-check returns the correct boundary before any digit could exceed the signed 32-bit range.
6. If no overflow occurs, multiplying by the recorded sign produces the required integer.

If no digit is consumed, `magnitude` remains zero, so the result is zero as required.

---

## 16. Complexity

Let `n` be the string length.

- Time: **O(n)**
- Auxiliary space: **O(1)**

Each character is examined at most once, and only scalar variables are used.

---

## 17. Interview narration

> “I’ll parse left to right in strict phases: skip leading spaces, consume one optional sign, then accumulate consecutive digits. Before appending each digit, I’ll check whether the magnitude would exceed the 32-bit boundary. The positive final digit limit is seven, while the negative magnitude allows eight. Parsing stops at the first non-digit, and if no digits are read the accumulated value remains zero.”

---

## 18. Pattern recognition

Use this structured parsing approach for:

- numeric parsers;
- version strings;
- tokens and simple grammars;
- protocol fields;
- validation pipelines;
- state-machine interview questions.

General principle:

```text
Define legal phases first, then consume input monotonically.
```

Parsing becomes much safer when every character is interpreted according to the current phase rather than through scattered special cases.

---

## 19. Quick test

```javascript
console.log(myAtoi('42'));            // 42
console.log(myAtoi('   -042'));       // -42
console.log(myAtoi('1337c0d3'));      // 1337
console.log(myAtoi('words and 987')); // 0
console.log(myAtoi('+-12'));          // 0
console.log(myAtoi('2147483648'));    // 2147483647
console.log(myAtoi('-2147483649'));   // -2147483648
```

---

## 20. Notebook version

### Pattern

**Ordered parser + overflow guard**

### Phases

```text
spaces → optional sign → consecutive digits → stop
```

### Digit accumulation

```text
magnitude = magnitude × 10 + digit
```

### Boundaries

```text
INT_MAX = 2147483647
INT_MIN = -2147483648
```

### Critical overflow rule

```text
prefix > 214748364
or
prefix == 214748364 and digit > 7/8
```

### Memory line

> Parse in phases; stop once; guard before appending the next digit.

### Complexity

```text
time: O(n)
space: O(1)
```
