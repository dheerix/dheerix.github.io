# Coding and DSA

The objective is not to memorize solutions. It is to restore independent problem-solving fluency and make reasoning visible.

Use Java unless another language is substantially more fluent under interview conditions.

## Coding Interview Protocol

### 1. Clarify

Ask about:

- input size
- invalid or empty inputs
- duplicates
- ordering
- expected return value
- memory constraints

### 2. Work an Example

Use a small example to expose hidden assumptions before coding.

### 3. State the Simple Solution

Briefly describe the brute-force approach and its complexity.

### 4. Derive the Better Approach

Explain:

- the repeated work being eliminated
- the data structure selected
- the invariant being maintained
- the expected complexity

### 5. Code Incrementally

- choose meaningful names
- keep functions small
- avoid premature abstraction
- narrate significant decisions
- pause if the implementation contradicts the proposed invariant

### 6. Test

Test:

- the normal case
- the smallest valid case
- empty input where relevant
- duplicates
- boundary values
- a case that breaks the obvious implementation

### 7. Close

State:

- time complexity
- space complexity
- one alternative
- one production consideration if relevant

## Pattern Checklist

### Arrays and Hash Maps

Recognition signals:

- membership checks
- counts and frequencies
- complement lookup
- grouping
- prefix or suffix aggregation

### Two Pointers

Recognition signals:

- sorted arrays
- pair relationships
- shrinking from both ends
- in-place compaction

### Sliding Window

Recognition signals:

- contiguous subarray or substring
- longest or shortest valid range
- maintaining counts while moving boundaries

### Stack

Recognition signals:

- matching delimiters
- nested state
- next greater element
- monotonic ordering

### Binary Search

Recognition signals:

- sorted search space
- monotonic true/false condition
- minimizing or maximizing a feasible answer

### Linked Lists

Recognition signals:

- pointer rewiring
- fast and slow pointers
- in-place merge or reversal

### Trees

Recognition signals:

- hierarchical state
- recursive subproblems
- path or subtree properties
- level-by-level traversal

### Graphs

Recognition signals:

- dependencies
- connectivity
- shortest unweighted path
- cycle detection
- components

### Heap

Recognition signals:

- top K
- repeated minimum or maximum
- merging ordered streams
- online priority

### Backtracking

Recognition signals:

- enumerate valid combinations
- choose, explore, and undo
- constraint-driven search

### Dynamic Programming

Recognition signals:

- overlapping subproblems
- decision at each position
- optimal substructure
- state that can be expressed using earlier states

## Focused Problem Set

The concise solution approaches are in [Coding Answer Key](coding-answer-key.md). Do not open the key until the unaided attempt is complete.

### Foundation

- Two Sum
- Contains Duplicate
- Group Anagrams
- Product of Array Except Self
- Valid Palindrome
- Three Sum

### Windows and Search

- Longest Substring Without Repeating Characters
- Longest Repeating Character Replacement
- Valid Parentheses
- Daily Temperatures
- Binary Search
- Search in Rotated Sorted Array

### Lists and Trees

- Reverse Linked List
- Merge Two Sorted Lists
- Linked List Cycle
- Maximum Depth of Binary Tree
- Binary Tree Level Order Traversal
- Validate Binary Search Tree
- Lowest Common Ancestor of a Binary Search Tree

### Graphs, Heaps, and Intervals

- Number of Islands
- Clone Graph
- Course Schedule
- Rotting Oranges
- Kth Largest Element in an Array
- Merge Intervals

### Backtracking and DP

- Combination Sum
- Subsets
- House Robber
- Coin Change
- Longest Increasing Subsequence

## Error Log

For every failed or slow problem, record:

| Field | Notes |
| --- | --- |
| Problem | |
| Pattern | |
| Initial approach | |
| Failure point | |
| Miss type | recognition / algorithm / coding / testing / communication |
| Correct invariant | |
| Re-solve date | |
| Clean within target time? | |

## Readiness Targets

- Easy: correct in 15–20 minutes
- Medium: correct in 30–35 minutes
- Complexity explained without prompting
- At least three meaningful tests
- No AI or autocomplete during the attempt
- Repeated problems solved from a blank editor, not from memory of individual lines
