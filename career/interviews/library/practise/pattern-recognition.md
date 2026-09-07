# DSA Pattern Recognition — Interview Memory

> The goal is not to remember solutions.
> The goal is to recognize what kind of problem I am looking at.

---

## 01 — Prefix Sum + Hash Map

### 🔔 Trigger Words

- contiguous subarray
- sum equals `k`
- target sum
- longest/count of subarrays
- negative numbers may exist
- need information about an earlier running total

### 🧠 Recognition Question

> **I know my running total. What earlier running total would I need to remove so that the remaining portion equals the target?**

### Core Equation

```text
currentPrefix - earlierPrefix = target
```

Therefore:

```text
earlierPrefix = currentPrefix - target
```

### Memory Pattern

```text
HAVE = currentPrefix
WANT = target

HAVE - ? = WANT

? = HAVE - WANT
```

Then:

```text
Have I seen ? before?
```

### 🔗 Connection

Think of it as:

> **Two Sum over running totals.**

Two Sum:

```text
current + complement = target
```

Prefix Sum:

```text
currentPrefix - earlierPrefix = target
```

Both:

> **Derive the missing value → Hash lookup.**

### Map Usually Stores

```text
prefixSum → index
```

For **longest** subarray:

```text
prefixSum → earliest index
```

For **count** of subarrays:

```text
prefixSum → frequency
```

That distinction will matter in future problems.

### 🚨 Sliding Window Warning

If negative numbers exist:

```text
sum too large → shrink
```

is NOT reliable.

Because adding a number can decrease the sum.

Think:

> **Target sum + negatives → Prefix Sum deserves immediate consideration.**

### One-Line Memory

> **Running total S, want K: have I seen S − K before?**

---

## 02 — Sliding Window

### 🔔 Trigger Words

- substring / subarray
- contiguous
- longest / shortest
- maximum / minimum window
- without repeating
- at most / at least `k`
- maintain some condition inside a contiguous region

### 🧠 Recognition Question

> **Can I keep one valid contiguous window and adjust its boundaries instead of restarting the search?**

If yes:

```text
Sliding Window
```

### Mental Picture

```text
         current valid region
        ┌───────────────┐
... ... [ a  b  c  d ] ... ...
         ↑           ↑
        left        right
```

`right`:

```text
EXPANDS / EXPLORES
```

`left`:

```text
SHRINKS / REPAIRS
```

### Core Pattern

```text
right moves forward

if window becomes invalid:
    move left forward
    until valid again

update answer
```

### Memory Pattern

> **Expand → invalid → shrink → valid → measure.**

### Example Trigger

```text
Longest substring without repeating characters
```

Condition:

```text
all characters unique
```

State:

```text
Set = characters currently in window
```

Duplicate arrives:

```text
Don't restart.

Shrink from LEFT
until valid again.
```

### Window Length

Both boundaries are inclusive:

```text
length = right - left + 1
```

### 🚨 Complexity Trap

Code may look like:

```js
for (...) {
    while (...) {
    }
}
```

Do NOT automatically say:

```text
O(n²)
```

Ask:

> **How many times can each pointer move?**

If:

```text
right → only forward ≤ n
left  → only forward ≤ n
```

then:

```text
n + n = 2n
→ O(n)
```

### One-Line Memory

> **Don't restart — shrink the window.**

---

# Prefix Sum vs Sliding Window

When I see **contiguous**, both should enter my mind.

Then distinguish them:

| Signal                              | Think                |
| ----------------------------------- | -------------------- |
| Target sum + negative numbers       | **Prefix Sum + Map** |
| Maintain a valid window condition   | **Sliding Window**   |
| Need earlier cumulative information | **Prefix Sum**       |
| Can repair by moving `left`         | **Sliding Window**   |
| Need `S - K` from the past          | **Prefix Sum + Map** |
| Longest/shortest valid region       | **Sliding Window**   |

---

# 🧠 My Interview Decision Tree

```text
CONTIGUOUS?
    |
    +--- No  → other patterns
    |
    +--- Yes
          |
          +--- SUM / cumulative relationship?
          |       |
          |       +--- negatives present?
          |               |
          |               +--- YES → PREFIX SUM + MAP
          |
          +--- Can I maintain a condition
               by expanding/shrinking?
                       |
                       +--- YES → SLIDING WINDOW
```

---

# The Two Anchors

### Prefix Sum

```text
CURRENT - EARLIER = TARGET
```

> **What prefix must I remove?**

### Sliding Window

```text
EXPAND → INVALID → SHRINK → VALID
```

> **Don't restart. Repair the window.**

---

# Interview Meta-Pattern

When I only see the brute-force solution, ask:

> **What work am I repeating?**

If I repeatedly calculate information about everything before me:

```text
→ Prefix / Hash structure?
```

If I repeatedly restart contiguous scans:

```text
→ Sliding Window / Two Pointers?
```

Optimization often means:

> **Keep useful information instead of recomputing it.**ß
