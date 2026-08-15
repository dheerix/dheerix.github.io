# Grind 75 — 14: First Bad Version

**Difficulty:** Easy  
**Primary pattern:** Binary search / first-true boundary  
**LeetCode:** https://leetcode.com/problems/first-bad-version/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

There are versions numbered `1` through `n`. At some unknown version, a defect appears. Every version after that is also bad.

```text
good good good bad bad bad
  1    2    3   4   5   6
                 ↑
            first bad version
```

You can call an external API:

```javascript
isBadVersion(version)
```

It returns `true` when that version is bad. Return the **first** bad version while minimizing API calls.

The search space is monotonic:

```text
false false false true true true
```

---

## 2. How this differs from ordinary binary search

Ordinary exact-match binary search can stop when it finds the target.

Here, finding a bad version is not enough:

```text
version 8 is bad
```

Version 8 might be the first bad version, or the transition may have happened earlier. A bad version is only a **candidate answer**.

Therefore:

```text
good middle → first bad must be to the right
bad middle  → middle may be first; keep it and search left
```

Boundary binary search continues after finding a valid candidate.

---

## 3. Linear approach

Check versions from `1` upward and return the first bad one.

```javascript
function firstBadVersionLinear(isBadVersion) {
  return function findFirstBad(n) {
    for (let version = 1; version <= n; version++) {
      if (isBadVersion(version)) {
        return version;
      }
    }

    return -1;
  };
}
```

- Time/API calls: **O(n)** worst case.
- Extra space: **O(1)**.

Because the predicate is monotonic, binary search reduces the API calls to O(log n).

---

## 4. Search-space convention

Use an inclusive interval:

```text
[left, right]
```

We maintain a stronger invariant than exact-match search:

> The first bad version is always inside `[left, right]`.

Initialize:

```text
left = 1
right = n
```

The problem guarantees at least one bad version, so `n` is a valid upper boundary.

We continue while:

```text
left < right
```

When the interval collapses to one version, that version is the first bad one.

---

## 5. Why the updates are asymmetric

### Middle is good

```javascript
left = middle + 1;
```

If `middle` is good, every earlier version is also good. Neither `middle` nor anything left of it can be the answer.

### Middle is bad

```javascript
right = middle;
```

If `middle` is bad, it might be the first bad version. We must keep it in the candidate interval while discarding only versions after it.

This is the most important line in the problem:

> For a valid candidate, keep `middle`; for an invalid candidate, move past it.

---

## 6. Optimal JavaScript solution

LeetCode supplies the function in this wrapper form:

```javascript
function solution(isBadVersion) {
  return function firstBadVersion(n) {
    let left = 1;
    let right = n;

    while (left < right) {
      const middle =
        left + Math.floor((right - left) / 2);

      if (isBadVersion(middle)) {
        // Middle is a candidate, but an earlier bad version may exist.
        right = middle;
      } else {
        // Middle is good, so the boundary must be strictly to its right.
        left = middle + 1;
      }
    }

    return left;
  };
}
```

---

## 7. Dry run

```text
n = 10
first bad = 6
```

| Iteration | Interval | Middle | API result | New interval |
|---:|---|---:|---|---|
| 1 | `[1, 10]` | 5 | good | `[6, 10]` |
| 2 | `[6, 10]` | 8 | bad | `[6, 8]` |
| 3 | `[6, 8]` | 7 | bad | `[6, 7]` |
| 4 | `[6, 7]` | 6 | bad | `[6, 6]` |

Now `left === right === 6`, so return `6`.

Notice that bad versions `8` and `7` were retained temporarily as candidates, then replaced by earlier bad candidates.

---

## 8. Code walkthrough

### `left = 1`

Versions are one-indexed. Starting from zero would call the API with an invalid version.

### `while (left < right)`

The loop searches for a boundary, not an exact value. When one candidate remains, the invariant proves it is the answer; it does not need another comparison.

### Midpoint formula

```javascript
left + Math.floor((right - left) / 2)
```

This portable form avoids overflow in fixed-width integer languages. Avoid JavaScript bitwise midpoint shortcuts because bitwise operations coerce numbers to signed 32-bit integers.

### One API call per iteration

Store or directly branch on the result once. Repeatedly calling an expensive external predicate for the same midpoint wastes the resource the problem explicitly asks us to minimize.

### `return left`

At termination, `left === right`, and the invariant says the first bad version is inside this one-element interval.

---

## 9. Correctness reasoning

Invariant:

> The first bad version lies within the inclusive interval `[left, right]`.

Initially, the guarantee that a bad version exists places the first bad version somewhere in `[1, n]`.

- If `middle` is good, monotonicity proves all versions through `middle` are good, so setting `left = middle + 1` preserves the answer.
- If `middle` is bad, the first bad version is at `middle` or earlier, so setting `right = middle` preserves the answer.

Each iteration strictly shrinks the interval. When `left === right`, the invariant leaves that one version as the first bad version. Therefore, returning `left` is correct.

---

## 10. Why the loop cannot get stuck

The midpoint uses the lower middle:

```text
middle = floor((left + right) / 2)
```

When `left < right`, this guarantees:

```text
left <= middle < right
```

Therefore:

- `right = middle` makes `right` smaller;
- `left = middle + 1` makes `left` larger.

The interval shrinks every iteration.

If using an upper midpoint in another boundary template, update rules must be reconsidered to preserve progress.

---

## 11. Complexity

- **Time/API calls: O(log n)** — each call eliminates roughly half the remaining versions.
- **Auxiliary space: O(1)** — only boundary variables are stored.

The API-call count is the meaningful cost here. Binary search reduces up to `n` calls to roughly `log₂(n)` calls.

For example:

```text
n ≈ 1,000,000
linear scan: up to 1,000,000 calls
binary search: about 20 calls
```

---

## 12. Alternative template with saved answer

You can also use the exact-search-style loop and record each bad candidate:

```javascript
function solutionWithAnswer(isBadVersion) {
  return function firstBadVersion(n) {
    let left = 1;
    let right = n;
    let answer = n;

    while (left <= right) {
      const middle =
        left + Math.floor((right - left) / 2);

      if (isBadVersion(middle)) {
        answer = middle;
        right = middle - 1;
      } else {
        left = middle + 1;
      }
    }

    return answer;
  };
}
```

This is correct, but it requires an additional `answer` variable. The converging-boundaries template directly represents the answer in the search interval and is especially useful for first-true/last-false problems.

---

## 13. General first-true template

For a monotonic predicate:

```text
false false false true true true
```

The reusable template is:

```javascript
function firstTrue(left, right, predicate) {
  while (left < right) {
    const middle =
      left + Math.floor((right - left) / 2);

    if (predicate(middle)) {
      right = middle;
    } else {
      left = middle + 1;
    }
  }

  return left;
}
```

This assumes the answer exists inside the initial interval. If existence is not guaranteed, include a sentinel boundary or verify the returned candidate afterward.

---

## 14. Common mistakes

1. **Returning immediately when a bad version is found.** It may not be the first bad version.
2. **Using `right = middle - 1` without storing the candidate.** This can discard the actual answer.
3. **Using `left = middle` after a good result.** A two-element interval can stop shrinking.
4. **Starting at version zero.** Valid versions begin at one.
5. **Mixing `left < right` with exact-match updates.** Choose a coherent boundary template.
6. **Calling `isBadVersion(middle)` multiple times per iteration.** Minimize external API calls.
7. **Assuming any boolean predicate is searchable.** It must be monotonic: all false values before all true values.
8. **Using a bitwise midpoint in JavaScript.** It forces signed 32-bit number conversion.
9. **Forgetting the existence assumption.** The official problem guarantees a bad version; generic first-true search may not.

---

## 15. What to say in an interview

> “The predicate is monotonic: versions are good up to a boundary and bad afterward. I’ll binary-search for the first true value. If the middle version is bad, it remains a candidate, so I move `right` to `middle`. If it is good, I can discard it and everything before it using `left = middle + 1`. When the boundaries meet, that version is the first bad one. This uses O(log n) API calls and O(1) space.”

If asked why a bad middle is retained:

> “Unlike exact search, finding true does not prove it is the first true; the boundary may be earlier.”

---

## 16. Pattern recognition

Think **first-true binary search** when:

- a predicate changes only once;
- candidates transition from invalid to valid;
- you need the earliest valid point;
- checking one candidate tells you which side contains the boundary.

Examples:

- first bad deployment/version;
- first timestamp meeting a condition;
- minimum capacity sufficient to finish work;
- minimum speed meeting a deadline;
- first element greater than or equal to a target;
- smallest feasible answer.

Memory cue:

> False is discarded; true is retained and challenged from the left.

---

## 17. Exact search versus boundary search

| Question | Exact binary search | First-true boundary search |
|---|---|---|
| Stop on match/true? | Yes | No |
| Meaning of true | Answer found | Candidate found |
| True update | return | `right = middle` |
| Main goal | locate any target | locate transition boundary |
| Typical loop | `left <= right` | `left < right` |

These are templates, not universal laws. What matters is the invariant and progress proof behind the chosen boundaries.

---

## 18. Edge cases

| `n` | First bad | Result | Notes |
|---:|---:|---:|---|
| 1 | 1 | 1 | Loop does not run |
| 2 | 1 | 1 | Middle/left is already bad |
| 2 | 2 | 2 | Version 1 discarded as good |
| 10 | 1 | 1 | All versions bad |
| 10 | 10 | 10 | Only final version bad |

One- and two-element intervals are the best tests for boundary-update bugs.

---

## 19. Notebook-ready notes

### 📚 Concept

**First Bad Version — first true boundary search**

```text
Pattern: false false false true true
Range: [1, n]
while left < right:
  middle = lower midpoint
  bad/true  → right = middle      (keep candidate)
  good/false→ left = middle + 1   (discard)
return left
```

### 🧠 My understanding

A bad midpoint may be the first bad version, so I cannot discard it; I keep it as the right boundary and search earlier. A good midpoint can never be the answer, and monotonicity rules out everything before it. The boundaries converge on the transition.

### 💼 Interview line

> “I’m not searching for any bad version; I’m searching for the false-to-true boundary.”

### ⚠️ Traps

- Do not return on the first `true`.
- Keep a bad midpoint with `right = middle`.
- Move past a good midpoint with `left = middle + 1`.
- The predicate must be monotonic.

---

## 20. Dheerix Glance

```text
FIRST BAD VERSION

Predicate shape: false false false true true
Goal:            first true
Interval:        [left, right], answer always inside
Initialize:      [1, n]
Loop:            left < right
Bad/true:        right = middle
Good/false:      left = middle + 1
Return:          left (same as right)
API calls:       O(log n)
Space:           O(1)
Memory cue:      “Keep true; discard false.”
```

---

## 21. Recall test

Without looking back:

1. What makes the predicate binary-searchable?
2. Why can we not return upon finding a bad version?
3. What does the interval invariant say?
4. Why does a bad midpoint use `right = middle` rather than `middle - 1`?
5. Why does a good midpoint use `left = middle + 1`?
6. Why does the loop stop at `left === right`?
7. What are the API-call and space complexities?
8. How does boundary search differ from exact search?

