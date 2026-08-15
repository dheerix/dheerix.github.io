# Grind 75 — 22: Middle of the Linked List

**Difficulty:** Easy  
**Primary pattern:** Fast and slow pointers  
**LeetCode:** https://leetcode.com/problems/middle-of-the-linked-list/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given the head of a singly linked list, return its middle node.

For an odd number of nodes, there is one middle:

```text
1 → 2 → 3 → 4 → 5
        ↑
      return 3
```

For an even number of nodes, return the **second** middle:

```text
1 → 2 → 3 → 4 → 5 → 6
            ↑
          return 4
```

The output is the node reference, not its index or value.

---

## 2. Straightforward two-pass approach

First count the nodes. Then traverse `floor(n / 2)` steps from the head.

```javascript
function middleNodeTwoPass(head) {
  let length = 0;
  let current = head;

  while (current !== null) {
    length++;
    current = current.next;
  }

  current = head;
  const middleIndex = Math.floor(length / 2);

  for (let i = 0; i < middleIndex; i++) {
    current = current.next;
  }

  return current;
}
```

- Time: **O(n)**.
- Extra space: **O(1)**.
- Traversals: two.

This is correct, but the length can be inferred during a single traversal using two speeds.

---

## 3. Fast and slow insight

Maintain:

```text
slow → moves one node per iteration
fast → moves two nodes per iteration
```

Distance relationship:

```text
fast distance = 2 × slow distance
```

When fast reaches the end of an `n`-node list, slow has moved approximately `n / 2` nodes and therefore points at the middle.

This is not based on values or indices. Relative pointer speed measures the list structure during traversal.

---

## 4. Optimal JavaScript solution

```javascript
function middleNode(head) {
  let slow = head;
  let fast = head;

  while (fast !== null && fast.next !== null) {
    slow = slow.next;
    fast = fast.next.next;
  }

  return slow;
}
```

---

## 5. Dry run: odd length

```text
1 → 2 → 3 → 4 → 5 → null
```

| Iteration | Slow | Fast |
|---:|---:|---:|
| Start | 1 | 1 |
| 1 | 2 | 3 |
| 2 | 3 | 5 |

Now `fast.next === null`, so the loop stops. Slow points at node `3`, the middle.

---

## 6. Dry run: even length

```text
1 → 2 → 3 → 4 → 5 → 6 → null
```

| Iteration | Slow | Fast |
|---:|---:|---:|
| Start | 1 | 1 |
| 1 | 2 | 3 |
| 2 | 3 | 5 |
| 3 | 4 | null |

Slow points at node `4`, which is the second middle as required.

The initialization and loop condition determine this tie-breaking behavior.

---

## 7. Why this returns the second middle

For an even length `n = 2k`:

- the loop runs `k` times;
- slow moves `k` nodes from zero-based index `0` to index `k`;
- the two middle indices are `k - 1` and `k`;
- index `k` is the second middle.

Example for six nodes:

```text
indices: 0 1 2 3 4 5
middles:     2 3
returned:      3
```

---

## 8. Code walkthrough

### Both pointers start at `head`

This initialization combined with the two-step fast pointer produces the required second-middle behavior.

### Safe loop guard

```javascript
fast !== null && fast.next !== null
```

The fast pointer moves two links, so both `fast` and its next node must exist.

JavaScript evaluates `&&` left to right and short-circuits. If `fast` is null, it does not access `fast.next`.

### Pointer movement

```javascript
slow = slow.next;
fast = fast.next.next;
```

The speed ratio must remain exactly one to two.

### Return node reference

Return `slow`, not `slow.val`. The required result is the middle node, including the list suffix beginning there.

---

## 9. Loop invariant

After `k` completed iterations:

```text
slow has moved k edges
fast has moved 2k edges
```

As long as the loop continues, both movements are valid. When fast can no longer move two steps, slow has traversed half the list, rounded down in distance from the head, which places it at index `floor(n / 2)`—the unique middle for odd `n` and the second middle for even `n`.

---

## 10. Correctness reasoning

For a list of length `n`, the loop runs exactly `floor(n / 2)` times:

- if `n = 2k`, fast makes `k` two-step movements and reaches `null`;
- if `n = 2k + 1`, fast makes `k` movements and stops at the last node because `fast.next` is null.

Slow makes one movement per iteration, so it ends at zero-based index `floor(n / 2)`. That is the middle index for odd length and the second-middle index for even length. Therefore, returning slow is correct.

---

## 11. Complexity

- **Time: O(n)** — fast traverses the list once at double speed; the number of iterations is about `n / 2`, which is still O(n).
- **Auxiliary space: O(1)** — only two node references are stored.
- **Passes: one**.

Constant factors do not change Big O: O(n/2) simplifies to O(n).

---

## 12. Follow-up: return the first middle

For an even-length list, sometimes a problem asks for the first middle instead.

One approach initializes fast one node ahead:

```javascript
function firstMiddleNode(head) {
  let slow = head;
  let fast = head.next;

  while (fast !== null && fast.next !== null) {
    slow = slow.next;
    fast = fast.next.next;
  }

  return slow;
}
```

For `1 → 2 → 3 → 4 → 5 → 6`, this returns node `3` instead of node `4`.

General lesson:

> Fast/slow-pointer tie-breaking depends on initialization and stopping conditions. Derive them from small even-length examples rather than memorizing blindly.

---

## 13. Relationship to Linked List Cycle

Both problems use the same speeds:

```text
slow moves 1
fast moves 2
```

But the observation differs:

| Problem | What pointer behavior reveals |
|---|---|
| Middle of list | Fast reaching the end places slow halfway |
| Linked-list cycle | Fast meeting slow proves a loop |

The technique is not the answer by itself. The meaning comes from the termination or collision condition.

---

## 14. Common mistakes

1. **Returning `slow.val`.** The problem requests the node reference.
2. **Returning the first middle for even length.** The official problem requires the second.
3. **Checking only `fast !== null`.** `fast.next.next` also requires `fast.next` to exist.
4. **Reversing the safe guard order.** Accessing `fast.next` before confirming `fast` exists can fail.
5. **Moving fast only one step.** Slow and fast then remain together and provide no midpoint information.
6. **Moving slow two steps.** The required 2:1 distance relationship is broken.
7. **Calling the runtime O(log n).** Halving iteration count is not halving the search space; the fast pointer still crosses O(n) links.
8. **Using an array to store nodes.** That works but costs O(n) extra space.
9. **Applying this directly to a cyclic list.** Fast never reaches an end; the official input is acyclic.

---

## 15. What to say in an interview

> “I can count the list and traverse again, but a fast and slow pointer finds the middle in one pass. Slow moves one node while fast moves two. When fast reaches the end or cannot take another two-step move, slow has covered half the distance. Starting both at the head makes slow land on the second middle for even-length lists. This is O(n) time and O(1) space.”

If asked why it is not O(log n):

> “We do half as many loop iterations, but the number of traversed links remains proportional to n; no search space is discarded.”

---

## 16. Pattern recognition

Think **fast and slow pointers** when:

- one pointer's progress should measure a fraction of a sequential structure;
- the length is unknown and a second pass is avoidable;
- you need a midpoint, cycle, or relative position;
- only forward traversal is available.

This technique is useful for:

- finding the middle before splitting a list;
- merge sort on linked lists;
- checking linked-list palindromes;
- deleting the nth node from the end with a fixed pointer gap;
- cycle detection.

Memory cue:

> When fast finishes two laps of distance, slow has covered one.

---

## 17. Edge cases

| List | Returned node |
|---|---|
| one node: `1` | `1` |
| two nodes: `1 → 2` | `2` |
| three nodes: `1 → 2 → 3` | `2` |
| four nodes: `1 → 2 → 3 → 4` | `3` |
| repeated values | structural middle node |

The official constraints guarantee at least one node. If an empty list were allowed, this implementation would return `null` naturally.

---

## 18. Notebook-ready notes

### 📚 Concept

**Middle of Linked List — fast/slow pointers**

```text
slow = head
fast = head
while fast and fast.next:
  slow = slow.next
  fast = fast.next.next
return slow
```

### 🧠 My understanding

Fast covers twice the distance of slow. When fast reaches the end, slow has crossed half the list. Starting them together and stopping when fast cannot move two steps places slow at `floor(n/2)`, which is the second middle for even lengths.

### 💼 Interview line

> “The fast pointer measures the list while the slow pointer lands halfway.”

### ⚠️ Traps

- Return the node, not its value.
- Guard both `fast` and `fast.next`.
- This template returns the second middle.
- Runtime is O(n), not O(log n).

---

## 19. Dheerix Glance

```text
MIDDLE OF LINKED LIST

Slow speed:       1 node
Fast speed:       2 nodes
Initialize:       both at head
Continue while:   fast && fast.next
Finish:           slow at floor(n/2)
Even length:      returns second middle
Return:           node reference
Time:             O(n)
Auxiliary space:  O(1)
Memory cue:       “Fast reaches end; slow reaches middle.”
```

---

## 20. Recall test

Without looking back:

1. Why does the two-pass solution work, and what does fast/slow improve?
2. What is the distance relationship between the pointers?
3. Why must the loop guard check `fast.next`?
4. Why does this template return the second middle?
5. How would you modify it to return the first middle?
6. Why is the runtime O(n), not O(log n)?
7. How does the same pointer technique serve cycle detection differently?
8. State the loop invariant in one sentence.

