# Grind 75 — 72: Basic Calculator

**Difficulty:** Hard  
**Primary pattern:** Expression parsing + stack  
**LeetCode:** 224  
**Target interview time:** 40 minutes  
**Language:** JavaScript

## Problem

Given a valid arithmetic expression string `s`, evaluate it and return its integer result.

The expression may contain:

- non-negative integers;
- `+` and `-`;
- parentheses `(` and `)`;
- spaces.

Do not use a built-in expression evaluator such as `eval()`.

Examples:

```text
"1 + 1"             -> 2
" 2-1 + 2 "         -> 3
"(1+(4+5+2)-3)+(6+8)" -> 23
"-2 + 1"            -> -1
```

---

## 1. Intuition

Without multiplication or division, the expression is a sequence of signed numbers:

```text
12 - 5 + 3
= +12 + (-5) + (+3)
```

So while scanning left to right, maintain:

- `number`: the multi-digit number currently being built;
- `sign`: whether that number should be added or subtracted;
- `result`: the evaluated total for the current parenthesis level.

Parentheses introduce a nested expression. When `(` begins, save the outside context:

```text
previous result
sign before the parenthesis
```

Evaluate the inside from zero. When `)` closes, combine it with the saved context:

```text
outside result + outside sign × inside result
```

Example:

```text
10 - (2 + 3)

outside result = 10
outside sign   = -1
inside result  = 5

combined = 10 + (-1 × 5) = 5
```

---

## 2. Brute-Force Approach — Repeatedly Resolve Parentheses

A direct but inefficient idea is:

1. find the innermost parenthesized expression;
2. evaluate it;
3. replace that substring with its result;
4. repeat until no parentheses remain.

```js
function calculate(s) {
  let expression = s.replaceAll(" ", "");

  while (expression.includes("(")) {
    const close = expression.indexOf(")");
    const open = expression.lastIndexOf("(", close);
    const value = evaluateFlat(expression.slice(open + 1, close));

    expression =
      expression.slice(0, open) +
      String(value) +
      expression.slice(close + 1);
  }

  return evaluateFlat(expression);
}

function evaluateFlat(expression) {
  let result = 0;
  let number = 0;
  let sign = 1;

  for (let i = 0; i <= expression.length; i++) {
    const char = expression[i];

    if (char >= "0" && char <= "9") {
      number = number * 10 + Number(char);
    } else {
      result += sign * number;
      number = 0;

      if (char === "+") sign = 1;
      if (char === "-") sign = -1;
    }
  }

  return result;
}
```

### Problems

- Repeated substring searches and string reconstruction can take `O(n²)` time.
- Negative replacements can create tricky cases such as `1--2`.
- Parsing logic becomes fragile around unary signs.

The expression should be processed once rather than repeatedly rewritten.

---

## 3. Optimal Solution — One Pass with a Context Stack

```js
/**
 * Evaluates an expression containing integers, +, -, parentheses, and spaces.
 *
 * @param {string} s
 * @return {number}
 */
function calculate(s) {
  let result = 0;
  let number = 0;
  let sign = 1;
  const stack = [];

  for (const char of s) {
    if (char >= "0" && char <= "9") {
      number = number * 10 + Number(char);
      continue;
    }

    if (char === "+" || char === "-") {
      // Commit the number that just ended.
      result += sign * number;
      number = 0;
      sign = char === "+" ? 1 : -1;
      continue;
    }

    if (char === "(") {
      // Save the expression context outside these parentheses.
      stack.push(result);
      stack.push(sign);

      // Start evaluating the inner expression independently.
      result = 0;
      number = 0;
      sign = 1;
      continue;
    }

    if (char === ")") {
      // Finish the final number inside the parentheses.
      result += sign * number;
      number = 0;

      const outerSign = stack.pop();
      const outerResult = stack.pop();

      result = outerResult + outerSign * result;
    }

    // Spaces require no action.
  }

  // The string may end immediately after a number.
  return result + sign * number;
}
```

---

## 4. Meaning of the State

| Variable | Meaning |
| --- | --- |
| `number` | Digits currently being assembled into one integer |
| `sign` | Sign belonging to `number`: `1` for plus, `-1` for minus |
| `result` | Sum of all committed terms at the current parenthesis level |
| `stack` | Saved outer contexts: result followed by sign |

### Important distinction

`result` does not yet include `number` while digits are still being read.

For:

```text
12 + 34
```

while scanning `34`:

```text
result = 12
sign   = +1
number = 34
```

The number is committed only when an operator, `)`, or the end of the string is reached.

---

## 5. Why Operators Commit the Previous Number

When scanning:

```text
12 - 5
```

The `-` appears after the number `12`. Therefore, on seeing `-`, first apply the old sign to the completed old number:

```js
result += sign * number;
```

Only then set the sign for the next number:

```js
sign = -1;
```

The operator belongs to the term that follows it, but it also tells us that the previous number has ended.

---

## 6. How Parentheses Are Compressed

Suppose the current expression is:

```text
7 - (2 + 3)
```

When `(` is reached:

```text
result = 7
sign   = -1
```

Push them in this order:

```js
stack.push(result); // 7
stack.push(sign);   // -1
```

Reset the inner calculation:

```text
result = 0
sign   = 1
```

After evaluating `2 + 3`:

```text
inner result = 5
```

At `)`:

```text
outerSign   = -1
outerResult = 7

result = 7 + (-1 × 5) = 2
```

The entire parenthesized expression becomes one signed value inside its outer context.

---

## 7. Walkthrough

Evaluate:

```text
1 - (2 + (3 - 4))
```

### Before first `(`

After reading `1 -`:

```text
result = 1
sign   = -1
```

At `(`, save:

```text
[1, -1]
```

Reset for the inside.

### Inside: `2 + (`

After reading `2 +`:

```text
inner result = 2
sign = +1
```

At the nested `(`, save the current inner context:

```text
[1, -1, 2, +1]
```

### Evaluate `3 - 4`

At the nested `)`:

```text
inner result = 3 - 4 = -1
```

Restore `[2, +1]`:

```text
result = 2 + (+1 × -1) = 1
```

### Close the outer parentheses

Restore `[1, -1]`:

```text
result = 1 + (-1 × 1) = 0
```

Return `0`.

---

## 8. Unary Minus

The same state machine naturally handles unary minus.

### At the beginning

```text
-2 + 1
```

On `-`, the current `number` is `0`, so committing it changes nothing. `sign` becomes `-1`, and the following `2` is treated as negative.

### Before parentheses

```text
-(2 + 3)
```

The `-` sets `sign = -1`. At `(`, that sign is saved as the multiplier for the complete inner result.

### Nested after subtraction

```text
1 - (-2)
```

The outer `-` is saved when `(` opens. The inner `-` makes the inner result `-2`:

```text
1 + (-1 × -2) = 3
```

No separate unary-minus parser is required for the valid grammar used by this problem.

---

## 9. Correctness Proof

We prove that the algorithm returns the value of the expression.

### Invariant at each parenthesis level

At any point while scanning a level:

- `result` equals the sum of all completely processed signed terms at that level;
- `number` equals the unfinished numeric token currently being read, or `0` if none;
- `sign` is the sign to apply to `number` or to the next parenthesized expression;
- `stack` stores the exact outer result and sign for every unmatched `(`.

### Digits

For a digit, `number = number × 10 + digit` constructs the correct multi-digit integer without changing committed terms. The invariant is preserved.

### Operators

When `+` or `-` is encountered, the preceding number is complete. Adding `sign × number` commits that term correctly, and setting the new sign prepares the next term. The invariant is preserved.

### Opening parenthesis

The algorithm saves the outer `result` and `sign`, then resets the state to evaluate the inner expression independently. No information is lost, so the invariant holds at the new level.

### Closing parenthesis

The final inner number is committed, giving the correct inner result by the invariant. The algorithm then computes:

```text
outerResult + outerSign × innerResult
```

which is exactly the value of the outer expression through the completed parenthesized term. Thus, the outer invariant is restored.

### End of input

The only possible uncommitted term is the final `number`. Returning `result + sign × number` includes it. Therefore, the returned value equals the complete expression.

---

## 10. Complexity

Let `n` be the expression length and `d` the maximum parenthesis nesting depth.

### Time

```text
O(n)
```

Every character is processed once.

### Space

```text
O(d)
```

Each unmatched `(` stores two numbers. In the worst case, `d = O(n)`.

---

## 11. Common Mistakes

### Mistake 1: Applying a new operator to the previous number

Commit using the old `sign` before updating it.

### Mistake 2: Forgetting the final number

There may be no operator after it:

```js
return result + sign * number;
```

### Mistake 3: Saving only the outer result

The sign immediately before `(` is also required.

### Mistake 4: Pushing and popping in inconsistent order

This implementation pushes:

```text
result, then sign
```

Therefore it pops:

```text
sign, then result
```

### Mistake 5: Failing to commit the number at `)`

The last number inside the parentheses may not have been followed by an operator.

### Mistake 6: Treating spaces as token boundaries that commit numbers

Spaces should simply be ignored. They do not change the expression state.

### Mistake 7: Using `eval()`

It avoids the actual parsing problem and is unsafe for untrusted input.

### Mistake 8: Assuming every minus is binary

Valid expressions may begin with `-` or contain `-(...)`. The sign-based state handles both.

---

## 12. Edge Cases

### Single number

```text
"42" -> 42
```

### Leading and trailing spaces

```text
"  7  " -> 7
```

### Leading unary minus

```text
"-7" -> -7
```

### Parenthesized negative value

```text
"(-7)" -> -7
```

### Minus before parentheses

```text
"10-(2+3)" -> 5
```

### Nested parentheses

```text
"1-(2-(3-4))" -> -2
```

### Zero

```text
"0-(0)" -> 0
```

### Multi-digit numbers

```text
"123 + 45" -> 168
```

### Consecutive signs permitted by valid grammar

Parentheses may produce cases such as:

```text
"1-(-2)" -> 3
```

---

## 13. Interview Explanation

> Because the expression contains only addition, subtraction, parentheses, and spaces, I can scan once while maintaining the current number, its sign, and the accumulated result at the current parenthesis level. When I see an operator, I commit the previous signed number. On `(`, I push the outer result and the sign before the parenthesis, then reset the state to evaluate the inner expression. On `)`, I commit the inner final number and combine the inner result as `outerResult + outerSign × innerResult`. Finally, I commit the trailing number. This is `O(n)` time and `O(d)` space for nesting depth.

### Clarify before coding

1. Are `*` and `/` excluded?
2. Are unary signs valid?
3. Is the expression guaranteed valid?
4. Can integer results exceed JavaScript's safe integer range?

Under the standard constraints, only `+`, `-`, parentheses, integers, and spaces occur; the expression is valid; and results fit the required integer range.

### If multiplication is added

This exact accumulator is insufficient because operator precedence matters. Basic Calculator II typically uses a stack or tracks the previous term; a general expression grammar can use recursive descent or the shunting-yard algorithm.

---

## 14. Notebook Version

### Recognition

```text
Only + and - => signed terms
Parentheses => save outer context on stack
```

### State

```text
result = committed total at current level
number = current multi-digit number
sign   = sign for current/next term
stack  = [outerResult, outerSign, ...]
```

### Rules

```text
digit: number = number * 10 + digit
+/-:   commit number, update sign
(:     push result and sign; reset
):     commit inner number; restore and combine
end:   commit final number
```

### JavaScript

```js
function calculate(s) {
  let result = 0;
  let number = 0;
  let sign = 1;
  const stack = [];

  for (const char of s) {
    if (char >= "0" && char <= "9") {
      number = number * 10 + Number(char);
    } else if (char === "+" || char === "-") {
      result += sign * number;
      number = 0;
      sign = char === "+" ? 1 : -1;
    } else if (char === "(") {
      stack.push(result, sign);
      result = 0;
      number = 0;
      sign = 1;
    } else if (char === ")") {
      result += sign * number;
      number = 0;

      const outerSign = stack.pop();
      const outerResult = stack.pop();
      result = outerResult + outerSign * result;
    }
  }

  return result + sign * number;
}
```

### Complexity

```text
Time:  O(n)
Space: O(parenthesis depth)
```

### Invariant

`result` contains all completed terms at the current level; `number` and `sign` describe the one unfinished term.

---

## 15. Memory Line

**An opening parenthesis saves the outside; a closing parenthesis folds the inside back in.**

