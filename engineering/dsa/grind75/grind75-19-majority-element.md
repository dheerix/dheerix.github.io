# Grind 75 — 19: Majority Element

**Difficulty:** Easy  
**Primary pattern:** Boyer–Moore voting / cancellation  
**LeetCode:** https://leetcode.com/problems/majority-element/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given an integer array of length `n`, return the value appearing more than `⌊n / 2⌋` times.

The problem guarantees that such a majority element exists.

```text
nums = [3, 2, 3]
answer = 3
```

```text
nums = [2, 2, 1, 1, 1, 2, 2]
answer = 2
```

“More than half” is stronger than “most frequent.” Only one value can occur more than `n / 2` times.

---

## 2. Straightforward frequency-map approach

Count every number, then return the one whose count exceeds `n / 2`.

```javascript
function majorityElementWithMap(nums) {
  const frequencies = new Map();
  const requiredCount = Math.floor(nums.length / 2);

  for (const number of nums) {
    const nextCount = (frequencies.get(number) ?? 0) + 1;
    frequencies.set(number, nextCount);

    if (nextCount > requiredCount) {
      return number;
    }
  }
}
```

- Time: **O(n)** average.
- Extra space: **O(k)** for `k` distinct values; worst case O(n).

This is correct and easy to derive. The guaranteed majority allows an O(1)-space solution.

---

## 3. Cancellation intuition

Imagine repeatedly removing pairs of different values from the array.

If one value occurs more than half the time, it outnumbers all other values combined:

```text
majority count > non-majority count
```

Every cancellation removes at most one majority occurrence and one non-majority occurrence. Since the majority has more copies than all opponents together, it cannot be completely eliminated.

Therefore:

> After canceling different values, the surviving candidate must be the majority.

Boyer–Moore voting performs this cancellation without physically removing elements.

---

## 4. Candidate and balance

Maintain:

```text
candidate → value currently surviving cancellation
balance   → unmatched votes supporting that candidate
```

For every number:

1. If `balance === 0`, choose the current number as the new candidate.
2. If the current number equals the candidate, increment balance.
3. Otherwise decrement balance—a candidate vote and opponent vote cancel.

The balance is not the candidate's total frequency. It is the net support within the portion since the candidate was last selected.

---

## 5. Optimal JavaScript solution

```javascript
function majorityElement(nums) {
  let candidate = null;
  let balance = 0;

  for (const number of nums) {
    if (balance === 0) {
      candidate = number;
    }

    if (number === candidate) {
      balance++;
    } else {
      balance--;
    }
  }

  return candidate;
}
```

---

## 6. Dry run

```text
nums = [2, 2, 1, 1, 1, 2, 2]
```

| Number | Candidate before | Balance before | Action | Candidate after | Balance after |
|---:|---:|---:|---|---:|---:|
| 2 | null | 0 | choose 2, support | 2 | 1 |
| 2 | 2 | 1 | support | 2 | 2 |
| 1 | 2 | 2 | cancel | 2 | 1 |
| 1 | 2 | 1 | cancel | 2 | 0 |
| 1 | 2 | 0 | choose 1, support | 1 | 1 |
| 2 | 1 | 1 | cancel | 1 | 0 |
| 2 | 1 | 0 | choose 2, support | 2 | 1 |

Return `2`.

The real majority may temporarily stop being the candidate. That is fine: cancellations remove equal numbers of candidate and opposing votes, preserving the identity of the global majority among what remains.

---

## 7. Another way to visualize the balance

For the current candidate:

```text
same value      → +1 vote
different value → -1 vote
zero balance    → current segment fully canceled
```

When balance reaches zero, the processed segment can be partitioned into different-value cancellations. It contributes no surviving candidate, so the next number may begin a fresh candidate segment.

---

## 8. Code walkthrough

### `candidate = null`

The value is irrelevant until balance is zero and the first array item becomes the candidate. The official array is non-empty.

### Candidate selection before voting

When `balance === 0`, set `candidate = number`, then the same number contributes a positive vote. The new balance becomes one.

### Equality comparison

Use strict equality. Array entries are integers, so there are no coercion requirements.

### Return without verification

The official problem guarantees that a majority exists. Under that promise, the final Boyer–Moore candidate must be it.

If the majority were not guaranteed, a second pass would be required to count the candidate and verify that its frequency exceeds `n / 2`.

---

## 9. Correctness reasoning

Conceptually cancel pairs of different elements. Removing one occurrence of the true majority and one non-majority occurrence does not change which value has more than half of the remaining uncanceled elements, because the majority initially outnumbers all other values combined.

The algorithm's increment/decrement operations simulate these cancellations. Whenever balance reaches zero, the processed candidate votes have been fully paired with different values and can be discarded from consideration.

Because the true majority cannot be fully canceled by all non-majority elements, it must be the final surviving candidate. The existence guarantee makes returning that candidate correct.

---

## 10. Complexity

- **Time: O(n)** — one pass through the array.
- **Auxiliary space: O(1)** — only the candidate and balance are stored.

No sorting or frequency table is required.

---

## 11. Why the existence guarantee matters

For an array with no majority:

```text
[1, 2, 3]
```

Boyer–Moore still returns a candidate, but that candidate is not necessarily a majority.

Verification version:

```javascript
function findMajorityIfPresent(nums) {
  let candidate = null;
  let balance = 0;

  for (const number of nums) {
    if (balance === 0) candidate = number;
    balance += number === candidate ? 1 : -1;
  }

  let frequency = 0;

  for (const number of nums) {
    if (number === candidate) frequency++;
  }

  return frequency > Math.floor(nums.length / 2)
    ? candidate
    : null;
}
```

This remains O(n) time and O(1) space, but uses two passes.

General lesson:

> A problem guarantee can remove a verification phase; without the guarantee, restore it.

---

## 12. Sorting alternative

If the array is sorted, the majority element must occupy the middle index:

```javascript
function majorityElementBySorting(nums) {
  nums.sort((a, b) => a - b);
  return nums[Math.floor(nums.length / 2)];
}
```

Why? Any value occupying more than half the array must cross the middle position once equal values are grouped.

Complexity:

- Time: **O(n log n)**.
- Extra space: depends on the sorting implementation.
- Side effect: mutates `nums` in JavaScript.

This is simpler than voting but slower and mutates the input unless a copy is sorted.

---

## 13. Common mistakes

1. **Finding the mode instead of a strict majority.** “Most frequent” need not exceed half.
2. **Treating `balance` as the candidate's actual count.** It is net uncanceled support.
3. **Changing candidate whenever a different number appears.** Change only when balance is zero.
4. **Forgetting to give the newly selected candidate its vote.** Candidate selection and balance update both occur for the current number.
5. **Believing the candidate can never change away from the true majority.** Temporary candidates are part of the cancellation process.
6. **Skipping verification when existence is not guaranteed.** Boyer–Moore always yields a candidate, not always a valid majority.
7. **Calling the map solution O(1) space.** It may store O(n) distinct keys.
8. **Sorting JavaScript numbers without a comparator.** Default sort is lexicographic: `[2, 10]` becomes `[10, 2]`.
9. **Ignoring sort mutation.** `Array.prototype.sort()` changes the original array.

---

## 14. What to say in an interview

> “A frequency map gives O(n) time but O(n) space. Since a majority is guaranteed and appears more than all other values combined, I can use Boyer–Moore voting. Matching values add a vote; different values cancel a vote. When balance reaches zero, I choose a new candidate. Pairwise cancellation cannot eliminate the true majority, so the final candidate is the answer. This is O(n) time and O(1) space.”

If asked about no guarantee:

> “I would make a second pass to verify that the final candidate actually occurs more than `floor(n/2)` times.”

---

## 15. Pattern recognition

Think **Boyer–Moore voting** when:

- one value is guaranteed to occur more than half the time;
- you need O(1) extra space;
- majority versus all opposition can be modeled through cancellation.

Do not use this basic form merely for “most frequent element.” The `> n/2` threshold is what makes pairwise cancellation decisive.

Memory cue:

> Opposing votes cancel; the strict majority survives.

---

## 16. Edge cases

| Input | Result | Reason |
|---|---:|---|
| `[5]` | 5 | Single value is majority |
| `[2, 2]` | 2 | All values identical |
| `[1, 2, 1]` | 1 | Two of three |
| `[3, 3, 4, 3, 4, 3, 3]` | 3 | Five of seven |
| Majority appears late | majority | Earlier candidates can be canceled |
| Negative values | normal | Equality/cancellation is value-agnostic |

---

## 17. Notebook-ready notes

### 📚 Concept

**Majority Element — Boyer–Moore voting**

```text
candidate = null, balance = 0
for number:
  balance 0 → candidate = number
  same as candidate → balance++
  different         → balance--
return candidate
```

### 🧠 My understanding

A strict majority outnumbers every other value combined. I can cancel one candidate occurrence against one different occurrence. Every fully canceled segment becomes irrelevant, and the true majority cannot be completely canceled, so it survives as the final candidate.

### 💼 Interview line

> “Pairwise cancellation removes equal opposition while preserving the strict majority.”

### ⚠️ Traps

- Balance is net support, not total frequency.
- New candidate is selected only at balance zero.
- Without a guaranteed majority, verify in a second pass.
- Numeric JavaScript sorting requires `(a, b) => a - b`.

---

## 18. Dheerix Glance

```text
MAJORITY ELEMENT

Guarantee:        one value occurs > floor(n/2)
Technique:        Boyer–Moore voting
State:            candidate + balance
Same value:       balance + 1
Different value:  balance - 1
At zero:          select current as candidate
Reason:           different-value pairs cancel
Time:             O(n)
Auxiliary space:  O(1)
No guarantee:     second pass to verify
Memory cue:       “The strict majority survives cancellation.”
```

---

## 19. Recall test

Without looking back:

1. What is the difference between a mode and a majority?
2. What does `balance` actually represent?
3. Why is selecting a new candidate safe at balance zero?
4. Why can the true majority not be completely canceled?
5. Can the true majority temporarily stop being the candidate?
6. Why is no second pass needed for the official problem?
7. What must change when a majority is not guaranteed?
8. Compare the map, sorting, and Boyer–Moore complexities.

