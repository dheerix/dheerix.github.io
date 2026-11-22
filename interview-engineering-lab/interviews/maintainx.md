# MaintainX

## Working hypothesis

Prioritize search depth, production system design, backend reliability, and clear
trade-off reasoning. Validate this against the current role and interview loop.

## Best evidence from the shared system

- Approved-record index design and mapping choices
- Analyzer and relevance evaluation results
- Transactional-source-to-search-index consistency strategy
- Zero-downtime reindex and alias cutover plan
- Capacity, shard, replica, latency, and failure reasoning

## Questions to rehearse

1. Design search for maintenance procedures and work-order content.
2. Diagnose why an exact equipment identifier ranks below partial text matches.
3. Keep search available while changing a mapping on a large index.
4. Explain how an approved database update reaches the index reliably.
5. Choose signals and an offline/online process for evaluating relevance.

## Unknowns to resolve

- [ ] Exact interview stages and duration
- [ ] Coding language and environment
- [ ] Elasticsearch depth expected
- [ ] Product/domain scenarios emphasized
- [ ] System-design scale assumptions
