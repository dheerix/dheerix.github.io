# Grind 75 — 13: Implement Queue Using Stacks

**Difficulty:** Easy  
**Primary pattern:** Two stacks / amortized analysis / data-structure design  
**LeetCode:** https://leetcode.com/problems/implement-queue-using-stacks/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Implement a first-in-first-out queue using only stack operations.

Required methods:

```text
push(x) → add x to the back
pop()   → remove and return the front
peek()  → return the front without removing it
empty() → return whether the queue is empty
```

A queue is FIFO:

```text
First In, First Out
```

A stack is LIFO:

```text
Last In, First Out
```

The challenge is to reproduce FIFO order using only LIFO structures.

---

## 2. The order mismatch

If we push queue values onto one stack:

```text
push 1, push 2, push 3

stack top
    3
    2
    1
```

Popping returns `3`, but a queue must return `1`.

Reversing the stack fixes the order:

```text
input stack         output stack
top 3               top 1
    2                   2
    1                   3
```

Moving every item from one stack to another reverses their order. Two LIFO reversals can produce FIFO behavior.

---

## 3. Two-stack design

Maintain:

```text
inputStack  → receives newly pushed values
outputStack → exposes the oldest value at its top
```

Rules:

### Push

Always push onto `inputStack`.

### Pop or peek

- If `outputStack` already contains values, use its top.
- If it is empty, move every value from `inputStack` into it.
- Then use the top of `outputStack`.

### Empty

The queue is empty only if both stacks are empty.

---

## 4. Why transfer only when output is empty?

Suppose the queue contains older values already arranged in `outputStack`, then a new value is pushed into `inputStack`.

```text
output top: oldest values ready to leave
input top:  newest values waiting behind them
```

Transferring the new values immediately would disturb the correct order. The existing `outputStack` must be fully consumed first.

Therefore:

> Move input to output only when output is empty.

This preserves FIFO order and avoids unnecessary repeated movement.

---

## 5. Optimal JavaScript implementation

```javascript
class MyQueue {
  constructor() {
    this.inputStack = [];
    this.outputStack = [];
  }

  push(x) {
    this.inputStack.push(x);
  }

  pop() {
    this.moveInputToOutputIfNeeded();
    return this.outputStack.pop();
  }

  peek() {
    this.moveInputToOutputIfNeeded();
    return this.outputStack[this.outputStack.length - 1];
  }

  empty() {
    return (
      this.inputStack.length === 0 &&
      this.outputStack.length === 0
    );
  }

  moveInputToOutputIfNeeded() {
    if (this.outputStack.length > 0) {
      return;
    }

    while (this.inputStack.length > 0) {
      this.outputStack.push(this.inputStack.pop());
    }
  }
}
```

---

## 6. Walkthrough

Operations:

```text
push(1)
push(2)
peek()
push(3)
pop()
pop()
pop()
```

### After `push(1)`, `push(2)`

```text
inputStack:  [1, 2]  ← top is 2
outputStack: []
```

### `peek()`

Output is empty, so transfer:

```text
inputStack:  []
outputStack: [2, 1]  ← top is 1
```

Return `1` without removing it.

### `push(3)`

```text
inputStack:  [3]
outputStack: [2, 1]  ← 1 and 2 are still older
```

Do not transfer `3` yet.

### First `pop()`

Output is non-empty. Pop and return `1`.

```text
inputStack:  [3]
outputStack: [2]
```

### Second `pop()`

Pop and return `2`.

```text
inputStack:  [3]
outputStack: []
```

### Third `pop()`

Output is empty, so transfer `3`, then pop it.

Return order is `1, 2, 3`: correct FIFO behavior.

---

## 7. Code walkthrough

### JavaScript arrays as stacks

Use only the end of the array:

```text
push(x) → add to stack top
pop()   → remove stack top
array[array.length - 1] → inspect stack top
```

These operations are O(1) amortized. Do not use `shift()` or `unshift()`; those are queue-like array operations and may reindex elements. The point of this exercise is to build the queue from stack behavior.

### `push(x)`

New elements belong behind all current queue elements, so they stay in `inputStack` until older output values are exhausted.

### Shared transfer helper

Both `pop()` and `peek()` need to ensure the oldest element is exposed. Centralizing that logic prevents duplication.

### `peek()`

Read the last output element without removing it:

```javascript
this.outputStack[this.outputStack.length - 1]
```

### `empty()`

Elements may exist in either stack. Checking only one stack would misreport the queue state.

The problem guarantees that `pop` and `peek` are called only when non-empty. Under a broader production contract, decide whether to return `undefined` or throw an error.

---

## 8. Invariants

Two invariants explain the design:

1. If `outputStack` is non-empty, its top is the front of the queue.
2. Every element in `outputStack` is older than every element in `inputStack`.

The transfer reverses the insertion order of the current input batch, placing its oldest item on top. Refusing to transfer while output contains older elements preserves the second invariant.

---

## 9. Correctness reasoning

Every pushed element enters `inputStack`. When it becomes part of the oldest pending batch, transfer reverses that batch into `outputStack`, placing the earliest-pushed element at the top.

While `outputStack` is non-empty, all its elements were enqueued before anything remaining in `inputStack`, so popping from output returns globally oldest elements first. Only after those are exhausted is the next input batch reversed. Therefore, `pop` and `peek` always expose the queue front, and the implementation is FIFO.

---

## 10. Complexity and amortized analysis

### `push`

- Time: **O(1)**.

### `pop` and `peek`

- Worst case for one call: **O(n)** if a transfer occurs.
- Amortized time: **O(1)**.

### `empty`

- Time: **O(1)**.

### Space

- **O(n)** total for storing the queue's `n` elements across two stacks.

Why amortized O(1)? Each element:

1. is pushed onto `inputStack` once;
2. is popped from `inputStack` once;
3. is pushed onto `outputStack` once;
4. is popped from `outputStack` once.

That is a constant number of stack operations per element over its entire lifetime. Across `n` queue operations, total work is O(n), even though an individual call can occasionally perform O(n) transfer work.

---

## 11. Worst-case versus amortized time

Do not say simply “`pop` is O(1)” without qualification.

Accurate statement:

> `pop` and `peek` are O(1) amortized, but O(n) in the worst case for a single operation that triggers transfer.

Amortized analysis does not mean average over random inputs. It gives a guarantee on the total cost of a sequence of operations, regardless of operation order.

---

## 12. Alternative: expensive push

Another design keeps one stack permanently arranged so its top is the queue front. Each push can move all existing values away, insert the new value, and restore the previous values.

```javascript
class MyQueueExpensivePush {
  constructor() {
    this.primary = [];
    this.temporary = [];
  }

  push(x) {
    while (this.primary.length > 0) {
      this.temporary.push(this.primary.pop());
    }

    this.primary.push(x);

    while (this.temporary.length > 0) {
      this.primary.push(this.temporary.pop());
    }
  }

  pop() {
    return this.primary.pop();
  }

  peek() {
    return this.primary[this.primary.length - 1];
  }

  empty() {
    return this.primary.length === 0;
  }
}
```

Here:

- `push`: O(n);
- `pop` and `peek`: O(1).

The lazy-transfer design is usually preferred because all operations become O(1) amortized and unnecessary movement is avoided.

---

## 13. Common mistakes

1. **Transferring on every `pop` or `peek`.** Transfer only when output is empty.
2. **Transferring immediately after every push.** This can disturb the order of older output elements and adds work.
3. **Checking only `inputStack` in `empty()`.** Elements may still be waiting in output.
4. **Using `shift()` and claiming a stack-only implementation.** `shift()` is a queue operation on the array's front.
5. **Removing during `peek()`.** Peek must not mutate queue contents.
6. **Calling single-operation `pop` worst-case O(1).** It is O(1) amortized and O(n) worst case.
7. **Claiming auxiliary storage is O(1).** The two stacks collectively store O(n) elements.
8. **Forgetting JavaScript method context.** Call the helper as `this.moveInputToOutputIfNeeded()`.
9. **Using a public helper name carelessly in production.** LeetCode accepts it; a private class method could be used where supported.

---

## 14. What to say in an interview

> “I’ll use an input stack for newly enqueued values and an output stack whose top represents the queue front. Push always goes to input. Pop and peek use output; only when output is empty do I transfer all input values, reversing their order. Each element moves from input to output at most once, so push is O(1), and pop and peek are O(1) amortized, with O(n) total storage.”

If asked why transfer is lazy:

> “Values already in output are older than every value in input and must leave first, so input should not be mixed in until output is exhausted.”

---

## 15. Pattern recognition

Think **two structures with lazy transfer** when:

- one structure's natural order is opposite the required order;
- transferring reverses order;
- work can be deferred until consumers need it;
- batches can be processed without repeatedly moving the same elements.

Think **amortized analysis** when:

- most operations are cheap;
- occasional operations are expensive;
- each item can participate in the expensive work only a bounded number of times.

Memory cue:

> Input stores the new; output serves the old.

---

## 16. Edge cases

| Operation sequence | Important behavior |
|---|---|
| New queue → `empty()` | `true` |
| `push(1)` → `peek()` | returns `1`, does not remove |
| `push(1)` → `pop()` → `empty()` | returns `1`, then `true` |
| Push several → pop one → push more | older output values still leave first |
| Transfer once → several pops | no repeated transfer |
| Input empty, output non-empty | queue is not empty |

---

## 17. Notebook-ready notes

### 📚 Concept

**Queue Using Stacks — lazy two-stack transfer**

```text
inputStack:  all new pushes
outputStack: oldest element on top

push: input.push(x)
pop/peek:
  if output empty:
    move all input → output
  use output top
empty: both stacks empty
```

### 🧠 My understanding

Moving a stack into another stack reverses order, making the oldest input value accessible first. Output values are always older than input values, so I transfer only when output is empty. Each element moves between stacks once, which makes the occasional expensive transfer O(1) amortized per operation.

### 💼 Interview line

> “I’ll reverse lazily: input collects new values, output exposes old values.”

### ⚠️ Traps

- Transfer only when output is empty.
- `empty()` checks both stacks.
- `peek()` does not pop.
- Say O(1) amortized, not worst-case O(1).

---

## 18. Dheerix Glance

```text
QUEUE USING STACKS

Queue order:      FIFO
Stack order:      LIFO
Structures:       input stack + output stack
Push:             always to input
Pop/peek:         from output
Transfer trigger: output is empty
Transfer effect:  reverses input order
Invariant:        output elements are older than input elements
Push time:        O(1)
Pop/peek time:    O(1) amortized, O(n) single-call worst case
Space:            O(n)
Memory cue:       “New waits in input; old leaves from output.”
```

---

## 19. Recall test

Without looking back:

1. Why does transferring between stacks create queue order?
2. Why must transfer happen only when output is empty?
3. What are the two core invariants?
4. Why does `empty()` inspect both stacks?
5. What is the worst-case cost of one `pop` that triggers a transfer?
6. Why is `pop` nevertheless O(1) amortized?
7. How many times can one element move between the stacks?
8. What trade-off does the expensive-push alternative make?

