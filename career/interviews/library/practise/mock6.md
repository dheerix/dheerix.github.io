# IBM Mock 06 — Daily Temperatures

## Problem

Given an array of daily temperatures, return an array where:

```text
answer[i]
```

is the number of days until a **warmer temperature** occurs.

If no warmer future day exists:

```text
answer[i] = 0
```

### Example

```text
Input:
[73, 74, 75, 71, 69, 72, 76, 73]

Output:
[1, 1, 4, 2, 1, 1, 0, 0]
```

---

# 🧠 Pattern Trigger

> **For each element, find the NEXT GREATER / NEXT SMALLER element → Monotonic Stack**

Typical phrases:

```text
next greater
next smaller
previous greater
previous smaller
warmer day
nearest larger
nearest smaller
first greater on the right
```

Recognition question:

> **Are previous elements waiting for a future value that will resolve them?**

If yes, think:

```text
MONOTONIC STACK
```

---

# 1. Brute Force

For every temperature, scan forward until finding the first warmer temperature.

```js
function dailyTemperatures(temperatures) {
	const n = temperatures.length;
	const answer = new Array(n).fill(0);

	for (let i = 0; i < n; i++) {
		for (let j = i + 1; j < n; j++) {
			if (temperatures[j] > temperatures[i]) {
				answer[i] = j - i;
				break;
			}
		}
	}

	return answer;
}
```

### Complexity

```text
Time:  O(n²)
Space: O(1) auxiliary
```

The problem is repeated searching.

For every day:

```text
start again
→ search right
→ find warmer
```

Can we avoid restarting?

---

# 2. Initial Two-Pointer Thought

Initial idea:

```text
left  = previous day
right = search for next warmer day
```

But one `left` pointer isn't enough.

Consider:

```text
[75, 71, 69, 72, 76]
```

Before `72` arrives:

```text
75 → unresolved
71 → unresolved
69 → unresolved
```

When `72` arrives:

```text
69 → resolved
71 → resolved
75 → still unresolved
```

We need to remember **multiple unresolved days simultaneously**.

A single pointer cannot represent all of them.

This suggests a stack.

---

# 3. The Key Mental Model — Unresolved Elements

Don't initially think:

> “I need a decreasing stack.”

Instead think:

> **The stack contains previous days still waiting for an answer.**

Example:

```text
[75, 71, 69]
```

None has found a warmer future day yet.

So:

```text
stack = [index of 75,
         index of 71,
         index of 69]
```

Then `72` arrives.

```text
72 > 69
```

69 is resolved.

Pop it.

Then:

```text
72 > 71
```

71 is resolved.

Pop it.

Then:

```text
72 < 75
```

75 is still unresolved.

Stop.

Push 72.

Stack now represents:

```text
[75, 72]
```

Both are still waiting for something warmer.

---

# 4. Why Store Indices?

We could store temperatures, but the output asks for:

```text
number of DAYS
```

So we need positions.

Store:

```text
index
```

because from an index we can obtain both:

```js
temperatures[index];
```

and:

```text
distance = currentIndex - previousIndex
```

Therefore:

```text
stack = indices of unresolved days
```

---

# 5. Resolving a Previous Day

Suppose:

```text
current index = i
previous unresolved index = prevIdx
```

If:

```js
temperatures[i] > temperatures[prevIdx];
```

then the current day is the first warmer day for `prevIdx`.

So:

```js
answer[prevIdx] = i - prevIdx;
```

Then remove it from the unresolved stack:

```js
stack.pop();
```

---

# 6. Why `while`, Not `if`?

One current temperature may resolve **multiple previous days**.

Example:

```text
[75, 71, 69, 72]
```

When `72` arrives:

```text
72 > 69 → resolve 69
72 > 71 → resolve 71
72 < 75 → stop
```

Therefore:

```js
while (
  stack.length > 0 &&
  temperatures[i] >
    temperatures[stack[stack.length - 1]]
) {
   ...
}
```

not:

```js
if (...)
```

---

# 7. Optimal Solution

```js
var dailyTemperatures = function (temperatures) {
	const n = temperatures.length;

	const answer = new Array(n).fill(0);
	const stack = [];

	for (let i = 0; i < n; i++) {
		while (
			stack.length > 0 &&
			temperatures[i] > temperatures[stack[stack.length - 1]]
		) {
			const prevIdx = stack.pop();

			answer[prevIdx] = i - prevIdx;
		}

		stack.push(i);
	}

	return answer;
};
```

---

# 8. Dry Run

Consider:

```text
temperatures = [73, 74, 75, 71, 69, 72]
```

Start:

```text
stack  = []
answer = [0,0,0,0,0,0]
```

### i = 0 → 73

Nothing waiting.

Push index `0`.

```text
stack = [73]
```

---

### i = 1 → 74

```text
74 > 73
```

Resolve 73:

```text
distance = 1 - 0 = 1
```

```text
answer = [1,0,0,0,0,0]
```

Push 74.

```text
stack = [74]
```

---

### i = 2 → 75

```text
75 > 74
```

Resolve:

```text
2 - 1 = 1
```

```text
answer = [1,1,0,0,0,0]
```

Push 75.

```text
stack = [75]
```

---

### i = 3 → 71

```text
71 < 75
```

Cannot resolve 75.

Push 71.

```text
stack = [75,71]
```

---

### i = 4 → 69

```text
69 < 71
```

Push.

```text
stack = [75,71,69]
```

---

### i = 5 → 72

Now:

```text
72 > 69
```

Pop 69.

```text
answer[4] = 5 - 4 = 1
```

Stack:

```text
[75,71]
```

Still:

```text
72 > 71
```

Pop 71.

```text
answer[3] = 5 - 3 = 2
```

Stack:

```text
[75]
```

Now:

```text
72 > 75 ❌
```

Stop.

Push 72.

```text
stack = [75,72]
```

Those two remain unresolved.

---

# 9. Why Is It Called a Monotonic Stack?

Look at the temperatures represented by the stack:

```text
75
71
69
```

They are decreasing.

Why?

If a warmer value appears, smaller values on top get removed.

After processing each element, unresolved temperatures maintain a monotonic ordering.

For Daily Temperatures:

> **The stack is monotonically decreasing by temperature.**

But don't memorize the direction first.

Remember:

> **Stack = unresolved candidates.**

The monotonic property naturally follows.

---

# 10. Time Complexity — Important Trap

The code contains:

```js
for (...) {
  while (...) {
  }
}
```

It looks like:

```text
O(n²)
```

but it isn't.

Each index can be:

```text
PUSHED exactly once
POPPED at most once
```

Therefore across the entire algorithm:

```text
≤ n pushes
≤ n pops

≤ 2n operations
```

So:

```text
Time = O(n)
```

---

# 11. Example of Many Pops

Consider:

```text
[90, 80, 70, 60, 100]
```

Before 100:

```text
stack:

90
80
70
60
```

When 100 arrives:

```text
100 > 60 → pop
100 > 70 → pop
100 > 80 → pop
100 > 90 → pop
```

The `while` executes four times in this iteration.

But those elements are now permanently removed.

They cannot be popped again.

Therefore total work across the whole algorithm remains:

```text
O(n)
```

---

# 12. Space Complexity

Worst case:

```text
[100, 90, 80, 70, 60]
```

No future value resolves anything.

The stack becomes:

```text
[100,90,80,70,60]
```

All `n` indices remain.

Therefore:

```text
Space = O(n)
```

---

# 13. Mistakes / Discoveries From Mock

## 1. Initially Said “Next Shorter”

The actual requirement is:

```text
NEXT GREATER
```

Always translate the story into the underlying relationship.

```text
warmer temperature
=
greater value
```

---

## 2. Initially Considered Two Pointers

Two pointers are insufficient because multiple previous elements can remain unresolved simultaneously.

### Recognition improvement

Ask:

> **Do I need to remember multiple previous candidates waiting for a future answer?**

That should make a stack worth considering.

---

## 3. Why Indices Instead of Values?

Because we need:

```text
distance
```

So:

```text
currentIndex - previousIndex
```

The index also lets us retrieve the value:

```js
temperatures[index];
```

One stored piece of information gives us both.

---

## 4. Nested Loop Complexity

Don't look at syntax alone:

```js
for + while
```

and declare O(n²).

Ask:

> **How many times can an element enter and leave this data structure?**

Here:

```text
push once
pop once
```

Therefore:

```text
O(n)
```

---

# 14. Interview Explanation

> “The brute-force approach would scan forward from every day until finding a warmer temperature, which is O(n²).
>
> Instead, I'll maintain a stack of indices for days that haven't yet found a warmer future temperature.
>
> As I scan from left to right, if the current temperature is warmer than the temperature represented by the top stack index, then the current day resolves that previous day. I pop its index and calculate the waiting time as `currentIndex - previousIndex`.
>
> I continue popping while the current temperature can resolve previous days, then push the current index because it is now waiting for its own warmer future day.
>
> Each index is pushed once and popped at most once, so the time complexity is O(n). The stack can contain all indices in the worst case, giving O(n) space.”

---

# 📓 Notebook Version

```text
Daily Temperatures

Trigger:

NEXT GREATER / SMALLER
→ MONOTONIC STACK

Mental model:

STACK =
UNRESOLVED previous elements

Store INDICES because:

value:
temps[index]

distance:
currentIndex - index


For each current:

while:
 current > temp[top]

    prev = pop()
    answer[prev] =
        currentIndex - prev

push current index


Time:
O(n)

Why?
each index:
push once
pop <= once

Space:
O(n)
```

---

# 🧠 Memory Lines

> **Next greater/smaller → Monotonic Stack.**

> **Stack = unresolved candidates waiting for a future answer.**

> **Store indices when the answer involves distance.**

> **One current element may resolve multiple previous elements → `while`, not `if`.**

> **Push once + pop once = O(n), despite nested loops.**

---

# 🔗 Pattern Recognition Addition

## Pattern 06 — Monotonic Stack

### Trigger

For every element, find something like:

```text
NEXT greater
NEXT smaller
PREVIOUS greater
PREVIOUS smaller
nearest greater
nearest smaller
warmer day
first larger value to right
```

Ask:

> **Are previous elements waiting for a future value that resolves them?**

Then consider:

```text
MONOTONIC STACK
```

Mental model:

```text
CURRENT VALUE ARRIVES
        ↓
Can it resolve the
top unresolved candidate?
        ↓
       YES
        ↓
       POP
        ↓
Can it resolve another?
        ↓
       YES
        ↓
       POP
        ↓
       ...
        ↓
Push current as unresolved
```

### What Should the Stack Store?

Ask what the output requires.

If only values matter:

```text
possibly values
```

If distance/position matters:

```text
indices
```

Often indices are more useful because:

```text
index → value
index → distance
```

---

# 🧠 Pattern Map — Mocks 01–06

```text
01 — PREFIX SUM + MAP

Target sum + cumulative history
→ "What earlier running total do I need?"

CURRENT - EARLIER = TARGET
```

```text
02 — SLIDING WINDOW

Contiguous + maintainable condition
→ "Can I shrink instead of restarting?"

EXPAND → INVALID → SHRINK → VALID
```

```text
03 — PREFIX / SUFFIX

Every position needs both sides
→ "Can I carry information from both directions?"

LEFT → STORE
RIGHT ← CARRY
```

```text
04 — SORT + SCAN

Intervals / relationships become local after ordering
→ "Would sorting simplify the comparisons?"

SORT → LAST RESULT → MERGE/PUSH
```

```text
05 — CANONICAL KEY + HASH MAP

Equivalent things look different
→ "Can I normalize them into the same key?"

NORMALIZE → HASH → GROUP
```

```text
06 — MONOTONIC STACK

Need next/previous greater/smaller
→ "Who is still waiting to be resolved?"

UNRESOLVED → CURRENT RESOLVES → POP
```

---

# ⚡ Six Recognition Questions

When reading a new problem:

```text
1. Need an earlier cumulative value?
   → Prefix Sum + Map

2. Maintain a contiguous valid region?
   → Sliding Window

3. Every index needs information
   from both directions?
   → Prefix / Suffix

4. Would sorting make relationships local?
   → Sort + Scan

5. Can equivalent objects become
   the same canonical key?
   → Hashing / Grouping

6. Are previous elements waiting
   for a next greater/smaller value?
   → Monotonic Stack
```

---

# 🔥 Meta-Pattern Learned Twice Now

Mock 2:

```text
Sliding Window

for + while
≠ automatically O(n²)

left moves ≤ n
right moves ≤ n
```

Mock 6:

```text
Monotonic Stack

for + while
≠ automatically O(n²)

push ≤ n
pop ≤ n
```

General rule:

> **Don't calculate complexity from indentation. Calculate how many times the underlying state can actually change.**
