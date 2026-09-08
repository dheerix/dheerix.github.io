# ADR 0004: Aggregate PR completion and independent verification

- Status: Accepted
- Date: 2026-09-07

## Context

A single Linear ticket may span multiple repositories and therefore multiple
pull requests. One merged PR does not prove that the ticket’s implementation is
complete.

At the same time, a ticket can have all required PRs merged while end-to-end,
business, or release verification is still pending.

PlanForge must expose both realities without replacing Linear’s workflow state.

## Decision

PlanForge derives implementation completion at the ticket level from the full
set of linked pull requests.

```text
all required linked PRs merged → implementation complete
any required PR open/draft/changes requested → implementation incomplete
```

Every linked PR is required by default. A PR may be marked optional,
superseded, or unrelated only through explicit evidence or metadata. PlanForge
must not infer that an unmerged PR is irrelevant.

Verification is an independent dimension:

```text
implementation: complete | incomplete
verification: verified | pending | failed | not_applicable
```

Linear remains authoritative for ticket and project status. PlanForge reports
derived implementation and verification overlays but does not automatically
transition Linear issues.

## Example

```text
Feature ticket
  ├── service change: merged
  ├── UI change: in review
  └── messaging configuration: merged

Implementation: incomplete
Verification: pending
```

After all required PRs merge:

```text
Implementation: complete
Verification: pending
```

## Rationale

This prevents premature completion in cross-repository work while preserving
the difference between code merge and proving the system behavior. It also
allows the tech-lead view to identify “merged but not verified” work without
creating a competing task state machine.

## Consequences

The evidence model must support:

- multiple PRs per Linear ticket;
- repository and PR ownership;
- required, optional, and superseded relationships;
- stacked and partial PRs;
- CI and business verification evidence;
- stale or missing PR links;
- disagreements between derived implementation state and Linear status.

The UI and Linear comment should show the underlying PR set, not only the
aggregate result, so an engineer can explain why a ticket is incomplete.

## Re-evaluation triggers

Revisit this decision if Linear gains a reliable native multi-PR completion
model, if teams adopt a different ticket-to-PR convention, or if verification
becomes part of the merge gate rather than a separate workflow phase.
