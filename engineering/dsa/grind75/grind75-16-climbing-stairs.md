# Grind 75 — 16: Climbing Stairs

**Difficulty:** Easy  
**Primary pattern:** Dynamic programming / Fibonacci recurrence  
**LeetCode:** https://leetcode.com/problems/climbing-stairs/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

You are climbing a staircase with `n` steps. Each move can climb either:

- one step; or
- two steps.

Return the number of distinct sequences of moves that reach exactly step `n`.

```text
n = 3

1 + 1 + 1
1 + 2
2 + 1

answer = 3
```

Order matters: `1 + 2` and `2 + 1` are different ways.

---

## 2. Start from the final move

To reach step `n`, the last move must be one of only two possibilities:

```text
1-step move from step n - 1
2-step move from step n - 2
```

These two sets of paths do not overlap because their final moves differ. Therefore:

```text
ways(n) = ways(n - 1) + ways(n - 2)
```

This is the Fibonacci recurrence.

The important skill is not recognizing the word “Fibonacci.” It is deriving the recurrence by asking:

> What are the mutually exclusive ways the final state can be reached?

---

## 3. Define the dynamic-programming state

Let:

```text
dp[i] = number of distinct ways to reach exactly step i
```

Transition:

```text
dp[i] = dp[i - 1] + dp[i - 2]
```

Base cases:

```text
dp[1] = 1  → [1]
dp[2] = 2  → [1+1], [2]
```

Under the official constraint `n >= 1`, these are sufficient.

An alternative mathematical convention uses:

```text
dp[0] = 1
```

There is one way to climb zero remaining steps: do nothing. Then the recurrence produces `dp[1] = 1` and `dp[2] = 2` naturally. Both conventions are correct when used consistently.

---

## 4. Brute-force recursion

The recurrence can be translated directly:

```javascript
function climbStairsRecursive(n) {
  if (n <= 2) return n;

  return (
    climbStairsRecursive(n - 1) +
    climbStairsRecursive(n - 2)
  );
}
```

### Why is it inefficient?

It recomputes the same subproblems repeatedly:

```text
ways(5)
├── ways(4)
│   ├── ways(3)
│   └── ways(2)
└── ways(3)  ← calculated again
```

Time is exponential, approximately O(2^n). Call-stack space is O(n).

This exposes the two classic dynamic-programming signals:

- **overlapping subproblems**: `ways(3)` is needed multiple times;
- **optimal/structural recurrence**: larger answers combine smaller answers.

---

## 5. Memoized recursion

Cache every computed result:

```javascript
function climbStairsMemoized(n) {
  const memo = new Map([
    [1, 1],
    [2, 2],
  ]);

  function ways(steps) {
    if (memo.has(steps)) {
      return memo.get(steps);
    }

    const result = ways(steps - 1) + ways(steps - 2);
    memo.set(steps, result);
    return result;
  }

  return ways(n);
}
```

- Time: **O(n)** — each state is computed once.
- Extra space: **O(n)** for the cache and recursion stack.

This is top-down dynamic programming.

---

## 6. Bottom-up tabulation

Compute smaller answers before larger ones:

```javascript
function climbStairsTable(n) {
  if (n <= 2) return n;

  const dp = new Array(n + 1).fill(0);
  dp[1] = 1;
  dp[2] = 2;

  for (let step = 3; step <= n; step++) {
    dp[step] = dp[step - 1] + dp[step - 2];
  }

  return dp[n];
}
```

- Time: **O(n)**.
- Extra space: **O(n)**.

This is bottom-up dynamic programming. It removes recursion, but the full array is unnecessary because each state depends on only the previous two states.

---

## 7. Space optimization

At step `i`, we need only:

```text
ways for i - 2
ways for i - 1
```

Older states will never be read again. Replace the DP array with two variables.

---

## 8. Optimal JavaScript solution

```javascript
function climbStairs(n) {
  if (n <= 2) {
    return n;
  }

  let twoStepsBefore = 1;
  let oneStepBefore = 2;

  for (let currentStep = 3; currentStep <= n; currentStep++) {
    const currentWays = oneStepBefore + twoStepsBefore;

    twoStepsBefore = oneStepBefore;
    oneStepBefore = currentWays;
  }

  return oneStepBefore;
}
```

---

## 9. Dry run

```text
n = 5
```

Initial state:

```text
ways(1) = 1
ways(2) = 2
```

| Current step | Two before | One before | Current ways |
|---:|---:|---:|---:|
| 3 | 1 | 2 | 3 |
| 4 | 2 | 3 | 5 |
| 5 | 3 | 5 | 8 |

Return `8`.

The variable updates slide the two-state window forward:

```text
(ways(i-2), ways(i-1))
       ↓ update
(ways(i-1), ways(i))
```

---

## 10. Code walkthrough

### Base cases

```javascript
if (n <= 2) return n;
```

For one step, there is one way. For two steps, there are two ways. Returning early also ensures the iterative state starts at a valid step three.

### Variable meaning

Before calculating `currentStep`:

```text
twoStepsBefore = ways(currentStep - 2)
oneStepBefore  = ways(currentStep - 1)
```

Clear names matter more than short names such as `a` and `b` when explaining state transitions.

### Update order

Calculate `currentWays` before overwriting either previous value. Then shift:

```text
old oneStepBefore → new twoStepsBefore
currentWays       → new oneStepBefore
```

Updating variables in the wrong order can lose a value still needed for the sum.

### Return value

After the final iteration, `oneStepBefore` holds `ways(n)`.

---

## 11. Correctness reasoning

Loop invariant:

> Before the iteration for step `i`, `twoStepsBefore` equals the number of ways to reach `i - 2`, and `oneStepBefore` equals the number of ways to reach `i - 1`.

Every path to step `i` ends with either a one-step move from `i - 1` or a two-step move from `i - 2`. These cases are exhaustive and disjoint, so their counts add. The update then establishes the invariant for step `i + 1`.

The base values make the invariant true before step three. Therefore, after processing step `n`, the returned value is exactly the number of distinct ways to reach it.

---

## 12. Complexity

Optimal iterative solution:

- **Time: O(n)** — each step from 3 through `n` is processed once.
- **Auxiliary space: O(1)** — only three numeric variables are used.

Comparison:

| Approach | Time | Extra space |
|---|---:|---:|
| Naive recursion | O(2^n) | O(n) stack |
| Memoization | O(n) | O(n) |
| DP table | O(n) | O(n) |
| Rolling variables | O(n) | O(1) |

---

## 13. Why this is dynamic programming

Dynamic programming usually involves:

1. defining a state;
2. expressing that state using smaller states;
3. identifying base cases;
4. ensuring each state is computed once;
5. choosing storage appropriate to the dependency range.

For this problem:

```text
State:      dp[i] = ways to reach step i
Transition: dp[i] = dp[i-1] + dp[i-2]
Base:       dp[1] = 1, dp[2] = 2
Order:      increasing i
Storage:    previous two values only
```

The code is short because the state and dependency are simple—not because the DP reasoning is absent.

---

## 14. Common mistakes

1. **Counting combinations instead of sequences.** `1+2` and `2+1` are different paths.
2. **Using `ways(n) = ways(n-1) + ways(n-2)` without base cases.** Recursion will not terminate correctly.
3. **Leaving naive recursion exponential.** Overlapping subproblems require caching or iteration.
4. **Starting the loop at the wrong step.** With states for steps one and two initialized, begin at three.
5. **Updating rolling variables in the wrong order.** Save the sum before shifting.
6. **Allocating a full DP array unnecessarily.** Only two previous states are required.
7. **Calling the optimized solution O(n) space.** It uses constant storage.
8. **Returning the wrong rolling variable.** After the loop, `oneStepBefore` represents the current/final step.
9. **Confusing this with minimum steps.** The question asks for the number of distinct ways.

---

## 15. What to say in an interview

> “Every valid path to step `i` ends either with a one-step move from `i - 1` or a two-step move from `i - 2`. Those cases are disjoint, so `ways(i) = ways(i - 1) + ways(i - 2)`, with base cases one and two. Naive recursion repeats states exponentially, so I’ll compute bottom-up. Since each state needs only the previous two, I can use rolling variables for O(n) time and O(1) space.”

If asked how you recognized DP:

> “The result decomposes into overlapping smaller states, and the same `ways(i)` value is reused by later states.”

---

## 16. Pattern recognition

Think **one-dimensional DP** when:

- the answer for position `i` depends on a small number of earlier positions;
- the problem counts ways, minimizes cost, or maximizes value over sequential choices;
- naive recursion branches and repeats the same state;
- state can be expressed using a prefix or remaining amount.

Think **rolling-state optimization** when:

- the transition reads only the most recent `k` states;
- older DP entries will never be used again.

Memory cue:

> Count the possible final moves, then add the ways that reach their starting points.

---

## 17. Follow-up: allowed jumps change

If allowed moves are `1`, `2`, or `3` steps:

```text
ways(i) = ways(i-1) + ways(i-2) + ways(i-3)
```

For an arbitrary set of allowed jumps:

```text
ways(i) = sum(ways(i - jump)) for every valid allowed jump
```

The same DP design remains:

- define what `dp[i]` means;
- enumerate the possible final moves;
- combine their predecessor states.

The required rolling-memory size becomes the largest dependency distance, if practical.

---

## 18. Edge cases

| `n` | Ways | Sequences |
|---:|---:|---|
| 1 | 1 | `1` |
| 2 | 2 | `1+1`, `2` |
| 3 | 3 | `1+1+1`, `1+2`, `2+1` |
| 4 | 5 | recurrence gives `3 + 2` |
| 5 | 8 | recurrence gives `5 + 3` |

The official constraints begin at `n = 1`. If a broader contract includes `n = 0`, define whether “doing nothing” counts as one way. Standard combinatorial DP usually uses `ways(0) = 1`.

---

## 19. Notebook-ready notes

### 📚 Concept

**Climbing Stairs — 1D DP / Fibonacci**

```text
State:      ways(i) = number of ways to reach step i
Transition: ways(i) = ways(i-1) + ways(i-2)
Base:       ways(1)=1, ways(2)=2
Optimize:   retain only previous two states
```

### 🧠 My understanding

Every path to a step has a unique final move: either one step from the previous stair or two steps from two stairs below. Adding those two disjoint path counts gives the recurrence. Since later states only need the last two results, a full DP table is unnecessary.

### 💼 Interview line

> “I’ll partition all paths by their final move and compute the resulting recurrence bottom-up.”

### ⚠️ Traps

- Order of moves creates distinct paths.
- Naive recursion repeats work exponentially.
- Initialize base cases consistently.
- Compute the new value before shifting rolling state.

---

## 20. Dheerix Glance

```text
CLIMBING STAIRS

State:            ways to reach step i
Final choices:    from i-1 using 1; from i-2 using 2
Recurrence:       ways(i)=ways(i-1)+ways(i-2)
Base:             1→1, 2→2
Pattern:          Fibonacci / 1D DP
Optimization:     rolling two states
Time:             O(n)
Auxiliary space:  O(1)
Memory cue:       “Ways in = ways from one back + two back.”
```

---

## 21. Recall test

Without looking back:

1. What exactly does the DP state represent?
2. How is the recurrence derived from the final move?
3. Why are the two predecessor groups disjoint?
4. Why is naive recursion exponential?
5. What makes memoization O(n)?
6. Why can the DP table be reduced to two variables?
7. What is the rolling-state invariant?
8. How would the recurrence change if jumps of size three were also allowed?

