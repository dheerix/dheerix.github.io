# Grind 75 — 33: Evaluate Reverse Polish Notation

**Difficulty:** Medium  
**Primary pattern:** Stack / expression evaluation  
**LeetCode:** https://leetcode.com/problems/evaluate-reverse-polish-notation/  
**Target time:** 30 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Evaluate an arithmetic expression written in Reverse Polish Notation (RPN), also called postfix notation.

In postfix notation, an operator appears **after** its two operands:

```text
Infix:   2 + 1
Postfix: 2 1 +
```

Example:

```text
tokens = ["2", "1", "+", "3", "*"]

(2 + 1) * 3 = 9
```

Supported operators:

```text
+  -  *  /
```

Division truncates toward zero.

---

## 2. Why postfix notation needs no parentheses

In infix notation:

```text
2 + 1 * 3
```

operator precedence determines grouping.

In RPN:

```text
2 1 + 3 *
```

the ordering explicitly says:

1. apply `+` to `2` and `1`;
2. apply `*` to that result and `3`.

Every operator acts on the two most recent unresolved values. This is LIFO behavior, so a stack is the natural structure.

---

## 3. Stack algorithm

Process tokens from left to right.

### Number token

Convert it to a number and push it.

### Operator token

Pop two values:

```text
rightOperand = first pop
leftOperand  = second pop
```

Compute:

```text
leftOperand operator rightOperand
```

Push the result back because it may become an operand for a later operator.

After all tokens, the stack contains one value: the expression result.

---

## 4. Operand order is crucial

Suppose the stack contains:

```text
[10, 3]  ← top is 3
```

and the operator is `-`.

Correct:

```text
right = 3   // first pop
left  = 10  // second pop
10 - 3 = 7
```

Incorrect reversal:

```text
3 - 10 = -7
```

Addition and multiplication hide this bug because they are commutative. Always name popped values `right` and `left` explicitly.

---

## 5. Optimal JavaScript solution

```javascript
function evalRPN(tokens) {
  const stack = [];
  const operators = new Set(['+', '-', '*', '/']);

  for (const token of tokens) {
    if (!operators.has(token)) {
      stack.push(Number(token));
      continue;
    }

    const rightOperand = stack.pop();
    const leftOperand = stack.pop();

    if (token === '+') {
      stack.push(leftOperand + rightOperand);
    } else if (token === '-') {
      stack.push(leftOperand - rightOperand);
    } else if (token === '*') {
      stack.push(leftOperand * rightOperand);
    } else {
      const quotient = leftOperand / rightOperand;
      stack.push(Math.trunc(quotient));
    }
  }

  return stack.pop();
}
```

---

## 6. Dry run

```text
tokens = ["2", "1", "+", "3", "*"]
```

| Token | Action | Stack |
|---|---|---|
| `"2"` | push 2 | `[2]` |
| `"1"` | push 1 | `[2,1]` |
| `"+"` | pop 1, 2; push 3 | `[3]` |
| `"3"` | push 3 | `[3,3]` |
| `"*"` | pop 3, 3; push 9 | `[9]` |

Return `9`.

---

## 7. More complex dry run

```text
tokens = ["4", "13", "5", "/", "+"]
```

```text
push 4          → [4]
push 13         → [4,13]
push 5          → [4,13,5]
13 / 5 = 2      → [4,2]
4 + 2 = 6       → [6]
```

Return `6`.

The result of `13 / 5` becomes a new operand for the later addition.

---

## 8. Division toward zero

The problem requires truncation toward zero:

```text
 7 / 3 =  2.333... →  2
-7 / 3 = -2.333... → -2
```

Use:

```javascript
Math.trunc(leftOperand / rightOperand)
```

Do not use `Math.floor`:

```text
Math.floor(-2.333...) = -3
```

Floor moves toward negative infinity, not toward zero.

---

## 9. Why detect operators explicitly?

Negative numbers such as `"-11"` are valid numeric tokens. Logic such as:

```text
token starts with '-'
```

would incorrectly classify them as subtraction operators.

Check exact membership in:

```javascript
new Set(['+', '-', '*', '/'])
```

Everything else is parsed as a number under the valid-input guarantee.

---

## 10. Code walkthrough

### Stack contents

At any moment, the stack contains evaluated values for expression fragments whose results have not yet been consumed by a later operator.

### Number conversion

`Number(token)` correctly handles positive and negative integer strings under the problem constraints.

### Operator reduction

Every binary operator replaces two stack values with one result, reducing unresolved value count by one.

### Final result

A valid RPN expression has exactly one unresolved value after every token is processed. Return it.

The problem guarantees valid input, so explicit stack-underflow or leftover-value validation is unnecessary for LeetCode. Production parsers should validate both.

---

## 11. Loop invariant

After processing any token prefix:

> The stack contains, in evaluation order, the results of all complete subexpressions in that prefix that have not yet been used by a subsequent operator.

A number adds one unresolved expression result. An operator consumes the two most recent unresolved results and replaces them with their correctly combined result, preserving the invariant.

---

## 12. Correctness reasoning

RPN places each operator immediately after the complete token sequences representing its left and right operands. Therefore, when an operator is encountered, the stack's top two entries are exactly those evaluated operands, with the right operand on top.

The algorithm computes the correct operation and pushes its result, making that complete subexpression available as one operand. By induction over tokens, the stack represents all partially evaluated expression structure correctly. Valid input leaves exactly the entire expression result on the stack.

---

## 13. Complexity

Let `n` be the number of tokens.

- **Time: O(n)** — every token is processed once; each stack operation is O(1) amortized.
- **Extra space: O(n)** worst case — many number tokens may accumulate before operators consume them.

The maximum stack size depends on expression shape, but O(n) is the safe bound.

---

## 14. Dispatch-map alternative

Operators can be stored as functions:

```javascript
function evalRPNWithOperations(tokens) {
  const operations = new Map([
    ['+', (left, right) => left + right],
    ['-', (left, right) => left - right],
    ['*', (left, right) => left * right],
    ['/', (left, right) => Math.trunc(left / right)],
  ]);

  const stack = [];

  for (const token of tokens) {
    if (!operations.has(token)) {
      stack.push(Number(token));
      continue;
    }

    const right = stack.pop();
    const left = stack.pop();
    stack.push(operations.get(token)(left, right));
  }

  return stack.pop();
}
```

This removes branching and makes adding operators easy. The explicit conditional version may be faster to write without worrying about function-map syntax.

---

## 15. Why a stack, not a queue?

An operator must consume the most recently completed operands, which can include results of nested subexpressions.

FIFO removal would select the oldest unresolved values and break grouping.

Example:

```text
2 1 + 3 *
```

After `2 1 +`, the value `3` represents that completed subexpression and must combine with the next input `3`. The stack keeps that most recent result immediately accessible.

---

## 16. Common mistakes

1. **Reversing operand order.** First pop is right; second pop is left.
2. **Using `Math.floor` for negative division.** Use `Math.trunc`.
3. **Treating every token containing `-` as an operator.** Negative numbers are operands.
4. **Pushing token strings without conversion.** `+` may concatenate strings instead of adding numbers.
5. **Not pushing operation results back.** Later operators need them.
6. **Using a queue.** Evaluation consumes the most recent partial results.
7. **Trying to apply infix precedence.** RPN order already encodes grouping.
8. **Returning the entire stack.** Valid input leaves one result.
9. **Claiming O(1) space.** The operand stack can grow linearly.

---

## 17. What to say in an interview

> “RPN places each operator after its operands, so I’ll keep unresolved values in a stack. Number tokens are pushed. For an operator, I pop the right operand first and the left operand second, evaluate `left op right`, and push the result for future operators. Division uses `Math.trunc` because the requirement is toward zero. This is O(n) time and O(n) worst-case space.”

If asked why parentheses are unnecessary:

> “Postfix token order fully determines when each pair of operands is reduced.”

---

## 18. Pattern recognition

Think **stack-based reduction** when:

- operators consume the most recent values;
- nested work collapses into one reusable result;
- postfix expressions are evaluated;
- tokens alternate between producing state and reducing state.

General reduction pattern:

```text
operand → push
operator → pop required operands, combine, push result
```

Memory cue:

> Numbers accumulate; operators collapse the latest pair.

---

## 19. Edge cases

| Tokens | Result | Important detail |
|---|---:|---|
| `["5"]` | 5 | Single number |
| `["2","3","+"]` | 5 | Basic reduction |
| `["3","10","-"]` | -7 | Operand order |
| `["-7","3","/"]` | -2 | Truncate toward zero |
| `["7","-3","/"]` | -2 | Negative operand token |
| nested expression tokens | correct single value | Results are pushed back |

The official problem guarantees no division by zero and a valid expression.

---

## 20. Notebook-ready notes

### 📚 Concept

**Evaluate RPN — stack reduction**

```text
for token:
  number → push Number(token)
  operator:
    right = pop()
    left = pop()
    push(left operator right)
return pop()

division → Math.trunc(left/right)
```

### 🧠 My understanding

Each number is a partial result. An operator consumes the two most recently completed results because postfix order places them immediately before it. The computed result goes back onto the stack and acts like a single operand for the remaining expression.

### 💼 Interview line

> “An operator reduces the two latest unresolved values into one reusable result.”

### ⚠️ Traps

- First pop is the right operand.
- Convert numeric strings explicitly.
- Use `Math.trunc`, not `Math.floor`, for division.
- Negative number tokens are not subtraction operators.

---

## 21. Dheerix Glance

```text
EVALUATE RPN

Notation:         postfix
Structure:        stack
Number token:     convert and push
Operator token:   pop right, pop left
Compute:          left op right
Then:             push result
Division:         truncate toward zero
Final stack:      one result
Time:             O(n)
Space:            O(n)
Memory cue:       “Right pops first; result goes back.”
```

---

## 22. Recall test

Without looking back:

1. Why does RPN not need parentheses or precedence rules?
2. What does the stack contain after any token prefix?
3. Which operand is popped first?
4. Why do subtraction and division expose operand-order bugs?
5. Why must division use `Math.trunc`?
6. How are negative number tokens distinguished from operators?
7. Why is every intermediate result pushed back?
8. State the loop invariant in one sentence.

