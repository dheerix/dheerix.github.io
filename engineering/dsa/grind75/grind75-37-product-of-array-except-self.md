# Grind 75 — 37: Product of Array Except Self

**Difficulty:** Medium  
**Primary pattern:** Prefix and suffix products  
**LeetCode:** https://leetcode.com/problems/product-of-array-except-self/  
**Target time:** 30 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Given an integer array `nums`, return an array where:

```text
answer[i] = product of every nums value except nums[i]
```

Example:

```text
nums   = [1, 2, 3, 4]
answer = [24, 12, 8, 6]
```

Because:

```text
answer[0] = 2×3×4 = 24
answer[1] = 1×3×4 = 12
answer[2] = 1×2×4 = 8
answer[3] = 1×2×3 = 6
```

Constraints:

- solve in O(n) time;
- do not use division.

---

## 2. Brute-force approach

For each index, multiply every other value.

```javascript
function productExceptSelfBruteForce(nums) {
  const answer = new Array(nums.length).fill(1);

  for (let i = 0; i < nums.length; i++) {
    for (let j = 0; j < nums.length; j++) {
      if (i !== j) {
        answer[i] *= nums[j];
      }
    }
  }

  return answer;
}
```

- Time: **O(n²)**.
- Output space: O(n).

The same products are recomputed many times.

---

## 3. Why total product and division are disallowed

Tempting:

```text
totalProduct / nums[i]
```

Problems:

1. Division is explicitly prohibited.
2. Zeros require special cases:
   - one zero: only its position may have a nonzero answer;
   - two zeros: every answer is zero.
3. In other numeric contexts, division can introduce precision concerns.

Prefix/suffix multiplication handles zeros without any special logic.

---

## 4. Decompose each answer

For index `i`:

```text
answer[i] =
  product of values strictly left of i
  ×
  product of values strictly right of i
```

Example:

```text
nums = [1, 2, 3, 4]
             ↑ i=2

left product  = 1×2 = 2
right product = 4
answer[2]     = 2×4 = 8
```

The current value is excluded automatically because neither side includes it.

---

## 5. Prefix and suffix arrays

A direct O(n)-time solution stores both sides:

```javascript
function productExceptSelfWithArrays(nums) {
  const n = nums.length;
  const prefix = new Array(n).fill(1);
  const suffix = new Array(n).fill(1);
  const answer = new Array(n);

  for (let i = 1; i < n; i++) {
    prefix[i] = prefix[i - 1] * nums[i - 1];
  }

  for (let i = n - 2; i >= 0; i--) {
    suffix[i] = suffix[i + 1] * nums[i + 1];
  }

  for (let i = 0; i < n; i++) {
    answer[i] = prefix[i] * suffix[i];
  }

  return answer;
}
```

- Time: **O(n)**.
- Extra space excluding output: **O(n)**.

We can reuse the answer array for prefix products and replace the suffix array with one running variable.

---

## 6. Space-optimized idea

### Left-to-right pass

Before processing index `i`, maintain:

```text
prefixProduct = product of nums[0...i-1]
```

Write it into `answer[i]`, then multiply the current value into the prefix for future indices.

### Right-to-left pass

Maintain:

```text
suffixProduct = product of nums[i+1...n-1]
```

Multiply it into `answer[i]`, then include `nums[i]` for the next position to the left.

Order is crucial: write/multiply the “strictly outside” product before incorporating the current element.

---

## 7. Optimal JavaScript solution

```javascript
function productExceptSelf(nums) {
  const answer = new Array(nums.length);

  let prefixProduct = 1;

  for (let i = 0; i < nums.length; i++) {
    answer[i] = prefixProduct;
    prefixProduct *= nums[i];
  }

  let suffixProduct = 1;

  for (let i = nums.length - 1; i >= 0; i--) {
    answer[i] *= suffixProduct;
    suffixProduct *= nums[i];
  }

  return answer;
}
```

---

## 8. Dry run

```text
nums = [1, 2, 3, 4]
```

### Prefix pass

| `i` | Prefix before current | `answer[i]` | Prefix after including current |
|---:|---:|---:|---:|
| 0 | 1 | 1 | 1 |
| 1 | 1 | 1 | 2 |
| 2 | 2 | 2 | 6 |
| 3 | 6 | 6 | 24 |

After prefix pass:

```text
answer = [1, 1, 2, 6]
```

### Suffix pass

| `i` | Suffix before current | Answer before | Answer after | Suffix after |
|---:|---:|---:|---:|---:|
| 3 | 1 | 6 | 6 | 4 |
| 2 | 4 | 2 | 8 | 12 |
| 1 | 12 | 1 | 12 | 24 |
| 0 | 24 | 1 | 24 | 24 |

Final:

```text
[24, 12, 8, 6]
```

---

## 9. Why initialize products to one?

One is the multiplicative identity:

```text
1 × x = x
```

At index zero, there are no values to the left. The product of an empty collection for this recurrence is one.

At the final index, there are no values to the right, so its suffix product is also one.

Using zero would erase every multiplication result.

---

## 10. Zero handling comes for free

### One zero

```text
nums = [1, 2, 0, 4]
```

Every position other than the zero includes that zero in either its prefix or suffix product, so its answer becomes zero. The zero position combines products from both nonzero sides:

```text
answer = [0, 0, 8, 0]
```

### Two zeros

Every position's product includes at least one zero:

```text
answer = all zeros
```

No zero-specific branches are required.

---

## 11. Loop invariants

### Prefix pass

Before iteration `i`:

> `prefixProduct` equals the product of all input values strictly before `i`.

After assigning `answer[i]`, multiplying by `nums[i]` establishes the invariant for `i + 1`.

### Suffix pass

Before iteration `i`:

> `suffixProduct` equals the product of all input values strictly after `i`, while `answer[i]` already holds the product strictly before `i`.

Multiplying them gives the required product excluding `i`.

---

## 12. Correctness reasoning

The first pass stores in every `answer[i]` the product of exactly the values with indices less than `i`.

The second pass maintains the product of exactly the values with indices greater than `i` and multiplies it into `answer[i]`. The two index sets are disjoint, exclude `i`, and together contain every other array position.

Therefore, each final answer entry equals the product of all input values except its own value.

---

## 13. Complexity

- **Time: O(n)** — two linear passes.
- **Auxiliary space excluding output: O(1)** — two running product variables.
- **Output space: O(n)** — required return array.

LeetCode's follow-up treats the output array as not counting toward extra space, which is why this is described as constant-space beyond the result.

Two passes are still O(n): O(2n) simplifies to O(n).

---

## 14. Code walkthrough

### Answer is temporarily prefix storage

The output array performs double duty. It first stores left-side products, then each entry is completed by multiplying its right-side product.

### Write before multiplying current

```javascript
answer[i] = prefixProduct;
prefixProduct *= nums[i];
```

Reversing these lines would include `nums[i]` in its own answer.

### Complete answer before growing suffix

```javascript
answer[i] *= suffixProduct;
suffixProduct *= nums[i];
```

The same exclusion rule applies from the right.

### Input remains unchanged

Only the answer and scalar accumulators are mutated.

---

## 15. Common mistakes

1. **Using division despite the constraint.** It also complicates zero handling.
2. **Including the current value in prefix or suffix.** Write the accumulator before multiplying by `nums[i]`.
3. **Initializing running products to zero.** Use the multiplicative identity one.
4. **Forgetting to multiply prefix and suffix contributions.** Each side alone is incomplete.
5. **Allocating both prefix and suffix arrays while claiming O(1) auxiliary space.** The optimized version uses the answer plus one suffix scalar.
6. **Calling two passes O(n²).** They are sequential, not nested.
7. **Adding explicit zero branches unnecessarily.** Prefix/suffix products already handle any number of zeros.
8. **Overwriting `nums` to store prefix products.** This destroys values needed during the suffix pass unless carefully designed.
9. **Confusing prefix including current with prefix strictly before current.** State definitions must be explicit.

---

## 16. What to say in an interview

> “For index `i`, the answer is the product strictly to its left times the product strictly to its right. In a left-to-right pass, I store each prefix product directly in the output. In a right-to-left pass, I maintain one running suffix product and multiply it into each output entry. I update each accumulator only after using it so the current value is excluded. This is O(n) time and O(1) auxiliary space beyond the output, with no division and natural zero handling.”

If asked why division is unnecessary:

> “The full product excluding an index decomposes cleanly into two products that never include that index.”

---

## 17. Pattern recognition

Think **prefix/suffix decomposition** when:

- each answer excludes the current index;
- the full contribution separates into left-side and right-side aggregates;
- the aggregate operation is associative;
- repeated recomputation should be avoided.

Similar ideas appear with:

- prefix sums;
- left/right maximums;
- trapping rain water;
- cumulative counts;
- range-query preprocessing.

Memory cue:

> Store everything before me; multiply everything after me.

---

## 18. Edge cases

| Input | Output | Important behavior |
|---|---|---|
| `[1,2]` | `[2,1]` | Empty side contributes one |
| `[1,2,3,4]` | `[24,12,8,6]` | Standard case |
| `[0,2,3]` | `[6,0,0]` | One zero |
| `[0,2,0]` | `[0,0,0]` | Two zeros |
| `[-1,2,-3]` | `[-6,3,-2]` | Signs handled normally |
| values include `1` | normal | Multiplicative identity |

The official constraints guarantee at least two elements.

---

## 19. Notebook-ready notes

### 📚 Concept

**Product Except Self — prefix × suffix**

```text
answer[i] = product(left of i) × product(right of i)

prefix = 1
left→right:
  answer[i] = prefix
  prefix *= nums[i]

suffix = 1
right→left:
  answer[i] *= suffix
  suffix *= nums[i]
```

### 🧠 My understanding

The required product splits into all values before the index and all values after it. I write each running product before including the current value, which automatically excludes self. The output stores prefixes, while one scalar supplies suffixes in the second pass.

### 💼 Interview line

> “I’ll decompose each result into the product strictly before and strictly after its index.”

### ⚠️ Traps

- Accumulators start at one.
- Use each accumulator before including the current value.
- Output storage is O(n); auxiliary state beyond output is O(1).
- Zero cases need no special branches.

---

## 20. Dheerix Glance

```text
PRODUCT EXCEPT SELF

Decomposition:    left product × right product
Prefix pass:      store before including current
Suffix pass:      multiply before including current
Identity:         1
Division:         not used
Zeros:            handled naturally
Time:             O(n)
Auxiliary space:  O(1) excluding output
Output:           O(n)
Memory cue:       “Before me × after me.”
```

---

## 21. Recall test

Without looking back:

1. How does `answer[i]` decompose?
2. Why can squarely using total product and division fail the requirement?
3. What does `prefixProduct` mean before iteration `i`?
4. Why must assignment happen before multiplying by `nums[i]`?
5. Why do running products begin at one?
6. How are one-zero and two-zero inputs handled without branches?
7. What counts as output versus auxiliary space?
8. State both loop invariants in one sentence each.

