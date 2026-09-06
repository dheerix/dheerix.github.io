# Grind 75 — 71: Word Ladder

**Difficulty:** Hard  
**Primary pattern:** Unweighted shortest path / BFS  
**LeetCode:** 127  
**Target interview time:** 45 minutes  
**Language:** JavaScript

## Problem

Given:

- a starting word `beginWord`;
- a target word `endWord`;
- a list of allowed words `wordList`;

return the number of words in the shortest transformation sequence from `beginWord` to `endWord`.

Each transformation must:

1. change exactly one letter;
2. produce a word contained in `wordList`.

Return `0` if no valid sequence exists.

Example:

```text
beginWord = "hit"
endWord   = "cog"
wordList  = ["hot", "dot", "dog", "lot", "log", "cog"]

shortest sequence:
hit -> hot -> dot -> dog -> cog

answer = 5
```

The answer counts words, not transformations. Five words means four changes.

---

## 1. Intuition — See a Graph Hidden Inside the Words

Treat every word as a graph node.

Two words share an edge when they differ in exactly one position:

```text
hit -- hot
hot -- dot
hot -- lot
dot -- dog
lot -- log
dog -- cog
log -- cog
```

Every edge represents one transformation and therefore has equal cost.

The problem becomes:

```text
Find the shortest path from beginWord to endWord
in an unweighted graph.
```

The correct traversal is BFS because BFS explores nodes level by level:

```text
level 1 -> beginWord
level 2 -> one transformation away
level 3 -> two transformations away
...
```

The first time BFS reaches `endWord`, it has found a shortest sequence.

### Recognition pattern

When a problem asks for:

- minimum moves or transformations;
- every move has the same cost;
- states can be viewed as nodes;

think **BFS over an implicit graph**.

---

## 2. Brute Force — Build Every Pairwise Edge

Compare every pair of words and connect them if they differ by exactly one character. Then run BFS on the explicit graph.

```js
function ladderLength(beginWord, endWord, wordList) {
  const words = [beginWord, ...wordList];
  const graph = Array.from({ length: words.length }, () => []);

  for (let i = 0; i < words.length; i++) {
    for (let j = i + 1; j < words.length; j++) {
      if (differsByOne(words[i], words[j])) {
        graph[i].push(j);
        graph[j].push(i);
      }
    }
  }

  const endIndex = words.indexOf(endWord);
  if (endIndex === -1) return 0;

  const queue = [[0, 1]];
  const visited = new Set([0]);
  let queueIndex = 0;

  while (queueIndex < queue.length) {
    const [node, length] = queue[queueIndex++];

    if (node === endIndex) return length;

    for (const neighbor of graph[node]) {
      if (!visited.has(neighbor)) {
        visited.add(neighbor);
        queue.push([neighbor, length + 1]);
      }
    }
  }

  return 0;
}

function differsByOne(first, second) {
  let differences = 0;

  for (let i = 0; i < first.length; i++) {
    if (first[i] !== second[i]) differences++;
    if (differences > 1) return false;
  }

  return differences === 1;
}
```

### Complexity

Let:

- `n` be the number of words;
- `L` be the word length.

Pairwise graph construction takes:

```text
O(n² × L)
```

The explicit graph can contain `O(n²)` edges, so it also requires large space.

The algorithm is correct but spends too much time discovering adjacency.

---

## 3. Optimal Interview Solution — Generate Neighbors During BFS

Instead of comparing a word with every dictionary word, generate all possible one-letter mutations.

For each position, try all 26 lowercase letters and test membership in a `Set`.

```js
/**
 * Returns the number of words in the shortest transformation sequence.
 *
 * @param {string} beginWord
 * @param {string} endWord
 * @param {string[]} wordList
 * @return {number}
 */
function ladderLength(beginWord, endWord, wordList) {
  const unusedWords = new Set(wordList);

  if (!unusedWords.has(endWord)) return 0;

  const queue = [[beginWord, 1]];
  let queueIndex = 0;

  // Mark beginWord visited if it appears in the dictionary.
  unusedWords.delete(beginWord);

  while (queueIndex < queue.length) {
    const [word, sequenceLength] = queue[queueIndex++];

    if (word === endWord) {
      return sequenceLength;
    }

    const letters = word.split("");

    for (let position = 0; position < letters.length; position++) {
      const originalLetter = letters[position];

      for (let code = 97; code <= 122; code++) {
        const replacement = String.fromCharCode(code);

        if (replacement === originalLetter) continue;

        letters[position] = replacement;
        const candidate = letters.join("");

        if (unusedWords.has(candidate)) {
          // Mark visited when enqueued, not when dequeued.
          unusedWords.delete(candidate);
          queue.push([candidate, sequenceLength + 1]);
        }
      }

      letters[position] = originalLetter;
    }
  }

  return 0;
}
```

---

## 4. Why the Dictionary Set Also Works as `visited`

Initially, `unusedWords` contains every allowed dictionary word.

When a word is discovered:

```js
unusedWords.delete(candidate);
```

Deleting it means:

- the word remains a valid transformation already placed in the queue;
- no later path will enqueue it again.

This is equivalent to a separate `visited` set but uses one structure.

### Why mark visited when enqueuing?

If marking is delayed until dequeue time, several words in the same BFS layer may discover and enqueue the same neighbor. That wastes time and memory.

The first discovery is already through a shortest path because BFS processes levels in increasing distance. Therefore, it is safe to mark the word visited immediately.

---

## 5. Walkthrough

```text
beginWord = "hit"
endWord   = "cog"
wordList  = ["hot", "dot", "dog", "lot", "log", "cog"]
```

### Initial state

```text
queue = [("hit", 1)]
```

### Level 1

From `hit`, generate one-letter mutations. The only dictionary match is:

```text
hit -> hot
```

```text
queue adds ("hot", 2)
```

### Level 2

From `hot`, valid unused neighbors are:

```text
hot -> dot
hot -> lot
```

```text
queue adds ("dot", 3), ("lot", 3)
```

### Level 3

```text
dot -> dog
lot -> log
```

```text
queue adds ("dog", 4), ("log", 4)
```

### Level 4

From `dog`, BFS generates `cog`:

```text
dog -> cog
queue adds ("cog", 5)
```

When `cog` is dequeued, return `5`.

Because BFS reached it at the earliest possible level, no shorter transformation sequence exists.

---

## 6. Correctness Proof

We prove that the algorithm returns the length of the shortest valid transformation sequence.

### Lemma 1: Every generated edge is valid

For a current word, the algorithm changes exactly one position and checks whether the resulting candidate exists in `wordList`. Therefore, every enqueued neighbor differs by exactly one character and is an allowed word.

### Lemma 2: Every valid unvisited neighbor can be generated

Any valid neighbor differs from the current word at exactly one position. When the algorithm reaches that position and tries the neighbor's replacement letter, it constructs that exact word. Since the neighbor is unused and belongs to the dictionary, it is enqueued.

### Lemma 3: BFS first discovers each word through a shortest sequence

BFS processes words in nondecreasing sequence length. All words at length `d` are processed before words at length `d + 1`. Thus, the first time a word is discovered, no shorter undiscovered route to it can exist.

### Theorem

By Lemmas 1 and 2, BFS traverses exactly the valid transformation edges reachable from `beginWord`. By Lemma 3, the first discovery of `endWord` has minimum sequence length. Therefore, the algorithm returns the shortest valid transformation length. If BFS finishes without reaching `endWord`, no valid sequence exists, so returning `0` is correct.

---

## 7. Complexity

Let:

- `n` be the number of words in `wordList`;
- `L` be the length of each word;
- the alphabet contain 26 lowercase letters.

Each dictionary word is enqueued at most once. For each processed word, we try `26 × L` mutations. Constructing a candidate string with `join` costs `O(L)` in JavaScript.

### Precise JavaScript bound

```text
Time: O(n × 26 × L²) = O(nL²)
```

In analyses that treat word creation or hashing as `O(1)`, this is often stated as `O(n × 26 × L)`.

### Space

```text
O(nL)
```

The dictionary set and BFS queue can hold `O(n)` words, each of length `L`.

---

## 8. Practical Optimization — Bidirectional BFS

Standard BFS may expand a large frontier. Bidirectional BFS searches simultaneously from `beginWord` and `endWord` and stops when the frontiers meet.

Always expand the smaller frontier to reduce branching.

```js
function ladderLength(beginWord, endWord, wordList) {
  const unusedWords = new Set(wordList);
  if (!unusedWords.has(endWord)) return 0;

  let front = new Set([beginWord]);
  let back = new Set([endWord]);
  let sequenceLength = 1;

  unusedWords.delete(beginWord);
  unusedWords.delete(endWord);

  while (front.size > 0 && back.size > 0) {
    if (front.size > back.size) {
      [front, back] = [back, front];
    }

    const nextFront = new Set();

    for (const word of front) {
      const letters = word.split("");

      for (let position = 0; position < letters.length; position++) {
        const originalLetter = letters[position];

        for (let code = 97; code <= 122; code++) {
          const replacement = String.fromCharCode(code);
          if (replacement === originalLetter) continue;

          letters[position] = replacement;
          const candidate = letters.join("");

          if (back.has(candidate)) {
            return sequenceLength + 1;
          }

          if (unusedWords.has(candidate)) {
            unusedWords.delete(candidate);
            nextFront.add(candidate);
          }
        }

        letters[position] = originalLetter;
      }
    }

    front = nextFront;
    sequenceLength++;
  }

  return 0;
}
```

### Why it helps

If the branching factor is `b` and shortest distance is `d`:

```text
one-direction BFS explores roughly b^d states
bidirectional BFS explores roughly 2 × b^(d/2) states
```

The worst-case asymptotic bound is still governed by the dictionary size, but the practical reduction can be dramatic.

---

## 9. Alternative Neighbor Lookup — Wildcard Patterns

Words differing by one character share a wildcard pattern:

```text
hot -> *ot, h*t, ho*
dot -> *ot, d*t, do*
```

Precompute a map from each pattern to matching words:

```text
*ot -> [hot, dot, lot]
```

Then BFS finds neighbors through patterns instead of trying all 26 letters. This is especially useful when the alphabet is large or not fixed.

Tradeoff:

- mutation generation uses less preprocessing;
- wildcard mapping stores additional pattern lists but makes adjacency explicit.

---

## 10. Common Mistakes

### Mistake 1: Using DFS for the shortest sequence

DFS may find a valid sequence, but not necessarily the shortest one. Unweighted shortest path requires BFS.

### Mistake 2: Forgetting the `endWord` requirement

If `endWord` is absent from `wordList`, return `0` immediately.

### Mistake 3: Returning number of transformations instead of words

Initialize the starting word's sequence length as `1`.

### Mistake 4: Marking visited when dequeued

Mark when enqueued to prevent duplicate queue entries.

### Mistake 5: Revisiting `beginWord`

Delete it from the unused set before BFS if it appears in `wordList`.

### Mistake 6: Forgetting to restore the original character

After trying every replacement at a position:

```js
letters[position] = originalLetter;
```

Otherwise, mutations for the next position start from a corrupted word.

### Mistake 7: Using `queue.shift()` repeatedly

JavaScript array `shift()` may be linear because remaining elements are reindexed. Use a queue index.

### Mistake 8: Generating the unchanged word

Skip the original letter. It cannot create a valid one-character transformation.

### Mistake 9: Comparing every word pair

That builds the graph in `O(n²L)`. Generate neighbors or use wildcard groups instead.

---

## 11. Edge Cases

### `endWord` absent

```text
begin = "hit"
end   = "cog"
list  = ["hot", "dot", "dog"]
answer = 0
```

### Direct transformation

```text
begin = "hit"
end   = "hot"
list  = ["hot"]
answer = 2
```

### No connecting path

The target may exist in the dictionary but belong to a disconnected graph component. BFS then exhausts the reachable words and returns `0`.

### Multiple shortest paths

BFS may discover any one of them. Only the length is required.

### Duplicate words in `wordList`

Converting the list to a `Set` removes duplicates naturally.

### Cycles

Word graphs can contain cycles. Removing visited words prevents infinite revisiting.

### `beginWord` appears in `wordList`

Delete it initially so it cannot be enqueued again.

### Same start and target

The standard constraints normally make them different. If an API allows equality, define the contract explicitly; the natural sequence length is `1`.

---

## 12. Interview Explanation

> I model each word as a node, with an unweighted edge between words that differ in exactly one character. The question is therefore an unweighted shortest-path problem, so I use BFS. I keep all unused dictionary words in a set. From each dequeued word, I try every letter at every position; a generated candidate is a valid neighbor if it is in the set. I remove it when enqueuing so it is visited only once. The starting sequence length is one because the answer counts words. The first time BFS reaches the target is guaranteed to be shortest. In JavaScript, candidate string construction makes the precise time `O(nL²)` for a fixed alphabet, with `O(nL)` storage. A bidirectional BFS is a strong practical optimization because it expands the smaller frontier from both ends.

### Strong opening questions

1. Are all words the same length?
2. Is the alphabet limited to lowercase English letters?
3. Is `endWord` required to appear in `wordList`?
4. Are we returning path length or the actual path?

The standard problem guarantees equal lengths and lowercase letters, requires every transformed word—including the target—to be in the list, and asks only for length.

---

## 13. Notebook Version

### Recognition

```text
word = node
one-letter change = edge
all moves cost 1
shortest path = BFS
```

### Algorithm

1. Put `wordList` into an unused-word set.
2. If `endWord` is absent, return `0`.
3. Queue `[beginWord, 1]`.
4. For each word, change every position to `a...z`.
5. If a candidate is unused:
   - delete it immediately;
   - enqueue it with length `+1`.
6. Return length when target is reached; otherwise `0`.

### JavaScript

```js
function ladderLength(beginWord, endWord, wordList) {
  const unused = new Set(wordList);
  if (!unused.has(endWord)) return 0;

  const queue = [[beginWord, 1]];
  let head = 0;
  unused.delete(beginWord);

  while (head < queue.length) {
    const [word, length] = queue[head++];
    if (word === endWord) return length;

    const chars = word.split("");

    for (let i = 0; i < chars.length; i++) {
      const original = chars[i];

      for (let code = 97; code <= 122; code++) {
        chars[i] = String.fromCharCode(code);
        const next = chars.join("");

        if (unused.has(next)) {
          unused.delete(next);
          queue.push([next, length + 1]);
        }
      }

      chars[i] = original;
    }
  }

  return 0;
}
```

### Complexity

```text
Time:  O(nL²) in JavaScript with fixed 26-letter alphabet
Space: O(nL)
```

### Invariant

When a word is first enqueued, its stored sequence length is the shortest possible length from `beginWord`.

---

## 14. Memory Line

**Words are nodes, one-letter changes are edges, and BFS counts the shortest ladder.**

