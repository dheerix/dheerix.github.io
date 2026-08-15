# Grind 75 — 64. Task Scheduler

## Problem

You are given an array of CPU tasks represented by uppercase letters and an integer cooldown `n`.

Each task takes one unit of time. Identical tasks must be separated by at least `n` time units, during which the CPU may execute different tasks or remain idle.

Return the minimum number of time units required to finish all tasks.

Example:

```text
tasks = ["A", "A", "A", "B", "B", "B"]
n = 2

one optimal schedule:
A B idle A B idle A B

answer = 8
```

---

## First clarify the cooldown rule

If `n = 2`, two copies of `A` need two complete intervals between them:

```text
A _ _ A
```

The next `A` may appear `n + 1` positions after the previous `A`.

Valid:

```text
A B C A
```

Invalid:

```text
A B A
```

The cooldown applies only to identical tasks. Different task types may run consecutively.

---

## What determines the schedule length?

The most frequent task is hardest to place. Less frequent tasks can usually fit into the gaps it forces.

Suppose:

```text
A appears 4 times
n = 2
```

Place the `A`s first:

```text
A _ _ A _ _ A _ _ A
```

The first three `A`s create three cooldown gaps, each containing two positions.

```text
number of gaps = maxFrequency - 1
gap size       = n
```

Other tasks fill those blank positions. Idle time is needed only if there are not enough other tasks to fill them.

This turns the problem from “Which task should I run next?” into “How much schedule structure is forced by the maximum frequency?”

---

## Simulation approach

A natural solution uses:

- a max heap containing currently available task frequencies;
- a cooldown queue containing tasks and the time when they become available again.

At each time unit:

1. release cooled-down tasks into the heap;
2. run the most frequent available task, or idle if none exists;
3. if that task still has remaining copies, place it into cooldown.

This works and generalizes well, but it costs approximately `O(T log K)`, where `T` is the final schedule length and `K` is the number of task types.

For this problem's uppercase-letter constraint, a direct counting formula is simpler and faster.

---

## Build the schedule skeleton

Let:

```text
maxFrequency = frequency of the most common task
```

If `A` is uniquely most frequent and appears `maxFrequency` times, arrange it into rows or frames:

```text
[A _ _] [A _ _] [A _ _] A
```

There are:

```text
maxFrequency - 1 complete frames
```

Each complete frame needs length:

```text
n + 1
```

The last copy ends the schedule skeleton and does not need a cooldown after it.

For one maximum-frequency task, the forced length is:

```text
(maxFrequency - 1) × (n + 1) + 1
```

---

## The tie case

Suppose multiple tasks share the maximum frequency:

```text
tasks = A A A B B B
n = 2
```

The structure becomes:

```text
[A B _] [A B _] A B
```

The final section contains both `A` and `B`, not just one task.

Let:

```text
numberOfMaxTasks = number of task types whose frequency equals maxFrequency
```

Then the forced skeleton length is:

```text
(maxFrequency - 1) × (n + 1) + numberOfMaxTasks
```

For the example:

```text
(3 - 1) × (2 + 1) + 2
= 2 × 3 + 2
= 8
```

---

## Why take the maximum with `tasks.length`?

Sometimes there are enough other tasks to fill every forced gap and extend beyond the skeleton.

Example:

```text
tasks = A A A B B B C C D E
n = 2
```

The skeleton expression is:

```text
(3 - 1) × 3 + 2 = 8
```

But there are 10 actual tasks. We cannot execute 10 unit-time tasks in fewer than 10 time units.

When tasks are dense enough, no idle time is needed, and the answer is simply `tasks.length`.

Therefore:

```text
answer = max(
  tasks.length,
  (maxFrequency - 1) × (n + 1) + numberOfMaxTasks
)
```

---

## Optimal solution

```javascript
function leastInterval(tasks, n) {
  const frequencies = new Array(26).fill(0);
  const codeA = "A".charCodeAt(0);

  for (const task of tasks) {
    frequencies[task.charCodeAt(0) - codeA]++;
  }

  const maxFrequency = Math.max(...frequencies);
  let numberOfMaxTasks = 0;

  for (const frequency of frequencies) {
    if (frequency === maxFrequency) {
      numberOfMaxTasks++;
    }
  }

  const forcedLength =
    (maxFrequency - 1) * (n + 1) + numberOfMaxTasks;

  return Math.max(tasks.length, forcedLength);
}
```

---

## Line-by-line reasoning

### Count each task type

```javascript
const frequencies = new Array(26).fill(0);
const codeA = "A".charCodeAt(0);

for (const task of tasks) {
  frequencies[task.charCodeAt(0) - codeA]++;
}
```

The problem guarantees uppercase English letters, so indices `0` through `25` represent `A` through `Z`.

### Find the maximum frequency

```javascript
const maxFrequency = Math.max(...frequencies);
```

This frequency determines how many cooldown-separated frames are forced.

### Count how many tasks tie for maximum

```javascript
let numberOfMaxTasks = 0;

for (const frequency of frequencies) {
  if (frequency === maxFrequency) {
    numberOfMaxTasks++;
  }
}
```

Every tied task occupies one position in the final section of the skeleton.

### Calculate the forced schedule length

```javascript
const forcedLength =
  (maxFrequency - 1) * (n + 1) + numberOfMaxTasks;
```

Interpretation:

```text
complete frames × frame width + final tied tasks
```

### Respect the actual task count

```javascript
return Math.max(tasks.length, forcedLength);
```

The answer cannot be shorter than the number of tasks. The forced length matters only when idle positions remain unavoidable.

---

## Walkthrough 1: idle time required

```text
tasks = [A, A, A, B, B, B]
n = 2
```

Counts:

```text
A = 3
B = 3
```

Values:

```text
maxFrequency = 3
numberOfMaxTasks = 2
tasks.length = 6
```

Forced length:

```text
(3 - 1) × (2 + 1) + 2 = 8
```

Answer:

```text
max(6, 8) = 8
```

Schedule:

```text
A B idle | A B idle | A B
```

---

## Walkthrough 2: no idle time required

```text
tasks = [A, A, A, B, B, B]
n = 0
```

Forced length:

```text
(3 - 1) × (0 + 1) + 2 = 4
```

But six tasks require six time units:

```text
max(6, 4) = 6
```

With no cooldown, any order works.

---

## Walkthrough 3: one dominant task

```text
tasks = [A, A, A, A, B, C]
n = 2
```

```text
maxFrequency = 4
numberOfMaxTasks = 1
forcedLength = (4 - 1) × 3 + 1 = 10
```

One schedule:

```text
A B C | A idle idle | A idle idle | A
```

Answer: `10`.

---

## Correctness argument

We show that the formula is both a lower bound and achievable.

### The forced length is a lower bound

Choose any task with frequency `maxFrequency`. Its first `maxFrequency - 1` copies must each be followed by at least `n` positions before its next copy, creating `maxFrequency - 1` frames of width at least `n + 1`.

If `numberOfMaxTasks` task types share that frequency, all of their final copies must appear after those complete frames, requiring that many final positions. Therefore every valid schedule has length at least:

```text
(maxFrequency - 1) × (n + 1) + numberOfMaxTasks
```

Every schedule also has length at least `tasks.length`, because each task consumes one time unit.

### This lower bound is achievable

Place the maximum-frequency task types across the complete frames and final section. Distribute the less frequent tasks into the open frame positions. If some positions remain empty, they become idle slots and the schedule length is the forced length. If the other tasks overflow the skeleton, they provide enough separation to eliminate idle time, and all tasks can be arranged in `tasks.length` positions.

Thus the minimum valid length is exactly the maximum of the two lower bounds.

---

## Complexity

Let `T = tasks.length`.

```text
time:  O(T)
space: O(1)
```

Counting scans all tasks once. Scanning 26 frequencies is constant work. The frequency array has constant size because task names are restricted to uppercase English letters.

---

## Common mistakes

### 1. Forgetting ties at the maximum frequency

This incomplete formula works only when one task type is uniquely most frequent:

```text
(maxFrequency - 1) × (n + 1) + 1
```

Use `numberOfMaxTasks`, not `1`.

### 2. Forgetting `Math.max(tasks.length, forcedLength)`

The skeleton formula may be smaller than the actual number of tasks when many other task types fill all gaps.

### 3. Using `n` instead of `n + 1` for frame width

`n` is the number of intervals **between** identical tasks. A frame also includes the task itself.

### 4. Adding cooldown after the final copy

There is no need to wait after all tasks have finished. That is why only `maxFrequency - 1` complete frames exist.

### 5. Believing alphabetical order matters

Only frequencies affect the minimum length. Task labels merely distinguish types.

### 6. Simulating with `Array.shift()`

If using a queue in JavaScript, prefer a front index because repeated `shift()` can reindex the array. The counting formula avoids simulation entirely.

### 7. Greedily scheduling without tracking cooldown

Always choosing the most frequent remaining task is invalid if that task is still cooling down. A simulation needs both availability and cooldown state.

---

## Edge cases

```text
tasks = ["A"], n = 100
answer = 1

tasks = ["A", "B", "C"], n = 50
answer = 3

tasks = ["A", "A", "A"], n = 2
schedule = A idle idle A idle idle A
answer = 7

tasks = ["A", "A", "B", "B"], n = 2
schedule = A B idle A B
answer = 5

n = 0
answer = tasks.length
```

---

## When the heap simulation is preferable

Use simulation instead of the formula when the problem changes, for example:

- tasks have different execution durations;
- task types have different cooldowns;
- the actual schedule must be returned;
- tasks arrive dynamically;
- processors can run multiple tasks simultaneously.

The formula depends on this problem's uniform one-unit tasks and shared cooldown.

Conceptual max-heap simulation:

```text
count frequencies
time = 0

while unfinished tasks remain:
    release tasks whose cooldown ended
    if heap is not empty:
        execute the most frequent available task
        place it in cooldown if copies remain
    time++
```

---

## Interview walkthrough

Say this before coding:

> The most frequent task determines the minimum spacing structure. If its frequency is `f`, its first `f - 1` copies create complete frames of width `n + 1`. If several task types share frequency `f`, all of their final copies occupy the last section, so the forced length is `(f - 1)(n + 1) + countMax`. The answer is the larger of that value and the total task count, because abundant other tasks can fill every idle slot.

If asked why not use a heap:

> A max heap can simulate a valid schedule, but because all tasks take one unit, all use the same cooldown, and there are only 26 task types, the frequency structure determines the answer directly.

Complexity statement:

> I count the tasks once and scan a constant-size array, giving `O(T)` time and `O(1)` auxiliary space.

---

## Notebook version

```javascript
function leastInterval(tasks, n) {
  const count = new Array(26).fill(0);
  const A = "A".charCodeAt(0);

  for (const task of tasks) {
    count[task.charCodeAt(0) - A]++;
  }

  const maxFrequency = Math.max(...count);
  let maxTaskTypes = 0;

  for (const frequency of count) {
    if (frequency === maxFrequency) maxTaskTypes++;
  }

  const skeleton =
    (maxFrequency - 1) * (n + 1) + maxTaskTypes;

  return Math.max(tasks.length, skeleton);
}
```

### Notebook bullets

- Most frequent task creates the schedule skeleton.
- Complete frames: `maxFrequency - 1`.
- Frame width: `n + 1`.
- Final section size: number of task types tied for maximum.
- Answer: `max(total tasks, skeleton length)`.
- Time `O(T)`; space `O(1)`.

### Memory line

> The busiest tasks build the frame; everyone else fills it.

### Formula card

```text
f = maximum task frequency
k = number of task types occurring f times

answer = max(tasks.length, (f - 1)(n + 1) + k)
```
