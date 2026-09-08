# SDE3 engineering-depth cheatsheet

Use this for any meaningful feature, PR, incident, migration, or system change.

## Core loop

```text
System Design
  → ADR
  → Implementation Evidence
  → Operational Evidence
  → Outcome
```

Working method:

```text
Ask → Challenge → Teach → Decide → Document → Verify
```

## Five questions for every change

```text
1. What changed?
2. What invariant could break?
3. What happens under retry or concurrency?
4. How was it verified?
5. What will alert us if it fails?
```

## 1. System design prompts

### Boundaries

- What problem and business constraint are we solving?
- What is out of scope?
- Which services, repositories, teams, and dependencies are involved?
- Who owns each state and decision?
- What is the source of truth?

### Correctness

- What state exists and where?
- What must always remain true?
- What does partial, stale, duplicated, or missing state mean?
- What transitions are valid?

### Distributed behavior

- What are the delivery and ordering guarantees?
- Can events be delayed, duplicated, lost, or reordered?
- What happens under retry, timeout, concurrency, and partial failure?
- Is the operation idempotent?
- How are conflicts resolved?

### Safety

- How is this rolled out and rolled back?
- Is it backward compatible?
- What data can be lost, duplicated, or made unrecoverable?
- What are the security, cost, capacity, and retention implications?

## 2. When to create an ADR

Create one when the decision:

- has meaningful alternatives or trade-offs;
- affects service or team ownership;
- changes correctness, consistency, availability, or security;
- is difficult to reverse;
- future engineers might otherwise need to rediscover it.

ADR minimum:

```text
Context → Decision → Invariants → Alternatives → Trade-offs
→ Failure behavior → Operational consequences → Verification
→ Re-evaluation triggers
```

## 3. Implementation evidence

Collect links to:

- PRs and commits;
- relevant code paths;
- unit, integration, contract, and end-to-end tests;
- migrations and compatibility checks;
- review decisions and cross-team discussion;
- failure, retry, concurrency, or replay tests;
- rollout and rollback evidence;
- design-versus-implementation deviations.

Label claims:

```text
Observed | Decided | Assumed | Open
```

## 4. Operational evidence

Measure what exposes the system’s failure modes.

### Reliability

```text
success/error rate
timeouts
retry count and retry exhaustion
dead-letter messages
failed transactions
deadlocks and lock wait
recovery time
```

### Correctness and convergence

```text
invariant violations
partial records and age
duplicate/conflicting state
source-of-truth vs projection mismatches
stale/rejected events
reconciliation success/failure
```

### Performance and capacity

```text
p50 / p95 / p99 latency
throughput
queue depth and message age
database latency
CPU, memory, storage, and connection utilization
capacity headroom
```

### Ownership

For each important metric, know:

```text
Owner → Dashboard → Threshold → Action → Escalation
```

## 5. Outcome record

Close the loop with:

```text
Problem before
→ Decision and implementation
→ Evidence collected
→ Measured result
→ Remaining risk
→ Next improvement
```

Never invent a metric. Write `not measured` and define how it will be measured.

## SDE3 evaluation lens

| Area | Evidence of depth |
|---|---|
| Reasoning | Constraints, invariants, alternatives, failure modes |
| Distributed systems | Ordering, retries, idempotency, consistency, concurrency, recovery |
| Production ownership | Metrics, alerts, capacity, security, cost, rollback |
| Communication | Clear design, decision, trade-off, and action |
| Leadership | Cross-team alignment, disagreement handling, ownership clarity |
| Outcomes | Measurable user, business, reliability, or delivery impact |

## Seller-service concurrency example

Two independent event streams contributed different halves of one relationship.
The design used a partial `InspectionId`-keyed cache and a transactional,
row-serialized update.

Known operational follow-ups:

```text
Pulsar retry/redelivery counts
Consumer error rate
Partial-cache count and age
Cache-to-listing projection mismatches
Lock contention and deadlocks
Missed inventoryFilter=Appraisal classifications
```

## Fast PR version

Before approving or merging, answer:

```text
□ What changed?
□ What invariant could break?
□ What happens if the event/request is repeated?
□ What happens if two writers race?
□ What test proves the failure path?
□ What metric or alert detects production failure?
□ Who owns recovery?
```
