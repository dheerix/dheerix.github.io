# Grind 75 — 18: Reverse Linked List

**Difficulty:** Easy  
**Primary pattern:** Linked-list pointer manipulation / iterative traversal  
**LeetCode:** https://leetcode.com/problems/reverse-linked-list/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given the head of a singly linked list, reverse every `next` reference and return the new head.

```text
Before:
1 → 2 → 3 → 4 → null

After:
null ← 1 ← 2 ← 3 ← 4
                       ↑
                    new head
```

The values stay in their existing node objects. Only the direction of the links changes.

The typical node definition is:

```javascript
function ListNode(val, next = null) {
  this.val = val;
  this.next = next;
}
```

---

## 2. The central danger: losing the remaining list

At a current node:

```text
previous ← current → remaining list
```

We want to change:

```javascript
current.next = previous;
```

But `current.next` is currently the only reference to the unprocessed remainder. If we overwrite it before saving it, the rest of the list becomes unreachable from our local variables.

Therefore, the safe order is:

```text
1. save next
2. reverse current link
3. advance previous
4. advance current
```

Memory sentence:

> Save the future before reversing the present.

---

## 3. Required pointers

Maintain three references:

```text
previous → head of the already reversed prefix
current  → node currently being processed
nextNode → saved head of the unprocessed remainder
```

Initial state:

```text
previous = null
current  = head
```

Why `previous = null`? The original head becomes the final tail, and its reversed `next` must point to `null`.

---

## 4. Step-by-step algorithm

While `current` exists:

1. `nextNode = current.next` — preserve the rest.
2. `current.next = previous` — reverse one link.
3. `previous = current` — grow the reversed prefix.
4. `current = nextNode` — continue into the saved remainder.

When `current` becomes `null`, every node has been moved into the reversed prefix. `previous` is the new head.

---

## 5. Optimal iterative JavaScript solution

```javascript
function reverseList(head) {
  let previous = null;
  let current = head;

  while (current !== null) {
    const nextNode = current.next;

    current.next = previous;
    previous = current;
    current = nextNode;
  }

  return previous;
}
```

---

## 6. Dry run

```text
1 → 2 → 3 → null
```

### Initial

```text
previous = null
current  = 1 → 2 → 3 → null
```

### Process node 1

```text
save nextNode = 2
set 1.next = null

previous = 1 → null
current  = 2 → 3 → null
```

### Process node 2

```text
save nextNode = 3
set 2.next = 1

previous = 2 → 1 → null
current  = 3 → null
```

### Process node 3

```text
save nextNode = null
set 3.next = 2

previous = 3 → 2 → 1 → null
current  = null
```

Return `previous`, which points to node `3`.

---

## 7. Pointer-state table

| Iteration | `previous` before | `current` | saved `nextNode` | `previous` after |
|---:|---|---|---|---|
| 1 | `null` | `1` | `2` | `1 → null` |
| 2 | `1` | `2` | `3` | `2 → 1 → null` |
| 3 | `2` | `3` | `null` | `3 → 2 → 1 → null` |

The unprocessed remainder always starts at `current`; the reversed prefix always starts at `previous`.

---

## 8. Loop invariant

At the beginning of every iteration:

1. `previous` points to the reversed form of all nodes processed so far.
2. `current` points to the first unprocessed node in the original direction.
3. Every original node belongs to exactly one of those two chains.

The loop moves one node from the front of the unprocessed chain to the front of the reversed chain while preserving access to both.

This “move one node between two regions” view makes pointer algorithms easier to reason about.

---

## 9. Correctness reasoning

Initially, the processed prefix is empty, so `previous = null` correctly represents its reversal, while `current = head` represents the entire unprocessed list.

During an iteration, `nextNode` preserves the unprocessed remainder. Setting `current.next = previous` correctly places the current node before the reversed prefix. Updating `previous` and `current` re-establishes the invariant with one additional processed node.

When `current === null`, no unprocessed nodes remain. By the invariant, `previous` points to the reversal of the entire original list. Therefore, returning `previous` is correct.

---

## 10. Complexity

- **Time: O(n)** — each node is visited exactly once.
- **Auxiliary space: O(1)** — only three node references are used.

The list is reversed in place; no new list nodes are created.

---

## 11. Recursive solution

```javascript
function reverseListRecursive(head) {
  if (head === null || head.next === null) {
    return head;
  }

  const newHead = reverseListRecursive(head.next);

  head.next.next = head;
  head.next = null;

  return newHead;
}
```

---

## 12. Understanding the recursive rewiring

Suppose the current call sees:

```text
head → next → ...
```

The recursive call reverses everything after `head` and returns the new head of that reversed suffix.

After recursion returns, `head.next` still refers to the node that originally followed `head`. That node is now the tail of the reversed suffix.

```javascript
head.next.next = head;
```

makes that node point backward to `head`.

Then:

```javascript
head.next = null;
```

removes the old forward link. Without this line, the final two nodes would point at each other and create a cycle.

Recursive complexity:

- Time: **O(n)**.
- Call-stack space: **O(n)**.

Prefer the iterative solution for O(1) auxiliary space and lower risk of call-stack overflow in JavaScript.

---

## 13. Why `previous` is the answer, not `current`

The loop ends because:

```text
current === null
```

`current` has moved one position beyond the original tail. Meanwhile, after processing the original tail, `previous` was updated to point at it.

```text
current  → null
previous → original tail → ... → original head → null
```

Therefore, return `previous`.

---

## 14. Common mistakes

1. **Overwriting `current.next` before saving it.** The unprocessed remainder becomes unreachable.
2. **Returning `head`.** The original head is now the tail.
3. **Returning `current`.** It is `null` when traversal finishes.
4. **Forgetting `previous = current`.** The reversed prefix does not advance.
5. **Forgetting `current = nextNode`.** The loop cannot continue correctly.
6. **Initializing `previous` to `head`.** The original head's link is not terminated and the state becomes incorrect.
7. **Creating new nodes unnecessarily.** Rewiring existing nodes gives O(1) extra space.
8. **Forgetting `head.next = null` in recursion.** This creates a cycle.
9. **Calling the recursive version O(1) space.** It consumes O(n) call-stack frames.
10. **Trying to reverse values instead of links.** The problem tests linked-list structure and may rely on node identity.

---

## 15. What to say in an interview

> “I’ll maintain `previous` as the head of the reversed prefix and `current` as the first unprocessed node. Before changing `current.next`, I must save it because that is my only reference to the remaining list. Then I reverse the link and advance both pointers. Each node is processed once, giving O(n) time and O(1) extra space.”

If asked for the invariant:

> “At every iteration, `previous` heads the correctly reversed processed prefix, while `current` heads the untouched remainder.”

---

## 16. Pattern recognition

Think **three-pointer linked-list rewiring** when:

- links must change direction;
- the current link is also the only route to future nodes;
- a list is divided into processed and unprocessed regions;
- nodes should be reused in place.

The broader linked-list safety rule:

> Before changing a pointer, save every reference you will still need afterward.

This applies to reversing sublists, removing nodes, merging lists, and reordering chains.

Memory cue:

> Save next, reverse link, advance both.

---

## 17. Edge cases

| Input | Output | Behavior |
|---|---|---|
| empty list | `null` | Loop does not run |
| one node | same node | Its `next` becomes/remains `null` |
| two nodes | second → first | One link reversal plus tail termination |
| long list | complete reversal | Every node moved once |
| repeated values | normal reversal | Node identity, not value, matters |

Useful property test:

```text
reverse(reverse(list)) = original node order
```

---

## 18. Notebook-ready notes

### 📚 Concept

**Reverse Linked List — three-pointer rewiring**

```text
previous = null
current = head

while current:
  nextNode = current.next   // save future
  current.next = previous  // reverse present
  previous = current       // grow reversed side
  current = nextNode       // enter remainder

return previous
```

### 🧠 My understanding

The list is divided into a reversed prefix and an untouched remainder. Each iteration moves the first remainder node onto the front of the reversed prefix. Saving `nextNode` before rewiring prevents the rest of the list from being lost.

### 💼 Interview line

> “I must preserve the next node before overwriting the only pointer that reaches it.”

### ⚠️ Traps

- Save `current.next` first.
- Return `previous`, not `head` or `current`.
- Iterative space is O(1); recursive space is O(n).
- Recursive version must set the old forward link to `null`.

---

## 19. Dheerix Glance

```text
REVERSE LINKED LIST

Regions:          reversed prefix + untouched remainder
previous:         head of reversed prefix
current:          first unprocessed node
nextNode:         saved remainder before rewiring
Order:            save → reverse → advance previous → advance current
Return:           previous
Time:             O(n)
Iterative space:  O(1)
Recursive space:  O(n)
Memory cue:       “Save the future before reversing the present.”
```

---

## 20. Recall test

Without looking back:

1. Why must `current.next` be saved before reversal?
2. What do `previous` and `current` represent at each iteration?
3. Why does `previous` start as `null`?
4. Why is `previous` the returned head?
5. What happens if `current` is advanced before saving its next node?
6. Why does the recursive solution set `head.next = null`?
7. Compare iterative and recursive space complexity.
8. State the loop invariant in one sentence.

