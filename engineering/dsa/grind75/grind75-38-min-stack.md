# Grind 75 — 38. Min Stack

## Problem

Design a stack that supports all standard stack operations while also returning its minimum element in constant time:

- `push(value)` — add a value to the top
- `pop()` — remove the top value
- `top()` — return the top value
- `getMin()` — return the smallest value currently in the stack

Every operation must run in **O(1)** time.

---

## 1. What makes the problem interesting?

A normal stack already gives us constant-time `push`, `pop`, and `top`.

The difficult operation is `getMin`.

If we scan the entire stack whenever `getMin()` is called, the result is correct, but the operation takes **O(n)** time. The requirement forces us to preserve enough information during `push` and `pop` so that the minimum is always immediately available.

The central lesson is:

> If a query must be fast, maintain its answer incrementally while updates occur.

---

## 2. Brute-force design

Store values in one ordinary array.

```javascript
class MinStackBruteForce {
  constructor() {
    this.stack = [];
  }

  push(value) {
    this.stack.push(value);
  }

  pop() {
    return this.stack.pop();
  }

  top() {
    return this.stack[this.stack.length - 1];
  }

  getMin() {
    return Math.min(...this.stack);
  }
}
```

### Complexity

| Operation | Time |
| --- | ---: |
| `push` | O(1) amortized |
| `pop` | O(1) |
| `top` | O(1) |
| `getMin` | O(n) |

This fails the constant-time requirement. Spreading a very large array into `Math.min` can also exceed JavaScript's argument limit.

---

## 3. Key insight: remember minimum history

Suppose the values are pushed in this order:

```text
5, 2, 4, 1
```

The minimum after every push is:

| Push | Main stack | Current minimum |
| ---: | --- | ---: |
| `5` | `[5]` | `5` |
| `2` | `[5, 2]` | `2` |
| `4` | `[5, 2, 4]` | `2` |
| `1` | `[5, 2, 4, 1]` | `1` |

If `1` is popped, the minimum must return to `2`. Therefore, storing only one `minimum` variable is insufficient unless we also retain the previous minima.

We can maintain two synchronized stacks:

1. `stack` stores every value.
2. `minStack` stores the minimum corresponding to every depth.

At index `i`:

```text
minStack[i] = minimum of stack[0 ... i]
```

This is the invariant that makes the design work.

---

## 4. Recommended JavaScript solution

```javascript
class MinStack {
  constructor() {
    this.stack = [];
    this.minStack = [];
  }

  push(value) {
    this.stack.push(value);

    const currentMin = this.minStack.length === 0
      ? value
      : Math.min(value, this.getMin());

    this.minStack.push(currentMin);
  }

  pop() {
    this.minStack.pop();
    return this.stack.pop();
  }

  top() {
    return this.stack[this.stack.length - 1];
  }

  getMin() {
    return this.minStack[this.minStack.length - 1];
  }
}
```

### Why it works

- On every `push`, calculate the new minimum and store it at the same depth.
- On every `pop`, remove one entry from both stacks.
- The top of `minStack` is therefore always the minimum of every value still present in `stack`.

---

## 5. Complete walkthrough

Run these operations:

```javascript
const minStack = new MinStack();

minStack.push(5);
minStack.push(2);
minStack.push(4);
minStack.push(1);
minStack.pop();
minStack.pop();
```

State after each operation:

| Operation | `stack` | `minStack` | `getMin()` |
| --- | --- | --- | ---: |
| `push(5)` | `[5]` | `[5]` | `5` |
| `push(2)` | `[5, 2]` | `[5, 2]` | `2` |
| `push(4)` | `[5, 2, 4]` | `[5, 2, 2]` | `2` |
| `push(1)` | `[5, 2, 4, 1]` | `[5, 2, 2, 1]` | `1` |
| `pop()` | `[5, 2, 4]` | `[5, 2, 2]` | `2` |
| `pop()` | `[5, 2]` | `[5, 2]` | `2` |

Notice what happens when `4` is pushed: it is not the new minimum, so `2` is repeated in `minStack`. That repetition keeps both arrays synchronized and makes `pop` extremely simple.

---

## 6. Correctness reasoning

We maintain this invariant:

> After every operation, the last value in `minStack` is the minimum of all values in `stack`.

### Base case

Before any values are added, both stacks are empty.

When the first value is pushed, it is placed in both stacks. It is necessarily the minimum.

### Push

Assume `minStack` currently ends with the correct minimum. When `value` is pushed, the new minimum must be one of only two values:

- the old minimum, or
- the newly pushed value.

We store `Math.min(value, oldMinimum)`, so the invariant remains true.

### Pop

Each `minStack` entry describes the minimum at the matching depth of `stack`. Removing the last entry from both stacks restores the exact minimum recorded for the preceding depth.

Therefore, `getMin()` always returns the correct value.

---

## 7. Complexity

| Operation | Time | Reason |
| --- | ---: | --- |
| `push` | O(1) amortized | One array push on each stack |
| `pop` | O(1) | One array pop from each stack |
| `top` | O(1) | Direct last-index access |
| `getMin` | O(1) | Direct last-index access |

- Total space: **O(n)**
- Auxiliary minimum-history space: **O(n)**

In JavaScript, `Array.prototype.push()` is normally described as amortized O(1), because an underlying array may occasionally need to grow.

---

## 8. Important edge case: duplicate minimums

Consider:

```text
push(2), push(2), pop()
```

After popping one `2`, the minimum must still be `2`.

The synchronized design handles this automatically:

```text
stack:    [2, 2]
minStack: [2, 2]
```

After one pop:

```text
stack:    [2]
minStack: [2]
```

This is why optimized variants that store only new minima must use `<=`, not merely `<`, or otherwise count duplicates.

---

## 9. Alternative: store only minimum changes

We can reduce repeated values in `minStack` by pushing only values that become a new minimum.

```javascript
class MinStackCompressed {
  constructor() {
    this.stack = [];
    this.minStack = [];
  }

  push(value) {
    this.stack.push(value);

    if (this.minStack.length === 0 || value <= this.getMin()) {
      this.minStack.push(value);
    }
  }

  pop() {
    const removed = this.stack.pop();

    if (removed === this.getMin()) {
      this.minStack.pop();
    }

    return removed;
  }

  top() {
    return this.stack[this.stack.length - 1];
  }

  getMin() {
    return this.minStack[this.minStack.length - 1];
  }
}
```

This can use less space in practice, but its worst-case space remains O(n), such as when values arrive in strictly decreasing order. The synchronized version is usually easier to explain and less error-prone in an interview.

---

## 10. Common mistakes

### Mistake 1: scanning during `getMin`

```javascript
return Math.min(...this.stack);
```

This makes `getMin` O(n), violating the requirement.

### Mistake 2: maintaining only one minimum variable

After the minimum is popped, there is no way to recover the previous minimum without rescanning or storing history.

### Mistake 3: forgetting to pop from `minStack`

The two stacks become misaligned, causing later minimum queries to return stale values.

### Mistake 4: mishandling duplicate minima

In the compressed design, use `value <= currentMin`. If only `<` is used, popping one occurrence may incorrectly remove the minimum while another equal value remains.

### Mistake 5: using `shift()` or `unshift()`

A stack operates at one end. In JavaScript, use `push()` and `pop()`; operations at the beginning of an array require reindexing and can take O(n).

---

## 11. Interview thought process

A clear verbal explanation could be:

> “A normal stack gives me push, pop, and top in constant time, but finding the minimum by scanning would be linear. I’ll trade O(n) additional space for O(1) queries by maintaining a second stack of minimum history. At every depth, its top records the minimum of the main stack at that same depth. Push adds to both stacks, pop removes from both, and getMin reads the second stack’s top.”

If asked why one variable is insufficient:

> “When the current minimum is removed, I need to restore the previous minimum. That requires history, not just the current value.”

---

## 12. Pattern recognition

Use this technique when:

- a mutable data structure needs a constant-time aggregate query;
- updates occur in a reversible LIFO order;
- previous aggregate states need to be restored after removals.

Related idea:

```text
main state + synchronized metadata state
```

The metadata might track a minimum, maximum, running aggregate, or another property associated with each stack depth.

---

## 13. Quick test

```javascript
const stack = new MinStack();

stack.push(-2);
stack.push(0);
stack.push(-3);

console.log(stack.getMin()); // -3
console.log(stack.pop());    // -3
console.log(stack.top());    // 0
console.log(stack.getMin()); // -2
```

---

## 14. Notebook version

### Pattern

**Stack + synchronized minimum-history stack**

### Core invariant

```text
minStack[i] = minimum of stack[0 ... i]
```

### Trigger

The problem asks for ordinary stack operations plus a minimum query, all in O(1).

### Memory line

> Store the answer for every stack depth so a pop restores the previous answer automatically.

### Complexity

```text
push, pop, top, getMin: O(1)
space: O(n)
```

### One-line implementation memory

```javascript
minStack.push(minStack.length === 0 ? value : Math.min(value, getMin()));
```

