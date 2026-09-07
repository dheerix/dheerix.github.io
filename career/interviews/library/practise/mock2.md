# IBM Mock 02 — Longest Substring Without Repeating Characters

## Problem

Given a string `s`, return the length of the longest substring without repeating characters.

A substring must be contiguous.

### Example

```text
s = "abcabcbb"

Output = 3
```

The longest substring is:

```text
"abc"
```

---

# 🧠 Pattern Trigger

> **Contiguous + longest/shortest + maintainable window condition → Sliding Window**

Here the condition is:

```text
No duplicate characters inside the current window.
```

---

# 1. Brute Force Intuition

Choose every possible starting position.

From each start, continue until a duplicate character appears.

```text
choose start
     ↓
expand
     ↓
duplicate?
     ↓
stop and restart from next start
```

Use a Set to determine whether the character already exists.

---

# 2. Brute Force Solution

```js
function lengthOfLongestSubstring(s) {
	let maxLength = 0;

	for (let i = 0; i < s.length; i++) {
		const seen = new Set();

		for (let j = i; j < s.length; j++) {
			if (seen.has(s[j])) {
				break;
			}

			seen.add(s[j]);

			maxLength = Math.max(maxLength, j - i + 1);
		}
	}

	return maxLength;
}
```

### Complexity

```text
Time:  O(n²)
Space: O(n)
```

This solution is correct.

The problem is that we repeatedly restart work.

---

# 3. Optimization Insight

Instead of:

> Duplicate found → throw everything away → restart

think:

> **Duplicate found → shrink only enough to make the existing window valid again.**

This gives us a sliding window.

---

# 4. Sliding Window

Maintain two pointers:

```text
left  = beginning of current valid window
right = character currently being explored
```

And maintain:

```text
Set = characters currently inside the window
```

Example:

```text
s = "abcb"

     a b c
     ↑   ↑
   left right
```

Current window:

```text
"abc"
```

Set:

```text
{a, b, c}
```

Now `right` encounters another `b`.

---

# 5. Duplicate Handling

We cannot add the new `b` yet because:

```text
b ∈ Set
```

Instead, move `left` forward while removing characters.

Starting with:

```text
[a b c] + b
 ↑
left
```

Remove `a`:

```text
[b c] + b
 ↑
left
```

`b` is still duplicated.

Remove old `b`:

```text
[c] + b
 ↑
left
```

Now the duplicate is gone.

Add the new `b`:

```text
[c b]
 ↑ ↑
 L R
```

The window is valid again.

---

# 6. Optimal Solution

```js
function lengthOfLongestSubstring(s) {
	let maxLength = 0;
	let left = 0;

	const seen = new Set();

	for (let right = 0; right < s.length; right++) {
		while (seen.has(s[right])) {
			seen.delete(s[left]);
			left++;
		}

		seen.add(s[right]);

		maxLength = Math.max(maxLength, right - left + 1);
	}

	return maxLength;
}
```

---

# 7. Why `right - left + 1`?

Because both boundaries are inclusive.

Example:

```text
index:     2   3   4
           a   b   c
           ↑       ↑
         left    right
```

There are three elements.

But:

```text
right - left
= 4 - 2
= 2
```

So:

```text
right - left + 1
= 4 - 2 + 1
= 3
```

General rule:

> **Inclusive range length = end - start + 1**

---

# 8. Why Is This O(n) With Nested Loops?

The code contains:

```js
for (...) {
  while (...) {
  }
}
```

That does NOT automatically mean O(n²).

Look at pointer movement.

`right`:

```text
→ → → → → →
```

only moves forward.

Maximum:

```text
n moves
```

`left`:

```text
→ → → → → →
```

also only moves forward.

Maximum:

```text
n moves
```

Therefore total pointer movement is bounded by approximately:

```text
n + n = 2n
```

Big O removes constants:

```text
O(2n) = O(n)
```

---

# 9. Important Complexity Lesson

> **Nested loops do not automatically mean O(n²).**

Instead ask:

> **How many times can each element actually be processed?**

In this sliding window:

- each character enters the window at most once
- each character leaves the window at most once

Therefore:

```text
O(n)
```

---

# 10. Space Complexity

Worst case:

```text
s = "abcdef..."
```

Every character is unique.

The Set may contain up to `n` characters.

Therefore:

```text
Space = O(n)
```

More precisely:

```text
O(min(n, alphabet size))
```

Since the problem specifies ASCII, the character universe itself is bounded.

---

# 11. Interview Evolution

Initial reasoning:

```text
Choose start
→ scan until duplicate
→ restart
```

This produced a correct:

```text
O(n²)
```

solution.

Interviewer asks:

> Can we avoid restarting?

New reasoning:

```text
Don't restart.
Keep the valid window.
Shrink it when necessary.
```

Result:

```text
O(n)
```

This is an important interview pattern:

> **Correct brute force first → identify repeated work → eliminate repeated work.**

---

# 12. Interview Explanation

> The brute-force solution would start at every character and expand until finding a duplicate, which takes O(n²) time.
>
> Instead, I'll maintain a sliding window using `left` and `right`. `left` represents the beginning of the current valid substring and `right` explores new characters.
>
> A Set contains the characters currently inside the window. If `s[right]` is already present, I'll move `left` forward and remove characters until that duplicate is gone.
>
> Then I'll add the current character and calculate the window length using `right - left + 1`.
>
> Although there is a while loop inside the for loop, both pointers only move forward, so each character enters and leaves the window at most once. Therefore the time complexity is O(n), with O(n) space in the worst case.

---

# 📓 Notebook Version

```text
Longest Substring Without Repeating Characters

Trigger:
contiguous + longest + window condition
→ Sliding Window

left  = start of current valid window
right = explores new chars
Set   = chars currently in window

Duplicate?

while current char exists:
    remove s[left]
    left++

Then:
add current char

length:
right - left + 1

Time:  O(n)
Space: O(n)

Why O(n) despite nested loop?
left and right only move forward.
Each char enters/leaves ≤ once.
```

---

# 🧠 Memory Lines

> **Don't restart — shrink the window.**

> **Nested loops ≠ automatically O(n²). Count pointer movement.**

> **Inclusive window length = right − left + 1.**

> **Contiguous + maintainable condition → think Sliding Window.**

---

# 🔗 Connection With Mock 01

```text
MOCK 01

Contiguous
+ target SUM
+ negative numbers

→ Prefix Sum + Map
```

versus:

```text
MOCK 02

Contiguous
+ longest
+ maintainable window condition

→ Sliding Window
```

The important question is not simply:

> "Is this a subarray/substring problem?"

Ask:

> **"What property am I trying to maintain?"**
