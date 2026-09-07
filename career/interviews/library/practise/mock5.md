# IBM Mock 05 — Group Anagrams

## Problem

Given an array of strings `strs`, group all anagrams together.

Anagrams contain the same characters with the same frequencies, but possibly in a different order.

### Example

```text
Input:
["eat", "tea", "tan", "ate", "nat", "bat"]

Output:
[
  ["eat", "tea", "ate"],
  ["tan", "nat"],
  ["bat"]
]
```

Assumptions:

- lowercase English letters `a-z`
- duplicate strings allowed
- output order does not matter

---

# 🧠 Pattern Trigger

> **Group items by equivalence → Find a canonical representation → Hash Map**

The important question is:

> **Can I transform equivalent items into the same key?**

For anagrams:

```text
eat → aet
tea → aet
ate → aet
```

Once they have the same representation, grouping becomes a Map problem.

---

# 1. Straightforward Idea

Compare every string with every other string and determine whether they are anagrams.

This would require repeated comparisons and would become expensive.

Instead:

> **Normalize each word into a canonical form.**

---

# 2. Canonical Representation — Sorted String

Sort every word:

```text
eat → aet
tea → aet
ate → aet

tan → ant
nat → ant

bat → abt
```

Then:

```text
"aet" → ["eat", "tea", "ate"]
"ant" → ["tan", "nat"]
"abt" → ["bat"]
```

So the Map structure is:

```text
canonical key → original values
```

---

# 3. Sorting Solution

```js
var groupAnagrams = function (strs) {
	const groups = new Map();

	for (const str of strs) {
		const key = str.split('').sort().join('');

		if (!groups.has(key)) {
			groups.set(key, []);
		}

		groups.get(key).push(str);
	}

	return Array.from(groups.values());
};
```

---

# 4. Why Map?

Once we calculate:

```text
key = canonical representation
```

we don't need to compare the current word against every previous word.

We simply ask:

```text
Does this group already exist?
```

Average Map lookup:

```text
O(1)
```

So:

```text
derive key
    ↓
Map lookup
    ↓
append to group
```

---

# 5. JavaScript Detail — `push` vs Spread

Initial implementation:

```js
groups.set(key, [...groups.get(key), str]);
```

This works.

But it creates a **new array** every time.

Prefer:

```js
groups.get(key).push(str);
```

because we can modify the existing group directly.

Also prefer:

```js
for (const str of strs)
```

instead of:

```js
for (str of strs)
```

to avoid accidental outer/global variables.

---

# 6. Complexity — Important Lesson

Define two variables:

```text
n = number of strings
k = length of a string
```

This is important.

Do NOT simply say:

```text
O(n)
```

because we're also processing characters inside each string.

---

## Sorting One String

For a string of length `k`:

```text
sorting = O(k log k)
```

We do this for `n` strings.

Therefore:

```text
Time = O(n × k log k)
```

or:

```text
O(nk log k)
```

---

# 7. Space Complexity

The grouped strings and canonical keys collectively contain information proportional to the total number of characters.

Conventional bound:

```text
O(nk)
```

Exact accounting can vary depending on whether input references and output storage are counted, but `O(nk)` is a safe interview answer for the constructed keys/output representation.

---

# 8. My Complexity Mistake

Initial thought:

```text
iterate strings → O(n)
Map → O(n)
```

But that ignored the work performed **inside each string**.

Important lesson:

> **When input contains collections inside collections, define dimensions separately.**

Examples:

```text
array of strings:

n = number of strings
k = string length
```

```text
matrix:

m = rows
n = columns
```

Then analyze both dimensions.

---

# 9. Important Clarification — 26 Letters ≠ String Length 26

The constraint:

```text
lowercase English letters a-z
```

means:

```text
26 possible CHARACTER VALUES
```

It does NOT mean:

```text
maximum string length = 26
```

For example:

```text
"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
```

is valid.

The string can be arbitrarily long while still using an alphabet of only 26 characters.

---

# 10. Optimization — Frequency Signature

Because there are only 26 possible letters, sorting isn't actually necessary.

Instead, count each character.

Example:

```text
"aabcc"
```

produces:

```text
a = 2
b = 1
c = 2
others = 0
```

Conceptually:

```text
[a,b,c,d,e,...]

[2,1,2,0,0,...]
```

Any anagram must produce exactly the same counts.

For example:

```text
"aabcc"
"cbaca"
```

both produce:

```text
[2,1,2,0,0,...]
```

Therefore the frequency array itself can become the canonical fingerprint.

---

# 11. Frequency-Key Solution

```js
var groupAnagrams = function (strs) {
	const groups = new Map();

	for (const str of strs) {
		const count = new Array(26).fill(0);

		for (const ch of str) {
			const index = ch.charCodeAt(0) - 'a'.charCodeAt(0);

			count[index]++;
		}

		const key = count.join('#');

		if (!groups.has(key)) {
			groups.set(key, []);
		}

		groups.get(key).push(str);
	}

	return Array.from(groups.values());
};
```

---

# 12. Why Does the Frequency Key Work?

Anagrams are defined by:

```text
same characters
+
same frequencies
```

Therefore:

```text
"eat"

a = 1
e = 1
t = 1
```

and:

```text
"tea"

a = 1
e = 1
t = 1
```

produce exactly the same fingerprint.

We don't care about character order.

---

# 13. Optimized Complexity

For every string, scan its `k` characters once:

```text
O(k)
```

For `n` strings:

```text
O(nk)
```

The fixed 26-element signature doesn't change the asymptotic complexity.

### Time

```text
O(nk)
```

### Space

```text
O(nk)
```

for grouping/keys under conventional accounting.

---

# 14. Why Was Sorting Faster on LeetCode?

Observed during the mock:

> The theoretically O(nk) frequency solution benchmarked slower than the O(nk log k) sorting solution in JavaScript.

This is completely possible.

Big O describes:

> **How runtime grows as input size grows.**

It does NOT directly measure actual execution time for a particular input.

The frequency solution performs operations such as:

```text
allocate 26-element array
fill array
JavaScript character loop
charCodeAt
increment counters
join 26 counters into key
```

The sorting version uses:

```js
split().sort().join();
```

which can benefit from highly optimized runtime/native implementations.

Also, when strings are short:

```text
k log k
```

may still represent very little work.

Therefore:

> **Better Big O does not guarantee faster execution for every real workload.**

---

# 15. Engineering Lesson — Big O vs Real Performance

Two algorithms:

```text
A = O(nk log k)
B = O(nk)
```

does NOT mean:

```text
B is always faster.
```

Real runtime also depends on:

```text
constant factors
allocations
cache behavior
runtime/JIT optimizations
native implementations
input size
data distribution
```

Big O becomes especially useful for understanding behavior as inputs scale.

### Memory Line

> **Asymptotically better ≠ always practically faster.**

---

# 16. Which Solution Should I Give in an Interview?

Start with the sorting solution.

Why?

```text
simple
clear
correct
easy to explain
harder to bug
```

Say:

> “I'll use the sorted characters as the canonical representation. This gives O(nk log k) time.”

Then, if asked to optimize:

> “Since the alphabet is restricted to 26 lowercase characters, I can replace sorting with a 26-element frequency signature, reducing the theoretical time to O(nk).”

This shows both:

```text
practical engineering judgment
+
algorithmic optimization ability
```

---

# 17. Interview Explanation

> “Anagrams need to produce the same grouping key. One simple canonical representation is the sorted string. For example, `eat`, `tea`, and `ate` all become `aet`.
>
> I'll iterate through the strings, sort each one to generate its key, and use a Map from that key to the corresponding group of original strings.
>
> If there are `n` strings of length `k`, sorting each string costs O(k log k), so the total time is O(nk log k).
>
> Since the alphabet is limited to 26 lowercase characters, we could optimize further by creating a 26-element character-frequency signature. That avoids sorting and gives O(nk) theoretical time.”

---

# 📓 Notebook Version

```text
Group Anagrams

Trigger:

GROUP equivalent things
→ find CANONICAL KEY
→ HASH MAP

eat → aet
tea → aet
ate → aet

"aet" → [eat, tea, ate]

Map:
canonicalKey → group

Sorting:
n strings
k chars/string

Time:
O(nk log k)

Optimization:

fixed alphabet a-z
→ count[26]

eat / tea / ate
→ same frequency signature

Time:
O(nk)

Important:
26 possible chars
≠
string length <= 26
```

---

# 🧠 Memory Lines

> **Equivalent objects → canonical representation → Hash Map.**

> **Same meaning/composition, different arrangement? Normalize first.**

> **Fixed small alphabet → frequency signature may replace sorting.**

> **For strings, define both `n` and `k` before stating complexity.**

> **Better Big O ≠ always faster in practice.**

---

# 🔗 Pattern Recognition Addition

## Pattern 05 — Canonical Key + Hash Map

### Trigger

The problem asks to:

```text
group
classify
detect equivalent objects
find duplicates under transformation
```

but equivalent items may look different.

Ask:

> **Can I transform every equivalent item into exactly the same representation?**

Then:

```text
ITEM
 ↓
CANONICAL REPRESENTATION
 ↓
HASH KEY
 ↓
GROUP / LOOKUP
```

Examples:

```text
eat → aet
tea → aet

→ same group
```

The canonical representation might be:

```text
sorted value
frequency signature
normalized coordinates
normalized fraction
normalized structure
```

The deeper pattern is not “sort strings.”

It is:

> **Normalize first, hash second.**

---

# 🧠 Pattern Map — Mocks 01–05

```text
01 — PREFIX SUM + MAP

Target sum + negatives
→ What earlier running total do I need?

CURRENT - EARLIER = TARGET
```

```text
02 — SLIDING WINDOW

Contiguous + maintainable condition
→ Can I shrink instead of restarting?

EXPAND → INVALID → SHRINK → VALID
```

```text
03 — PREFIX / SUFFIX

Every position needs both sides
→ Can I carry information from both directions?

LEFT → STORE
RIGHT ← CARRY
```

```text
04 — SORT + SCAN

Intervals + overlap
→ Can sorting make the relationship local?

SORT → LAST MERGED → MERGE/PUSH
```

```text
05 — CANONICAL KEY + HASHING

Different-looking items need grouping by equivalence
→ Can I normalize them to the same key?

NORMALIZE → HASH → GROUP
```

---

# ⚡ Five Recognition Questions

When reading a new problem, ask:

```text
1. Do I need an earlier cumulative value?
   → Prefix Sum + Map

2. Can I maintain a valid contiguous region?
   → Sliding Window

3. Does every position depend on both sides?
   → Prefix / Suffix

4. Would sorting make relationships local?
   → Sort + Scan

5. Can equivalent objects be normalized
   into the same key?
   → Canonical Key + Hash Map
```
