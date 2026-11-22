# Module 01 — Interview Defense and Knowledge Gaps

## Project positioning: OneSearch

**Confirmed:** worked on Holland & Barrett OneSearch modernizing legacy Oracle-backed search to Elasticsearch and building/integrating .NET search APIs, under a Principal Engineer.

**Unknown; do not invent:** who selected Elasticsearch, ownership of index creation and mappings, synonym/analyzer tuning, actual data migration and CDC design, cutover process, exact throughput/latency figures and relevance impact.

A defensible opening: "I contributed to the Oracle-to-Elasticsearch search modernization and .NET search API work. I can explain the architecture and trade-offs; for the parts led by the Principal Engineer, I distinguish my implementation work from broader design decisions."

## Observed diagnostic history

- **Section 1**: Understood leading-wildcard search cost, refresh visibility and recall/precision. Initially overclaimed that SQL cannot support relevance or semantic search. Correction: Oracle full-text and modern DB vector capabilities exist.
- **Section 2**: Initially mixed refresh, fsync and flush. Corrected through a write-path trace and explicit memory/page-cache model.
- **Section 3**: Correctly reasoned that a promoted replica may need an updated searcher view, independently of successful replication.
- **Latency analysis**: Correctly recognized API/network/coordination overhead beyond Lucene query execution. Need to explicitly investigate queueing, fetch, serialization, critical-path tracing.

Treat scores from short responses as diagnostics, not an assessment of overall seniority.

## Core interview questions and model answers

### 1. Why is an inverted index useful?

> "A conventional leading-wildcard SQL LIKE may need broad scans because a B-tree doesn't have a usable leading prefix. A term-to-document inverted index can identify matching candidates by consulting postings lists. It also supports frequency/position information for ranking and phrase matching. But relational databases have full-text options, so I'd compare real workloads and capabilities rather than assume Elasticsearch always wins."

Follow-up: When can Oracle Text or a functional/other index make database search competitive?

### 2. Why is an acknowledged write not immediately searchable?

> "The write can be accepted and durably recorded in the translog before a refresh opens a Lucene searcher that sees the new index changes. Refresh controls search visibility. GET by ID uses a real-time retrieval path and may see the updated document earlier."

Follow-up: Difference between `refresh=true` and `refresh=wait_for`; throughput implications.

### 3. Explain translog, refresh, flush and merge.

> "The translog protects operations after the durable Lucene commit. Refresh opens a newer searchable view without necessarily making a durable commit. Flush establishes a durable Lucene commit and advances the translog lifecycle. Merging consolidates immutable segments and can reclaim deleted-document space."

Follow-up: Why do file-backed segments remain searchable from OS page cache after commit?

### 4. What happens after a primary shard fails?

> "Under the normal replication protocol, in-sync replicas have processed acknowledged operations. An eligible replica can be promoted. Each replica has its own local Lucene segments and translog, so search visibility can require refresh independent of having processed the write. A client timeout during failure does not prove the write failed."

Follow-up: Why is replication not equivalent to backup?

### 5. How does distributed search execute?

> "A coordinator selects eligible copies of targeted shards. Each shard executes the query through its current Lucene reader, finds candidates and produces local scores/top hits. The coordinator merges the top results and fetches fields for the winning documents. Ranking and fetching have different costs; many shards can increase fan-out."

Follow-up: Why can BM25 differ across shards? When would DFS help?

### 6. How do you migrate Oracle search without losing changes?

> "Use a consistent snapshot and linked CDC position, preserve stable IDs, apply ordered source versions and handle deletes with durable tombstones or an equivalent version ledger. Inspect bulk item outcomes, reconcile records and source versions, validate relevance/freshness, then switch a read alias. Keep rollback synchronization in mind."

Follow-up: Old bulk insert arrives long after v103 delete; why can external hard-delete versioning alone fail?

### 7. How do you improve poor relevance?

> "First separate retrieval failure from ranking failure. Inspect mappings, analyzers, indexed fields, filters and query type. Test changes on labeled query-document judgments, then consider field boosts, synonyms, taxonomy, vector retrieval or reranking only when appropriate. Measure Precision@K/Recall@K/NDCG, latency and regressions."

Follow-up: Why is fuzzy matching not semantic search?

### 8. How do you debug 800ms latency if each shard query profiles at 40ms?

> "Compare API duration, Elasticsearch took and shard profiles. Examine queueing, coordinating-node work, fetch, serialization, network, retries and node contention. The Profile API does not explain all end-to-end time. Measure before changing query design or shard count."

Follow-up: A reindex causes rising merge I/O and search queues; how to prove causation?

### 9. How many shards for 12 million documents?

> "Document count alone isn't sufficient. Establish index byte size, query complexity, traffic, updates, node resources, recovery/availability requirements and growth; benchmark different layouts. Replicas address redundancy and serving capacity, not a magical decrease in per-query latency."

Follow-up: How can custom tenant routing create hot shards?

### 10. When choose hybrid retrieval?

> "For exact identifiers and constrained terms, lexical search is essential. Embeddings can improve vocabulary mismatch. I'd compare BM25 with hybrid fusion and potentially cross-encoder reranking, using judged queries and production latency, rather than assuming semantic similarity proves correctness."

Follow-up: What happens when the embedding model changes but the existing document vectors are not rebuilt?

## Open defense scenarios

1. A snapshot bulk worker reindexes v100 after a v103 deletion; design a safe long-delay retry strategy.
2. Candidate index contains 700 mapping failures, 300 unprocessed documents and CDC backlog of 25,000 events; product manager requests immediate cutover because search is faster. Define cutover gate and acceptable risk.
3. Client GET returns updated price 10.99 while search still shows 12.99. Trace the views and refresh.
4. Heavy reindex increases merge activity, disk I/O and p95. Identify evidence that would confirm or reject merge contention.
5. Explain a personal OneSearch contribution precisely without inflating architecture ownership.

## Immediate revision priorities

1. Refresh ≠ fsync ≠ flush; memorize **mechanisms**, not just names.
2. Distinguish source-of-truth correctness from Elasticsearch's replication guarantees.
3. Understand matching, scoring and fetching as distinct stages.
4. Debug with measurements from the full critical path.
5. Confirm actual OneSearch responsibilities before the technical interview.

## Curriculum boundary

Module 01 coverage complete; start Module 02 Chapter 05 (Guardlane / production ML) next. These notes are intended for later handbook/PDF extraction, not a final approved PDF edition.
