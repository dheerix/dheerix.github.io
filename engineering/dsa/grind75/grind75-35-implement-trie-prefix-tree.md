# Grind 75 — 35: Implement Trie (Prefix Tree)

**Difficulty:** Medium  
**Primary pattern:** Trie / prefix indexing / data-structure design  
**LeetCode:** https://leetcode.com/problems/implement-trie-prefix-tree/  
**Target time:** 35 minutes  
**Language:** JavaScript

---

## 1. Problem in plain English

Implement a trie supporting:

```text
insert(word)       → store a word
search(word)       → is this exact word stored?
startsWith(prefix) → does any stored word begin with this prefix?
```

Example:

```text
insert("apple")
search("apple")   → true
search("app")     → false
startsWith("app") → true
insert("app")
search("app")     → true
```

The distinction between exact words and prefixes is the central requirement.

---

## 2. What is a trie?

A trie is a tree where edges represent characters and every path from the root represents a prefix.

Insert:

```text
app
apple
apt
```

Conceptual structure:

```text
root
 └─ a
    └─ p
       ├─ p  ← word "app" ends here
       │  └─ l
       │     └─ e ← word "apple" ends here
       └─ t  ← word "apt" ends here
```

Shared prefixes share nodes, so `app` and `apple` reuse the path `a → p → p`.

---

## 3. Trie node state

Every node needs:

```text
children  → character to child-node mapping
isWord    → whether a complete inserted word ends here
```

```javascript
class TrieNode {
  constructor() {
    this.children = new Map();
    this.isWord = false;
  }
}
```

The root represents the empty prefix and does not correspond to a character.

---

## 4. Why `isWord` is necessary

After inserting `"apple"`, the path for `"app"` exists:

```text
root → a → p → p
```

But `"app"` was not necessarily inserted as a complete word.

Therefore:

```text
path exists       → prefix exists
path ends at isWord=true → exact word exists
```

Without an end marker, `search("app")` and `startsWith("app")` would be indistinguishable.

---

## 5. Operations

### Insert

Start at root. For each character:

1. create a child if absent;
2. move to that child.

After the final character, mark `isWord = true`.

### Search

Follow every character path. If any edge is missing, return false. After the final character, return the node's `isWord`.

### Starts with

Follow every prefix character. If all edges exist, return true regardless of the final node's `isWord`.

---

## 6. Optimal JavaScript implementation

```javascript
class TrieNode {
  constructor() {
    this.children = new Map();
    this.isWord = false;
  }
}

class Trie {
  constructor() {
    this.root = new TrieNode();
  }

  insert(word) {
    let current = this.root;

    for (const character of word) {
      if (!current.children.has(character)) {
        current.children.set(character, new TrieNode());
      }

      current = current.children.get(character);
    }

    current.isWord = true;
  }

  search(word) {
    const finalNode = this.findNode(word);
    return finalNode !== null && finalNode.isWord;
  }

  startsWith(prefix) {
    return this.findNode(prefix) !== null;
  }

  findNode(text) {
    let current = this.root;

    for (const character of text) {
      if (!current.children.has(character)) {
        return null;
      }

      current = current.children.get(character);
    }

    return current;
  }
}
```

---

## 7. Dry run

### Insert `"apple"`

```text
root
```

Read `a`: absent → create node, move to it.  
Read `p`: absent → create node, move.  
Read second `p`: create and move.  
Read `l`: create and move.  
Read `e`: create and move.  
Mark final node `isWord = true`.

### Search `"app"`

All three character edges exist. Final node has:

```text
isWord = false
```

Return false.

### `startsWith("app")`

The same path exists. Prefix search does not require `isWord`, so return true.

### Insert `"app"`

No nodes are created; the path already exists. Mark its final node `isWord = true`. Now exact search returns true.

---

## 8. Code walkthrough

### One root node

All words begin from the same empty-prefix root. The root allows words with different first characters to share one structure.

### `Map` children

`Map` stores only edges that exist and works for general characters. It also avoids plain-object prototype concerns.

### Reuse existing nodes

Insertion creates nodes only for the previously unseen suffix. Shared prefixes remain shared.

### Shared traversal helper

`search` and `startsWith` perform identical path traversal. Their only difference is the final condition, so `findNode` prevents duplicated logic.

### Repeated insertion

Inserting the same word again simply sets `isWord = true` again. The structure remains valid and no duplicate path is created.

---

## 9. Invariants

After any sequence of insertions:

1. Every path from root spells a prefix of at least one inserted word.
2. Every inserted word has a complete root-to-node path.
3. A node has `isWord = true` exactly when its path string has been inserted as a complete word.

The operations preserve these invariants by reusing paths, creating only missing edges, and marking only final word nodes.

---

## 10. Correctness reasoning

During insertion, each input character corresponds to one traversed or newly created edge, so the final node represents exactly the word. Marking it records full-word membership without changing shorter-prefix status.

`findNode(text)` succeeds exactly when every character edge exists consecutively from the root, so it correctly determines prefix-path existence. `startsWith` uses that fact directly. `search` additionally requires `isWord`, which distinguishes a stored word from a path that exists only because of a longer word. Therefore, all operations satisfy their contracts.

---

## 11. Complexity

Let `L` be the length of the input word or prefix.

- `insert`: **O(L)** average time.
- `search`: **O(L)** average time.
- `startsWith`: **O(L)** average time.
- Per-operation traversal space: **O(1)** besides iteration state.
- Total trie space: **O(T)** nodes, where `T` is the total number of characters across inserted words in the worst case.

Shared prefixes reduce actual node count. A tighter description is the number of distinct prefixes represented.

For JavaScript `for...of`, `L` can be understood as iterated code points; LeetCode inputs are lowercase English letters.

---

## 12. Fixed 26-child array alternative

The official problem uses lowercase English letters. Each node can store a 26-element array:

```javascript
class ArrayTrieNode {
  constructor() {
    this.children = new Array(26).fill(null);
    this.isWord = false;
  }
}
```

Child index:

```javascript
const index = character.charCodeAt(0) - 97;
```

Trade-off:

| Children structure | Benefits | Costs |
|---|---|---|
| `Map` | sparse, general alphabet, clear | hashing/object overhead |
| 26-array | direct indexed access, predictable | allocates 26 slots per node |

Both provide O(L) operations under their assumptions. The map version is easiest to write and explain in JavaScript.

---

## 13. Why not use a set of full words?

A `Set` makes exact `search` easy:

```text
words.has(word)
```

But `startsWith(prefix)` would require scanning many stored words, potentially proportional to the number and total length of words.

A trie indexes every prefix along the path, so prefix lookup depends only on prefix length:

```text
O(prefix length)
```

The trie spends structural memory to make prefix queries efficient.

---

## 14. Deletion follow-up

To delete a word:

1. traverse to its final node;
2. set `isWord = false`;
3. optionally remove nodes backward only if they:
   - have no children; and
   - are not the end of another word.

Example: deleting `"app"` must not remove nodes needed by `"apple"`. Similarly, deleting `"apple"` must preserve `"app"` if its end marker is true.

Deletion demonstrates why both shared paths and word-end markers must be handled carefully.

---

## 15. Common mistakes

1. **Forgetting `isWord`.** Exact search incorrectly returns true for every existing prefix.
2. **Returning `isWord` from `startsWith`.** Prefix queries do not require a complete word.
3. **Creating a new path for every word.** Shared prefixes should reuse existing nodes.
4. **Marking every traversed node as a word.** Only the final node ends the inserted word.
5. **Using one global children map.** Each node needs its own outgoing-character mapping.
6. **Beginning traversal anywhere other than root.** Every lookup represents a root-based prefix.
7. **Using a full-word set and calling prefix lookup O(L).** Without a prefix index, it may scan all words.
8. **Assuming a `Map` lookup is worst-case mathematically constant.** O(1) average is the conventional analysis.
9. **Allocating a 26-array while claiming alphabet generality.** That optimization depends on lowercase English constraints.
10. **Removing shared nodes during deletion.** Other stored words may need them.

---

## 16. What to say in an interview

> “A trie stores one character per edge, so root-to-node paths represent prefixes. Each node has a map of children and an `isWord` marker. Insert follows or creates the path and marks only the final node. Search requires both the path and the final marker, while `startsWith` requires only the path. Each operation is O(L) for input length L, and total space is proportional to the number of distinct prefix nodes.”

If asked why not a word set:

> “A set handles exact lookup, but a trie makes prefix lookup depend only on prefix length rather than scanning stored words.”

---

## 17. Pattern recognition

Think **trie** when:

- many strings share prefixes;
- prefix queries are frequent;
- autocomplete or dictionary traversal is required;
- character-by-character pruning can reduce search.

Common uses:

- autocomplete;
- spell checking;
- prefix counts;
- word search in grids;
- routing prefixes;
- dictionary segmentation.

Memory cue:

> Paths mean prefixes; end markers mean words.

---

## 18. Edge cases

| Operations | Expected behavior |
|---|---|
| new trie, `search("a")` | false |
| insert `"a"`, search `"a"` | true |
| insert `"apple"`, search `"app"` | false |
| insert `"apple"`, startsWith `"app"` | true |
| then insert `"app"` | both words searchable |
| insert same word twice | remains true without duplicate paths |
| different first letters | branch from root |

The official constraints use non-empty lowercase words and prefixes. Under a broader contract, inserting the empty string would mark the root as `isWord = true`.

---

## 19. Notebook-ready notes

### 📚 Concept

**Trie — prefix tree**

```text
Node:
  children: character → child node
  isWord: complete word ends here

insert:
  follow/create each character
  finalNode.isWord = true

search:
  path exists AND finalNode.isWord

startsWith:
  path exists
```

### 🧠 My understanding

A root-to-node path represents a prefix. Multiple words reuse shared prefix nodes. Path existence alone answers prefix queries, while `isWord` records whether that exact path was inserted as a complete word.

### 💼 Interview line

> “The path indexes the prefix; the end marker distinguishes a stored word.”

### ⚠️ Traps

- Mark only the final insertion node.
- Exact search checks `isWord`; prefix search does not.
- Each node owns a separate children structure.
- Total storage is based on distinct prefix nodes.

---

## 20. Dheerix Glance

```text
IMPLEMENT TRIE

Root meaning:      empty prefix
Edge meaning:      one character
Path meaning:      prefix
Node children:     Map<char, TrieNode>
End marker:        isWord
Insert:            create missing path, mark end
Search:            path exists + end marked
StartsWith:        path exists only
Operation time:    O(L)
Total space:       O(total distinct prefix characters)
Memory cue:        “Path is prefix; marker is word.”
```

---

## 21. Recall test

Without looking back:

1. What does a trie node path represent?
2. Why is `isWord` required?
3. How do `search` and `startsWith` differ?
4. What does insertion do when a prefix path already exists?
5. Why is a full-word set weaker for prefix queries?
6. What are the operation and total-space complexities?
7. What trade-off exists between `Map` children and 26-element arrays?
8. What must deletion preserve when words share prefixes?

