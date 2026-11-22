# Engineering Lab

All three lab tracks evolve one conceptual platform. They may begin as design
experiments and small isolated programs; integration is optional and must earn its
time through interview value.

## Shared platform flow

```text
Upload → durable job → extract → validate → human review → approve → index → search
                    ↘ retry / dead letter / replay ↗
```

## Shared domain vocabulary

- `Document`: uploaded source and immutable identity
- `ProcessingJob`: asynchronous attempt to transform a document
- `Extraction`: structured candidate data plus provenance and confidence
- `Review`: human decision and corrections
- `ApprovedRecord`: canonical data eligible for downstream use
- `SearchDocument`: denormalized representation optimized for retrieval

## Scope guardrail

Start with interfaces, invariants, failure cases, and one executable experiment.
Do not add UI, authentication, deployment, or cloud infrastructure unless a
specific interview competency requires it.
