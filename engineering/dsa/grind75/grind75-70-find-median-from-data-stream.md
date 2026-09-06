# Grind 75 — 70: Find Median from Data Stream

**Difficulty:** Hard  
**Primary pattern:** Two heaps / streaming order statistics  
**LeetCode:** 295  
**Target interview time:** 30 minutes  
**Language:** JavaScript

## Problem

Design a data structure that supports:

- `addNum(num)`: add an integer from a data stream;
- `findMedian()`: return the median of all numbers added so far.

For a sorted collection:

- odd count: the median is the middle value;
- even count: the median is the average of the two middle values.

Example:

```text
addNum(1)
addNum(2)
findMedian() -> 1.5
addNum(3)
findMedian() -> 2
```

---

## 1. Intuition

The median depends only on the center of the sorted data—not on every position.

Conceptually split the numbers into two halves:

```text
lower half | upper half
```

We need fast access to:

- the largest value in the lower half;
- the smallest value in the upper half.

That suggests two heaps:

```text
lower half -> max-heap -> largest lower value at top
upper half -> min-heap -> smallest upper value at top
```

Example:

```text
sorted values = [1, 2, 3, 4, 5, 6]

lower max-heap represents [1, 2, 3] -> top = 3
upper min-heap represents [4, 5, 6] -> top = 4

median = (3 + 4) / 2 = 3.5
```

We maintain two invariants:

1. **Ordering:** every value in `lower` is less than or equal to every value in `upper`.
2. **Balance:** `lower` has either the same number of elements as `upper` or exactly one extra.

Then the median is always available from the heap tops.

---

## 2. Brute Force — Sort Every Time

Store every number. Whenever `findMedian()` is called, sort the array.

```js
class MedianFinder {
  constructor() {
    this.numbers = [];
  }

  addNum(num) {
    this.numbers.push(num);
  }

  findMedian() {
    const sorted = [...this.numbers].sort((a, b) => a - b);
    const middle = Math.floor(sorted.length / 2);

    if (sorted.length % 2 === 1) {
      return sorted[middle];
    }

    return (sorted[middle - 1] + sorted[middle]) / 2;
  }
}
```

### Complexity

- `addNum`: `O(1)` amortized.
- `findMedian`: `O(n log n)` time and `O(n)` space for the copy.

This wastes work because the same values are sorted again after every query.

---

## 3. Better Solution — Keep a Sorted Array

Maintain sorted order during insertion. Binary search finds the insertion index, but inserting into the middle of a JavaScript array shifts elements.

```js
class MedianFinder {
  constructor() {
    this.numbers = [];
  }

  addNum(num) {
    let left = 0;
    let right = this.numbers.length;

    while (left < right) {
      const middle = left + Math.floor((right - left) / 2);

      if (this.numbers[middle] < num) {
        left = middle + 1;
      } else {
        right = middle;
      }
    }

    this.numbers.splice(left, 0, num);
  }

  findMedian() {
    const n = this.numbers.length;
    const middle = Math.floor(n / 2);

    return n % 2 === 1
      ? this.numbers[middle]
      : (this.numbers[middle - 1] + this.numbers[middle]) / 2;
  }
}
```

### Complexity

- `addNum`: `O(log n)` search plus `O(n)` shifting, therefore `O(n)`.
- `findMedian`: `O(1)`.
- Space: `O(n)`.

This is better when median queries are extremely frequent, but insertion remains linear.

---

## 4. Optimal Solution — Two Heaps

JavaScript does not provide a built-in priority queue in every interview environment, so this artifact includes a small reusable binary heap.

```js
class Heap {
  /**
   * compare(a, b) returns true when a should be above b.
   * Min-heap: (a, b) => a < b
   * Max-heap: (a, b) => a > b
   */
  constructor(compare) {
    this.values = [];
    this.compare = compare;
  }

  size() {
    return this.values.length;
  }

  peek() {
    return this.values[0];
  }

  push(value) {
    this.values.push(value);
    this.#bubbleUp(this.values.length - 1);
  }

  pop() {
    if (this.values.length === 0) return undefined;
    if (this.values.length === 1) return this.values.pop();

    const top = this.values[0];
    this.values[0] = this.values.pop();
    this.#bubbleDown(0);
    return top;
  }

  #bubbleUp(index) {
    while (index > 0) {
      const parent = Math.floor((index - 1) / 2);

      if (!this.compare(this.values[index], this.values[parent])) break;

      [this.values[index], this.values[parent]] =
        [this.values[parent], this.values[index]];

      index = parent;
    }
  }

  #bubbleDown(index) {
    const length = this.values.length;

    while (true) {
      const left = index * 2 + 1;
      const right = index * 2 + 2;
      let best = index;

      if (
        left < length &&
        this.compare(this.values[left], this.values[best])
      ) {
        best = left;
      }

      if (
        right < length &&
        this.compare(this.values[right], this.values[best])
      ) {
        best = right;
      }

      if (best === index) break;

      [this.values[index], this.values[best]] =
        [this.values[best], this.values[index]];

      index = best;
    }
  }
}

class MedianFinder {
  constructor() {
    // Lower half: largest value is available at the top.
    this.lower = new Heap((a, b) => a > b);

    // Upper half: smallest value is available at the top.
    this.upper = new Heap((a, b) => a < b);
  }

  /**
   * @param {number} num
   * @return {void}
   */
  addNum(num) {
    // Always insert into lower first.
    this.lower.push(num);

    // Move lower's largest value into upper.
    this.upper.push(this.lower.pop());

    // lower is allowed to hold one extra value.
    if (this.upper.size() > this.lower.size()) {
      this.lower.push(this.upper.pop());
    }
  }

  /**
   * @return {number}
   */
  findMedian() {
    if (this.lower.size() > this.upper.size()) {
      return this.lower.peek();
    }

    return (this.lower.peek() + this.upper.peek()) / 2;
  }
}
```

---

## 5. Why the Three-Step Insertion Works

### Step 1: Insert into `lower`

```js
this.lower.push(num);
```

We temporarily place the new value in the lower half, even if it is large.

### Step 2: Restore ordering

```js
this.upper.push(this.lower.pop());
```

The largest value in `lower` is moved to `upper`. After this move, every remaining value in `lower` is less than or equal to the moved value, and that moved value joins the upper half.

This restores the ordering invariant.

### Step 3: Restore balance

```js
if (this.upper.size() > this.lower.size()) {
  this.lower.push(this.upper.pop());
}
```

If `upper` became larger, move its smallest value back into `lower`.

After rebalancing:

```text
lower.size === upper.size
or
lower.size === upper.size + 1
```

Because `upper.pop()` is the smallest value in the upper half, moving it to `lower` preserves ordering.

---

## 6. Walkthrough

Insert values in this order:

```text
5, 2, 10, 4
```

The heap notation below shows logical contents; internal heap-array order may differ.

### Add `5`

1. Push into `lower`: `[5]`
2. Move max to `upper`: `lower=[]`, `upper=[5]`
3. `upper` is larger, so move its min back.

```text
lower = [5]
upper = []
median = 5
```

### Add `2`

1. Push `2` into `lower`: `[5,2]`
2. Move lower max `5` to `upper`.

```text
lower = [2]
upper = [5]
median = (2 + 5) / 2 = 3.5
```

### Add `10`

1. Push `10` into `lower`.
2. Move lower max `10` to `upper`.
3. `upper` now has two values, so move its min `5` back.

```text
lower = [2,5] with top 5
upper = [10]
median = 5
```

### Add `4`

1. Push `4` into `lower`.
2. Move lower max `5` to `upper`.

```text
lower = [2,4] with top 4
upper = [5,10] with top 5
median = (4 + 5) / 2 = 4.5
```

Sorted values are `[2,4,5,10]`, confirming the answer.

---

## 7. Correctness Proof

We prove that `findMedian()` always returns the correct median after every insertion.

### Invariant 1: Ordering

Every value in `lower` is less than or equal to every value in `upper`.

During insertion, the new number is first placed in `lower`. Moving the maximum of `lower` into `upper` ensures that all values remaining in `lower` are no greater than that moved boundary value. If rebalancing moves the minimum of `upper` back to `lower`, that value is no greater than every value still in `upper`. Therefore, ordering is preserved.

### Invariant 2: Balance

After insertion:

```text
lower.size === upper.size
or
lower.size === upper.size + 1
```

The algorithm moves one value from `lower` to `upper`, then moves one back only if `upper` is larger. Thus, the allowed size relationship is restored after every insertion.

### Median correctness

Because of ordering, `lower.peek()` is the greatest value in the lower half and `upper.peek()` is the least value in the upper half.

- If the total count is odd, balance guarantees that `lower` contains one extra value. Its maximum is the single middle value.
- If the count is even, the heaps have equal sizes. The two middle values are `lower.peek()` and `upper.peek()`, so their average is the median.

Therefore, `findMedian()` always returns the correct median.

---

## 8. Complexity

For `n` values currently stored:

### `addNum`

```text
O(log n)
```

Each heap insertion or removal takes `O(log n)`, and only a constant number of heap operations occur.

### `findMedian`

```text
O(1)
```

It reads one or two heap tops.

### Space

```text
O(n)
```

Every streamed value is stored in exactly one heap.

---

## 9. Common Mistakes

### Mistake 1: Using two min-heaps

The lower half needs fast access to its largest value, so it must be a max-heap.

### Mistake 2: Balancing size but ignoring ordering

Equal heap sizes are insufficient. All lower-half values must also be no greater than all upper-half values.

### Mistake 3: Allowing either heap to have the extra element without matching `findMedian`

This implementation deliberately gives the extra value to `lower`. The median logic depends on that convention.

### Mistake 4: Dividing the wrong values

For an even count:

```js
(lower.peek() + upper.peek()) / 2
```

Do not average arbitrary heap elements.

### Mistake 5: Forgetting JavaScript's numeric sort comparator

The brute-force version requires:

```js
array.sort((a, b) => a - b)
```

Default sorting is lexicographic.

### Mistake 6: Implementing heap comparison backward

```js
max-heap: (a, b) => a > b
min-heap: (a, b) => a < b
```

### Mistake 7: Removing a heap root without restoring heap order

Replace the root with the last item, then bubble it down.

### Mistake 8: Saying `findMedian` is `O(log n)`

Heap `peek()` is `O(1)`. Only updates cost `O(log n)`.

---

## 10. Edge Cases

### First number

It remains in `lower`, so the median is that number.

### Two numbers

The heaps hold one each, and the median is their average.

### Duplicate numbers

Duplicates work normally because heap ordering is non-strict.

```text
[2,2,2] -> median 2
```

### Negative numbers

Heap comparisons and averaging work unchanged.

```text
[-5,-1,-3] -> median -3
```

### Increasing input

Rebalancing prevents all values from accumulating in `upper`.

### Decreasing input

Rebalancing prevents all values from accumulating in `lower`.

### Median is fractional

JavaScript uses floating-point `Number`, so `(1 + 2) / 2` correctly returns `1.5`.

### Calling `findMedian()` before any insertion

The standard problem guarantees a valid call. In production code, define a contract or throw an explicit error for an empty stream.

---

## 11. Interview Explanation

> I need efficient insertion and constant-time access to the middle, so I split the stream into two heaps. A max-heap stores the lower half and exposes its largest value; a min-heap stores the upper half and exposes its smallest value. I maintain two invariants: every lower value is at most every upper value, and the lower heap has either the same size as the upper heap or one extra. To insert, I push into lower, move lower's maximum to upper to restore ordering, then move upper's minimum back if upper becomes larger. With an odd count, lower's top is the median; with an even count, I average both tops. Insertion is `O(log n)`, median lookup is `O(1)`, and storage is `O(n)`.

### Useful follow-up: values lie in a fixed small range

If all values are integers in a small known range, such as `[0,100]`, a frequency array can replace heaps. Track the total count and scan cumulative frequencies to locate the middle ranks.

### Useful follow-up: 99% of values lie in `[0,100]`

Maintain counts for the fixed range plus separate storage/counts for outliers below and above it. The exact design depends on query and update constraints.

---

## 12. Notebook Version

### Recognition

```text
Streaming median
=> need both middle boundaries continuously
=> max-heap lower half + min-heap upper half
```

### Invariants

```text
1. max(lower) <= min(upper)
2. lower.size === upper.size
   or lower.size === upper.size + 1
```

### Insert

```text
1. lower.push(num)
2. upper.push(lower.pop())
3. if upper is larger: lower.push(upper.pop())
```

### Median

```text
odd:  lower.peek()
even: (lower.peek() + upper.peek()) / 2
```

### Core JavaScript

```js
class MedianFinder {
  constructor() {
    this.lower = new Heap((a, b) => a > b); // max-heap
    this.upper = new Heap((a, b) => a < b); // min-heap
  }

  addNum(num) {
    this.lower.push(num);
    this.upper.push(this.lower.pop());

    if (this.upper.size() > this.lower.size()) {
      this.lower.push(this.upper.pop());
    }
  }

  findMedian() {
    if (this.lower.size() > this.upper.size()) {
      return this.lower.peek();
    }

    return (this.lower.peek() + this.upper.peek()) / 2;
  }
}
```

### Complexity

```text
addNum:    O(log n)
findMedian: O(1)
space:      O(n)
```

---

## 13. Memory Line

**Lower keeps the biggest small value; upper keeps the smallest big value.**

