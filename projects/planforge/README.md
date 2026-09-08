# PlanForge

Engineering control-plane learning record focused on transforming intent into
reliable, reviewable cross-repository work.

The dossier covers deterministic orchestration, context, state, dependencies,
retries, idempotency, approvals, verification, recovery, observability,
reproducibility, and cost.

## Documents

- [System design](system-design.md)
- [Implementation status](implementation-status.md)
- [Delivery case study](case-study.md)

## Architecture decisions

- [PlanForge as a cross-repository control plane](adrs/0001-planforge-as-cross-repository-control-plane.md)
- [Versioned central plans and repository projections](adrs/0002-versioned-central-plan-and-repository-projections.md)
- [Evidence-backed deviation findings](adrs/0003-evidence-backed-deviation-findings.md)
- [Aggregate change completion and independent verification](adrs/0004-aggregate-pr-completion-and-independent-verification.md)

The case study records an appraisal-signal contract-drift finding and a
deferred-recovery finding without exposing work-system links or identifiers.
