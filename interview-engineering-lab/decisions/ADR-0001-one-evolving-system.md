# ADR-0001 — Use one evolving system across interview tracks

Status: Accepted

Date: 2026-11-14

## Context

MaintainX, Foci, and Valency emphasize different areas, but the underlying
competencies overlap: distributed workflows, reliable backend systems, AI
integration, testing, and technical communication. Separate projects would repeat
scaffolding and fragment decisions and progress.

Interview preparation is the constraint. A polished product is not the goal, and
integration work can consume time without improving an interview skill.

## Decision

Use one conceptual document-processing platform with three focused lab tracks.
Share domain language and architectural decisions, but allow isolated experiments
until integration itself tests a target competency.

Keep deep general knowledge in the repository's existing `engineering/` area and
use this workspace as the interview-focused control plane.

## Alternatives considered

### One project per company

Rejected because it duplicates common concepts, setup, and failure handling while
making progress harder to compare.

### A fully integrated application from day one

Rejected because UI, deployment, and framework plumbing would create scope that
is not currently justified by interview needs.

### Notes and mocks only

Rejected because some claims—idempotency, concurrency behavior, relevance, and
evaluation quality—benefit from executable experiments and measured evidence.

## Consequences

- Concepts and decisions transfer across companies.
- Progress has one canonical ledger.
- Experiments can stay small and replaceable.
- Shared vocabulary may hide company-specific requirements, so company pages must
  record verified interview guidance.
- Integration remains optional and must be justified by a competency.

## Interview explanation

I chose one document-processing system because it exposes the overlapping hard
problems—reliable distributed processing, AI orchestration, and search—without
duplicating project setup. Each lab stays isolated until integration teaches a
specific competency, which keeps the work optimized for interview learning rather
than product polish.
