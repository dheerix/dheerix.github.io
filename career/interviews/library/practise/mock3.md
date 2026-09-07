# IBM Mock 03 — Product of Array Except Self

## Problem

Given an integer array `nums`, return an array `answer` where:

```text
answer[i] = product of every element except nums[i]
```

Constraints:

- No division
- O(n) time
- Output array does not count toward auxiliary space

### Example

```text
nums   = [1, 2, 3, 4]
answer = [24, 12, 8, 6]
```

---

# 🧠 Pattern Trigger

> **For every index, need information from everything LEFT and everything RIGHT → Prefix/Suffix accumulation**

Think:

```text
answer[i]
    =
product(left of i)
    ×
product(right of i)
```

---

# 1. Brute Force

For every index, scan the entire array and multiply everything except the current element.

```js
function productExceptSelf(nums) {
	const result = [];

	for (let i = 0; i < nums.length; i++) {
		let product = 1;

		for (let j = 0; j < nums.length; j++) {
			if (i !== j) {
				product *= nums[j];
			}
		}

		result[i] = product;
	}

	return result;
}
```

### Complexity

```text
Time:  O(n²)
Space: O(1) auxiliary
```

The output array is not counted.

---

# 2. Optimization Intuition

The brute-force solution repeatedly calculates the same products.

For:

```text
nums = [1, 2, 3, 4]
```

At index `2`:

```text
left product  = 1 × 2 = 2
right product = 4

answer[2] = 2 × 4 = 8
```

Instead of recalculating these for every index:

> **Carry cumulative information from both directions.**

---

# 3. Left / Prefix Pass

First calculate the product of everything **before** each index.

```text
nums:       [1, 2, 3, 4]
left:       [1, 1, 2, 6]
```

Meaning:

```text
index 0 → nothing left      → 1
index 1 → 1                 → 1
index 2 → 1 × 2             → 2
index 3 → 1 × 2 × 3         → 6
```

We can build this directly into the output array:

```js
result[0] = 1;

for (let i = 1; i < nums.length; i++) {
	result[i] = result[i - 1] * nums[i - 1];
}
```

After this pass:

```text
result = [1, 1, 2, 6]
```

At this point:

> `result[i]` = product of everything LEFT of `i`.

---

# 4. Right / Suffix Pass

Now scan from right to left.

Maintain:

```js
let suffixProduct = 1;
```

This represents:

> Product of everything RIGHT of the current index.

Starting:

```text
nums   = [1, 2, 3, 4]
result = [1, 1, 2, 6]

                     ←
```

### i = 3

Nothing exists to the right:

```text
suffixProduct = 1

result[3] = 6 × 1
          = 6
```

Then include `nums[3]` for the next index:

```text
suffixProduct = 1 × 4
              = 4
```

### i = 2

```text
result[2] = 2 × 4
          = 8

suffixProduct = 4 × 3
              = 12
```

### i = 1

```text
result[1] = 1 × 12
          = 12

suffixProduct = 12 × 2
              = 24
```

### i = 0

```text
result[0] = 1 × 24
          = 24
```

Final:

```text
[24, 12, 8, 6]
```

---

# 5. Optimal Solution

```js
function productExceptSelf(nums) {
	const result = [];

	// LEFT products
	result[0] = 1;

	for (let i = 1; i < nums.length; i++) {
		result[i] = result[i - 1] * nums[i - 1];
	}

	// RIGHT products
	let suffixProduct = 1;

	for (let i = nums.length - 1; i >= 0; i--) {
		result[i] *= suffixProduct;
		suffixProduct *= nums[i];
	}

	return result;
}
```

---

# 6. Why Initialize With `1`?

Because `1` is the **multiplicative identity**:

```text
x × 1 = x
```

At index `0`:

```text
nothing exists to the left
```

So:

```text
left product = 1
```

At the final index:

```text
nothing exists to the right
```

So:

```text
right product = 1
```

This avoids special-case logic.

Memory:

> **Empty product = 1.**

---

# 7. Why Two Passes?

First pass:

```text
→ → → → →

build LEFT information
```

Second pass:

```text
← ← ← ← ←

carry RIGHT information
```

At every position:

```text
LEFT × RIGHT = answer
```

---

# 8. Complexity

## Time

```text
First pass  = O(n)
Second pass = O(n)

O(n) + O(n)
= O(2n)
= O(n)
```

## Auxiliary Space

```text
O(1)
```

The required output array is explicitly excluded.

Besides the output, we only maintain:

```text
suffixProduct
loop variables
```

If the interviewer asks for **total memory including output**:

```text
O(n)
```

---

# 9. Why Not a Map?

A Map could store products, but the problem doesn't require arbitrary lookup by value.

What matters is positional cumulative information:

```text
everything before i
everything after i
```

Arrays/prefix-suffix accumulation match the problem more naturally.

---

# 10. Why Not Sliding Window?

Sliding window is useful when maintaining a **contiguous region satisfying some condition**.

Here there is no moving valid window.

Instead:

```text
For EVERY index:

need everything LEFT
+
need everything RIGHT
```

That's a different trigger:

> **Prefix/Suffix accumulation**

---

# 11. Zeroes Are Automatically Handled

Example:

```text
nums = [-1, 1, 0, -3, 3]
```

No special zero logic is required.

Prefix and suffix multiplication naturally propagates the zero into every answer where appropriate.

Output:

```text
[0, 0, 9, 0, 0]
```

This is one reason avoiding division is useful.

---

# 12. Mistakes From Mock Interview

### Initially reached for Map

My first optimization thought:

```text
index → product
```

But the stronger observation was:

```text
answer[i]
=
everything before i
×
everything after i
```

That should trigger prefix/suffix accumulation.

---

### Initially thought Sliding Window

But there is no window being expanded/shrunk.

Ask:

```text
Am I maintaining a contiguous VALID REGION?
```

If no, sliding window probably isn't the right abstraction.

---

### Reverse Loop Boundary

Wrong:

```js
for (let i = nums.length - 1; i > 0; i--)
```

This skips index `0`.

Correct:

```js
for (let i = nums.length - 1; i >= 0; i--)
```

---

### Variable Declaration

Wrong:

```js
suffixProduct = 1;
```

Correct:

```js
let suffixProduct = 1;
```

---

### Space Complexity

Initially:

```text
O(n)
```

because `result` stores n values.

But the interviewer explicitly excluded the output array.

Therefore:

```text
Auxiliary Space = O(1)
```

Always pay attention to what the interviewer says counts as extra space.

---

# 13. Interview Explanation

> “The brute-force approach would calculate the product for every index by scanning all other elements, which takes O(n²).
>
> The key observation is that the answer at each index is the product of everything to its left multiplied by everything to its right.
>
> I'll first traverse left-to-right and store the prefix product before each index directly in the output array.
>
> Then I'll traverse right-to-left while maintaining a running suffix product. At each index, I multiply the existing left product by that suffix product.
>
> This gives O(n) time using two passes and O(1) auxiliary space because the output array doesn't count toward extra space.”

---

# 📓 Notebook Version

```text
Product Except Self

Trigger:

For each i:
need EVERYTHING LEFT
+
EVERYTHING RIGHT

→ PREFIX / SUFFIX

Formula:

answer[i]
=
leftProduct[i]
×
rightProduct[i]

Pass 1 →
store left product in result

Pass 2 ←
carry suffixProduct
result[i] *= suffixProduct

Initialize with 1:
empty product = 1

Time: O(n)
Aux: O(1)
```

---

# 🧠 Memory Lines

> **Everything left + everything right → Prefix/Suffix.**

> **Don't recompute both sides for every index — carry them.**

> **Left → store. Right ← carry.**

> **Empty product = 1.**

---

# 🔗 Pattern Recognition Update

## Prefix/Suffix Accumulation

### Trigger

When the answer for every position depends on:

```text
information BEFORE i
+
information AFTER i
```

ask:

> **Can I accumulate one direction and then the other?**

Typical shape:

```text
              i
              ↓
[ LEFT LEFT ] X [ RIGHT RIGHT ]

answer[i]
   =
LEFT aggregate
   +
RIGHT aggregate
```

The operator doesn't necessarily have to be multiplication.

The deeper pattern is:

> **Precompute/carry cumulative information from both directions.**

---

# 🧠 Distinguish the First Three Mock Patterns

```text
TARGET SUM + need earlier cumulative state
        ↓
PREFIX SUM + HASH MAP
```

```text
CONTIGUOUS + maintain valid region
        ↓
SLIDING WINDOW
```

```text
EACH POSITION needs LEFT + RIGHT information
        ↓
PREFIX / SUFFIX
```

### Three Recognition Questions

```text
1. "What earlier running total do I need?"
   → Prefix Sum + Map

2. "Can I repair this window instead of restarting?"
   → Sliding Window

3. "Can I carry information from both directions?"
   → Prefix / Suffix
```
