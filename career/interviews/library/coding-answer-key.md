# Coding Answer Key

This is a comparison tool, not a first-pass study guide.

For each problem:

1. attempt it without AI
2. explain and test the solution
3. record the miss
4. compare with this key
5. re-solve from a blank editor within 24–72 hours

## Arrays and Hash Maps

### Two Sum

Maintain a map from value to index. For each value `x`, check whether `target - x` has already been seen, then store `x`.

- Time: `O(n)`
- Space: `O(n)`
- Common miss: inserting before checking can incorrectly reuse the same element.

### Contains Duplicate

Insert each value into a set. Return true when a value already exists.

- Time: `O(n)` expected
- Space: `O(n)`
- Alternative: sort in `O(n log n)` time with less auxiliary data-structure space.

### Group Anagrams

Use a canonical representation as the map key. Options:

- sorted characters: simple, `O(k log k)` per word
- fixed character-frequency vector: `O(k)` per word for a bounded alphabet

Map each key to its group.

- Time: `O(n × k)` with frequency keys
- Space: `O(n × k)`

### Product of Array Except Self

Write prefix products into the output array. Traverse from right to left while maintaining a suffix product and multiply it into each output position.

- Time: `O(n)`
- Extra space: `O(1)` excluding the output
- Common miss: division fails with zeros and is usually disallowed.

### Valid Palindrome

Move two pointers inward. Skip non-alphanumeric characters and compare normalized characters.

- Time: `O(n)`
- Space: `O(1)`

### Three Sum

Sort the array. Fix one index, then use two pointers on the remaining range. Skip duplicate fixed values and duplicate pointer values after finding a triplet.

- Time: `O(n²)`
- Space: depends on sorting implementation
- Common miss: incomplete duplicate handling.

## Windows, Stacks, and Search

### Longest Substring Without Repeating Characters

Maintain a sliding window and a map of each character’s latest index. When a repeated character occurs inside the current window, move the left boundary to one position after its previous index.

- Time: `O(n)`
- Space: `O(character set)`
- Common miss: moving the left boundary backward.

### Longest Repeating Character Replacement

Maintain character counts in the current window and the maximum frequency seen. The number of replacements required is:

```text
window length - highest frequency
```

Shrink while that value exceeds `k`.

- Time: `O(n)`
- Space: `O(character set)`

### Valid Parentheses

Push opening brackets. For a closing bracket, require that the stack top is its matching opener. The stack must be empty at the end.

- Time: `O(n)`
- Space: `O(n)`
- Common miss: forgetting an early empty-stack check.

### Daily Temperatures

Maintain a monotonic decreasing stack of unresolved indices. When the current temperature is higher than the stack top, pop and compute the distance.

- Time: `O(n)`
- Space: `O(n)`
- Reason: every index is pushed and popped at most once.

### Binary Search

Maintain an inclusive or half-open range consistently. Compare the midpoint and discard the impossible half.

- Time: `O(log n)`
- Space: `O(1)`
- Common miss: mixing interval conventions and creating an infinite loop.

### Search in Rotated Sorted Array

At every step, at least one half is sorted. Determine the sorted half, test whether the target lies inside it, and discard the other half.

- Time: `O(log n)`
- Space: `O(1)`

## Linked Lists and Trees

### Reverse Linked List

Track `previous`, `current`, and `next`. Redirect `current.next`, then advance.

- Time: `O(n)`
- Space: `O(1)`
- Common miss: losing the remainder before saving `next`.

### Merge Two Sorted Lists

Use a dummy head and append the smaller current node. Attach the remaining list at the end.

- Time: `O(n + m)`
- Space: `O(1)` auxiliary

### Linked List Cycle

Move one pointer one step and another two steps. If they meet, a cycle exists. If the fast pointer reaches the end, no cycle exists.

- Time: `O(n)`
- Space: `O(1)`

### Maximum Depth of Binary Tree

Recursively return:

```text
1 + max(left depth, right depth)
```

Base case for a null node is zero.

- Time: `O(n)`
- Space: `O(h)` recursion stack

### Binary Tree Level Order Traversal

Use BFS with a queue. Capture the queue size at the start of each level and process exactly that many nodes.

- Time: `O(n)`
- Space: `O(w)`, where `w` is maximum tree width

### Validate Binary Search Tree

Recursively carry valid lower and upper bounds. Every node must be strictly inside its bounds.

- Time: `O(n)`
- Space: `O(h)`
- Common miss: checking only a node against its direct children.

### Lowest Common Ancestor of a Binary Search Tree

Use BST ordering:

- both targets smaller: go left
- both larger: go right
- otherwise the current node is the split point

- Time: `O(h)`
- Space: `O(1)` iteratively

## Graphs, Heaps, and Intervals

### Number of Islands

Scan the grid. When land is found, increment the count and run DFS or BFS to mark the entire connected component visited.

- Time: `O(rows × columns)`
- Space: up to `O(rows × columns)`

### Clone Graph

Traverse with DFS or BFS and maintain a map from original node to cloned node. Create a clone the first time a node is visited and reuse it for cycles and shared neighbors.

- Time: `O(V + E)`
- Space: `O(V)`

### Course Schedule

Build a directed graph and indegree counts. Use Kahn’s topological sort:

1. enqueue all zero-indegree courses
2. remove them and decrement neighbor indegrees
3. count processed nodes

All courses can be completed if the processed count equals the number of courses.

- Time: `O(V + E)`
- Space: `O(V + E)`

### Rotting Oranges

Use multi-source BFS. Enqueue all rotten oranges initially, then process level by level while rotting adjacent fresh oranges.

- Time: `O(rows × columns)`
- Space: `O(rows × columns)`
- Return failure if fresh oranges remain.

### Kth Largest Element in an Array

Maintain a min-heap of size `k`. Push values and remove the minimum whenever the heap exceeds `k`. The heap root is the kth largest.

- Time: `O(n log k)`
- Space: `O(k)`
- Alternative: Quickselect averages `O(n)`.

### Merge Intervals

Sort by start time. Compare each interval with the last merged interval:

- overlap: extend the end
- no overlap: append a new interval

- Time: `O(n log n)`
- Space: `O(n)` for output

## Backtracking and Dynamic Programming

### Combination Sum

Backtrack using:

- remaining target
- current combination
- current candidate index

Allow reuse by recursing with the same index. Stop when the remaining value is zero or negative.

- Time: exponential
- Space: proportional to recursion depth plus output

### Subsets

At each position, either include the element or skip it, or use a loop-based backtracking approach that appends the current path at every node.

- Time: `O(n × 2ⁿ)` including output construction
- Space: `O(n)` recursion excluding output

### House Robber

For each house, choose between:

```text
skip = best through previous house
rob  = value + best through house before previous
```

Keep only the previous two states.

- Time: `O(n)`
- Space: `O(1)`

### Coin Change

Let `dp[a]` be the minimum coins needed for amount `a`. Initialize `dp[0] = 0` and other states to an unreachable sentinel. For each amount, try every coin.

- Time: `O(amount × number of coins)`
- Space: `O(amount)`
- Return failure if the target remains unreachable.

### Longest Increasing Subsequence

Interview-safe dynamic programming:

```text
dp[i] = longest increasing subsequence ending at i
```

For every earlier `j < i`, if `nums[j] < nums[i]`, update `dp[i]`.

- Time: `O(n²)`
- Space: `O(n)`

Optimized approach:

Maintain the smallest possible tail for an increasing subsequence of each length and use binary search.

- Time: `O(n log n)`
- Space: `O(n)`

## What a Complete Coding Answer Sounds Like

> I’ll use a hash map so each earlier value can be checked in constant expected time. Before storing the current value, I check whether its complement already exists, which prevents reusing the same element. This is O(n) time and O(n) space. I would test a normal pair, duplicates such as `[3,3]`, negative values, and the minimum valid input.

The explanation is short because the reasoning, invariant, and complexity are all explicit.
