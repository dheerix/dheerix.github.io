# ADR 0003: Evidence-backed deviation findings

- Status: Accepted
- Date: 2026-09-07

## Context

The approved plan describes intended scope, repository ownership,
dependencies, acceptance criteria, and verification. During implementation,
the actual evidence is distributed across Linear tickets, GitHub pull
requests, changed files, repository state, CI results, and review discussion.

Some differences are confirmed defects. Others are legitimate implementation
variations or incomplete evidence. A comparison system that labels every
difference as an error would create noise and reduce trust.

PlanForge must improve visibility without creating a parallel workflow system.

## Decision

PlanForge treats plan-versus-implementation results as evidence-backed findings
or questions, not automatic workflow decisions.

Each finding records:

```text
finding type: confirmed | suspected | question
confidence: high | medium | low
status: open | discussed | accepted | dismissed | corrected | needs-replan
category: scope | contract-drift | integration-risk | business-rule |
          verification-gap | lifecycle-recovery-gap
evidence: Linear, repository, pull-request, CI, or other supported records
```

The first delivery surface is a concise Linear comment. Later projections may
include a GitHub PR comment and a read-only HTML detail view. All projections
come from the same versioned analysis artifact.

PlanForge does not:

- automatically change Linear status;
- automatically approve or reject a pull request;
- silently rewrite the frozen plan;
- claim a business defect from a diff without sufficient evidence;
- treat a suspected finding as confirmed.

## Finding lifecycle

```text
evidence collected
  → finding detected
  → suspected/question
  → engineer discussion
  → confirmed, accepted, dismissed, or corrected
  → new plan version if scope or shared decisions change
```

An accepted implementation variation is not necessarily a defect. A new plan
version is required when the change affects approved scope, shared decisions,
dependencies, acceptance criteria, or other implementation contracts.

## Workflow ownership

- Linear owns ticket status and project workflow.
- GitHub owns pull-request review and merge state.
- Engineers own the decision to accept, correct, dismiss, or replan.
- PlanForge owns evidence collection, comparison, finding explanation, and
  review-oriented projections.

## Rationale

This model makes PlanForge useful as a technical-lead visibility layer without
turning it into an unreliable autonomous reviewer or a second project tracker.
It also preserves uncertainty, which is essential when repository evidence is
incomplete or when business meaning cannot be proven from code changes alone.

## Consequences

The analysis schema must preserve provenance and freshness for every finding.
The system must support multiple pull requests per ticket, stacked pull
requests, partial merges, amended links, and missing evidence.

The Linear comment should be the canonical human-readable summary. GitHub and
HTML views should link back to it and to exact evidence rather than generating
independent interpretations.

## Re-evaluation triggers

Revisit this decision if:

- PlanForge gains authority to mutate workflow state;
- evidence quality is high enough for automated correction decisions;
- teams require policy-specific enforcement rather than review findings; or
- the finding lifecycle becomes more complex than the underlying Linear/GitHub
  workflow.
