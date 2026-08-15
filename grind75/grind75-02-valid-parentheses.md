# Grind 75 — 02: Valid Parentheses

**Difficulty:** Easy  
**Primary pattern:** Stack / matching delimiters  
**LeetCode:** https://leetcode.com/problems/valid-parentheses/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given a string containing only `(`, `)`, `{`, `}`, `[` and `]`, determine whether every opening bracket is closed:

1. by the same bracket type;
2. in the correct order;
3. with no bracket left unmatched.

```text
"()[]{}"  → true
"([{}])"  → true
"(]"      → false: wrong type
"([)]"    → false: wrong nesting order
"(("      → false: openings remain
")"       → false: closing bracket has no opener
```

---

## 2. The essential distinction: counts are not enough

At first, we might count opening and closing brackets. But equal counts do not guarantee valid nesting.

```text
([)]
```

This string contains one of every required opening and closing type, yet it is invalid. After opening `(` and then `[`, the `[` must be closed before the `(`.

The problem is about **order**, not merely frequency.

---

## 3. Why a stack fits

A stack follows **LIFO**:

```text
Last In, First Out
```

The most recently opened bracket is the first one that must close.

```text
Input: ([{}])

Read (  → stack: [ ( ]
Read [  → stack: [ (, [ ]
Read {  → stack: [ (, [, { ]
Read }  → pop {; matches
Read ]  → pop [; matches
Read )  → pop (; matches
End     → stack empty, therefore valid
```

Invariant:

> After processing any prefix of the string, the stack contains exactly the opening brackets that have not yet been closed, in their opening order.

---

## 4. Approaches considered

### Repeated string replacement

Continuously remove `()`, `[]`, and `{}` until the string stops changing. The result is valid if it becomes empty.

This can work, but repeated scanning and string creation can take **O(n²)** time. It also hides the structural reason the problem is a stack problem.

### Stack

Scan once. Push openings. For a closing bracket, pop and verify the latest opening.

- Time: **O(n)**
- Extra space: **O(n)** worst case

The stack is the clearest and optimal general solution.

---

## 5. Step-by-step algorithm

Create a map from each closing bracket to the opening bracket it requires:

```text
) → (
] → [
} → {
```

For every character:

1. If it is an opening bracket, push it onto the stack.
2. Otherwise, it is a closing bracket:
   - if the stack is empty, return `false`;
   - pop the most recent opening bracket;
   - if it is not the required type, return `false`.
3. After processing the string, return whether the stack is empty.

There are two different failure modes:

- **Premature closing:** stack is empty when a closing bracket appears.
- **Wrong closing:** stack top exists but is the wrong bracket type.

---

## 6. Dry run: invalid nesting

```text
s = "([)]"
```

| Character | Stack before | Action | Stack after |
|---|---|---|---|
| `(` | `[]` | Push | `[(]` |
| `[` | `[(]` | Push | `[(, []` |
| `)` | `[(, []` | Pop `[`; expected `(` | Return `false` |

The algorithm rejects the string immediately. It does not need to inspect the remaining `]`.

---

## 7. Optimal JavaScript solution

```javascript
function isValid(s) {
  const requiredOpening = new Map([
    [')', '('],
    [']', '['],
    ['}', '{'],
  ]);

  const stack = [];

  for (const bracket of s) {
    if (!requiredOpening.has(bracket)) {
      // It is an opening bracket, so it remains unfinished for now.
      stack.push(bracket);
      continue;
    }

    // A closing bracket must match the latest unfinished opening bracket.
    const latestOpening = stack.pop();

    if (latestOpening !== requiredOpening.get(bracket)) {
      return false;
    }
  }

  // Any remaining opening bracket was never closed.
  return stack.length === 0;
}
```

---

## 8. Code walkthrough

### `requiredOpening`

The current character tells us what it requires. For example, when we read `]`, the map tells us that the latest opening must be `[`. This avoids a long chain of conditions.

### `const stack = []`

JavaScript arrays work naturally as stacks:

- `push(value)` adds to the top;
- `pop()` removes and returns the top;
- both are O(1) amortized.

Avoid `shift()` and `unshift()` for stacks because they operate at the beginning and may require reindexing elements.

### `if (!requiredOpening.has(bracket))`

Under the problem constraint, a character absent from the closing-bracket map must be an opening bracket.

### `const latestOpening = stack.pop()`

If the stack is empty, JavaScript returns `undefined`. That will not equal any required opening bracket, so the same comparison handles premature closing without a separate empty-stack branch.

### `return stack.length === 0`

Matching every encountered closer is not sufficient. The input `"(("` encounters no bad closer, but the non-empty stack reveals unclosed openings.

---

## 9. Complexity

- **Time: O(n)** — every character is processed once; each push and pop is O(1) amortized.
- **Extra space: O(n)** — an input containing only opening brackets stores all `n` characters.

The small three-entry matching map is constant space. The growing stack determines the O(n) space bound.

---

## 10. Common mistakes

1. **Counting bracket types.** Equal counts do not prove correct nesting; `([)]` is the counterexample.
2. **Checking only adjacent pairs.** Valid pairs can contain other complete pairs, as in `([{}])`.
3. **Forgetting the final empty-stack check.** Inputs such as `((` would incorrectly return `true`.
4. **Ignoring a closing bracket when the stack is empty.** A closer cannot appear before its opener.
5. **Using a queue.** We need the most recent unmatched opener, not the oldest one.
6. **Using `shift()` as the removal operation.** That creates queue behavior and is less efficient for arrays.
7. **Pushing both opening and closing brackets.** Only unresolved openings need storage.

---

## 11. What to say in an interview

> “Correctness depends on nesting order, so counts alone are insufficient. Every closing bracket must match the most recent unmatched opening bracket, which is LIFO behavior. I’ll push opening brackets onto a stack. When I encounter a closer, I’ll pop and verify the expected opening type. At the end, the stack must be empty. This is O(n) time and O(n) worst-case space.”

If asked for the invariant:

> “The stack contains exactly the opening brackets from the processed prefix that have not yet been matched.”

---

## 12. Pattern recognition

Think **stack** when you see:

- nested structures;
- matching open and close tokens;
- undoing the latest action;
- resolving the most recent unfinished work;
- “nearest previous unresolved item.”

Examples beyond brackets:

- parsing nested expressions or HTML-like tags;
- browser back history;
- undo operations;
- function call stacks;
- simplifying file paths;
- monotonic-stack problems such as Next Greater Element.

Memory cue:

> Nested work closes from the inside out.

---

## 13. Alternative implementation: store expected closers

Instead of storing opening brackets, push the closing bracket expected later.

```javascript
function isValidExpectedCloser(s) {
  const stack = [];

  for (const bracket of s) {
    if (bracket === '(') stack.push(')');
    else if (bracket === '[') stack.push(']');
    else if (bracket === '{') stack.push('}');
    else if (stack.pop() !== bracket) return false;
  }

  return stack.length === 0;
}
```

This is concise and correct. The map-based version is more declarative and easier to extend with additional bracket types. Either is interview-appropriate if explained clearly.

---

## 14. Edge cases

| Input | Result | Reason |
|---|---:|---|
| `""` | `true` | No unmatched brackets |
| `"("` | `false` | Opening remains |
| `")"` | `false` | No opening exists |
| `"()"` | `true` | Direct match |
| `"([{}])"` | `true` | Correct nested order |
| `"([)]"` | `false` | Incorrect nesting |
| `"(){[]}"` | `true` | Multiple valid groups |

The official constraints contain only bracket characters. In production code with arbitrary characters, clarify whether non-bracket characters should be ignored or rejected.

---

## 15. Notebook-ready notes

### 📚 Concept

**Valid Parentheses — Stack / LIFO**

Every closer must match the latest unmatched opener.

```text
opening → push
closing → pop and compare
end     → stack must be empty
```

### 🧠 My understanding

Counts cannot represent nesting. The stack remembers unfinished openings, and its top is the only opening the next closer is allowed to resolve. The string is valid only if no comparison fails and no unfinished opening remains.

### 💼 Interview line

> “Nested delimiters close in reverse opening order, so the structure is naturally LIFO.”

### ⚠️ Traps

- A closing bracket with an empty stack is invalid.
- A mismatched stack top is invalid.
- A non-empty stack at the end is invalid.

---

## 16. Dheerix Glance

```text
VALID PARENTHESES

Signal:         nested open/close tokens
Structure:      stack (LIFO)
Push:           opening brackets
On closer:      pop latest opener and compare types
Final check:    stack.length === 0
Time:           O(n)
Extra space:    O(n)
Counterexample: ([)] proves counts are insufficient
Memory cue:     “Last opened, first closed.”
```

---

## 17. Recall test

Without looking back:

1. Why does counting bracket types fail?
2. What does the stack represent at any moment?
3. Why must the stack be empty at the end?
4. What happens when `pop()` is called on an empty JavaScript array?
5. Why is a queue the wrong structure?
6. State the algorithm and complexity in two sentences.

