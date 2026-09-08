# ADR 0002: Versioned central plans with repository projections

- Status: Accepted
- Date: 2026-09-07

## Context

A cross-repository feature needs one shared view of scope, dependencies,
acceptance criteria, and workflow. Each repository also needs a local artifact
that an implementation agent can consume without opening the PlanForge
workspace.

Independent plans per repository would allow shared decisions and acceptance
criteria to drift. A single plan copied everywhere would give repository agents
too much unrelated context and would not provide clear ownership boundaries.

The product requirement may change after planning. The system therefore needs
history without allowing old implementation artifacts to change silently.

## Decision

PlanForge generates:

1. one central execution plan for the complete feature;
2. one repository-scoped projection for each affected repository;
3. one repository-local projection and ticket pack under
   `.planforge/<planId>/` when the checkout is available.

Every artifact carries the same:

```text
planId
planVersion
schemaVersion
```

The central plan remains the authoritative machine-readable representation of
the confirmed feature decisions. Repository projections may narrow the work to
their repository, but may not introduce independent shared decisions.

When the PRD or Linear scope changes after a plan version is frozen:

```text
increment planVersion
→ regenerate central plan
→ regenerate every repository projection and ticket pack
→ validate the complete artifact set
→ resume execution from the new version
```

An existing plan version is immutable as an artifact. The feature itself is not
immutable; it evolves through explicit plan versions.

## Rationale

This provides a stable contract for implementation agents while preserving
Linear as the product and workflow source of truth. Repository-local artifacts
make work portable across teams and Codex tasks. Shared identifiers and
validation prevent one repository from quietly executing against a different
feature version.

## Consequences

PlanForge must validate:

- matching `planId` and `planVersion` across artifacts;
- repository ownership of tasks and acceptance criteria;
- dependency references;
- required workflow phases;
- required verification methods;
- freshness of repository-local projections.

Regeneration must be deterministic from the saved freeze manifest. Editing a
repository projection independently creates drift and should be detected or
overwritten by regeneration.

The repository-local projection is an implementation input, not a new source
of truth. The central archive is a regeneration and audit source, not a runtime
dependency for an agent working inside the repository.

## Re-evaluation triggers

Revisit this decision if:

- repository projections become too large or difficult to consume;
- teams require repository-owned plan extensions;
- Linear gains a native cross-repository execution contract;
- plan regeneration causes unacceptable disruption to active work; or
- PlanForge introduces durable execution state beyond planning and evidence.
