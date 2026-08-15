# Grind 75 — 36: Coin Change

**Difficulty:** Medium  
**Primary pattern:** One-dimensional dynamic programming / unbounded choices  
**LeetCode:** https://leetcode.com/problems/coin-change/  
**Target time:** 25 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given coin denominations and a target amount, return the minimum number of coins needed to form the amount.

Each denomination can be used any number of times.

```text
coins = [1, 2, 5]
amount = 11

5 + 5 + 1 → 3 coins
answer = 3
```

If the amount cannot be formed, return `-1`.

```text
coins = [2]
amount = 3
answer = -1
```

For amount zero, return zero coins.

---

## 2. Why greedy is not generally correct

A tempting strategy repeatedly chooses the largest coin not exceeding the remaining amount.

Counterexample:

```text
coins = [1, 3, 4]
amount = 6
```

Greedy:

```text
4 + 1 + 1 = 3 coins
```

Optimal:

```text
3 + 3 = 2 coins
```

Some currency systems support greedy change, but arbitrary denominations do not. We must compare alternatives systematically.

---

## 3. Define the DP state

Let:

```text
dp[a] = minimum number of coins needed to form amount a
```

Base case:

```text
dp[0] = 0
```

There is one valid way to form zero amount for this minimum-count problem: use zero coins.

---

## 4. Derive the transition from the final coin

Suppose the final coin used to form amount `a` has value `coin`.

Before adding it, we must have formed:

```text
a - coin
```

If that remainder is reachable, the candidate count is:

```text
dp[a - coin] + 1
```

Try every denomination:

```text
dp[a] = min(
  dp[a - coin] + 1
  for every coin <= a
)
```

The final-coin choices cover every possible solution.

---

## 5. Representing unreachable states

Initialize amounts to an impossible upper bound:

```javascript
new Array(amount + 1).fill(amount + 1)
```

Why is `amount + 1` impossible? If denomination `1` exists, no valid minimum uses more than `amount` coins. If `1` does not exist, any valid solution still uses at most `amount` positive-value coins.

Therefore, `amount + 1` safely means:

```text
not reached yet
```

Using zero as the default would be incorrect because zero is a real answer only for amount zero.

`Infinity` is another valid sentinel.

---

## 6. Optimal bottom-up JavaScript solution

```javascript
function coinChange(coins, amount) {
  const unreachable = amount + 1;
  const dp = new Array(amount + 1).fill(unreachable);
  dp[0] = 0;

  for (let currentAmount = 1;
    currentAmount <= amount;
    currentAmount++) {
    for (const coin of coins) {
      if (coin <= currentAmount) {
        dp[currentAmount] = Math.min(
          dp[currentAmount],
          dp[currentAmount - coin] + 1,
        );
      }
    }
  }

  return dp[amount] === unreachable
    ? -1
    : dp[amount];
}
```

---

## 7. Dry run

```text
coins = [1, 2, 5]
amount = 6
```

Initialize:

```text
dp = [0, 7, 7, 7, 7, 7, 7]
```

| Amount | Best construction | `dp[amount]` |
|---:|---|---:|
| 1 | 1 | 1 |
| 2 | 2 | 1 |
| 3 | 2 + 1 | 2 |
| 4 | 2 + 2 | 2 |
| 5 | 5 | 1 |
| 6 | 5 + 1 | 2 |

Final:

```text
dp = [0, 1, 1, 2, 2, 1, 2]
```

Return `2`.

---

## 8. Detailed transition example

For current amount `6`:

```text
using coin 1: dp[5] + 1 = 1 + 1 = 2
using coin 2: dp[4] + 1 = 2 + 1 = 3
using coin 5: dp[1] + 1 = 1 + 1 = 2
```

Take the minimum:

```text
dp[6] = 2
```

We do not need to know the order in which the earlier coins were chosen, only their minimum count.

---

## 9. Why increasing amount order works

To compute `dp[currentAmount]`, every dependency has index:

```text
currentAmount - coin < currentAmount
```

Those smaller amounts have already been computed in an ascending loop.

This is bottom-up dynamic programming: solve dependencies before dependent states.

Because a coin can be used repeatedly, a state may build on another state that already used the same denomination. Nothing removes a coin from availability.

---

## 10. Code walkthrough

### DP array size

Indices `0...amount` represent every subamount needed to build the target.

### Base case

`dp[0] = 0` anchors transitions such as:

```text
dp[coin] = dp[0] + 1 = 1
```

### Coin eligibility

Only use a coin when `coin <= currentAmount`; otherwise the remainder index would be negative.

### Unreachable remainder

With the `amount + 1` sentinel, adding one to an unreachable state gives `amount + 2`, which cannot improve the current sentinel. Thus an explicit reachability check is not required.

With `Infinity`, `Infinity + 1` remains `Infinity` for the same effect.

### Final conversion

If the target remains at the sentinel, no sequence of coins reached it, so return `-1`.

---

## 11. Correctness reasoning

Inductive invariant:

> After computing amount `a`, `dp[a]` is the minimum coin count among all combinations that form `a`, or the sentinel if none exists.

The base `dp[0] = 0` is correct. For amount `a`, every valid combination has some final coin `c`, leaving a valid combination for `a-c`. By induction, `dp[a-c]` is the minimum count for that remainder, so `dp[a-c] + 1` is the best solution ending with `c`.

The algorithm considers every eligible final denomination and takes the minimum, covering every possible solution. If no predecessor is reachable, the sentinel remains. Therefore the final state is correct.

---

## 12. Complexity

Let:

```text
A = amount
C = number of coin denominations
```

- **Time: O(A × C)** — for every amount, inspect every denomination.
- **Extra space: O(A)** — one DP entry per subamount.

This is pseudo-polynomial: complexity depends on the numeric value of `amount`, not merely the number of bits needed to represent it.

---

## 13. Top-down memoized alternative

```javascript
function coinChangeMemoized(coins, amount) {
  const memo = new Map([[0, 0]]);

  function minimumCoins(remaining) {
    if (remaining < 0) return Infinity;
    if (memo.has(remaining)) return memo.get(remaining);

    let best = Infinity;

    for (const coin of coins) {
      best = Math.min(
        best,
        minimumCoins(remaining - coin) + 1,
      );
    }

    memo.set(remaining, best);
    return best;
  }

  const answer = minimumCoins(amount);
  return answer === Infinity ? -1 : answer;
}
```

- Time: **O(A × C)** after memoization.
- Extra space: **O(A)** for memo plus O(A) worst-case recursion stack.

Without memoization, recursion branches exponentially and repeats the same remaining amounts.

Bottom-up is usually preferable in JavaScript because it avoids deep recursion.

---

## 14. Loop-order note

Another bottom-up form loops through coins first:

```javascript
function coinChangeCoinsFirst(coins, amount) {
  const dp = new Array(amount + 1).fill(Infinity);
  dp[0] = 0;

  for (const coin of coins) {
    for (let current = coin;
      current <= amount;
      current++) {
      dp[current] = Math.min(
        dp[current],
        dp[current - coin] + 1,
      );
    }
  }

  return dp[amount] === Infinity ? -1 : dp[amount];
}
```

For minimum coin count with unlimited reuse, both loop orders work. In counting variants, loop order can change whether permutations or combinations are counted, so it should never be treated as universally interchangeable.

---

## 15. BFS interpretation

Amounts can be viewed as graph nodes. From amount `x`, adding a coin creates an edge to `x + coin`. Every edge represents using one coin.

Then the answer is the shortest number of edges from zero to the target. BFS can solve it because every coin use has equal cost.

Dynamic programming is usually more compact and avoids queue/visited overhead, but the graph view reinforces why minimum coin count resembles an unweighted shortest-path problem.

---

## 16. Common mistakes

1. **Using greedy largest-coin-first for arbitrary denominations.** `[1,3,4]`, amount `6` disproves it.
2. **Initializing every DP entry to zero.** Unreachable states become indistinguishable from the zero-amount answer.
3. **Forgetting `dp[0] = 0`.** Exact coin values cannot build from a valid base.
4. **Accessing `dp[currentAmount - coin]` when coin is larger.** The index becomes negative.
5. **Returning the sentinel instead of `-1`.** Convert unreachable target state at the end.
6. **Returning a number of combinations.** This problem asks for minimum coin count.
7. **Using naive recursion without memoization.** Repeated subproblems cause exponential time.
8. **Claiming O(C^A) for the memoized/bottom-up solution.** Each of A states checks C coins once.
9. **Calling O(A×C) polynomial in input bit length.** It is pseudo-polynomial in numeric amount.
10. **Assuming loop order never matters across coin-change variants.** Counting problems differ.

---

## 17. What to say in an interview

> “Greedy is not safe for arbitrary denominations, so I’ll use dynamic programming. Let `dp[a]` be the minimum coins needed for amount `a`, with `dp[0]=0`. For each amount, I try every possible final coin and update from `dp[a-coin]+1`. Unreachable states start at `amount+1`. Computing amounts in increasing order makes all dependencies available. Complexity is O(amount × numberOfCoins) time and O(amount) space.”

If asked why the recurrence is complete:

> “Every valid solution has some final coin, and I explicitly evaluate every denomination as that final choice.”

---

## 18. Pattern recognition

Think **unbounded one-dimensional DP** when:

- a target amount/capacity is built from reusable choices;
- the question minimizes or maximizes the number/cost of choices;
- state depends on smaller numeric states;
- greedy choices have counterexamples.

DP design checklist:

```text
state:      best answer for amount a
base:       amount zero
transition: try one final choice
invalid:    explicit sentinel
order:      dependencies before current state
```

Memory cue:

> Choose the final coin; reuse the best remainder.

---

## 19. Edge cases

| Coins | Amount | Result | Reason |
|---|---:|---:|---|
| `[1]` | 0 | 0 | No coins needed |
| `[1]` | 3 | 3 | Three ones |
| `[2]` | 3 | -1 | Unreachable |
| `[2]` | 4 | 2 | Two twos |
| `[1,3,4]` | 6 | 2 | Greedy counterexample |
| coin equals amount | amount | 1 | Direct transition from zero |
| amount smaller than all coins | amount | -1 | No eligible transition |

---

## 20. Notebook-ready notes

### 📚 Concept

**Coin Change — minimum-count DP**

```text
dp[a] = minimum coins to form amount a
dp[0] = 0
others = amount + 1 / Infinity

for amount a:
  for coin <= a:
    dp[a] = min(dp[a], dp[a-coin] + 1)

unreachable target → -1
```

### 🧠 My understanding

Every solution for an amount ends with some denomination. Removing that final coin leaves a smaller amount whose best solution I already know. I try every possible final coin and keep the smallest count. A sentinel separates unreachable states from the valid zero-coin base.

### 💼 Interview line

> “I’ll try every denomination as the final coin and reuse the minimum solution for the remainder.”

### ⚠️ Traps

- Greedy is not generally valid.
- Zero is valid only for `dp[0]`.
- Check `coin <= currentAmount`.
- Return `-1` for an untouched sentinel.

---

## 21. Dheerix Glance

```text
COIN CHANGE

State:            dp[a] = minimum coins for a
Base:             dp[0] = 0
Unreachable:      amount+1 or Infinity
Choice:           final coin
Transition:       dp[a]=min(dp[a], dp[a-coin]+1)
Coin reuse:       unlimited
Order:            increasing amounts
Time:             O(amount × coins)
Space:            O(amount)
Memory cue:       “Final coin + best remainder.”
```

---

## 22. Recall test

Without looking back:

1. What counterexample disproves greedy selection?
2. What exactly does `dp[a]` represent?
3. How is the recurrence derived from the final coin?
4. Why is `dp[0] = 0` required?
5. Why is zero a bad default for other states?
6. Why is `amount + 1` a safe sentinel?
7. What are the time and space complexities?
8. Why is the runtime called pseudo-polynomial?
9. How does memoization change naive recursion?

