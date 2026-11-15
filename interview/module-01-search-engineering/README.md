# Module 01 — Search Engineering & Information Retrieval

Senior / Tech Lead interview handbook. Prepared for MaintainX Senior Search Developer, with retrieval foundations applicable to Foci and Valency.

> **Scope and provenance:** These notes are educational examples based on our interview curriculum. The fictional product catalog, numeric workload figures and suggested architectures are **not** statements about Holland & Barrett's implementation. Confirm personal responsibilities and any confidential details before incorporating them into public-facing interview stories.

## Chapters

1. [Production Search Architecture](01-production-search-architecture.md) — inverted index, analysis, Lucene segments, refresh, translog, commits and durability.
2. [Distributed Search and Migration](02-distributed-search-and-migration.md) — primary/replica shards, routing, query/fetch, CDC, external versioning and tombstones.
3. [Relevance and Hybrid Retrieval](03-relevance-and-hybrid-retrieval.md) — BM25, precision/recall, NDCG, embeddings, ANN, RRF and reranking.
4. [Performance and Reliability](04-performance-and-reliability.md) — tracing, search profiling, resource contention, pagination, caching and incident diagnosis.
5. [Interview Defense](interview-defense.md) — questions, natural spoken answers, diagnostic corrections and revision priorities.

## Learning approach

For each chapter: define the problem; trace real execution flow; explain internals; identify edge cases and failure modes; show example queries; compare trade-offs; then practice speaking a defensible interview answer.

### OneSearch framing

**Known experience:** participated in Oracle-to-Elasticsearch search modernization and .NET search APIs at Holland & Barrett while working under a Principal Engineer.

**Do not claim without confirming:** ownership of initial architecture, CDC implementation, exact relevance tuning, production metrics, shard sizing, full migration cutover or measurable performance gains.

## Study status

- Module 01 instructional coverage completed for current interview preparation.
- Deep technical defense and retrospective reconstruction of actual OneSearch responsibilities remain optional follow-up tasks.
- Module 02 begins with production classification/Guardlane, with retrieval concepts reused for RAG.

## Sources / references

- [Elasticsearch near-real-time search](https://www.elastic.co/docs/manage-data/data-store/near-real-time-search)
- [Elasticsearch translog settings](https://www.elastic.co/docs/reference/elasticsearch/index-settings/translog)
- [Elasticsearch search API](https://www.elastic.co/docs/api/doc/elasticsearch/operation/operation-search)
- [Elasticsearch index API](https://www.elastic.co/docs/api/doc/elasticsearch/operation/operation-index-2)
- [Elasticsearch reference documentation](https://www.elastic.co/docs/reference/elasticsearch/)
