# Grind 75 — 34: Course Schedule

**Difficulty:** Medium  
**Primary pattern:** Directed graph / topological sort / cycle detection  
**LeetCode:** https://leetcode.com/problems/course-schedule/  
**Target time:** 30 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

There are `numCourses` courses labeled `0` through `numCourses - 1`.

Each prerequisite pair:

```text
[course, prerequisite]
```

means the prerequisite must be completed before the course.

```text
[1, 0] means 0 → 1
```

Return whether it is possible to finish every course.

Possible:

```text
0 → 1 → 2
```

Impossible:

```text
0 → 1
↑   ↓
└───┘
```

A directed cycle means each course in the cycle waits for another course in the same cycle, so none can begin.

---

## 2. Translate into a directed graph

For pair `[course, prerequisite]`, build:

```text
prerequisite → course
```

Why this direction? Completing the prerequisite unlocks the dependent course.

Represent:

```text
adjacency[prerequisite] = courses unlocked by it
indegree[course] = number of unfinished prerequisites
```

The question becomes:

> Does this directed graph contain a cycle?

Equivalently:

> Can all vertices appear in a topological ordering?

---

## 3. Topological ordering

A topological ordering places every prerequisite before the course that depends on it.

Example:

```text
edges: 0 → 1, 0 → 2, 1 → 3, 2 → 3

valid orders:
0,1,2,3
0,2,1,3
```

A directed graph has a topological ordering if and only if it is acyclic.

Course Schedule asks only whether an order exists, not to return the order itself.

---

## 4. Kahn's algorithm intuition

An indegree-zero course has no unfinished prerequisites, so it can be taken now.

Process it:

1. remove it conceptually from the graph;
2. decrement indegree for every course it unlocks;
3. if a dependent course reaches indegree zero, enqueue it.

If all courses are eventually processed, the graph is acyclic.

If processing stops early, every remaining course still has a prerequisite among the remaining courses. That dependency knot contains a cycle.

---

## 5. Step-by-step algorithm

1. Create an adjacency list for every course.
2. Create an indegree array initialized to zero.
3. For each `[course, prerequisite]`:
   - add `course` to `adjacency[prerequisite]`;
   - increment `indegree[course]`.
4. Enqueue every course whose indegree is zero.
5. Repeatedly dequeue a course:
   - count it as completed;
   - decrement each dependent course's indegree;
   - enqueue dependents that become zero.
6. Return whether completed count equals `numCourses`.

---

## 6. Optimal JavaScript solution

```javascript
function canFinish(numCourses, prerequisites) {
  const adjacency = Array.from(
    { length: numCourses },
    () => [],
  );

  const indegree = new Array(numCourses).fill(0);

  for (const [course, prerequisite] of prerequisites) {
    adjacency[prerequisite].push(course);
    indegree[course]++;
  }

  const queue = [];
  let front = 0;

  for (let course = 0; course < numCourses; course++) {
    if (indegree[course] === 0) {
      queue.push(course);
    }
  }

  let completedCourses = 0;

  while (front < queue.length) {
    const completed = queue[front++];
    completedCourses++;

    for (const dependent of adjacency[completed]) {
      indegree[dependent]--;

      if (indegree[dependent] === 0) {
        queue.push(dependent);
      }
    }
  }

  return completedCourses === numCourses;
}
```

---

## 7. Dry run: possible schedule

```text
numCourses = 4
prerequisites = [[1,0], [2,0], [3,1], [3,2]]
```

Graph:

```text
0 → 1 → 3
 \→ 2 →/
```

Initial indegrees:

```text
course:   0 1 2 3
indegree: 0 1 1 2
```

Process:

| Completed | Indegree changes | Newly available | Count |
|---:|---|---|---:|
| 0 | 1→0, 2→0 | 1, 2 | 1 |
| 1 | 3: 2→1 | — | 2 |
| 2 | 3: 1→0 | 3 | 3 |
| 3 | none | — | 4 |

All four courses complete, so return `true`.

---

## 8. Dry run: cycle

```text
prerequisites = [[1,0], [0,1]]
```

Graph:

```text
0 → 1 → 0
```

Indegrees:

```text
course 0: 1
course 1: 1
```

No course has indegree zero, so the initial queue is empty. Completed count remains zero, which is less than two. Return `false`.

---

## 9. Why counting processed courses detects cycles

In an acyclic directed graph, there is always at least one indegree-zero node. Removing such nodes repeatedly eventually removes every node.

In a cycle, every cycle node has at least one incoming edge from another remaining cycle node. None can reach indegree zero solely by removing nodes outside the cycle.

Therefore:

```text
processed count === total vertices → acyclic
processed count < total vertices   → cycle exists
```

---

## 10. Code walkthrough

### Adjacency direction

```javascript
adjacency[prerequisite].push(course);
```

When a prerequisite is completed, we need to find courses affected by that completion. Reversing this edge direction would require different traversal logic.

### Indegree

`indegree[course]` counts how many prerequisite edges still point into the course.

### Initial queue

Every indegree-zero course can be completed immediately. There may be multiple independent starting courses, so enqueue all of them.

### Enqueue exactly at zero

A course enters the queue when its final prerequisite is removed. It should not enter earlier, and it will not reach zero again under valid edge processing.

### Front-index queue

Use `queue[front++]` instead of `queue.shift()` to avoid repeated beginning-of-array removal.

---

## 11. Invariants

During processing:

1. `indegree[c]` equals the number of prerequisites for course `c` that have not yet been processed.
2. Every course in the unprocessed portion of the queue currently has indegree zero.
3. `completedCourses` counts distinct courses removed from the graph.

Decrementing dependents when a course is completed preserves these meanings.

---

## 12. Correctness reasoning

Every enqueued course has indegree zero, so all its prerequisites have been processed and completing it is valid. Decrementing outgoing neighbors accurately removes that completed prerequisite.

If all courses are processed, their dequeue order is a valid topological ordering, so completing every course is possible.

If fewer than all courses are processed, no remaining course has indegree zero. Following prerequisite edges among the finite remaining nodes must eventually revisit a node, forming a directed cycle. Courses in that cycle cannot be completed. Thus the boolean result is correct.

---

## 13. Complexity

Let:

```text
V = numCourses
E = prerequisites.length
```

- **Time: O(V + E)** — initialize all courses, build every edge once, enqueue each course at most once, and traverse each edge once.
- **Extra space: O(V + E)** — adjacency list, indegree array, and queue.

Do not call time O(V²) merely because this is a graph. Adjacency-list traversal is linear in vertices plus edges.

---

## 14. DFS cycle-detection alternative

A directed DFS can track three states:

```text
0 = unvisited
1 = visiting, currently on recursion path
2 = fully processed
```

Encountering a `visiting` node means a back edge and therefore a cycle.

```javascript
function canFinishDfs(numCourses, prerequisites) {
  const adjacency = Array.from(
    { length: numCourses },
    () => [],
  );

  for (const [course, prerequisite] of prerequisites) {
    adjacency[prerequisite].push(course);
  }

  const state = new Array(numCourses).fill(0);

  function hasCycle(course) {
    if (state[course] === 1) return true;
    if (state[course] === 2) return false;

    state[course] = 1;

    for (const dependent of adjacency[course]) {
      if (hasCycle(dependent)) return true;
    }

    state[course] = 2;
    return false;
  }

  for (let course = 0; course < numCourses; course++) {
    if (hasCycle(course)) {
      return false;
    }
  }

  return true;
}
```

This is also O(V + E), with O(V) recursion stack worst case. Kahn's algorithm avoids JavaScript recursion-depth concerns and directly models prerequisites becoming available.

---

## 15. Why a simple visited set is insufficient for DFS

In a directed graph, encountering any previously visited node does not necessarily mean a cycle.

```text
0 → 1 → 3
 \→ 2 → 3
```

Node `3` is reached twice through converging paths, but no cycle exists.

DFS must distinguish:

- a node on the **current recursion path** (`visiting`)—cycle;
- a node fully processed through an earlier path (`visited/done`)—safe.

This is why directed cycle detection uses three colors/states rather than one boolean visited flag.

---

## 16. Common mistakes

1. **Reversing edge meaning.** `[course, prerequisite]` means prerequisite points to course for Kahn's processing.
2. **Incrementing the prerequisite's indegree.** The dependent course receives the incoming edge.
3. **Enqueuing only course zero.** Any course can begin with zero prerequisites.
4. **Returning true when the queue merely becomes empty.** Compare processed count with all courses.
5. **Using undirected cycle logic.** Prerequisite relationships are directed.
6. **Using one DFS visited state.** Converging DAG paths are not cycles.
7. **Forgetting disconnected components.** Initialize/check every course, including those absent from prerequisite pairs.
8. **Using `queue.shift()` repeatedly in JavaScript.** Prefer a front index.
9. **Building an adjacency matrix unnecessarily.** It costs O(V²) space; an adjacency list is O(V+E).
10. **Confusing this problem with returning the actual schedule.** It asks only for feasibility, though topological order can be retained.

---

## 17. What to say in an interview

> “I’ll model prerequisites as a directed graph from prerequisite to dependent course. A schedule exists exactly when the graph is acyclic. Using Kahn's topological sort, I count indegrees, enqueue all zero-indegree courses, and process them while decrementing their dependents. If I process all courses, the dequeue order is a valid schedule; if processing stops early, the remaining dependency graph contains a cycle. Complexity is O(V+E) time and space.”

If asked why early stoppage proves a cycle:

> “Every remaining node still depends on another remaining node; in a finite directed graph, following those dependencies must eventually repeat a node.”

---

## 18. Pattern recognition

Think **topological sort** when:

- tasks have prerequisite dependencies;
- a valid execution order is needed;
- you must detect circular dependencies;
- nodes become available only after incoming requirements are removed.

Common applications:

- course planning;
- build systems;
- deployment ordering;
- package dependencies;
- workflow scheduling;
- DAG job execution.

Memory cue:

> Start with no prerequisites; completing work unlocks dependents.

---

## 19. Follow-up: return a course order

Save dequeued courses:

```javascript
function findCourseOrder(numCourses, prerequisites) {
  const adjacency = Array.from(
    { length: numCourses },
    () => [],
  );
  const indegree = new Array(numCourses).fill(0);

  for (const [course, prerequisite] of prerequisites) {
    adjacency[prerequisite].push(course);
    indegree[course]++;
  }

  const queue = [];
  let front = 0;

  for (let course = 0; course < numCourses; course++) {
    if (indegree[course] === 0) queue.push(course);
  }

  const order = [];

  while (front < queue.length) {
    const course = queue[front++];
    order.push(course);

    for (const dependent of adjacency[course]) {
      indegree[dependent]--;
      if (indegree[dependent] === 0) {
        queue.push(dependent);
      }
    }
  }

  return order.length === numCourses ? order : [];
}
```

Course Schedule II asks for this ordering rather than only feasibility.

---

## 20. Edge cases

| Situation | Result |
|---|---:|
| zero prerequisite pairs | `true` |
| one course | `true` |
| simple chain | `true` |
| branching DAG | `true` |
| direct two-course cycle | `false` |
| self-dependency `[0,0]` | `false` |
| one cyclic component plus independent courses | `false` |
| duplicate edges if permitted | indegrees and adjacency must treat them consistently |

The official input constraints should be followed regarding duplicate prerequisite pairs.

---

## 21. Notebook-ready notes

### 📚 Concept

**Course Schedule — Kahn's topological sort**

```text
edge: prerequisite → course
indegree[course] = prerequisite count
queue all indegree-0 courses

while queue:
  complete course
  completed++
  for dependent:
    indegree--
    reaches 0 → enqueue

completed === numCourses → possible
```

### 🧠 My understanding

An indegree-zero course has no remaining blockers. Removing it may unlock dependents. If this process removes every node, the removal order is a valid schedule. If nodes remain but none is unblocked, their dependencies contain a directed cycle.

### 💼 Interview line

> “I’ll repeatedly remove courses with no remaining prerequisites; anything permanently stuck belongs to a cycle.”

### ⚠️ Traps

- Build prerequisite → dependent edges.
- Increment the dependent course's indegree.
- Initialize every zero-indegree course.
- Compare completed count to total courses.

---

## 22. Dheerix Glance

```text
COURSE SCHEDULE

Model:            directed dependency graph
Edge:             prerequisite → course
Cycle meaning:    impossible schedule
Technique:        Kahn's topological sort
Initial queue:    all indegree-zero courses
Process:          remove node, decrement dependents
Unlock:           dependent indegree becomes zero
Success:          processed count == V
Time:             O(V + E)
Space:            O(V + E)
Memory cue:       “No blockers first; unlock the rest.”
```

---

## 23. Recall test

Without looking back:

1. What direction should each prerequisite edge have, and why?
2. What does indegree represent?
3. Why are indegree-zero courses safe to process?
4. Why does processing fewer than all courses prove a cycle?
5. What are Kahn's algorithm's invariants?
6. Why is one boolean visited array insufficient for directed DFS cycle detection?
7. What are the time and space complexities in V and E?
8. How would the solution change to return an actual course order?

