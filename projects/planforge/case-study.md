# PlanForge case study: two real delivery findings

This case study uses the real examples checked into the PlanForge repository.
They demonstrate the value of comparing frozen intent with implementation
evidence across repositories and workflows.

## Case 1: Appraisal-signal contract drift

The versioned plan covered an appraisal-signal workflow spanning lead,
seller-service, seller-UI, messaging configuration, and release verification.

The frozen contract defined `inventoryFilter` as the canonical request field
with values `All`, `NotInStock`, and `Appraisal`. Repository evidence showed
that the active seller UI request model still serialized `parkedStatus`.

PlanForge emitted `DEV-001`:

- category: `contract-drift`
- severity: `blocker`
- owner: `seller-ui`
- status: `resolved`
- action: align the UI serializer and tests with `inventoryFilter`

This is the clearest proof of the PlanForge thesis. Each repository could look
reasonable in isolation, while the integration contract was inconsistent. The
finding is useful because it contains expected behavior, actual evidence,
impact, owner, recommendation, and a Linear reference.

## Case 2: Deferred-inspection recovery gap

The requirement was to stop automatically creating an active inspection when
a lead was created. A merged change implemented that immediate behavior, but
the deferred workflow had no durable request or inactive inspection data to
recover later.

PlanForge emitted `DEV-002`:

- category: `deferred-recovery-gap`
- severity: `blocker`
- owner: `leads-service`
- status: `resolving`
- action: persist the request/data without activating it until Add to Parked

This demonstrates a deeper form of review than ticket matching. The immediate
acceptance criterion can appear satisfied while the later state transition is
impossible because the required durable state was discarded.

## Evidence boundary and limitation

These findings must not be presented as two findings from one canonical plan:

- `DEV-001` belongs to the appraisal-signal plan.
- `DEV-002` belongs to a related deferred-inspection plan.
- The generated `DEV-002` artifact correctly includes a provenance warning
  requiring confirmation of the Linear relationship before posting.

That warning is itself useful evidence. It shows that PlanForge has begun to
protect the plan/evidence boundary, but the portfolio should not claim that
cross-project relationship resolution is complete until the relationship is
explicitly modeled and validated.

## What this proves about PlanForge

The examples establish four meaningful capabilities:

1. A versioned plan can act as a comparison baseline.
2. Evidence can be collected from multiple repositories, PRs, and Linear
   artifacts without changing those sources.
3. Deterministic rules can identify both contract drift and missing recovery
   state.
4. Findings can be expressed as reviewable delivery decisions rather than an
   opaque dashboard score.

They do not yet prove autonomous execution, safe automatic remediation,
production-scale freshness, or that the local control plane can replace any
part of Linear. Those remain future investigation areas.

The implementation validation suite also passed on 2026-09-07, including
foundation, execution-plan, workspace-discovery, and workspace-server tests.
This verifies the checked-in implementation paths; it does not replace a
production run against live repositories and pull requests.

## Portfolio conclusion

PlanForge is significant beyond a Codex planning mode because these examples
persist a cross-repository baseline and compare later implementation evidence
against it. A Codex plan can help one session reason about intended work;
PlanForge adds durable identity, repository projections, evidence provenance,
deviation lifecycle, and a shared tech-lead review surface.

The next implementation-level proof is to run the same evidence path against a
single canonical project where all linked PRs, repository states, and final
verification records are attached to the same `planId` and `planVersion`.
