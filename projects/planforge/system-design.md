# PlanForge: System Design

- Status: Product architecture baseline
- Focus: converting engineering intent into reliable cross-repository work

## Core problem

Engineering intent is distributed across a Linear project, product documents,
multiple repositories, tickets, pull requests, and conversations. The main
risk is not generating prose; it is losing intent and integration constraints
between planning and implementation.

PlanForge turns that intent into a reviewable and eventually machine-executable
plan while preserving human approval at architectural decision points.

## Product evolution

### V1: approved cross-repository planning

Inputs:

- Linear project or issue link
- product/PRD requirements document
- one or more target repositories

PlanForge:

1. interprets the requirements;
2. maps requirements to technical implementation surfaces in each repository;
3. identifies ownership and cross-repository dependencies;
4. generates architecture artifacts such as flowcharts, sequence diagrams,
   component/class diagrams, file paths, and possible code-change locations;
5. runs the plan through engineering review and approvals;
6. freezes a versioned planning snapshot after engineering confirmation;
7. attaches the plan back to Linear;
8. creates separated tickets for the relevant repositories.

The frozen plan is the implementation baseline for that plan version. Linear
and the PRD remain the product source of truth; a later requirement change
creates a new plan version rather than silently changing the old snapshot.

### V2: machine-readable execution plan

V2 turns the central frozen plan into YAML-backed work units. The plan evolves
through these capability levels:

```text
task + acceptance criteria
  → task + repository/context
  → dependency-aware task graph
  → task graph + verification steps
  → executable workflow + approval and recovery state
```

Repository-specific tickets remain separate, but the central plan preserves
their dependency and integration relationships.

### Control-panel vision

The eventual control panel provides a single view of:

- approved plan and current stage
- repository-specific tickets
- pull requests and completion status
- verification results
- plan-versus-implementation deviations
- integration risks and unresolved approvals
- recovery or replanning actions

## Deviation as the first obvious use case

The most valuable near-term workflow is not autonomous execution. It is making
deviation obvious:

```text
frozen plan
  → actual tickets and PRs
  → changed files and behavior
  → plan/implementation comparison
  → highlighted deviation
  → engineer explains, accepts, or replans
```

The initial deviation experience should help identify:

- integration errors across repositories;
- business behavior that differs from the approved requirement;
- missing or changed acceptance criteria;
- unplanned scope;
- implementation that satisfies local tickets but breaks the system-level
  dependency graph.

This gives PlanForge a narrow, high-value proof point before autonomous
execution is attempted. PlanForge reports and links deviations; it does not
become the system that approves or corrects implementation work.

### Automatic evidence path

Linear is the planning hub. Its linked GitHub pull requests provide the
default implementation evidence:

```text
Linear plan/ticket
  → linked GitHub PRs
  → repository diffs and changed files
  → CI/test/verification evidence
  → plan-versus-implementation comparison
  → deviation report
```

The first implementation can therefore be mostly automatic. It should collect
linked PRs, resolve the actual commits and repositories, and compare them with
the frozen plan’s expected scope and acceptance criteria.

Automation is strongest for:

- missing or unexpected repositories;
- missing or unexpected files and symbols;
- unlinked or incomplete tickets/PRs;
- dependency order violations;
- absent verification evidence;
- changed scope.

Automation can identify likely integration and business risks, but should not
claim that a business requirement is satisfied from a diff alone. Those cases
should be marked for engineer review with the relevant plan criterion, code
change, and evidence side by side.

The design must handle real Git workflows such as stacked PRs, multiple PRs
for one ticket, partial merges, amended links, and PRs that touch shared files
outside the predicted scope.

### Delivery surfaces

Deviation results will be delivered in this order:

1. **Linear comment** — the first and canonical review output because Linear
   contains the approved plan and ticket relationships.
2. **GitHub PR comment** — an implementation-local summary linked back to the
   canonical Linear analysis.
3. **HTML viewer** — a richer, user-selected control-panel workspace.

The HTML viewer is an umbrella for multiple features rather than one fixed
dashboard. A user should be able to choose views such as:

- plan and dependency graph;
- repository and ticket progress;
- PR completion and verification evidence;
- plan-versus-implementation deviations;
- integration-risk review;
- approvals, decisions, and recovery state.

All surfaces should render from the same versioned PlanForge analysis model.
The Linear comment is the durable summary; PR comments and HTML views are
projections optimized for their respective workflows.

### First Linear deviation comment

The first comment should be short enough to read inside Linear and structured
enough for later projections:

```text
PlanForge deviation review

Plan: <plan id and revision>
Status: aligned | deviations found | review required
PRs reviewed: <links>

Summary
<one or two sentences>

Deviations
- [severity] <deviation>
  Planned: <plan task/criterion>
  Actual: <PR/file/evidence>
  Impact: <why it matters>
  Finding: confirmed | suspected | question
  Confidence: high | medium | low
  Review: open | accepted | dismissed | needs-replan

Verification
- <acceptance criterion> — verified / missing / human review

Integration risks
- <risk or none detected>

Decision needed
- <engineer action, or “none”>

Details: <HTML viewer link>
Generated from: <analysis version>
```

The comment should link to exact PRs, files, plan tasks, and verification
evidence where possible. It should never silently rewrite the frozen plan. A
developer’s explanation or accepted deviation should become a new piece of
evidence and, when the scope changes, a new plan revision.

### Findings are hypotheses until reviewed

PlanForge should be comfortable saying:

> “This may violate the integration requirement because repository A changed
> without the corresponding change in repository B. Please confirm whether the
> dependency is handled elsewhere.”

That is safer and more useful than asserting an integration defect from a diff
alone. Every finding therefore has both a finding type and a review state:

```text
detected → suspected/question → engineer review → confirmed/dismissed/accepted
                                                    ↓
                                                replan if needed
```

An accepted implementation variation is not necessarily a defect. It becomes
important when it changes scope, violates an invariant, weakens verification,
or leaves a business or integration requirement unresolved.

## Workflow authority

PlanForge must not create a parallel project-management workflow.

- Linear remains authoritative for project, ticket, and status transitions.
- GitHub pull-request approval remains authoritative for code review.
- PlanForge engineering confirmations are freeze gates for generated planning
  artifacts and ticket creation, not a second approval database.
- PlanForge writes reports and comments, then derives visibility from the
  linked Linear and GitHub state.

Useful derived overlays may include `deviated`, `off_track`, `discussed`, and
`corrected`, but they should point to evidence and should not replace Linear
workflow states. A correction is complete when the underlying Linear/GitHub
state and evidence show it is complete.

## Architectural boundary

PlanForge should be treated as a control plane, not as an unconstrained agent.

```text
requirements → interpretation → approved plan → execution evidence
                                      ↓
                              verification and deviation
```

Reasoning is useful for interpretation, mapping, and comparison. State,
approvals, dependencies, task status, and verification should be explicit and
durable rather than hidden in agent conversation history.

## Candidate plan unit

Each machine-readable task should eventually contain:

```yaml
plan_id: plan-...
task_id: task-...
repository: repo-name
scope:
  files: []
  symbols_or_blocks: []
  required_context: []
depends_on: []
description: ...
acceptance_criteria: []
verification:
  checks: []
  expected_evidence: []
approval:
  required: false
status: proposed
```

The schema should remain deliberately small until actual execution and
verification workflows prove which fields are necessary.

## Key invariants

- A plan snapshot cannot be frozen without the required engineering
  confirmations for that planning stage.
- A task cannot be ready when its dependencies are unresolved.
- A repository-specific task must retain its relationship to the central plan.
- Acceptance criteria must be testable or explicitly marked as human review.
- Implementation deviation must not silently mutate the frozen plan snapshot.
- A PRD/Linear requirement change creates a new plan version with traceability
  to the prior version.
- A merged PR marks the repository implementation as complete.
- A Linear ticket is implementation-complete only when all required PRs linked
  to that ticket are merged.
- Execution status and verification status are separate dimensions; a merged PR
  may still have pending end-to-end or business verification.

### Ticket completion aggregation

One ticket may span several repositories and therefore several pull requests.
PlanForge should aggregate implementation state rather than treating the first
merged PR as completion:

```text
ticket
  ├── required PR A: merged
  ├── required PR B: in review
  └── required PR C: merged

implementation: incomplete
```

Only when every required PR is merged does the ticket become implementation-
complete. Optional or superseded PRs must be explicitly marked in the linked
evidence; PlanForge should not infer that an unmerged PR is irrelevant.

After implementation completion, verification remains independent:

```text
all required PRs merged → implementation complete
verification evidence   → verified / pending / failed
```

## Open decisions

1. What evidence is sufficient to prove a task complete?
2. How should cross-repository dependencies block or unblock work?
3. Which deviations need only discussion, and which require a Linear/PRD
   change or new plan version?
4. Is the first control-panel implementation read-only, or does it perform
   ticket/status mutations?
5. Where does PlanForge stop and Codex execution begin?
