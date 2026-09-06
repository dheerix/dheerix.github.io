# Grind 75 — 48. Accounts Merge

## Problem

Each account has this form:

```text
[name, email1, email2, ...]
```

Two accounts belong to the same person if they share at least one email address. Merge all accounts belonging to the same person, sort their emails, and return:

```text
[name, sorted unique emails...]
```

Names alone do not establish identity: different people can have the same name.

---

## 1. Hidden model: connected components

Treat each email as a graph node.

Emails appearing in the same account are connected because they belong to the same person.

If accounts overlap indirectly, connectivity handles the transitive relationship:

```text
Account A: [a@mail, b@mail]
Account B: [b@mail, c@mail]
Account C: [c@mail, d@mail]

a ↔ b ↔ c ↔ d
```

Even though Account A and Account C share no email directly, all four emails belong to one connected component and must be merged.

Therefore:

> One merged account equals one connected component of emails.

---

## 2. Build the graph efficiently

For one account containing:

```text
[name, e1, e2, e3, e4]
```

We do not need to connect every pair of emails. Connecting each email to the first email is sufficient:

```text
e1 ↔ e2
e1 ↔ e3
e1 ↔ e4
```

This creates a connected star with O(k) edges for `k` emails, rather than O(k²) pairwise edges.

We also store:

```text
email → name
```

so that each connected component can be converted back into the required output format.

---

## 3. Recommended JavaScript solution: graph + iterative DFS

```javascript
function accountsMerge(accounts) {
  const graph = new Map();
  const nameByEmail = new Map();

  function addEmail(email) {
    if (!graph.has(email)) {
      graph.set(email, []);
    }
  }

  for (const account of accounts) {
    const name = account[0];
    const firstEmail = account[1];

    addEmail(firstEmail);

    for (let i = 1; i < account.length; i++) {
      const email = account[i];
      addEmail(email);
      nameByEmail.set(email, name);

      if (i > 1) {
        graph.get(firstEmail).push(email);
        graph.get(email).push(firstEmail);
      }
    }
  }

  const visited = new Set();
  const mergedAccounts = [];

  for (const email of graph.keys()) {
    if (visited.has(email)) continue;

    const stack = [email];
    const component = [];
    visited.add(email);

    while (stack.length > 0) {
      const currentEmail = stack.pop();
      component.push(currentEmail);

      for (const neighbor of graph.get(currentEmail)) {
        if (!visited.has(neighbor)) {
          visited.add(neighbor);
          stack.push(neighbor);
        }
      }
    }

    component.sort();
    mergedAccounts.push([nameByEmail.get(email), ...component]);
  }

  return mergedAccounts;
}
```

The standard problem guarantees every account contains at least one email.

---

## 4. Why the graph must be undirected

Email ownership is a symmetric relationship. If `a` and `b` occur in one account, traversal must be able to move both ways:

```javascript
graph.get(firstEmail).push(email);
graph.get(email).push(firstEmail);
```

A one-directional graph can make connectivity depend on which email traversal starts from and may split one real component incorrectly.

---

## 5. Why mark visited when pushing?

Use:

```javascript
visited.add(neighbor);
stack.push(neighbor);
```

at discovery time.

If marking waits until `pop()`, several adjacent emails may push the same node into the stack repeatedly. Early marking guarantees each email enters the worklist once.

---

## 6. Walkthrough

Input:

```text
[
  ["John", "a@mail", "b@mail"],
  ["John", "b@mail", "c@mail"],
  ["Mary", "m@mail"],
  ["John", "x@mail"]
]
```

### Build connections

```text
a@mail ↔ b@mail ↔ c@mail

m@mail

x@mail
```

### Traverse components

Starting at `a@mail`, DFS reaches:

```text
[a@mail, b@mail, c@mail]
```

Sort and prepend the associated name:

```text
["John", "a@mail", "b@mail", "c@mail"]
```

The other isolated components become:

```text
["Mary", "m@mail"]
["John", "x@mail"]
```

The two John components stay separate because sharing a name does not prove they are the same person.

---

## 7. Why one shared email merges entire accounts

Suppose:

```text
Account 1: [a, b, c]
Account 2: [c, d, e]
```

The shared email `c` connects the groups:

```text
a — c — d
b — c — e
```

Graph traversal naturally collects the full transitive closure:

```text
{a, b, c, d, e}
```

This is why checking only pairwise account matches and merging once is fragile: a merge can reveal further overlaps. Connected-components algorithms handle every chain systematically.

---

## 8. Correctness reasoning

### Emails belonging to one person are connected

Within each account, every email is connected to the first email. Therefore, all emails in that account lie in one graph component. If two accounts share an email, their component paths meet at that node, so their emails become connected transitively.

### Connected emails belong together

Every graph edge was created only between emails listed in the same account. Following a path therefore represents a chain of shared account ownership. All emails in one component belong to the same merged person.

### Every email appears exactly once

The outer loop begins a traversal only from unvisited emails. DFS marks the entire component visited, so no component can be emitted twice. Every graph email is eventually either used as a traversal start or reached from one.

### Output format is correct

Each collected component is sorted, and its name is retrieved from any email in that component. Under the problem guarantee, all connected accounts refer to the same person.

Therefore, the algorithm returns exactly the required merged accounts.

---

## 9. Complexity

Let:

- `E` = total number of email occurrences across all accounts;
- `U` = number of unique emails.

Graph construction and traversal take O(E) time.

Sorting the emails within components takes, in total, at most:

```text
O(U log U)
```

Therefore:

- Time: **O(E + U log U)**
- Space: **O(E + U)**, usually summarized as **O(E)**

Sorting dominates when one component contains many emails.

---

## 10. Alternative: Union-Find by account index

Disjoint Set Union (DSU) is designed to merge connected groups.

For every email:

- remember the first account index that contained it;
- if it appears again, union the current account with the earlier account.

```javascript
class UnionFind {
  constructor(size) {
    this.parent = Array.from({ length: size }, (_, index) => index);
    this.rank = new Array(size).fill(0);
  }

  find(node) {
    if (this.parent[node] !== node) {
      this.parent[node] = this.find(this.parent[node]);
    }

    return this.parent[node];
  }

  union(first, second) {
    let rootFirst = this.find(first);
    let rootSecond = this.find(second);

    if (rootFirst === rootSecond) return;

    if (this.rank[rootFirst] < this.rank[rootSecond]) {
      [rootFirst, rootSecond] = [rootSecond, rootFirst];
    }

    this.parent[rootSecond] = rootFirst;

    if (this.rank[rootFirst] === this.rank[rootSecond]) {
      this.rank[rootFirst]++;
    }
  }
}

function accountsMergeUnionFind(accounts) {
  const unionFind = new UnionFind(accounts.length);
  const accountByEmail = new Map();

  for (let accountIndex = 0; accountIndex < accounts.length; accountIndex++) {
    for (let i = 1; i < accounts[accountIndex].length; i++) {
      const email = accounts[accountIndex][i];

      if (accountByEmail.has(email)) {
        unionFind.union(accountIndex, accountByEmail.get(email));
      } else {
        accountByEmail.set(email, accountIndex);
      }
    }
  }

  const emailsByRoot = new Map();

  for (const [email, accountIndex] of accountByEmail) {
    const root = unionFind.find(accountIndex);

    if (!emailsByRoot.has(root)) {
      emailsByRoot.set(root, []);
    }

    emailsByRoot.get(root).push(email);
  }

  const merged = [];

  for (const [root, emails] of emailsByRoot) {
    emails.sort();
    merged.push([accounts[root][0], ...emails]);
  }

  return merged;
}
```

With path compression and union by rank, DSU operations are nearly constant time amortized. Sorting the final groups still dominates the asymptotic runtime.

---

## 11. DFS versus Union-Find

| Graph traversal | Union-Find |
| --- | --- |
| Builds explicit email edges | Merges account groups directly |
| Components found with DFS/BFS | Components identified by representatives |
| Familiar after Number of Islands | Excellent for repeated connectivity unions |
| Easy to visualize | Often compact once DSU is mastered |

Both are correct. The graph approach directly exposes the connected-components model; Union-Find is a highly reusable connectivity tool.

---

## 12. Why not merge by name?

Two accounts with the same name can represent different people:

```text
["John", "john.personal@mail"]
["John", "another.john@mail"]
```

Without a shared email path, they must remain separate.

The name is output metadata. Email connectivity establishes identity.

---

## 13. Common mistakes

### Mistake 1: merge accounts only when adjacent in the input

Related accounts may appear anywhere.

### Mistake 2: handle only direct overlaps

Ownership is transitive. A chain of shared emails forms one component.

### Mistake 3: connect all email pairs in one account

That works but creates unnecessary O(k²) edges. A star through the first email is sufficient.

### Mistake 4: build directed edges

The relation must be traversable in both directions.

### Mistake 5: forget isolated emails

Ensure every email gets a graph entry, even when the account contains only one email.

### Mistake 6: mark visited too late

Mark when adding an email to the stack or queue.

### Mistake 7: forget to sort each merged email list

The output requires lexicographically sorted emails.

### Mistake 8: rely on output account order

The problem permits merged accounts in any order; only emails inside each account must be sorted.

---

## 14. JavaScript details

### `Map` and `Set`

They avoid prototype-key hazards and provide clear membership operations for arbitrary email strings.

### Lexicographic sort

For email strings:

```javascript
component.sort();
```

is appropriate because JavaScript's default sort is lexicographic.

### Iterative traversal

An explicit stack avoids call-stack overflow if one account component contains a very large number of emails.

---

## 15. Interview narration

> “I’ll model emails as graph nodes. Within each account, I’ll connect every email to the first one, which makes the account connected using only linear edges. Shared emails join those structures transitively. Then I’ll traverse each unvisited connected component, sort its emails, and prepend the name associated with any email in that component.”

If choosing DSU:

> “Each repeated email tells me two account indices belong to the same component, so I’ll union them and then group emails by their final representative.”

---

## 16. Pattern recognition

Use connected components or Union-Find when records must be merged through shared identifiers:

- customer identity resolution;
- duplicate profiles;
- devices sharing identifiers;
- linked social accounts;
- network connectivity;
- synonym or equivalence groups.

General pattern:

```text
shared identifier creates an edge/union
                  ↓
transitive relationships form components
                  ↓
aggregate each component
```

---

## 17. Quick test

```javascript
const accounts = [
  ['John', 'johnsmith@mail.com', 'john_newyork@mail.com'],
  ['John', 'johnsmith@mail.com', 'john00@mail.com'],
  ['Mary', 'mary@mail.com'],
  ['John', 'johnnybravo@mail.com']
];

console.log(accountsMerge(accounts));
// Account order may vary:
// [
//   ['John', 'john00@mail.com', 'john_newyork@mail.com', 'johnsmith@mail.com'],
//   ['Mary', 'mary@mail.com'],
//   ['John', 'johnnybravo@mail.com']
// ]
```

---

## 18. Notebook version

### Pattern

**Connected components through shared identifiers**

### Graph model

```text
email = node
same account = edge
merged person = connected component
```

### Efficient construction

```text
Connect every account email to its first email.
```

### Memory line

> Shared emails are edges; transitive ownership is a connected component.

### Complexity

```text
time: O(E + U log U)
space: O(E + U)
```

