# ADR 0001: PlanForge as a cross-repository engineering control plane

- Status: Accepted
- Date: 2026-09-07

## Context

Codex Plan mode is effective for understanding a coding task, inspecting a
repository, producing an implementation plan, and executing work within an
engineering task.

It does not by itself provide the durable organizational contract needed for a
feature that spans multiple repositories, teams, Linear tickets, pull
requests, verification evidence, and implementation deviations.

PlanForge began as a planning skill but has evolved toward a broader system:

```text
Linear/PRD
  → cross-repository technical plan
  → repository projections and tickets
  → PR and verification evidence
  → deviation findings
  → Linear and HTML review surfaces
```

## Decision

PlanForge is a cross-repository engineering control plane. It coordinates
planning artifacts and implementation evidence across Linear, repositories,
and pull requests.

The ownership boundaries are:

- Linear remains the canonical product and workflow system.
- GitHub pull-request approval remains the code-review authority.
- Codex or engineers perform implementation work.
- PlanForge generates versioned plans, repository projections, evidence
  comparisons, deviation findings, and review surfaces.

PlanForge does not replace Codex Plan mode. Codex remains the task-level
execution and reasoning engine; PlanForge supplies durable cross-repository
context and traceability.

## Initial scope

PlanForge owns:

- cross-repository plan interpretation and mapping;
- versioned machine-readable plan artifacts;
- repository-local execution projections;
- ticket and pull-request relationship analysis;
- acceptance and verification evidence mapping;
- suspected or confirmed deviation reports;
- Linear comments and read-only HTML views.

## Explicit non-goals

PlanForge does not initially:

- replace Linear status transitions;
- replace GitHub code-review approval;
- silently mutate a frozen plan version;
- autonomously modify production code;
- add agents solely to make the system appear agentic;
- become a second project-management database.

## Rationale

This boundary gives PlanForge a meaningful role beyond generating plans while
avoiding duplication of tools that already own the workflow. Its durable value
is preserving intent and making cross-repository execution evidence visible.

The first proof of value is not autonomous implementation. It is detecting a
meaningful integration or business deviation that would otherwise be difficult
to see across tickets and pull requests.

## Consequences

PlanForge must maintain stable identifiers and relationships across:

- Linear project and ticket;
- plan and plan version;
- repository and repository projection;
- acceptance criterion;
- pull request;
- verification evidence;
- deviation finding.

Every derived view must identify its source plan version and evidence
freshness. PlanForge must also tolerate partial implementation, multiple PRs
per ticket, stacked PRs, and changes to the PRD after a plan version is frozen.

## Re-evaluation triggers

Revisit this decision if:

- Linear or GitHub cannot provide sufficient cross-repository traceability;
- PlanForge needs durable execution state beyond evidence and planning;
- bounded agents begin executing tasks;
- PlanForge must own workflow transitions for a product reason; or
- the cost of maintaining projections exceeds the value of the control plane.
