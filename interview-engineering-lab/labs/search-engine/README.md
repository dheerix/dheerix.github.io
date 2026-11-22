# Search Engine Lab

Make approved document content searchable and learn why a result ranks where it
does.

## Interview competencies

- Inverted indexes, mappings, analyzers, and tokenization
- Query versus filter context
- BM25 intuition, field boosts, and structured signals
- Index lifecycle, aliases, reindexing, shards, and replicas
- Relevance evaluation, latency, and operational trade-offs

## Experiment 01 — Analyzer and ranking behavior

Create a small judged corpus of 20–50 approved records and 10 representative
queries. Compare at least two analyzer/mapping choices and explain ranking changes.

Produce:

1. The document mapping and the reason for each important field type.
2. Expected tokens for three difficult inputs.
3. Query judgments before tuning.
4. A comparison using a simple metric such as precision@5 or reciprocal rank.
5. One relevance improvement and one regression it could cause.

## Follow-up questions

- Why not search the transactional database directly?
- What creates stale search results, and how should the product represent them?
- When should a field be `text`, `keyword`, or both?
- How do shard count and replicas affect reads, writes, recovery, and cost?
- How would you migrate a mapping without downtime?

## Exit criteria

- Can predict basic analyzer output and diagnose a surprising match.
- Can explain BM25 without relying on its formula.
- Can distinguish relevance tuning from retrieval correctness.
- Can propose a safe reindex and alias cutover.
