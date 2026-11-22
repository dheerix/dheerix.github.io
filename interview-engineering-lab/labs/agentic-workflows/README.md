# Agentic Workflows Lab

Extract structured information from documents while keeping behavior observable,
evaluated, and safe to review.

## Interview competencies

- Workflow versus autonomous-agent boundaries
- Typed tool contracts and deterministic orchestration
- Context selection, provenance, and token/cost budgets
- Evaluation datasets, rubrics, and regression testing
- Confidence, guardrails, fallbacks, and human review

## Experiment 01 — Reliable extraction contract

Define a schema for one document type and evaluate two extraction strategies on a
small fixed dataset. One strategy may be deterministic; the other may use a model
or model-shaped test double if credentials are unavailable.

Produce:

1. Typed input/output contracts with provenance for extracted fields.
2. A failure taxonomy: missing, malformed, unsupported, conflicting, and
   low-confidence values.
3. An evaluation set containing normal, ambiguous, and adversarial cases.
4. Field-level correctness plus a review-routing metric.
5. A trace showing what context and tools were used for one failed case.

## Follow-up questions

- Why use an agent here instead of a deterministic pipeline?
- Which decisions must remain deterministic?
- How do you detect silent quality regression?
- How do you prevent untrusted document content from controlling tools?
- How do you balance false acceptance against human-review volume?

## Exit criteria

- Outputs are typed, attributable, and reproducible enough to debug.
- Quality is measured against a fixed dataset.
- Low-confidence or invalid results fail safely.
- Agent autonomy is limited by an explicit engineering reason.
