# Engineering-depth operating model

This is the reusable process for turning normal engineering work into evidence
of SDE3-level technical depth and communication.

The goal is not to produce a large document for every change. The goal is to
remember the important questions, capture the decisions that matter, and leave
behind evidence that another engineer can inspect.

## The complete loop

```text
Real change
  → System design
  → ADR
  → Implementation evidence
  → Operational evidence
  → Outcome and communication
```

Use the working method at every stage:

```text
Ask → Challenge → Teach → Decide → Document → Verify
```

## Stage 1: System design

Answer these before or during implementation.

### Context and boundaries

- What user or business problem is being solved?
- What is explicitly out of scope?
- Which services, repositories, teams, and external dependencies are involved?
- Who owns each state and decision?
- What is the source of truth?

### State and correctness

- What state exists, and where is it stored?
- What are the invariants?
- What transitions are valid?
- What does partial, stale, duplicated, or missing state mean?
- What must never happen?

### Runtime behavior

- What is the normal request/event flow?
- Which parts are synchronous and which are asynchronous?
- What are the latency, freshness, and availability requirements?
- What happens when dependencies are slow, unavailable, or return bad data?

### Distributed-systems questions

- What are the delivery and ordering guarantees?
- Can messages be duplicated, delayed, lost, or reordered?
- What is the consistency model?
- Where can two writers update the same state concurrently?
- Is the operation idempotent?
- What is the retry boundary, and can retries create side effects?
- How are conflicts resolved?

### Change safety

- What is the migration or rollout plan?
- Is the change backward compatible?
- How is it tested under failure, not only success?
- How can it be rolled back?
- What data could be lost, duplicated, or made unrecoverable?

### Required design output

For a meaningful change, produce:

- one context or architecture diagram;
- one runtime or sequence diagram when timing/order matters;
- a short list of invariants;
- failure and recovery behavior;
- alternatives considered and why one was chosen.

## Stage 2: ADR

Create an ADR when a decision has meaningful trade-offs, affects ownership or
correctness, or will be difficult to reverse.

An ADR should contain:

1. **Context** — what forced the decision?
2. **Decision** — what will the system do?
3. **Invariants** — what must remain true?
4. **Alternatives** — what else was considered?
5. **Trade-offs** — what gets better and worse?
6. **Failure behavior** — what happens when the design is stressed?
7. **Operational consequences** — what must be measured or operated?
8. **Verification** — what proves the implementation matches the decision?
9. **Re-evaluation triggers** — when should the decision be revisited?

Do not use an ADR to record every implementation detail. Record the decision
that future engineers might otherwise have to rediscover.

## Stage 3: Implementation evidence

Collect evidence that the system design became real behavior.

- Relevant PRs and commits
- Code paths and ownership boundaries
- Unit, integration, contract, or end-to-end tests
- Migration output and compatibility checks
- Review discussion and decisions from other teams
- Failure-path or concurrency tests
- Rollout and rollback evidence
- Known deviations between design and implementation

Label each statement:

- **Observed** — directly supported by code, tests, logs, or a PR;
- **Decided** — explicitly agreed by engineers or product;
- **Assumed** — plausible but not verified;
- **Open** — requires a future decision or measurement.

## Stage 4: Operational things to measure

Not every system needs every metric. Select the metrics that expose its actual
failure modes.

### Correctness and convergence

- invariant violations;
- duplicate or conflicting state;
- partial records and their age;
- reconciliation success/failure;
- source-of-truth versus projection mismatches;
- stale or rejected events;
- replay success rate.

### Reliability

- request/event success rate;
- dependency error rate;
- timeout rate;
- retry count and retry exhaustion;
- dead-letter or poison-message count;
- failed database transactions;
- deadlocks and lock-wait time;
- recovery time after failure.

### Performance and capacity

- p50/p95/p99 latency;
- queue depth and message age;
- throughput;
- database query latency;
- connection pool and thread utilization;
- CPU, memory, and storage growth;
- capacity headroom and saturation point.

### Product and business behavior

- affected requests or users;
- false positives/negatives for AI decisions;
- missed or delayed business outcomes;
- feature adoption;
- support tickets or operational escalations;
- prevented defects or rework;
- delivery lead time.

### Safety and governance

- authorization failures;
- sensitive-data access and retention;
- audit-event completeness;
- policy or contract violations;
- human-review volume;
- automated decisions requiring override;
- cost per request, event, or workflow.

### Ownership and response

For every important metric, identify:

- who owns it;
- where it is visible;
- what threshold matters;
- what action follows an alert;
- whether the action is automated, manual, or a rollback.

## Stage 5: Outcome record

Close the loop with a short outcome note:

- problem before the change;
- decision made;
- implementation delivered;
- evidence collected;
- measured outcome;
- remaining risk;
- what should change next time.

Never invent an outcome. Write “not measured” and create a follow-up when the
measurement is important.

## How SDE3 depth is evaluated

I evaluate work across six dimensions:

| Dimension | Strong evidence looks like |
|---|---|
| Technical reasoning | You identify constraints, invariants, alternatives, and failure modes before choosing implementation details. |
| Distributed-systems judgment | You reason about ordering, retries, idempotency, consistency, concurrency, partial failure, and recovery. |
| Production ownership | You define metrics, alerts, capacity, security, cost, rollback, and operational ownership. |
| Communication | Another engineer can understand the system, decision, trade-off, and action without relying on conversation history. |
| Technical leadership | You align across teams, handle disagreement, clarify ownership, and improve the quality of the shared decision. |
| Outcome orientation | You connect the change to measurable user, business, reliability, or delivery impact. |

The evidence is stronger when it is:

- based on a real system;
- linked to code, tests, PRs, incidents, or metrics;
- explicit about uncertainty and limitations;
- understandable at both implementation and executive-summary levels;
- followed through to production behavior.

## Example: seller-service concurrency change

### System design

Two independent Pulsar event streams provide different halves of one
inspection-to-appraisal relationship. The design establishes an
inspection-keyed partial cache, preserves sibling fields, and protects the
read-modify-write with a consistent cache-then-listing lock order.

### ADR

The ADR records at-least-once delivery, `KeyShared` ordering, redelivery,
transaction and lock behavior, idempotency, partial state, last-processed-event
semantics, and known limitations.

### Implementation evidence

The merged PR includes integration coverage for both event orders, redelivery,
replacement listing cleanup, stale events, duplicate resolution, and response
projection.

### Operational measurements still needed

- Pulsar retry and redelivery counts;
- consumer error rate;
- age and count of partial cache rows;
- cache-to-listing projection mismatch count;
- lock wait/deadlock behavior;
- replay or reconciliation success;
- number of listings missed by `inventoryFilter=Appraisal` because an event
  never completed.

### SDE3 communication summary

> The change introduced a convergence problem, not just a new column. Two
> independently delivered events can race to update one relationship, so the
> implementation uses a partial inspection-keyed cache and a transactional,
> row-serialized update. The tests cover the known event races. The remaining
> production risk is permanently partial state because there is no repair or
> alerting path yet.

## Practical rule

For a small change, use the compressed version:

```text
What changed?
What invariant could break?
What happens under retry or concurrency?
How was it verified?
What will alert us if it fails?
```

For a system-level change, complete the full System Design → ADR → Evidence →
Operations → Outcome loop.
