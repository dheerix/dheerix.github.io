# Grind 75 — 30: 3Sum

**Difficulty:** Medium  
**Primary pattern:** Sorting / fixed value + two pointers / duplicate control  
**LeetCode:** https://leetcode.com/problems/3sum/  
**Target time:** 30 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given an integer array, return every unique triplet of values whose sum is zero.

```text
nums = [-1, 0, 1, 2, -1, -4]

answer = [
  [-1, -1, 2],
  [-1, 0, 1]
]
```

Requirements:

- use three different array positions;
- return value triplets, not indices;
- do not return duplicate triplets;
- triplet order and result order do not matter.

---

## 2. Brute-force approach

Try every combination of three indices.

```javascript
function threeSumBruteForce(nums) {
  const uniqueTriplets = new Set();

  for (let i = 0; i < nums.length - 2; i++) {
    for (let j = i + 1; j < nums.length - 1; j++) {
      for (let k = j + 1; k < nums.length; k++) {
        if (nums[i] + nums[j] + nums[k] === 0) {
          const triplet = [nums[i], nums[j], nums[k]]
            .sort((a, b) => a - b);

          uniqueTriplets.add(triplet.join(','));
        }
      }
    }
  }

  return [...uniqueTriplets].map((key) =>
    key.split(',').map(Number),
  );
}
```

- Time: **O(n³)**.
- Extra space: depends on result/deduplication storage.

The target improvement is O(n²).

---

## 3. Reduce 3Sum to Two Sum

Fix one number `nums[i]`.

Then the other two values must satisfy:

```text
nums[left] + nums[right] = -nums[i]
```

This is a Two Sum subproblem.

If the array is sorted, two pointers solve that subproblem in linear time:

```text
sum too small → move left rightward to increase it
sum too large → move right leftward to decrease it
sum equals 0  → record triplet and move both
```

One O(n) two-pointer scan for each of O(n) fixed values gives O(n²).

---

## 4. Why sorting is valuable

Sorting provides three capabilities:

1. **Directional movement:** pointer movement predictably changes the sum.
2. **Adjacent duplicates:** repeated values can be skipped easily.
3. **Early termination:** once the fixed value is positive, no later triplet can sum to zero.

Sorting costs O(n log n), which is dominated by the O(n²) search.

In JavaScript, numeric sorting must use:

```javascript
nums.sort((a, b) => a - b);
```

Default sort is lexicographic.

---

## 5. Pointer logic after fixing `i`

Initialize:

```text
left = i + 1
right = n - 1
```

Calculate:

```text
sum = nums[i] + nums[left] + nums[right]
```

### Sum is too small

Move `left++`. Because the array is sorted, this is the only move that can increase the sum.

### Sum is too large

Move `right--` to decrease the sum.

### Sum is zero

Record the triplet, move both pointers, and skip repeated left/right values so the same value combination is not emitted again.

---

## 6. Duplicate control at two levels

### Duplicate fixed value

```text
if (i > 0 && nums[i] === nums[i - 1]) {
  continue;
}
```

If the same fixed value was already processed, its two-pointer search would generate the same triplets.

### Duplicate values after finding a triplet

After moving both pointers:

```javascript
while (left < right && nums[left] === nums[left - 1]) {
  left++;
}

while (left < right && nums[right] === nums[right + 1]) {
  right--;
}
```

This skips repeated second and third values for the current fixed value.

Do not skip duplicates by blindly excluding repeated values everywhere. Multiple copies can be necessary for a valid triplet, as in `[-1, -1, 2]` or `[0, 0, 0]`.

---

## 7. Optimal JavaScript solution

```javascript
function threeSum(nums) {
  nums.sort((a, b) => a - b);
  const triplets = [];

  for (let i = 0; i < nums.length - 2; i++) {
    if (nums[i] > 0) {
      break;
    }

    if (i > 0 && nums[i] === nums[i - 1]) {
      continue;
    }

    let left = i + 1;
    let right = nums.length - 1;

    while (left < right) {
      const sum = nums[i] + nums[left] + nums[right];

      if (sum < 0) {
        left++;
      } else if (sum > 0) {
        right--;
      } else {
        triplets.push([nums[i], nums[left], nums[right]]);
        left++;
        right--;

        while (
          left < right &&
          nums[left] === nums[left - 1]
        ) {
          left++;
        }

        while (
          left < right &&
          nums[right] === nums[right + 1]
        ) {
          right--;
        }
      }
    }
  }

  return triplets;
}
```

---

## 8. Dry run

Input after sorting:

```text
[-4, -1, -1, 0, 1, 2]
```

### Fix `-4`

```text
left=-1, right=2 → sum=-3 → move left
left=-1, right=2 → sum=-3 → move left
left=0,  right=2 → sum=-2 → move left
left=1,  right=2 → sum=-1 → move left
```

No triplet.

### Fix first `-1`

```text
left=-1, right=2 → sum=0
record [-1,-1,2]
move inward

left=0, right=1 → sum=0
record [-1,0,1]
```

### Next fixed `-1`

Skip it because it duplicates the previous fixed value.

### Fix `0`

Remaining values are positive and do not produce zero with this input.

Answer:

```text
[[-1,-1,2], [-1,0,1]]
```

---

## 9. Why `nums[i] > 0` allows stopping

After sorting, if the fixed value is positive:

```text
nums[i] > 0
```

then every later value is at least as large and therefore positive. Three positive values cannot sum to zero.

Do not stop when `nums[i] === 0`; `[0,0,0]` is a valid triplet.

---

## 10. Code walkthrough

### Sorting mutates input

`nums.sort(...)` changes the caller's array. LeetCode accepts this. If mutation is forbidden:

```javascript
const sorted = [...nums].sort((a, b) => a - b);
```

and use `sorted` throughout.

### Outer loop ends at `n - 3`

The fixed index must leave at least two positions for `left` and `right`.

### `left < right`

The pointers must refer to different indices. When they meet, fewer than two positions remain.

### Move one pointer for nonzero sums

Sorted order makes the direction safe. Moving right inward when the sum is too small would only decrease or preserve the sum, never fix it.

### Move both after a match

The current pair has been recorded. Keeping either pointer on the same value risks repeating the same combination; move both and then skip duplicates.

---

## 11. Correctness reasoning

For each unique fixed index `i`, `left` and `right` search all feasible pairs in the sorted suffix.

- If the sum is too small, every pair using the same left value and a right index no larger than the current right is also too small, so incrementing left discards no valid solution.
- If the sum is too large, every pair using the same right value and a left index no smaller than the current left is also too large, so decrementing right is safe.
- If the sum is zero, the triplet is valid. Moving both pointers continues the search, while duplicate skipping removes only repeated value combinations.

Every possible triplet has some smallest sorted index chosen by the outer loop, and its remaining pair is covered by the two-pointer scan. Therefore, all and only unique zero-sum triplets are returned.

---

## 12. Complexity

- Sorting: **O(n log n)**.
- Outer loop × two-pointer scan: **O(n²)**.
- Total time: **O(n²)**.
- Auxiliary space: depends on sorting implementation; excluding output, often O(log n) to O(n). With an explicit copy, O(n).
- Output space: up to O(number of returned triplets).

The inner pointer loop is O(n), not O(n²), because `left` only increases and `right` only decreases during one outer iteration.

---

## 13. Hash-set alternative

For each fixed value, a Two Sum hash set can find complements:

```text
needed = -(nums[i] + nums[j])
```

This can also achieve O(n²) average time, but unique-triplet deduplication becomes more cumbersome. Sorting plus two pointers naturally canonicalizes values and makes duplicate skipping explicit.

Choose the approach that makes both search and uniqueness easy to prove.

---

## 14. Common mistakes

1. **Forgetting to sort.** Two-pointer directional movement depends on order.
2. **Using default JavaScript sort.** It sorts numbers lexicographically.
3. **Returning duplicate triplets.** Skip duplicate fixed, left, and right values.
4. **Skipping all duplicate values preemptively.** Valid triplets may require two or three equal values.
5. **Using `left <= right`.** Three distinct positions are required.
6. **Moving the wrong pointer.** Small sum → increase left; large sum → decrease right.
7. **Moving only one pointer after finding a triplet.** This can repeat combinations or miss clean progression.
8. **Breaking at `nums[i] >= 0`.** `[0,0,0]` would be missed; break only when positive.
9. **Returning indices.** This problem asks for value triplets.
10. **Ignoring sort mutation.** Mention it or sort a copy if required.

---

## 15. What to say in an interview

> “Brute force tries all triples in O(n³). I’ll sort the array, fix one value, and solve Two Sum on the remaining suffix with left and right pointers. If the sum is low, I move left; if high, I move right. Sorting also lets me skip repeated fixed values and repeated pointer values so each triplet is emitted once. The search is O(n²), dominated over O(n log n) sorting.”

If asked about duplicate handling:

> “I skip a fixed value only if the previous outer iteration already used the same value, and after recording a triplet I skip identical values at both moving boundaries.”

---

## 16. Pattern recognition

Think **sort + fix one + two pointers** when:

- a multi-value sum must hit a target;
- output uniqueness matters;
- values, not original indices, are required;
- fixing one dimension reduces the problem to a known smaller problem.

General reduction:

```text
3Sum target T:
fix x
find pair summing to T - x
```

The same idea extends conceptually to 4Sum by fixing more values.

Memory cue:

> Sort, fix one, squeeze the other two.

---

## 17. Edge cases

| Input | Result pattern |
|---|---|
| `[]`, fewer than 3 values | empty result |
| `[0,0,0]` | `[[0,0,0]]` |
| `[0,0,0,0]` | still one unique triplet |
| all positive | empty; early break |
| all negative | empty |
| `[-1,-1,2]` | duplicate values can be required |
| many repeated values | duplicate skipping prevents repeated output |

---

## 18. Notebook-ready notes

### 📚 Concept

**3Sum — sort + fixed value + two pointers**

```text
sort ascending
for each unique i:
  if nums[i] > 0 → stop
  left=i+1, right=n-1
  sum = fixed+left+right
  sum < 0 → left++
  sum > 0 → right--
  sum = 0 → record, move both, skip duplicates
```

### 🧠 My understanding

Fixing one value turns the remaining requirement into Two Sum. Sorting lets pointer movement change the sum predictably and places duplicates together. I handle uniqueness both at the fixed value and after finding each pair.

### 💼 Interview line

> “I’ll reduce 3Sum to O(n) Two Sum scans over a sorted suffix.”

### ⚠️ Traps

- Numeric sort comparator is required.
- Break only when fixed value is positive.
- Skip duplicates without eliminating necessary repeated copies.
- Move both pointers after a match.

---

## 19. Dheerix Glance

```text
3SUM

Goal:             unique triplets summing to zero
Preprocess:       numeric ascending sort
Reduction:        fix nums[i], two-sum target=-nums[i]
Pointers:         left=i+1, right=n-1
Too small:        left++
Too large:        right--
Match:            record; move both; skip duplicate values
Outer duplicate:  skip nums[i] == nums[i-1]
Early stop:       nums[i] > 0
Time:             O(n²)
Memory cue:       “Sort, fix one, squeeze two.”
```

---

## 20. Recall test

Without looking back:

1. How does fixing one value reduce 3Sum to Two Sum?
2. What three advantages does sorting provide?
3. Why does a small sum require moving `left`?
4. Where must duplicate values be skipped?
5. Why must valid repeated values such as `[-1,-1,2]` remain possible?
6. Why can the loop stop when the fixed value becomes positive?
7. Why is the total search O(n²), not O(n³)?
8. State the two-pointer invariant in one sentence.
