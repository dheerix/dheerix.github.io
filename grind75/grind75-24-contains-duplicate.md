# Grind 75 — 24: Contains Duplicate

**Difficulty:** Easy  
**Primary pattern:** Hash set / seen-before detection  
**LeetCode:** https://leetcode.com/problems/contains-duplicate/  
**Target time:** 15 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given an integer array, return `true` if any value appears at least twice. Return `false` if every value is distinct.

```text
[1, 2, 3, 1] → true
[1, 2, 3, 4] → false
[1, 1, 1]    → true
```

We need only determine whether a duplicate exists. We do not need its count, indices, or all duplicate values.

---

## 2. Brute-force approach

Compare every value with every later value.

```javascript
function containsDuplicateBruteForce(nums) {
  for (let i = 0; i < nums.length; i++) {
    for (let j = i + 1; j < nums.length; j++) {
      if (nums[i] === nums[j]) {
        return true;
      }
    }
  }

  return false;
}
```

- Time: **O(n²)**.
- Extra space: **O(1)**.

The repeated work is searching the processed values again for every new number.

---

## 3. Sorting approach

After sorting, equal values become adjacent.

```javascript
function containsDuplicateBySorting(nums) {
  const sorted = [...nums].sort((a, b) => a - b);

  for (let i = 1; i < sorted.length; i++) {
    if (sorted[i] === sorted[i - 1]) {
      return true;
    }
  }

  return false;
}
```

- Time: **O(n log n)**.
- Extra space: **O(n)** here because a copy protects the input.

Sorting `nums` directly may use less explicit storage but mutates the caller's array. JavaScript numeric sorting also requires `(a, b) => a - b`; default sorting is lexicographic.

---

## 4. Optimal insight: remember what has appeared

Maintain a set named `seen`.

For each number:

1. If `seen` already contains it, a previous equal value exists—return `true`.
2. Otherwise add it to `seen`.
3. If the scan finishes, every value was unique—return `false`.

A `Set` is sufficient because the question asks only about existence. We do not need counts or indices.

---

## 5. Optimal JavaScript solution

```javascript
function containsDuplicate(nums) {
  const seen = new Set();

  for (const number of nums) {
    if (seen.has(number)) {
      return true;
    }

    seen.add(number);
  }

  return false;
}
```

---

## 6. Dry run

```text
nums = [4, 2, 7, 2]
```

| Number | Set before | Already seen? | Action |
|---:|---|---:|---|
| 4 | `{}` | no | add 4 |
| 2 | `{4}` | no | add 2 |
| 7 | `{4,2}` | no | add 7 |
| 2 | `{4,2,7}` | yes | return `true` |

The scan stops at the first proof. There is no reason to inspect later values.

---

## 7. Loop invariant

At the start of each iteration:

> `seen` contains exactly the distinct values from the already processed prefix of the array.

Therefore, `seen.has(number)` is precisely the question:

> Has the current value occurred at an earlier index?

If yes, the pair of occurrences proves a duplicate. If no, adding it preserves the invariant.

---

## 8. Correctness reasoning

If the function returns `true`, the current value was already in `seen`, meaning an equal value appeared earlier. Therefore, a duplicate exists.

If a duplicate exists, consider its second occurrence during the scan. Its first occurrence must already have been added to `seen`, so the membership check returns `true`.

If the loop completes, no value ever matched an earlier value, so every array element is distinct and returning `false` is correct.

---

## 9. Complexity

- **Time: O(n)** average — each number performs one average O(1) set lookup and at most one insertion.
- **Extra space: O(n)** worst case — when all values are unique, the set stores all `n` values.

This is another example where one pass does **not** imply constant space. The traversal is linear, but the remembered history grows with input size.

Hash collections have theoretical collision-related worst cases, but O(1) average operations and O(n) average total time are the standard interview analysis.

---

## 10. Concise size-comparison solution

```javascript
function containsDuplicateConcise(nums) {
  return new Set(nums).size !== nums.length;
}
```

This works because a set keeps only unique values. If its size is smaller than the array length, at least one value was removed as a duplicate.

Complexity remains:

- Time: **O(n)** average.
- Extra space: **O(n)**.

Trade-off: this version always processes the entire array, while the explicit loop can return as soon as it finds a duplicate. The loop also demonstrates the seen-before pattern more clearly in interviews.

---

## 11. Why a set rather than a map?

Choose the weakest structure that stores exactly the information needed.

| Requirement | Structure |
|---|---|
| Has this value appeared? | `Set` |
| How many times has it appeared? | `Map<value, count>` |
| At which index did it appear? | `Map<value, index>` |

For Contains Duplicate, membership alone answers the question, so a set is the cleanest abstraction.

Compare Two Sum: it needs the earlier index, so it requires a map rather than a set.

---

## 12. Common mistakes

1. **Calling the set solution O(1) space.** It may hold every input value.
2. **Adding before checking without adapting the logic.** After adding, `seen.has(number)` is always true for the current value.
3. **Using a map with counts unnecessarily.** It works but stores more information than required.
4. **Forgetting early return.** Once a duplicate is found, the answer cannot change.
5. **Sorting JavaScript numbers without a comparator.** Default sorting is lexicographic.
6. **Sorting in place without mentioning mutation.** `nums.sort()` changes the input.
7. **Claiming the concise set-size solution short-circuits.** `new Set(nums)` consumes the whole iterable first.
8. **Comparing only adjacent original elements.** Duplicates may be separated until sorting or hashing brings them together logically.
9. **Confusing duplicates with repeated indices.** Two distinct positions must contain equal values.

---

## 13. What to say in an interview

> “The brute-force solution compares every pair in O(n²) time. I only need to know whether each current value appeared earlier, so I'll store the processed values in a set. If membership succeeds, I return true immediately; otherwise I add the value. This gives O(n) average time and O(n) worst-case extra space.”

If asked about the trade-off:

> “The set spends memory to replace repeated linear searches with average constant-time membership checks.”

---

## 14. Pattern recognition

Think **seen set** when:

- the question asks whether any item repeats;
- you need only membership, not frequency or location;
- an online scan should detect the first repeated occurrence;
- order of previous items is irrelevant.

General form:

```javascript
const seen = new Set();

for (const item of items) {
  if (seen.has(item)) {
    // repeated item found
  }

  seen.add(item);
}
```

Memory cue:

> Ask before adding: “Have I seen this already?”

---

## 15. Follow-up variations

### Return the first duplicated value

Return `number` instead of `true` on the membership hit.

### Return duplicate indices

Use `Map<number, index>` so the earlier position is retained.

### Determine whether a duplicate exists within distance `k`

Maintain a sliding-window set of only the previous `k` values, removing values that leave the window.

### Return all duplicated values once

Use one set for seen values and another for duplicates, or count frequencies.

The base question trains the membership pattern; each variation changes what historical information must be retained.

---

## 16. Edge cases

| Input | Result | Reason |
|---|---:|---|
| `[]` | `false` | No duplicate possible |
| `[1]` | `false` | One value |
| `[1, 1]` | `true` | Immediate duplicate |
| `[1, 2, 1]` | `true` | Non-adjacent duplicate |
| `[-1, 0, -1]` | `true` | Negative values work normally |
| `[1, 2, 3]` | `false` | All unique |

---

## 17. Notebook-ready notes

### 📚 Concept

**Contains Duplicate — seen set**

```text
seen = empty Set
for each number:
  already in seen → true
  otherwise add it
finish → false
```

### 🧠 My understanding

The set represents all distinct values in the processed prefix. When the current value is already present, I have found two different positions with the same value. I trade O(n) memory for O(n) average time.

### 💼 Interview line

> “Membership is the only history I need, so a set is the exact structure.”

### ⚠️ Traps

- Check before adding.
- Set space is O(n), not O(1).
- Sort requires a numeric comparator and may mutate input.
- The concise size approach cannot return early.

---

## 18. Dheerix Glance

```text
CONTAINS DUPLICATE

Question:         has current value appeared before?
Structure:        Set
Invariant:        set contains processed distinct values
On membership:    return true
Otherwise:        add current value
Finish:           return false
Time:             O(n) average
Extra space:      O(n)
Memory cue:       “Check first, then remember.”
```

---

## 19. Recall test

Without looking back:

1. What exactly does the set contain during traversal?
2. Why must membership be checked before insertion?
3. Why is a set sufficient whereas Two Sum needs a map?
4. Why is the solution O(n) space despite being one pass?
5. What trade-off does sorting make?
6. Why can the explicit loop outperform `new Set(nums).size` on some inputs?
7. How would the structure change if duplicate indices were required?
8. State the loop invariant in one sentence.

