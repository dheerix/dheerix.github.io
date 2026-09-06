# Grind 75 — 03: Merge Two Sorted Lists

**Difficulty:** Easy  
**Primary pattern:** Linked list / two pointers / dummy head  
**LeetCode:** https://leetcode.com/problems/merge-two-sorted-lists/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

You are given the heads of two linked lists. Each list is already sorted in non-decreasing order. Merge their nodes into one sorted linked list and return its head.

```text
list1: 1 → 2 → 4
list2: 1 → 3 → 4

result: 1 → 1 → 2 → 3 → 4 → 4
```

The usual LeetCode node definition is:

```javascript
function ListNode(val, next = null) {
  this.val = val;
  this.next = next;
}
```

---

## 2. What “sorted” gives us

At any moment, the smallest remaining node must be one of:

- the current node of `list1`;
- the current node of `list2`.

We never need to search deeper into either list. If `list1.val <= list2.val`, then `list1` is safe to append because every later value in both lists is at least as large as the two current values.

This is the same merge operation used by merge sort.

---

## 3. Why linked lists change the implementation

With arrays, merging often means copying values into a new array. With linked lists, we can reuse the existing nodes by changing their `next` references.

We maintain three useful references:

```text
list1  → first unmerged node from list 1
list2  → first unmerged node from list 2
tail   → last node in the merged list
```

After attaching one node to `tail.next`, move both:

1. the pointer belonging to the chosen source list;
2. `tail`, so it again points at the last merged node.

---

## 4. The awkward first-node problem

Without a dummy node, the first selected node must initialize both the result head and the tail. Every later node follows different logic.

A **dummy head** removes that branch:

```text
dummy → first real node → second real node → ...
          ↑
       return this
```

The dummy is a temporary node placed before the real result. Every real node is always attached using:

```javascript
tail.next = chosenNode;
tail = tail.next;
```

At the end, return `dummy.next`, not `dummy`.

The dummy node is not a hack; it is a sentinel that simplifies boundary handling.

---

## 5. Step-by-step algorithm

1. Create `dummy`, and set `tail = dummy`.
2. While both lists still contain nodes:
   - compare `list1.val` and `list2.val`;
   - attach the smaller node to `tail.next`;
   - advance the pointer of the chosen list;
   - advance `tail`.
3. At most one list still contains nodes. Attach that entire remainder directly.
4. Return `dummy.next`.

We do not need another loop for the remainder because it is already sorted and all its values are at least as large as the last selected value.

---

## 6. Dry run

```text
list1 = 1 → 2 → 4
list2 = 1 → 3 → 4
```

| Step | `list1.val` | `list2.val` | Choose | Merged list |
|---:|---:|---:|---|---|
| 1 | 1 | 1 | list1 | `1` |
| 2 | 2 | 1 | list2 | `1 → 1` |
| 3 | 2 | 3 | list1 | `1 → 1 → 2` |
| 4 | 4 | 3 | list2 | `1 → 1 → 2 → 3` |
| 5 | 4 | 4 | list1 | `1 → 1 → 2 → 3 → 4` |
| End | null | 4 | attach remainder | `1 → 1 → 2 → 3 → 4 → 4` |

Using `<=` chooses from `list1` when values tie. Using `<` would also produce sorted values, but `<=` preserves the relative preference of the first list.

---

## 7. Optimal iterative JavaScript solution

```javascript
function mergeTwoLists(list1, list2) {
  // Sentinel node removes special handling for the first appended node.
  const dummy = new ListNode();
  let tail = dummy;

  while (list1 !== null && list2 !== null) {
    if (list1.val <= list2.val) {
      tail.next = list1;
      list1 = list1.next;
    } else {
      tail.next = list2;
      list2 = list2.next;
    }

    tail = tail.next;
  }

  // Only one list can have nodes left; its remainder is already sorted.
  tail.next = list1 !== null ? list1 : list2;

  return dummy.next;
}
```

---

## 8. Code walkthrough

### `const dummy = new ListNode()`

The value is irrelevant. Only `dummy.next` matters. The dummy gives us a permanent node before the real head.

### `let tail = dummy`

`tail` always points to the last node of the merged portion. Initially the merged portion contains no real nodes, so the tail is the dummy.

### `while (list1 !== null && list2 !== null)`

Comparison is possible only while both current nodes exist. Accessing `.val` after either becomes `null` would fail.

### `tail.next = list1`

This reuses the existing node. We are not copying its value into a new node.

### `list1 = list1.next`

Advance the source pointer after saving its current node through `tail.next`. Changing `list1` does not alter `tail.next`; both variables simply held references.

### `tail = tail.next`

Move the result tail to the node just appended. Forgetting this line repeatedly overwrites the same `next` reference.

### `tail.next = list1 !== null ? list1 : list2`

The loop ends when at least one list is empty. Attach the other list's entire remaining chain in O(1) pointer work.

### `return dummy.next`

The dummy is not part of the answer. Its `next` reference points at the true merged head—or `null` if both inputs were empty.

---

## 9. Correctness reasoning

Loop invariant:

> Before each iteration, the chain from `dummy.next` through `tail` contains the smallest nodes processed so far in sorted order, and `list1` and `list2` point to the first unmerged nodes of their respective lists.

During an iteration, the smaller current node is the smallest node remaining across both lists, so appending it preserves sorted order. Advancing only its source pointer preserves the definition of the unmerged portions.

When one list ends, every node in the other remainder is at least as large as the merged tail and is already internally sorted. Attaching it completes a sorted list containing every input node exactly once.

---

## 10. Complexity

Let `n` and `m` be the list lengths.

- **Time: O(n + m)** — each node is visited or attached once.
- **Auxiliary space: O(1)** — only a fixed number of references and one dummy node are created.

The returned list still contains `n + m` nodes, but those nodes already existed in the input. Reusing them does not count as auxiliary space.

---

## 11. Common mistakes

1. **Returning `dummy` instead of `dummy.next`.** The sentinel is not part of the result.
2. **Forgetting `tail = tail.next`.** Later attachments overwrite the same link.
3. **Forgetting to advance the chosen source list.** The loop becomes infinite.
4. **Advancing the source before linking carelessly.** You can lose the node that should be appended.
5. **Stopping after the main loop.** The non-empty list's remainder must be attached.
6. **Creating new nodes unnecessarily.** Relinking existing nodes gives O(1) auxiliary space.
7. **Dereferencing `null`.** The comparison loop must require both pointers to be non-null.
8. **Thinking `tail.next = remainder` is O(k).** Assigning the reference is O(1); no traversal occurs.

---

## 12. What to say in an interview

> “Because both lists are sorted, the smallest remaining node must be at one of the two current heads. I’ll compare those nodes, append the smaller one, and advance only that list. A dummy head lets every append use identical pointer logic without a special case for the result's first node. When either list ends, I can attach the other sorted remainder directly. This is O(n + m) time and O(1) auxiliary space because I reuse the existing nodes.”

If asked why the remainder is safe:

> “All earlier nodes were selected as the smaller current value, so the remaining head cannot be smaller than the merged tail; and the remainder is already sorted.”

---

## 13. Pattern recognition

Think **two pointers moving through sorted inputs** when:

- two collections are already sorted;
- the next answer can be chosen from their current frontiers;
- each pointer moves only forward;
- the result combines both inputs while preserving order.

Think **dummy/sentinel node** when:

- constructing a linked-list result;
- deleting or inserting near the head;
- the first node otherwise requires special handling.

Memory cue:

> Compare the two frontiers; append the smaller; advance its source.

---

## 14. Recursive alternative

```javascript
function mergeTwoListsRecursive(list1, list2) {
  if (list1 === null) return list2;
  if (list2 === null) return list1;

  if (list1.val <= list2.val) {
    list1.next = mergeTwoListsRecursive(list1.next, list2);
    return list1;
  }

  list2.next = mergeTwoListsRecursive(list1, list2.next);
  return list2;
}
```

The recursive version is elegant but uses **O(n + m)** call-stack space in the worst case. JavaScript also does not reliably optimize tail calls across common interview runtimes. Prefer the iterative solution unless recursion is specifically requested.

---

## 15. Edge cases

| `list1` | `list2` | Result |
|---|---|---|
| empty | empty | empty |
| empty | `1 → 3` | `1 → 3` |
| `2 → 4` | empty | `2 → 4` |
| `1` | `2` | `1 → 2` |
| `2` | `1` | `1 → 2` |
| `1 → 1` | `1 → 1` | four `1` nodes |
| negative values | mixed values | normal numeric comparison works |

---

## 16. Notebook-ready notes

### 📚 Concept

**Merge Two Sorted Lists — two pointers + dummy head**

```text
Compare list1.val and list2.val
Attach smaller node to tail.next
Advance chosen list
Advance tail
Attach remaining list
Return dummy.next
```

### 🧠 My understanding

Because each list is sorted, I only compare their current heads. The smaller head is globally safe to append. The dummy head removes first-node branching, and relinking existing nodes keeps auxiliary space constant.

### 💼 Interview line

> “The next merged node must be one of the two current heads; a sentinel lets me append it uniformly.”

### ⚠️ Traps

- Advance both the chosen source pointer and `tail`.
- Attach the remainder after the loop.
- Return `dummy.next`.

---

## 17. Dheerix Glance

```text
MERGE TWO SORTED LISTS

Signal:          two sorted linked lists
Pointers:        list1, list2, tail
Boundary tool:   dummy/sentinel head
Choose:          smaller current node
Move:            chosen source + tail
Finish:          tail.next = non-empty remainder
Return:          dummy.next
Time:            O(n + m)
Auxiliary space: O(1) iterative
Memory cue:      “Compare frontiers; move the winner.”
```

---

## 18. Recall test

Without looking back:

1. Why is comparing only the two current nodes sufficient?
2. What problem does the dummy head remove?
3. Which two references move after appending a node?
4. Why can the remaining chain be attached without another loop?
5. Why is auxiliary space O(1) even though the result has `n + m` nodes?
6. What are the iterative and recursive space complexities?
7. State the loop invariant in one sentence.

