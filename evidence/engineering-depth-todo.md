# SDE3 evidence TODO

This list is for proving technical depth and technical communication. It is
not a generic study checklist. Every item should produce an artifact that can
be discussed in an interview, design review, promotion packet, or portfolio.

## Revisit queue

This is the current next-action list. Resume from the first unfinished item.

1. **Operational evidence for seller-service** — measure partial-cache age,
   Pulsar redelivery/retry counts, consumer errors, lock contention, and
   cache-to-listing projection mismatches.
2. **Operational evidence for Guardlane** — verify the 750ms target against
   p95/p99 latency, timeout/error/fail-open counts, and evidence retention.
3. **Operational evidence for PlanForge** — run one canonical project with
   one `planId`/`planVersion` across all repositories, PRs, deviations, and
   final verification.
4. **Outcome records** — capture measurable impact for seller-service,
   Guardlane, and PlanForge; explicitly mark unavailable metrics.
5. **Leadership narratives** — document three cross-team decisions, including
   the cross-team discussion behind the seller-service concurrency change.
6. **Implementation-depth artifact** — select one additional difficult PR and
   connect code paths, tests, review feedback, and production outcome.
7. **AI Upload Chatbot** — begin only after the operational and outcome gaps
   above are addressed.

## Priority order

### 1. Add one distributed-systems case study — documented

**Why:** Guardlane and PlanForge currently prove AI-system and cross-repository
architecture. A separate distributed-systems example is the largest breadth
gap.

**Chosen:** a seller-service change involving independent appraisal-link and
listing/inspection events, retries/redelivery, consistency, and concurrency.

**General selection rule:** choose one real system involving queues/events, retries, consistency,
caching, concurrency, or a data migration. Prefer a system you have operated
or changed rather than an invented design.

**Produce:**

- problem and business constraints;
- architecture/context diagram;
- state ownership and invariants;
- normal and failure paths;
- consistency and concurrency model;
- capacity and scaling assumptions;
- alternatives and rejected designs;
- rollout, migration, observability, and rollback;
- one ADR and one short executive summary.

**Done when:** you can explain what happens during a dependency outage,
duplicate event, retry, partial deployment, and data inconsistency—and support
the answers with repository or production evidence.

Current artifact: [seller-service appraisal association case study](../projects/seller-service/appraisal-association-system-design.md).

Next: collect production evidence for partial-state duration, redelivery,
consumer errors, and cache/listing convergence. The concurrency strategy is
now recorded in the system-design ADR.

### 2. Add an operational evidence record

**Why:** Architecture claims become SDE3 evidence when connected to runtime
ownership and measurable outcomes.

For Guardlane or PlanForge, record:

- latency or freshness target;
- error and failure taxonomy;
- alerts and dashboards;
- security/data boundary;
- retention and deletion behavior;
- cost drivers;
- owner and escalation path;
- one incident, replay, load test, or failure simulation.

**Done when:** the document distinguishes observed measurements from proposed
targets and lists what would wake an engineer up at 2 a.m.

### 3. Capture measurable impact

For each completed project, create a one-page outcome record:

- problem before the change;
- decision and implementation;
- measurable result;
- evidence source;
- remaining limitation;
- what you would change with more time.

Use real numbers where available: p95 latency, error rate, incidents,
rework, delivery time, adoption, review findings, or cost. Do not invent
metrics; mark unavailable measurements as a follow-up.

### 4. Document technical leadership and influence

Create a decision narrative for three situations where you aligned people or
teams:

- disagreement and how it was resolved;
- a design review where you changed or defended an approach;
- mentoring, delegation, or raising another engineer's effectiveness.

Use the format: context → disagreement → options → decision → communication →
result → lesson. This is evidence of SDE3 scope beyond individual technical
execution.

### 5. Add implementation-depth artifacts

Select two difficult code changes from the real repositories and document:

- the code path and invariants;
- the debugging or investigation process;
- the change and why it was safe;
- tests and verification;
- review feedback;
- production or integration outcome.

Link to the actual PR, commit, test, or file. The goal is to connect system
design judgment to code-level execution.

### 6. Develop the AI Upload Chatbot only after the above

Use it as a focused production-AI design study covering permissions,
grounding, retrieval, evaluation, citations, uncertainty, retention, and
fallbacks. It should expand the portfolio, not become another unfinished
project competing with Guardlane and PlanForge.

## Working method for every item

Use the same loop:

```text
Ask → Challenge → Teach → Decide → Document → Verify
```

For each artifact, label every statement as one of:

- **Observed** — supported by code, logs, tests, dashboards, PRs, or incidents;
- **Decided** — an explicit architectural or product choice;
- **Assumed** — useful but not yet verified;
- **Open** — requires future evidence or a decision.

## Immediate next action

Start with item 1: collect the seller-service production evidence. If access to
production metrics is unavailable, record that limitation and define the exact
queries, dashboards, or alerts needed to obtain it later. Do not invent the
measurements.
