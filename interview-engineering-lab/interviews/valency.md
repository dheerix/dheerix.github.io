# Valency

## Working hypothesis

Prioritize document processing, structured extraction, AI orchestration,
validation, and human-in-the-loop workflow design. Validate this against the
current role and loop.

## Best evidence from the shared system

- Versioned extraction schema with field provenance
- Failure taxonomy and fixed evaluation dataset
- Confidence-based human-review routing
- Review state machine and audit trail
- Idempotent processing and safe replay behavior

## Questions to rehearse

1. Design ingestion and extraction for heterogeneous business documents.
2. Evolve an extraction schema without breaking jobs already in flight.
3. Decide when a result is accepted, retried, rejected, or sent to review.
4. Measure extraction quality when some fields are ambiguous.
5. Preserve provenance, privacy, and auditability across the workflow.

## Unknowns to resolve

- [ ] Exact interview stages and duration
- [ ] Domain-specific document types
- [ ] Quality, latency, and review-volume targets
- [ ] Expected AI/ML depth versus platform depth
- [ ] Security and compliance expectations
