# Grind 75 — 04: Best Time to Buy and Sell Stock

**Difficulty:** Easy  
**Primary pattern:** One pass / running minimum / greedy  
**LeetCode:** https://leetcode.com/problems/best-time-to-buy-and-sell-stock/  
**Target time:** 20 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

`prices[i]` is a stock price on day `i`. Choose exactly one day to buy and a **later** day to sell. Return the largest possible profit. If no profitable transaction exists, return `0`.

```text
prices = [7, 1, 5, 3, 6, 4]

Buy at 1 on day 1
Sell at 6 on day 4
Profit = 6 - 1 = 5
```

You cannot sell before buying, and only one buy-sell transaction is allowed.

---

## 2. Translate the problem into an equation

For a selling day `j`, profit is:

```text
profit = prices[j] - prices[i], where i < j
```

If today is the selling day, the best possible buying price is therefore:

```text
minimum price from an earlier day
```

This changes the question from:

> Which pair of days should I try?

to:

> If I sell today, what is the cheapest valid price I could have bought at earlier?

---

## 3. Brute-force approach

Try every buy day with every later sell day.

```javascript
function maxProfitBruteForce(prices) {
  let bestProfit = 0;

  for (let buyDay = 0; buyDay < prices.length; buyDay++) {
    for (let sellDay = buyDay + 1; sellDay < prices.length; sellDay++) {
      const profit = prices[sellDay] - prices[buyDay];
      bestProfit = Math.max(bestProfit, profit);
    }
  }

  return bestProfit;
}
```

### Complexity

- Time: **O(n²)** — checks every valid pair of days.
- Extra space: **O(1)**.

### Repeated work

For each selling day, brute force scans many earlier days again to find a good buying price. We can carry the cheapest earlier price forward instead.

---

## 4. Optimal insight: evaluate every day as a selling day

Scan from left to right while maintaining:

```text
minimumPrice = cheapest price seen so far
bestProfit   = largest valid profit seen so far
```

For each price:

1. calculate the profit if we sell today after buying at `minimumPrice`;
2. update `bestProfit`;
3. update `minimumPrice` for future days.

The scan direction automatically enforces time order: `minimumPrice` comes only from the current day or an earlier day, never from the future.

---

## 5. Dry run

```text
prices = [7, 1, 5, 3, 6, 4]
```

| Day | Price | Minimum so far | Profit if sold today | Best profit |
|---:|---:|---:|---:|---:|
| 0 | 7 | 7 | 0 | 0 |
| 1 | 1 | 1 | 0 | 0 |
| 2 | 5 | 1 | 4 | 4 |
| 3 | 3 | 1 | 2 | 4 |
| 4 | 6 | 1 | 5 | 5 |
| 5 | 4 | 1 | 3 | 5 |

Answer: `5`.

The algorithm does not need to remember the actual transaction unless the interviewer asks for the days. It only preserves the information required for the maximum profit.

---

## 6. Optimal JavaScript solution

```javascript
function maxProfit(prices) {
  let minimumPrice = Infinity;
  let bestProfit = 0;

  for (const currentPrice of prices) {
    // Treat today as the selling day, using the cheapest price seen so far.
    const profitIfSoldToday = currentPrice - minimumPrice;
    bestProfit = Math.max(bestProfit, profitIfSoldToday);

    // Today may become the best buying day for a future sale.
    minimumPrice = Math.min(minimumPrice, currentPrice);
  }

  return bestProfit;
}
```

---

## 7. Code walkthrough

### `let minimumPrice = Infinity`

Any actual price will be smaller than `Infinity`, so the first price safely becomes the minimum. This also makes an empty array return `0` without special handling.

### `let bestProfit = 0`

Returning `0` means “make no transaction” when every possible transaction loses money.

### `const profitIfSoldToday = currentPrice - minimumPrice`

For the current selling day, the cheapest price seen so far produces the maximum valid profit.

On the first iteration this computes `price - Infinity`, which is `-Infinity`; `bestProfit` remains `0`. The minimum is then initialized to the first price.

### Update profit before the minimum

This ordering makes the explanation precise: today is evaluated as a selling day using historical information, then it becomes a possible buying day for the future.

Updating the minimum first also produces the same final profit for this problem because buying and selling on the same day yields `0`, but the “evaluate, then incorporate” ordering preserves the cleaner invariant that buying must be earlier.

---

## 8. Correctness reasoning

Invariant after processing day `i`:

1. `minimumPrice` is the smallest price among days `0...i`.
2. `bestProfit` is the largest valid profit from any buy-sell pair entirely within days `0...i`, or `0` if none is profitable.

When processing a new day, any newly optimal transaction must sell on that day. Its best buy price is the minimum from previous days, which we have retained. Comparing that profit with the previous best therefore covers every possible transaction. Updating the minimum prepares the invariant for the next day.

---

## 9. Complexity

- **Time: O(n)** — each price is processed once.
- **Extra space: O(1)** — only two running values are maintained.

This is a true O(1)-space optimization, unlike Two Sum, because no data structure grows with the input.

---

## 10. Common mistakes

1. **Using the global minimum and global maximum without respecting order.** The maximum price may occur before the minimum price.
2. **Allowing selling before buying.** Left-to-right scanning prevents this naturally.
3. **Returning a negative profit.** The required result is `0` when no profitable trade exists.
4. **Looking for the largest adjacent rise.** The best transaction may span several days.
5. **Resetting the minimum after finding a profit.** Keep the cheapest historical price until an even cheaper one appears.
6. **Summing every upward movement.** That solves the multiple-transactions variant, not this one.
7. **Calling this O(n) space.** Only constant state is stored, so auxiliary space is O(1).

Critical counterexample for global min/max:

```text
[9, 10, 1, 5]

Global max - global min = 10 - 1 = 9, but that sells before buying.
Valid best profit = 5 - 1 = 4.
```

---

## 11. What to say in an interview

> “The brute-force solution checks every earlier buy day for every sell day, which is O(n²). While scanning left to right, I only need the cheapest valid buying price seen before the current day. I’ll treat each current price as a potential selling price, calculate its profit against that running minimum, and retain the best profit. Then I update the minimum for future days. This is O(n) time and O(1) extra space.”

If asked for the greedy justification:

> “For a fixed selling day, no earlier buying price can beat the minimum earlier price, so retaining anything else is unnecessary.”

---

## 12. Pattern recognition

Think **running minimum/maximum** when:

- a current decision must be paired with the best earlier value;
- order matters;
- you need the best difference between a later and earlier element;
- historical data can be compressed into one best-so-far value.

General pattern:

```text
for each current item:
    evaluate answer using best historical state
    update global answer
    incorporate current item into historical state
```

Memory cue:

> For every sell day, carry the cheapest past buy.

---

## 13. Is this a sliding-window problem?

It is sometimes described informally using `left` and `right` pointers:

- `left` represents the current cheapest buy day;
- `right` scans potential sell days.

However, no fixed or variable-size window is being maintained, and no elements leave a window. The clearest pattern name is **running minimum / greedy one-pass scan**.

Correct classification matters less than understanding the maintained state.

---

## 14. Follow-up: return the buy and sell days

```javascript
function bestTrade(prices) {
  let minimumPrice = Infinity;
  let minimumDay = -1;
  let bestProfit = 0;
  let bestBuyDay = -1;
  let bestSellDay = -1;

  for (let day = 0; day < prices.length; day++) {
    const currentPrice = prices[day];
    const profit = currentPrice - minimumPrice;

    if (profit > bestProfit) {
      bestProfit = profit;
      bestBuyDay = minimumDay;
      bestSellDay = day;
    }

    if (currentPrice < minimumPrice) {
      minimumPrice = currentPrice;
      minimumDay = day;
    }
  }

  return {
    profit: bestProfit,
    buyDay: bestBuyDay,
    sellDay: bestSellDay,
  };
}
```

The underlying algorithm does not change; we simply retain the indices associated with the running minimum and best result.

---

## 15. Edge cases

| Prices | Result | Reason |
|---|---:|---|
| `[]` | `0` | No transaction possible |
| `[5]` | `0` | No later selling day |
| `[7, 6, 4, 3, 1]` | `0` | Prices only fall |
| `[1, 2]` | `1` | One profitable pair |
| `[2, 2]` | `0` | No positive profit |
| `[3, 1, 4]` | `3` | Buy at `1`, sell at `4` |
| `[2, 4, 1]` | `2` | Cannot use future `1` to buy for past `4` |

---

## 16. Notebook-ready notes

### 📚 Concept

**Best Time to Buy and Sell Stock — running minimum**

```text
For each price:
profit today = current price - minimum earlier price
best profit  = max(best profit, profit today)
minimum      = min(minimum, current price)
```

### 🧠 My understanding

For a fixed selling day, only the cheapest earlier price matters. I do not need to retain all earlier prices. Scanning left to right preserves the buy-before-sell rule, while two variables compress the relevant history.

### 💼 Interview line

> “I’ll evaluate every day as a selling day against the cheapest valid buying price seen earlier.”

### ⚠️ Traps

- Do not subtract the global minimum from a maximum that occurred earlier.
- Do not sum multiple profits; only one transaction is allowed.
- Keep the answer at least `0`.

---

## 17. Dheerix Glance

```text
BEST TIME TO BUY AND SELL STOCK

Equation:        profit = sell - buy
Order:           buy day < sell day
Historical state:minimum price seen so far
Current decision:sell today
Update:          best = max(best, current - minimum)
Time:            O(n)
Extra space:     O(1)
Memory cue:      “Sell today against the cheapest past.”
```

---

## 18. Recall test

Without looking back:

1. Why is the global minimum/global maximum approach unsafe?
2. What does `minimumPrice` represent before evaluating a selling day?
3. Why does a left-to-right scan enforce buy-before-sell?
4. Why should the result start at `0`?
5. Why is the space complexity O(1), unlike Two Sum?
6. What changes if the interviewer asks for the actual buy and sell days?
7. State the invariant in one sentence.

