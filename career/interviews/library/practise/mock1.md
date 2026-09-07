# IBM Mock 01 — Longest Subarray With Sum K

## Problem

Given an integer array `nums` and an integer `k`, return the length of the longest contiguous subarray whose sum equals `k`.

The array may contain positive numbers, negative numbers, and zero.

### Example

```text
nums = [1, -1, 5, -2, 3]
k = 3

Output = 4
```

The longest valid subarray is:

```text
[1, -1, 5, -2]
```

---

## 🧠 Pattern Trigger

> **Contiguous subarray + target sum + negative numbers → Prefix Sum + Map**

Because negative numbers are allowed, a normal sliding window is unreliable.

---

## 1. Brute Force

Try every possible starting position and extend the ending position while maintaining the sum.

```js
function longestSubarraySumK(nums, k) {
	let maxLength = 0;

	for (let start = 0; start < nums.length; start++) {
		let sum = 0;

		for (let end = start; end < nums.length; end++) {
			sum += nums[end];

			if (sum === k) {
				maxLength = Math.max(maxLength, end - start + 1);
			}
		}
	}

	return maxLength;
}
```

### Complexity

```text
Time:  O(n²)
Space: O(1)
```

---

# 2. Optimal Intuition

A running sum by itself only easily detects a valid subarray beginning at index `0`.

Instead, think:

```text
currentPrefix - earlierPrefix = target
```

Keep **target on the right side**.

If:

```text
currentPrefix = 10
target = 4
```

then:

```text
10 - earlierPrefix = 4

earlierPrefix = 6
```

Therefore, if I previously encountered a running sum of `6`, everything after that point until the current index sums to `4`.

---

## The Core Equation

```text
currentPrefix - earlierPrefix = k
```

Rearrange:

```text
earlierPrefix = currentPrefix - k
```

In code:

```js
const needed = prefixSum - k;
```

Then ask:

> Have I seen `needed` as a prefix sum before?

---

# 3. Two Sum Connection

This is very similar to Two Sum.

### Two Sum

```text
current + needed = target

needed = target - current
```

### Prefix Sum

```text
currentPrefix - earlierPrefix = target

earlierPrefix = currentPrefix - target
```

Both use the same general idea:

> **I know two quantities. Derive the missing quantity and look it up in a hash structure.**

Difference:

```text
Two Sum:
value → index

Prefix Sum:
running sum → earliest index
```

A useful mental model:

> **Prefix Sum problems often feel like Two Sum over running totals.**

---

# 4. What Does the Map Store?

```text
prefixSum → earliest index
```

Example:

```text
nums = [2, 1, -1, 2]
k = 2
```

At the final index:

```text
prefixSum = 4

4 - earlierPrefix = 2

earlierPrefix = 2
```

We previously saw prefix sum `2` at index `0`.

Therefore:

```text
[ 2 ] [ 1, -1, 2 ]
  ↑         ↑
prefix     target
remove    subarray
```

The remaining subarray sums to `2`.

---

# 5. Why Store the Earliest Index?

Suppose prefix sum `2` occurred at:

```text
index 0
index 2
```

and the current index is `5`.

Possible lengths:

```text
5 - 0 = 5
5 - 2 = 3
```

The earliest occurrence produces the longest possible subarray.

Therefore:

> **Never overwrite an existing prefix sum.**

```js
if (!seen.has(prefixSum)) {
	seen.set(prefixSum, i);
}
```

---

# 6. Why `0 → -1`?

Initialize:

```js
seen.set(0, -1);
```

Meaning:

> **Before reading any elements, my running sum was zero.**

This handles subarrays beginning at index `0`.

Example:

```text
nums = [5, 2, -2]
k = 5
```

At index `0`:

```text
prefixSum = 5

5 - earlierPrefix = 5

earlierPrefix = 0
```

We already have:

```text
0 → -1
```

Therefore:

```text
length = 0 - (-1)
       = 1
```

So `[5]` is correctly detected.

It also works for:

```text
nums = [2, 1, 2, 8]
k = 5
```

At index `2`:

```text
prefixSum = 5

5 - 0 = 5

length = 2 - (-1)
       = 3
```

So:

```text
[2, 1, 2]
```

is detected without any special case.

---

# 7. Optimal Solution

```js
function longestSubarraySumK(nums, k) {
	let prefixSum = 0;
	let maxLength = 0;

	const seen = new Map();

	// Before the array begins:
	// prefix sum = 0 at index -1
	seen.set(0, -1);

	for (let i = 0; i < nums.length; i++) {
		prefixSum += nums[i];

		const needed = prefixSum - k;

		if (seen.has(needed)) {
			const length = i - seen.get(needed);
			maxLength = Math.max(maxLength, length);
		}

		// Preserve earliest occurrence
		if (!seen.has(prefixSum)) {
			seen.set(prefixSum, i);
		}
	}

	return maxLength;
}
```

---

# 8. Dry-Run Mental Model

At every index, think:

```text
1. What is my running total?

2. currentPrefix - earlierPrefix = target

3. Therefore:
   earlierPrefix = currentPrefix - target

4. Have I seen that earlierPrefix before?

5. If yes:
   currentIndex - earlierIndex = valid subarray length
```

Example:

```text
prefixSum = 10
k = 4

10 - earlierPrefix = 4

earlierPrefix = 6
```

Ask:

```text
Have I seen running sum 6 before?
```

If yes, everything after that earlier prefix until now sums to `4`.

---

# 9. Why Not Sliding Window?

Because negative numbers destroy monotonicity.

With only positive numbers:

```text
expand → sum increases
shrink → sum decreases
```

But with negatives:

```text
expand → sum might decrease
shrink → sum might increase
```

Therefore a rule like:

```text
sum > target → shrink
```

is not reliable.

Use prefix sums instead.

---

# 10. Complexity

### Time

```text
O(n)
```

We traverse the array once.

Map lookup and insertion are O(1) average.

### Space

```text
O(n)
```

In the worst case every prefix sum is unique.

---

# 11. Mistakes From Mock Interview

### Loop Boundary

Wrong:

```js
i <= nums.length;
```

Correct:

```js
i < nums.length;
```

---

### Map Lookup

Wrong:

```js
seen(comp);
```

Correct:

```js
seen.get(comp);
```

---

### Map Insertion

Wrong:

```js
seen[prefixSum] = i;
```

Correct:

```js
seen.set(prefixSum, i);
```

---

### Length Calculation

Correct relationship:

```js
const length = i - seen.get(needed);

maxLength = Math.max(maxLength, length);
```

---

### Preserve Earliest Prefix

Wrong:

```js
seen.set(prefixSum, i);
```

unconditionally.

Correct:

```js
if (!seen.has(prefixSum)) {
	seen.set(prefixSum, i);
}
```

---

# 12. Interview Explanation

> The brute-force approach would try every possible start and end index, giving O(n²) time.
>
> We can optimize this using prefix sums. If my current running sum is `S`, I need an earlier prefix such that `S - earlierPrefix = k`. Therefore the earlier prefix I'm looking for is `S - k`.
>
> I'll store prefix sums and their earliest indices in a Map. Whenever `S - k` exists, the elements after that earlier index through the current index form a valid subarray.
>
> I preserve the earliest occurrence because it gives the longest possible subarray.
>
> This gives O(n) time and O(n) space.

---

# 📓 Notebook Version

```text
Longest Subarray Sum K

Trigger:
contiguous + target sum + negatives
→ Prefix Sum + Map

Equation:

currentPrefix - earlierPrefix = K

therefore:

earlierPrefix = currentPrefix - K

Map:
prefixSum → earliest index

Initialize:
0 → -1

Why earliest?
currentIndex - earliestIndex
= longest length

Time:  O(n)
Space: O(n)

Negatives?
Sliding window unreliable.
```

---

# 🧠 Memory Lines

> **Current prefix − earlier prefix = target.**

> **I am not searching for K in the Map. I am searching for the prefix I can remove so that K remains.**

> **Running total S. Want K. Have I seen S − K before?**

> **Prefix Sum = Two Sum over running totals.**
