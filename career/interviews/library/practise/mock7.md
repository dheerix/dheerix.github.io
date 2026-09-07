# IBM Mock 07 — Binary Search

## Problem

Given a **sorted** array of distinct integers and a target, return the target's index.

If the target doesn't exist:

```text
return -1
```

Required:

```text
O(log n)
```

### Example

```text
nums   = [-1, 0, 3, 5, 9, 12]
target = 9

output = 4
```

---

# 🧠 Pattern Trigger

> **Sorted + Search + O(log n) → Binary Search**

Strong clues:

```text
sorted
search / find
target
O(log n)
```

Recognition question:

> **Can I use some condition to safely discard half of the remaining search space?**

If yes:

```text
BINARY SEARCH
```

---

# 1. Brute Force

Scan every element:

```js
for (let i = 0; i < nums.length; i++) {
	if (nums[i] === target) {
		return i;
	}
}

return -1;
```

### Complexity

```text
Time:  O(n)
Space: O(1)
```

But we're given something valuable:

```text
SORTED
```

And explicitly required:

```text
O(log n)
```

Those are strong binary-search signals.

---

# 2. Search Space

Initialize:

```js
let left = 0;
let right = nums.length - 1;
```

Meaning:

```text
[left ................ right]
```

is the current search space.

Both boundaries are **inclusive**.

Invariant:

> **If the target exists, it must currently be somewhere inside `[left, right]`.**

---

# 3. Find the Middle

```js
const mid = Math.floor(left + (right - left) / 2);
```

Conceptually:

```text
left                 right
 ↓                     ↓
[ . . . . . MID . . . . ]
            ↑
```

In fixed-width integer languages, this form avoids the potential overflow of:

```text
(left + right) / 2
```

In JavaScript, `Math.floor()` is needed because division can produce a decimal.

---

# 4. Three Cases

## Case 1 — Found

```js
nums[mid] === target;
```

Return:

```js
return mid;
```

---

## Case 2 — Mid Is Too Small

```js
nums[mid] < target;
```

Because the array is sorted:

```text
everything LEFT of mid
+
mid itself
```

is also too small.

So discard that entire half:

```js
left = mid + 1;
```

Important:

```text
DO NOT also change right.
```

---

## Case 3 — Mid Is Too Large

```js
nums[mid] > target;
```

Because the array is sorted:

```text
everything RIGHT of mid
+
mid itself
```

is too large.

Discard it:

```js
right = mid - 1;
```

Important:

```text
DO NOT also change left.
```

---

# 5. Why `mid + 1` and `mid - 1`?

We already checked:

```text
nums[mid]
```

and know it isn't the target.

Therefore `mid` itself can be removed from consideration.

```text
target > nums[mid]

left = mid + 1
```

and:

```text
target < nums[mid]

right = mid - 1
```

Memory:

> **Mid has already been judged — exclude it.**

---

# 6. Why `left <= right`?

Use:

```js
while (left <= right)
```

because:

```text
left === right
```

still represents **one valid candidate**.

Example:

```text
nums = [5]
target = 5

left  = 0
right = 0
```

With:

```js
while (left < right)
```

the loop never executes.

We would never inspect `5`.

With:

```js
while (left <= right)
```

the final candidate gets checked.

### Memory

> **Inclusive `[left,right]` search space → `left <= right`.**

---

# 7. Optimal Solution

```js
var search = function (nums, target) {
	let left = 0;
	let right = nums.length - 1;

	while (left <= right) {
		const mid = Math.floor(left + (right - left) / 2);

		if (nums[mid] === target) {
			return mid;
		}

		if (nums[mid] < target) {
			left = mid + 1;
		} else {
			right = mid - 1;
		}
	}

	return -1;
};
```

---

# 8. Dry Run

```text
nums   = [-1, 0, 3, 5, 9, 12]
target = 9
```

Initially:

```text
L                 R
↓                 ↓
-1  0  3  5  9  12
       ↑
      MID
```

```text
mid = 2
nums[mid] = 3

3 < 9
```

Discard:

```text
[-1, 0, 3]
```

Now:

```text
left = mid + 1 = 3
```

Search:

```text
5  9  12
↑      ↑
L      R
   ↑
  MID
```

```text
nums[mid] = 9
```

Found.

Return:

```text
4
```

---

# 9. Why O(log n)?

This was the important complexity explanation.

Every comparison eliminates approximately **half** of the remaining candidates.

```text
n
↓
n/2
↓
n/4
↓
n/8
↓
n/16
...
↓
1
```

After `k` iterations:

```text
n / 2^k = 1
```

Therefore:

```text
n = 2^k

k = log₂(n)
```

So:

```text
Time = O(log n)
```

---

# 10. Space Complexity

We only maintain:

```text
left
right
mid
```

No data structure grows with input size.

Therefore:

```text
Space = O(1)
```

---

# 11. Mistakes / Discoveries From Mock

## 1. Initially Changed Both Boundaries

Initial reasoning included something like:

```text
target > mid

left = mid + 1
right--
```

But this is incorrect.

Once we know which half is impossible:

> **Discard that half only.**

So:

```text
target > nums[mid]

left = mid + 1
```

`right` stays unchanged.

Likewise:

```text
target < nums[mid]

right = mid - 1
```

`left` stays unchanged.

---

## 2. Redundant Equality Check

Initial implementation:

```js
if (nums[mid] === target) {
  return mid;
}

if (target > nums[mid]) {
  ...
} else if (target < nums[mid]) {
  ...
} else {
  return mid;
}
```

The final:

```js
else {
  return mid;
}
```

is unreachable because equality was already handled.

Cleaner:

```js
if (nums[mid] === target) {
	return mid;
}

if (nums[mid] < target) {
	left = mid + 1;
} else {
	right = mid - 1;
}
```

---

# 12. Interview Explanation

> “The straightforward solution would scan the array in O(n), but because the array is sorted and the required complexity is O(log n), I'll use binary search.
>
> I'll maintain an inclusive search range using `left` and `right`. At each iteration I'll calculate the middle index.
>
> If the middle value equals the target, I'll return it. If it's smaller than the target, then because the array is sorted, everything through the middle can safely be discarded, so I'll set `left = mid + 1`. Otherwise I'll discard the right half using `right = mid - 1`.
>
> Each iteration removes approximately half of the remaining search space, so the time complexity is O(log n), with O(1) auxiliary space.”

---

# 📓 Notebook Version

```text
Binary Search

Trigger:

SORTED
+
SEARCH
+
O(log n)

→ BINARY SEARCH


Search space:

[left ........ right]

inclusive boundaries


mid:

left + (right-left)/2


If:

nums[mid] == target
→ FOUND

nums[mid] < target
→ discard LEFT HALF
→ left = mid + 1

nums[mid] > target
→ discard RIGHT HALF
→ right = mid - 1


Loop:

while(left <= right)

Why <= ?

left == right
still means ONE candidate remains.


Time:
O(log n)

Why?
each step removes HALF.

Space:
O(1)
```

---

# 🧠 Memory Lines

> **Sorted + search + O(log n) → Binary Search.**

> **Binary search = discard half with evidence.**

> **Mid has already been judged — exclude it with `mid ± 1`.**

> **Inclusive boundaries `[left,right]` → `left <= right`.**

> **O(log n) = repeatedly cut the problem in half.**

---

# 🔗 Pattern Recognition Addition

## Pattern 07 — Binary Search

### Obvious Trigger

```text
SORTED ARRAY
+
FIND TARGET
```

Ask:

> **Can comparison with the middle tell me which entire half is impossible?**

If yes:

```text
BINARY SEARCH
```

But the deeper pattern is more useful.

Binary search is not fundamentally about arrays.

It is about:

> **A search space where testing one point gives enough information to discard a large portion of the remaining possibilities.**

Conceptually:

```text
SEARCH SPACE
     ↓
choose middle
     ↓
evaluate condition
   ↙     ↘
discard  discard
left     right
half     half
```

---

# 🧠 Pattern Map — Mocks 01–07

```text
01 — PREFIX SUM + MAP

Need earlier cumulative state
→ What earlier running total do I need?

CURRENT - EARLIER = TARGET
```

```text
02 — SLIDING WINDOW

Contiguous + maintainable condition
→ Can I shrink instead of restarting?

EXPAND → INVALID → SHRINK → VALID
```

```text
03 — PREFIX / SUFFIX

Every index depends on both sides
→ Can I carry information from both directions?

LEFT → STORE
RIGHT ← CARRY
```

```text
04 — SORT + SCAN

Ordering makes relationships local
→ Would sorting simplify the problem?

SORT → COMPARE → MERGE/PUSH
```

```text
05 — CANONICAL KEY + HASHING

Equivalent things look different
→ Can I normalize them into the same key?

NORMALIZE → HASH → GROUP
```

```text
06 — MONOTONIC STACK

Need next/previous greater/smaller
→ Who is waiting to be resolved?

UNRESOLVED → CURRENT RESOLVES → POP
```

```text
07 — BINARY SEARCH

Ordered/searchable space
→ Can one comparison eliminate half?

CHECK MIDDLE → DISCARD HALF
```

---

# ⚡ Seven Recognition Questions

```text
1. Need an earlier cumulative value?
   → Prefix Sum + Map

2. Maintain a contiguous valid region?
   → Sliding Window

3. Every index needs both sides?
   → Prefix / Suffix

4. Would sorting make relationships local?
   → Sort + Scan

5. Can equivalent objects become
   the same canonical key?
   → Hashing / Grouping

6. Are previous elements waiting for
   a next greater/smaller value?
   → Monotonic Stack

7. Can one comparison eliminate
   half the search space?
   → Binary Search
```

---

# 🔥 Complexity Recognition So Far

```text
ONE PASS
→ usually O(n)

SORT
→ usually O(n log n)

HALVE SEARCH SPACE
→ O(log n)

PUSH ONCE + POP ONCE
→ O(n)

TWO FORWARD-MOVING POINTERS
→ often O(n)
```

Don't infer complexity purely from how the code looks.

Ask:

> **How much total work can happen across the entire algorithm?**
