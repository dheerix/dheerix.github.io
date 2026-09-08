# Portfolio alignment

The portfolio is not a collection of unrelated projects. It is a set of
systems that demonstrate different parts of SDE3-level engineering judgment.

| System | Primary question | Engineering depth demonstrated | Current evidence |
|---|---|---|---|
| Guardlane | How should an AI moderation decision participate in a latency-sensitive production workflow? | Service boundaries, failure semantics, policy ownership, availability trade-offs, evidence persistence, human review | Production integration analysis, timeout/failure ADRs, policy adapter design |
| PlanForge | How can engineering intent become traceable work across repositories without creating a competing project-management system? | Cross-repository planning, versioned state, dependency modeling, evidence provenance, deviation analysis, workflow authority | Implemented planning/evidence/control-plane features, PlanForge system design, four ADRs |
| AI Upload Chatbot | How should an AI product handle grounding, permissions, evaluation, and user-visible uncertainty? | Production AI lifecycle and safety design | Design study; implementation evidence not yet collected |
| System Design | What general principles explain the decisions above? | Distributed-systems reasoning, consistency, failure handling, ownership, operability | Shared methods and future case studies |

## What is already done

The strongest completed portfolio evidence is:

1. Guardlane has a concrete production decision record. The design explains why
   the business path fails open on timeout but fails closed on malformed or
   explicit moderation failures, and why contextual exceptions remain in the
   buyer-service rather than inside the generic moderation service.
2. PlanForge has moved beyond a planning prompt. Its implementation includes
   repository projections, evidence collection, deviation findings, status and
   freshness concepts, and a review surface. The ADRs establish that Linear
   remains authoritative and that PlanForge is an evidence/control plane.
3. The portfolio now separates system design from AI-systems engineering:
   system design captures reusable reasoning, while each AI system captures
   concrete runtime behavior, ownership, and operational trade-offs.

## What is not yet proven

The portfolio should not claim maturity solely because code and documents
exist. The following evidence is still required:

- Guardlane: measured timeout/error behavior in production, alert thresholds,
  decision/evidence retention, and a documented incident or replay exercise.
- PlanForge: a complete end-to-end run from a real Linear feature through
  repository projections, multiple linked PRs, deviation detection, and
  independently verified completion.
- PlanForge: evidence that its control-plane value is durable across users,
  sessions, repositories, and changing PRDs—not merely better than a single
  Codex planning session.
- Both systems: explicit cost, security, data-retention, and operational
  ownership decisions.

## Recommended sequence

### 1. Close the PlanForge vertical slice

Use one real feature with at least two repositories and multiple PRs. Capture
the central plan version, repository tasks, linked PR evidence, one suspected
deviation, a status change, and the final verification result. This is the
highest-value next step because it tests the product thesis end to end.

### 2. Convert implementation facts into evidence

Record commands, fixtures, generated artifacts, test results, and known
failures in a small case study. Separate what the implementation currently does
from what the ADR says it should do.

### 3. Add operational depth

For each system, document the useful metrics, failure taxonomy, data boundary,
retention rule, and owner. This turns architecture knowledge into production
engineering judgment.

### 4. Only then design agentic execution

Agentic setup is a later PlanForge capability, not a prerequisite for proving
the control-plane thesis. First establish durable plans, evidence, deviation
handling, and verification. Then decide where bounded automation is safe and
where human approval or recovery is mandatory.

## Definition of portfolio progress

Progress is demonstrated when each system can answer four questions with
artifacts:

1. What decision was made and why?
2. What happens when the normal path fails?
3. How do we know the implementation matches the intended behavior?
4. What evidence shows the decision works in the real operating environment?
