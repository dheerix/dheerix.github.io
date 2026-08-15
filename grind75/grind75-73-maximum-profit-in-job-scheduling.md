# Grind 75 — 73: Maximum Profit in Job Scheduling

**Difficulty:** Hard  
**Primary pattern:** Weighted interval scheduling + DP + binary search  
**LeetCode:** 1235  
**Target interview time:** 45 minutes  
**Language:** JavaScript

## Problem

You are given three arrays:

- `startTime[i]`: when job `i` begins;
- `endTime[i]`: when job `i` finishes;
- `profit[i]`: profit earned by completing job `i`.

Choose a set of non-overlapping jobs with maximum total profit.

If one job ends at time `x`, another job may start at time `x`; those jobs do not overlap.

Example:

```text
startTime = [1,2,3,3]
endTime   = [3,4,5,6]
profit    = [50,10,40,70]

Best choice:
[1,3] profit 50
[3,6] profit 70

answer = 120
```

---

## 1. Intuition

At each job, there are two choices:

```text
skip the job
or
take the job and jump to the next compatible job
```

This is not ordinary interval scheduling, where choosing the earliest finishing job maximizes the **number** of jobs. Here, jobs have different profits. A locally convenient job may block a much more profitable combination.

The decision is:

```text
best(i) = max(
  best(i + 1),
  jobs[i].profit + best(nextCompatibleIndex)
)
```

To make `nextCompatibleIndex` efficient:

1. combine the three arrays into job objects;
2. sort jobs by start time;
3. binary-search for the first job whose start time is at least the current job's end time.

This is the classic **weighted interval scheduling** pattern.

---

## 2. Why Greedy Is Not Enough

### Earliest finishing job can fail

```text
Job A: [1,2], profit 1
Job B: [2,3], profit 1
Job C: [1,3], profit 100
```

Choosing the earliest-finishing jobs gives `A + B = 2`, but the optimal choice is `C = 100`.

### Highest-profit job first can also fail

```text
Job A: [1,10], profit 100
Job B: [1,5],  profit 60
Job C: [5,10], profit 60
```

Choosing the single highest-profit job gives `100`, while `B + C = 120`.

Profit introduces a global tradeoff, so we need dynamic programming rather than a simple local rule.

---

## 3. Brute Force — Explore Every Valid Subset

After sorting by start time, recursively decide whether to skip or take each compatible job.

```js
function jobScheduling(startTime, endTime, profit) {
  const jobs = startTime
    .map((start, i) => ({
      start,
      end: endTime[i],
      profit: profit[i],
    }))
    .sort((a, b) => a.start - b.start);

  function search(index, availableAt) {
    if (index === jobs.length) return 0;

    const skip = search(index + 1, availableAt);
    let take = 0;

    if (jobs[index].start >= availableAt) {
      take =
        jobs[index].profit +
        search(index + 1, jobs[index].end);
    }

    return Math.max(skip, take);
  }

  return search(0, 0);
}
```

### Complexity

- Time: `O(2^n)` in the worst case.
- Recursion space: `O(n)`.

Many recursive calls solve the same remaining scheduling problem repeatedly.

---

## 4. Better Solution — Memoized DP with Linear Search

Define:

```text
dp(i) = maximum profit obtainable using jobs from index i onward
```

For every taken job, scan forward to find the next compatible one.

```js
function jobScheduling(startTime, endTime, profit) {
  const jobs = startTime
    .map((start, i) => [start, endTime[i], profit[i]])
    .sort((a, b) => a[0] - b[0]);

  const memo = new Array(jobs.length);

  function dp(index) {
    if (index === jobs.length) return 0;
    if (memo[index] !== undefined) return memo[index];

    let next = index + 1;
    while (next < jobs.length && jobs[next][0] < jobs[index][1]) {
      next++;
    }

    const skip = dp(index + 1);
    const take = jobs[index][2] + dp(next);

    memo[index] = Math.max(skip, take);
    return memo[index];
  }

  return dp(0);
}
```

### Complexity

- Time: `O(n²)` because each state may scan forward linearly.
- Space: `O(n)` for memoization and recursion.

The remaining inefficiency is finding the next compatible job.

---

## 5. Optimal Solution — Bottom-Up DP + Binary Search

```js
/**
 * Returns the maximum profit obtainable from non-overlapping jobs.
 *
 * @param {number[]} startTime
 * @param {number[]} endTime
 * @param {number[]} profit
 * @return {number}
 */
function jobScheduling(startTime, endTime, profit) {
  const jobs = startTime
    .map((start, index) => ({
      start,
      end: endTime[index],
      profit: profit[index],
    }))
    .sort((first, second) => first.start - second.start);

  const starts = jobs.map((job) => job.start);
  const dp = new Array(jobs.length + 1).fill(0);

  for (let index = jobs.length - 1; index >= 0; index--) {
    const nextIndex = lowerBound(starts, jobs[index].end);

    const skipProfit = dp[index + 1];
    const takeProfit = jobs[index].profit + dp[nextIndex];

    dp[index] = Math.max(skipProfit, takeProfit);
  }

  return dp[0];
}

/**
 * Returns the first index whose value is >= target.
 * Returns values.length if no such index exists.
 */
function lowerBound(values, target) {
  let left = 0;
  let right = values.length;

  while (left < right) {
    const middle = left + Math.floor((right - left) / 2);

    if (values[middle] < target) {
      left = middle + 1;
    } else {
      right = middle;
    }
  }

  return left;
}
```

---

## 6. DP State and Transition

### State

```text
dp[i] = maximum profit available using jobs i through n - 1
```

The jobs are sorted by start time.

### Base case

```text
dp[n] = 0
```

There are no jobs remaining after the final index.

### Choice 1: Skip job `i`

```text
skipProfit = dp[i + 1]
```

### Choice 2: Take job `i`

After taking it, the next selected job must start at or after `jobs[i].end`.

```text
nextIndex = first j where jobs[j].start >= jobs[i].end
takeProfit = jobs[i].profit + dp[nextIndex]
```

### Transition

```text
dp[i] = max(skipProfit, takeProfit)
```

Because `dp[i]` depends on larger indices, fill the table from right to left.

---

## 7. Why Binary Search Uses `>= end`

The problem says a job ending at time `x` does not conflict with a job beginning at `x`.

Therefore, the next job must satisfy:

```text
nextStart >= currentEnd
```

The binary search must return the first start time greater than or equal to the target: a standard lower bound.

Using `>` would incorrectly reject jobs that begin exactly when the current one ends.

---

## 8. Walkthrough

```text
startTime = [1,2,3,3]
endTime   = [3,4,5,6]
profit    = [50,10,40,70]
```

Sorted jobs:

| Index | Start | End | Profit |
| ---: | ---: | ---: | ---: |
| 0 | 1 | 3 | 50 |
| 1 | 2 | 4 | 10 |
| 2 | 3 | 5 | 40 |
| 3 | 3 | 6 | 70 |

Start array:

```text
[1,2,3,3]
```

Initialize:

```text
dp[4] = 0
```

### `i = 3`: job `[3,6]`, profit `70`

No later job starts at or after `6`:

```text
next = 4
take = 70 + dp[4] = 70
skip = dp[4] = 0
dp[3] = 70
```

### `i = 2`: job `[3,5]`, profit `40`

```text
next = 4
take = 40
skip = dp[3] = 70
dp[2] = 70
```

### `i = 1`: job `[2,4]`, profit `10`

```text
next = 4
take = 10
skip = dp[2] = 70
dp[1] = 70
```

### `i = 0`: job `[1,3]`, profit `50`

The first job starting at or after `3` is index `2`:

```text
next = 2
take = 50 + dp[2] = 120
skip = dp[1] = 70
dp[0] = 120
```

Return `120`.

---

## 9. Correctness Proof

We prove that `dp[i]` equals the maximum profit obtainable from jobs `i...n-1`.

### Base case

At `i = n`, no jobs remain, so the maximum profit is `0`. Thus, `dp[n] = 0` is correct.

### Inductive hypothesis

Assume `dp[j]` is correct for every `j > i`.

### Inductive step

Any optimal schedule using jobs from index `i` onward must make exactly one of two choices about job `i`:

1. **Skip job `i`.** The best remaining profit is `dp[i + 1]`, correct by the hypothesis.
2. **Take job `i`.** Every overlapping job becomes unavailable. Because jobs are sorted by start time, binary search finds the first compatible index `nextIndex`. The best remaining compatible profit is `dp[nextIndex]`, correct by the hypothesis. Total profit is `jobs[i].profit + dp[nextIndex]`.

These cases are exhaustive and mutually exclusive. Taking their maximum therefore gives the optimal profit for state `i`.

By backward induction, `dp[0]` is the maximum profit for all jobs.

---

## 10. Complexity

Let `n` be the number of jobs.

### Time

```text
O(n log n)
```

- Constructing jobs: `O(n)`.
- Sorting jobs: `O(n log n)`.
- `n` DP states, each with an `O(log n)` binary search.

### Space

```text
O(n)
```

The job array, start array, and DP table each use linear space.

---

## 11. Top-Down Alternative

The same recurrence can be written with memoized recursion:

```js
function jobScheduling(startTime, endTime, profit) {
  const jobs = startTime
    .map((start, i) => [start, endTime[i], profit[i]])
    .sort((a, b) => a[0] - b[0]);

  const starts = jobs.map((job) => job[0]);
  const memo = new Array(jobs.length);

  function dp(index) {
    if (index === jobs.length) return 0;
    if (memo[index] !== undefined) return memo[index];

    const next = lowerBound(starts, jobs[index][1]);
    const skip = dp(index + 1);
    const take = jobs[index][2] + dp(next);

    memo[index] = Math.max(skip, take);
    return memo[index];
  }

  return dp(0);
}
```

It has the same `O(n log n)` time and `O(n)` storage, but JavaScript recursion depth can be a concern for large inputs. Bottom-up DP avoids call-stack risk.

---

## 12. Common Mistakes

### Mistake 1: Applying unweighted interval-scheduling greedily

Earliest finish time maximizes job count, not total profit.

### Mistake 2: Sorting one input array independently

Start, end, and profit belong together. Combine them into job records before sorting.

### Mistake 3: Searching for `start > end`

The correct compatibility condition is:

```text
nextStart >= currentEnd
```

### Mistake 4: Using binary search on unsorted starts

Binary search requires the jobs to be sorted by start time.

### Mistake 5: Taking a job and continuing from `i + 1`

That may allow overlapping work. Taking a job must jump to its first compatible successor.

### Mistake 6: Forgetting the skip choice

Even a profitable job may block a more valuable combination.

### Mistake 7: Using `Array.findIndex()` for every job

That makes next-job lookup linear and total time `O(n²)`.

### Mistake 8: Memoizing by current time

Times may be large and sparse. The sorted job index is a smaller, cleaner state.

### Mistake 9: Wrong DP fill direction

`dp[i]` depends on future indices, so bottom-up evaluation must move right to left.

---

## 13. Edge Cases

### One job

Return its profit.

### All jobs overlap

Return the highest-profit individual job.

### No jobs overlap

Return the sum of all profits.

### Jobs touch at boundaries

```text
[1,3] and [3,5]
```

Both may be selected.

### Duplicate start times

Sorting and lower-bound search still work. The DP compares all choices.

### Duplicate intervals with different profits

The DP naturally chooses the more profitable alternative unless another combination is better.

### A long job versus several short jobs

This is precisely the case where the take/skip recurrence is necessary.

### Next compatible job does not exist

`lowerBound` returns `n`, and `dp[n] = 0` handles it safely.

---

## 14. Interview Explanation

> This is weighted interval scheduling, so a greedy earliest-finish rule is insufficient. I combine the arrays into jobs and sort by start time. Let `dp[i]` be the maximum profit available from job `i` onward. For each job, I either skip it and use `dp[i+1]`, or take it and add its profit to `dp[next]`, where `next` is the first job starting at or after the current end time. Because start times are sorted, I find `next` with lower-bound binary search. Filling the DP right to left gives `O(n log n)` time and `O(n)` space.

### Clarify aloud

1. Can a job begin exactly when another ends? Yes.
2. Must at least one job be selected? Standard positive profits make the optimum non-empty when jobs exist.
3. Are jobs initially sorted? No assumption is needed.
4. Do we need the maximum profit only or the chosen schedule? The standard problem asks only for profit.

### If the interviewer asks for the selected jobs

Store the decision at each `dp[i]`. Starting at index `0`, follow either `i + 1` for skip or `nextIndex` for take, collecting taken jobs.

---

## 15. Notebook Version

### Recognition

```text
Non-overlapping intervals + different profits
=> weighted interval scheduling
=> sort + take/skip DP + binary search
```

### State

```text
dp[i] = best profit using jobs from i onward
```

### Transition

```text
next = first start >= jobs[i].end

skip = dp[i + 1]
take = jobs[i].profit + dp[next]

dp[i] = max(skip, take)
```

### JavaScript

```js
function jobScheduling(startTime, endTime, profit) {
  const jobs = startTime
    .map((start, i) => [start, endTime[i], profit[i]])
    .sort((a, b) => a[0] - b[0]);

  const starts = jobs.map((job) => job[0]);
  const dp = new Array(jobs.length + 1).fill(0);

  for (let i = jobs.length - 1; i >= 0; i--) {
    const next = lowerBound(starts, jobs[i][1]);

    dp[i] = Math.max(
      dp[i + 1],
      jobs[i][2] + dp[next]
    );
  }

  return dp[0];
}

function lowerBound(values, target) {
  let left = 0;
  let right = values.length;

  while (left < right) {
    const middle = left + Math.floor((right - left) / 2);

    if (values[middle] < target) left = middle + 1;
    else right = middle;
  }

  return left;
}
```

### Complexity

```text
Time:  O(n log n)
Space: O(n)
```

### Invariant

When computing `dp[i]`, all future states needed by the skip and take choices are already optimal.

---

## 16. Memory Line

**For every weighted job: skip one step, or take it and binary-jump beyond its end.**

