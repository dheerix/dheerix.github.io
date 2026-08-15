# Grind 75 — 12: Linked List Cycle

**Difficulty:** Easy  
**Primary pattern:** Fast and slow pointers / Floyd's cycle detection  
**LeetCode:** https://leetcode.com/problems/linked-list-cycle/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given the head of a singly linked list, determine whether following `next` references eventually revisits a previously visited node.

No cycle:

```text
1 → 2 → 3 → null
```

Cycle:

```text
1 → 2 → 3 → 4
        ↑     ↓
        └─────┘
```

The input description may mention `pos`, the index to which the tail connects. `pos` is used by the test system to construct the list; it is not passed to your function.

The typical node definition is:

```javascript
function ListNode(val) {
  this.val = val;
  this.next = null;
}
```

---

## 2. What makes this different from an array?

A linked list has no length available in advance and no random access. We can only follow `next` references.

If the list is acyclic, traversal eventually reaches `null`.

If the list contains a cycle, ordinary traversal never reaches `null` and repeats forever unless we record visited nodes or exploit pointer motion.

---

## 3. Straightforward approach: visited set

Store each node object in a `Set`.

```javascript
function hasCycleWithSet(head) {
  const visited = new Set();
  let current = head;

  while (current !== null) {
    if (visited.has(current)) {
      return true;
    }

    visited.add(current);
    current = current.next;
  }

  return false;
}
```

### Complexity

- Time: **O(n)** average.
- Extra space: **O(n)**.

This is correct and intuitive. The optimal solution preserves O(n) time while reducing extra space to O(1).

Important: the set stores **node identities**, not values. Two different nodes may legally contain the same value without forming a cycle.

---

## 4. Optimal insight: two different speeds

Use two pointers:

```text
slow → moves 1 edge per iteration
fast → moves 2 edges per iteration
```

There are two possible outcomes:

### No cycle

The fast pointer reaches `null` or a node whose `next` is `null`.

### Cycle exists

Once both pointers are inside the cycle, the fast pointer gains one node on the slow pointer every iteration. On a finite circular path, it must eventually catch the slow pointer.

This is Floyd's cycle detection algorithm, also called the **tortoise and hare** algorithm.

---

## 5. Why meeting proves a cycle

Both pointers begin at the same head, but we do not compare them before moving. After each iteration:

```text
slow has moved k steps
fast has moved 2k steps
```

In an acyclic list, two forward-moving pointers of different speeds cannot meet again before the faster one reaches the end.

In a cycle of length `C`, consider positions modulo `C`. Once inside the cycle, the relative distance changes by:

```text
2 - 1 = 1 position per iteration
```

The relative distance must eventually become `0 mod C`, so the pointers occupy the same node.

This is not a timing coincidence; it is guaranteed by modular movement on a finite cycle.

---

## 6. Optimal JavaScript solution

```javascript
function hasCycle(head) {
  let slow = head;
  let fast = head;

  while (fast !== null && fast.next !== null) {
    slow = slow.next;
    fast = fast.next.next;

    if (slow === fast) {
      return true;
    }
  }

  return false;
}
```

---

## 7. Code walkthrough

### Both pointers start at `head`

Starting together is fine because comparison happens only after each has moved. If we compared before moving, every non-empty list would incorrectly appear cyclic.

### Loop guard

```javascript
fast !== null && fast.next !== null
```

The fast pointer advances two edges, so both `fast` and `fast.next` must exist before evaluating `fast.next.next`.

The order of the conditions matters because JavaScript short-circuits from left to right. If `fast` is null, `fast.next` is never accessed.

### Reference comparison

```javascript
slow === fast
```

This asks whether both variables refer to the exact same node object. Comparing `slow.val === fast.val` would be incorrect because separate nodes can have equal values.

### Why return false after the loop?

The loop stops only because the fast pointer cannot take two more steps. That means the list has a reachable end, so it cannot contain a cycle along the traversed path.

---

## 8. Dry run: no cycle

```text
1 → 2 → 3 → 4 → null
```

| Iteration | Slow | Fast |
|---:|---:|---:|
| Start | 1 | 1 |
| 1 | 2 | 3 |
| 2 | 3 | null |

The loop ends because `fast === null`. Return `false`.

---

## 9. Dry run: cycle

```text
1 → 2 → 3 → 4 → 5
        ↑         ↓
        └─────────┘
```

Cycle nodes are `3 → 4 → 5 → 3`.

| Iteration | Slow | Fast |
|---:|---:|---:|
| Start | 1 | 1 |
| 1 | 2 | 3 |
| 2 | 3 | 5 |
| 3 | 4 | 4 |

The pointers meet at node `4`, proving a cycle.

They do not have to meet at the cycle entrance.

---

## 10. Correctness reasoning

### If the function returns `true`

`slow` and `fast` refer to the same node after traveling different numbers of edges. In a deterministic singly linked list, revisiting the same reachable node implies that following `next` references repeats a path. Therefore, a cycle exists.

### If a cycle exists

The fast pointer cannot reach `null`. Eventually both pointers enter the finite cycle. The fast pointer gains one cycle position on the slow pointer per iteration, so their relative distance becomes zero modulo the cycle length and they meet. Therefore, the function returns `true`.

### If no cycle exists

The finite list ends at `null`. The fast pointer reaches the end, the loop stops, and the function returns `false`.

Together, these establish correctness.

---

## 11. Complexity

- **Time: O(n)** — in an acyclic list, the fast pointer reaches the end; in a cyclic list, the pointers meet after a linear number of steps.
- **Auxiliary space: O(1)** — only two node references are stored.

The algorithm does not modify the list.

---

## 12. Why the algorithm is still O(n) inside a cycle

Let:

```text
L = number of nodes before the cycle
C = cycle length
```

The pointers enter the cycle after O(L) movement. Once both are inside, the fast pointer closes one relative position per iteration, so it takes at most O(C) additional iterations to meet.

```text
O(L + C) = O(n)
```

No unbounded circling occurs before detection.

---

## 13. Follow-up: find the cycle entrance

After `slow` and `fast` meet:

1. move one pointer back to `head`;
2. keep the other at the meeting point;
3. advance both one step at a time;
4. their next meeting point is the cycle entrance.

```javascript
function detectCycleStart(head) {
  let slow = head;
  let fast = head;

  while (fast !== null && fast.next !== null) {
    slow = slow.next;
    fast = fast.next.next;

    if (slow === fast) {
      let fromHead = head;

      while (fromHead !== slow) {
        fromHead = fromHead.next;
        slow = slow.next;
      }

      return slow;
    }
  }

  return null;
}
```

This also runs in O(n) time and O(1) space.

The underlying distance relationship explains it. If the distance from head to the cycle entrance is `L`, the meeting point is positioned so that moving `L` steps from both head and meeting point lands at the entrance modulo the cycle length.

---

## 14. Common mistakes

1. **Comparing node values instead of node references.** Equal values do not imply the same node.
2. **Comparing `slow === fast` before either moves.** Both start at the head, causing an immediate false positive.
3. **Checking only `fast !== null`.** Accessing `fast.next.next` also requires `fast.next` to exist.
4. **Using `fast.next` after `fast` may be null.** Keep the short-circuit guard in safe order.
5. **Moving both pointers at the same speed.** Their distance never changes, so one cannot catch the other.
6. **Mutating node references to mark visitation.** This is unnecessary and can destroy the list.
7. **Claiming the meeting point is always the cycle entrance.** It generally is not.
8. **Thinking repeated values form a cycle.** Cycles are about reference paths, not data duplication.
9. **Using a visited set and claiming O(1) space.** The set grows to O(n).

---

## 15. What to say in an interview

> “The direct solution stores visited node references in a set, which takes O(n) space. I can reduce that using Floyd's cycle detection: a slow pointer moves one step and a fast pointer moves two. If the list ends, fast reaches null. If a cycle exists, once both pointers are inside it, fast gains one position per iteration modulo the cycle length and must meet slow. That gives O(n) time and O(1) extra space.”

If asked why values are not compared:

> “A cycle means revisiting the same node object, while multiple different nodes may contain identical values.”

---

## 16. Pattern recognition

Think **fast and slow pointers** when:

- a sequence is generated by repeatedly following a deterministic next step;
- you need to detect a loop without storing history;
- you need the middle of a linked list;
- two traversal speeds reveal structure.

Floyd's algorithm applies beyond linked lists, including repeated function-state transitions and some duplicate-number problems.

Memory cue:

> An end lets the hare escape; a cycle makes it meet the tortoise.

---

## 17. Edge cases

| Structure | Result | Why |
|---|---:|---|
| empty list | `false` | No nodes |
| one node → null | `false` | Fast cannot take two steps |
| one node → itself | `true` | Both meet after moving |
| two nodes → null | `false` | Fast reaches end |
| two nodes forming a cycle | `true` | Relative motion forces meeting |
| long prefix before cycle | `true` | Detection occurs after entering cycle |
| repeated values, no cycle | `false` | Node identities remain distinct |

---

## 18. Notebook-ready notes

### 📚 Concept

**Linked List Cycle — Floyd's tortoise and hare**

```text
slow moves 1
fast moves 2
slow === fast after movement → cycle
fast === null or fast.next === null → no cycle
```

### 🧠 My understanding

In a finite acyclic list, the fast pointer escapes through `null`. Inside a cycle, fast gains one relative position on slow every iteration, so it must eventually land on the same node. Comparing references is essential because values can repeat.

### 💼 Interview line

> “Different speeds turn a cycle into an inevitable pointer collision.”

### ⚠️ Traps

- Guard both `fast` and `fast.next`.
- Compare after movement.
- Compare node identity, not `.val`.
- The collision point is not necessarily the entrance.

---

## 19. Dheerix Glance

```text
LINKED LIST CYCLE

Technique:       Floyd's fast/slow pointers
Slow speed:      1 edge
Fast speed:      2 edges
Cycle proof:     fast gains 1 position per cycle iteration
Detect:          slow === fast after movement
No cycle:        fast or fast.next reaches null
Comparison:      node identity, not value
Time:            O(n)
Auxiliary space: O(1)
Memory cue:      “Escape means no cycle; collision means cycle.”
```

---

## 20. Recall test

Without looking back:

1. Why must the set solution store node objects rather than values?
2. Why are two different pointer speeds necessary?
3. Why must fast and slow meet inside a cycle?
4. Why does the loop guard inspect both `fast` and `fast.next`?
5. Why is the algorithm O(n), not potentially infinite?
6. Is the first meeting point always the cycle entrance?
7. How can the entrance be found after a collision?
8. State the correctness argument in two sentences.

