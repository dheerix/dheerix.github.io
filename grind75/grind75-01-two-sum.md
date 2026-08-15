# Grind 75 — 01: Two Sum

**Difficulty:** Easy  
**Primary pattern:** Hash map / complement lookup  
**LeetCode:** https://leetcode.com/problems/two-sum/  
**Target time:** 15 minutes

---

## 1. Problem in plain English

You are given an array of integers and a target value. Find the **indices of two different elements** whose values add up to the target.

```text
Input:  nums = [2, 7, 11, 15], target = 9
Output: [0, 1]

Reason: nums[0] + nums[1] = 2 + 7 = 9
```

The problem guarantees exactly one valid answer. The same array position cannot be used twice.

---

## 2. Translate the problem into an equation

We need:

```text
x + y = target
```

If the current number is `y`, the number we need is:

```text
x = target - y
```

This missing number is called the **complement**.

For example, if the target is `11` and the current value is `8`:

```text
complement = 11 - 8 = 3
```

The real question is therefore not:

> Which two numbers should I try?

It is:

> Have I already seen the complement of the current number?

That reframing produces the optimal solution.

---

## 3. Brute-force approach

For every element, inspect every element after it.

```javascript
function twoSumBruteForce(nums, target) {
  for (let i = 0; i < nums.length; i++) {
    for (let j = i + 1; j < nums.length; j++) {
      if (nums[i] + nums[j] === target) {
        return [i, j];
      }
    }
  }

  return [];
}
```

### Why it works

Every possible pair `(i, j)` is tested once. Starting `j` at `i + 1` prevents using the same element twice and avoids checking a pair in both orders.

### Complexity

- Time: **O(n²)** — in the worst case, roughly `n(n - 1) / 2` pairs are examined.
- Extra space: **O(1)** — only loop variables are used.

### Why improve it?

The nested loop spends time repeatedly searching for the required complement. A hash map can answer that lookup in average **O(1)** time.

---

## 4. Optimal insight: remember what has already been seen

Maintain a `Map`:

```text
number → index where it appeared
```

For each current number:

1. Calculate `complement = target - current`.
2. Check whether the complement is already in the map.
3. If yes, return the stored index and the current index.
4. Otherwise, store the current number and its index.

The order matters: **check first, then store**. This prevents the current element from matching itself.

---

## 5. Dry run

```text
nums = [3, 2, 4], target = 6
```

| i | Current | Complement | Seen before step | Action |
|---:|---:|---:|---|---|
| 0 | 3 | 3 | `{}` | Not found; store `3 → 0` |
| 1 | 2 | 4 | `{3 → 0}` | Not found; store `2 → 1` |
| 2 | 4 | 2 | `{3 → 0, 2 → 1}` | Found `2 → 1`; return `[1, 2]` |

Notice the duplicate-safe behavior for `[3, 3]`, target `6`:

```text
i = 0: need 3; map is empty; store 3 → 0
i = 1: need 3; map contains 3 → 0; return [0, 1]
```

Two different indices are used correctly.

---

## 6. Optimal JavaScript solution

```javascript
function twoSum(nums, target) {
  // Maps each previously visited value to its array index.
  const seen = new Map();

  for (let currentIndex = 0; currentIndex < nums.length; currentIndex++) {
    const currentValue = nums[currentIndex];
    const complement = target - currentValue;

    // If the required partner appeared earlier, the pair is complete.
    if (seen.has(complement)) {
      return [seen.get(complement), currentIndex];
    }

    // Store only after checking so an element cannot match itself.
    seen.set(currentValue, currentIndex);
  }

  // The problem guarantees a solution; this handles the general case.
  return [];
}
```

---

## 7. Code walkthrough

### `const seen = new Map();`

The key is a number already visited. The value is its index. We need the index because the required output is indices, not values.

### `const complement = target - currentValue;`

Instead of searching all future pairs, derive the only value that can complete the current number.

### `seen.has(complement)` and `seen.get(complement)`

`has` checks whether the key exists; `get` retrieves its stored index. Do not use truthiness such as `if (seen.get(complement))`, because index `0` is falsy in JavaScript.

### `seen.set(currentValue, currentIndex)`

If no pair has been completed yet, remember the current number for later elements. Assignment also handles duplicate values safely for this problem.

### Why return immediately?

The problem guarantees one answer. Once a valid pair is found, no additional work is useful.

---

## 8. Complexity

- **Time: O(n)** average — each element is visited once; `Map` lookup and insertion are O(1) average.
- **Extra space: O(n)** — if the answer is found late, the map can contain nearly every element.

Important distinction:

```text
One pass does not mean O(1) space.
```

The loop is linear, but the map grows with the input.

---

## 9. Common mistakes

1. **Calling the hash-map solution O(1) space.** The map can grow to `n` entries, so it is O(n).
2. **Storing before checking.** With `nums = [3, 2]` and target `6`, storing `3` first could incorrectly match index `0` with itself if the logic is careless.
3. **Returning the numbers instead of their indices.** The required result is `[index1, index2]`.
4. **Using two pointers on the original unsorted array.** Two pointers require sorting, but ordinary sorting loses original indices unless values are paired with indices.
5. **Testing `seen.get(complement)` for truthiness.** Index `0` is falsy. Use `seen.has(complement)` to test existence.
6. **Using a plain object carelessly.** `Map` supports numeric keys directly and avoids object-key coercion and prototype concerns.
7. **Assuming all values are positive.** Negative numbers and zero are valid; the complement equation still works.

---

## 10. What to say in an interview

> “The brute-force solution checks every pair, which is O(n²) time and O(1) extra space. We can avoid repeatedly searching for the second value. For each current value, I calculate its complement, `target - currentValue`, and check whether that complement was seen earlier. I’ll store previously seen values with their indices in a JavaScript Map. That gives O(n) average time and O(n) extra space. I’ll check before inserting so I never reuse the same element.”

This explanation communicates:

- a correct baseline;
- the repeated work being removed;
- the invariant maintained by the map;
- the self-match edge case;
- both complexity trade-offs.

---

## 11. Pattern recognition

Think **hash map + complement** when a problem contains language such as:

- “find two values that produce a target”;
- “have we seen the matching value before?”;
- “return the original indices”;
- “find a pair in an unsorted collection.”

General pattern:

```text
Current information + required partner = desired result
Required partner = desired result - current information
```

Do not memorize “Two Sum uses a map.” Memorize:

> When repeated searching is expensive, store earlier information in a form that makes the next lookup cheap.

---

## 12. Follow-up questions

### What if the array is sorted?

Use two pointers in O(n) time and O(1) extra space: one at each end. Move the left pointer when the sum is too small and the right pointer when it is too large.

### What if all matching pairs are required?

The data structure may need to store multiple indices per value, and duplicate-output handling must be defined.

### What if only existence is required?

Use a JavaScript `Set` rather than mapping values to indices.

### What if no solution is guaranteed?

Return an empty array, `null`, or throw an error according to the agreed function contract.

---

## 13. Notebook-ready notes

### 📚 Concept

**Two Sum — Hash map/complement lookup**

For each value `x`, required partner is:

```text
complement = target - x
```

Store previously seen values in a `Map` as `value → index`. Check for the complement before storing the current value.

### 🧠 My understanding

Brute force repeatedly asks every other element whether it is the partner. The map remembers earlier elements, so I can directly ask whether the one required partner has appeared. I trade O(n) memory to reduce O(n²) time to O(n).

### 💼 Interview line

> “I’ll replace repeated pair searching with a one-pass complement lookup using a Map.”

### ⚠️ Trap

The optimized solution uses **O(n) space**, not O(1). Check before inserting to avoid using the same index twice. In JavaScript, use `Map.has()` rather than relying on the truthiness of `Map.get()`.

---

## 14. Dheerix Glance

```text
TWO SUM

Equation:       x + y = target
Need:           complement = target - current
Store:          value → index
Order:          check complement, then store current
Time:           O(n) average
Extra space:    O(n)
Core trade-off: memory replaces repeated searching
Interview cue:  “Have I already seen what I need?”
```

---

## 15. Recall test

Without looking back, answer:

1. What exactly is stored in the map?
2. Why do we check before inserting?
3. Why is the space complexity O(n)?
4. Why must JavaScript use `Map.has()` rather than testing `Map.get()` directly?
5. When would two pointers be preferable?
6. State the map invariant in one sentence.

**Invariant:** Before processing index `i`, the map contains values from indices `0` through `i - 1`, mapped to their earlier indices.
