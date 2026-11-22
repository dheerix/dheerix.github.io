# System Design Scenario Cheat Sheet

> **See the situation → name the concept → connect the surrounding concepts → picture the implementation.**

## Scenario → Terminology → Connected Concepts

| Scenario / smell | Terminology to recall | Connected concepts / concrete hook |
|---|---|---|
| Same message arrives twice | **At-least-once delivery → Idempotency** | ACK, Inbox, stable EventId |
| DB update + processed EventId must agree | **Inbox / Processed Messages + local transaction** | atomicity; business update + EventId in one transaction |
| DB saved; event must definitely publish | **Transactional Outbox** | DB transaction → Outbox row → relay/worker → broker |
| Multi-service workflow partially succeeds | **Saga** | independently committed steps → compensation |
| Dependency temporarily fails | **Retry** | bounded retry, exponential backoff, jitter |
| Repeated retries amplify an unhealthy dependency | **Retry Storm / Retry Amplification** | timeout, backoff, jitter, cascading failure |
| Dependency keeps failing | **Circuit Breaker** | HttpClient resilience; CLOSED → OPEN → HALF-OPEN |
| One dependency/workload consumes too much capacity | **Bulkhead** | capacity isolation; often per-pod SemaphoreSlim / isolated worker pool |
| Work arrives faster than it can be processed | **Backpressure** | bounded Channel/queue, wait/reject/drop/degrade, load shedding |
| One customer dominates workers | **Noisy Neighbor** | fairness, per-tenant limits, bulkhead |
| Worker crashes halfway | **Checkpointing** | processing cursor, chunks, idempotency |
| Worker finishes but crashes before ACK | **Redelivery + Idempotency** | at-least-once, processed-message record |
| Huge background operation | **Durable Queue + Worker** | BackgroundService, checkpoint, retry |
| Huge file upload | **Control Plane / Data Plane** | presigned URL, S3/object storage, multipart, async processing |
| Read-heavy endpoint | **Cache-aside** | working set, TTL, invalidation |
| Cached value may be slightly old | **Bounded Staleness** | TTL, eventual consistency |
| Thousands miss same cache key | **Cache Stampede** | single-flight, request coalescing; per-key SemaphoreSlim locally |
| Many cache keys expire together | **TTL Jitter** | thundering herd |
| Cache dies and DB gets hammered | **Cascading Failure** | bulkhead, circuit breaker, load shedding |
| One vehicle/key gets huge traffic | **Hot Key** | skew, partitioning, aggregation |
| One broker partition overloaded | **Hot Partition / Skew** | partition key, consumer group |
| Need to know who is currently online | **Heartbeat + Lease/TTL** | ephemeral state, expiration |
| Browser only needs server updates | **SSE** | push, reconnect, resynchronization |
| Browser and server both continuously send | **WebSocket** | persistent bidirectional connection |
| Multiple API pods need same live update | **Pub/Sub + Fan-out** | ephemeral notification, SSE |
| Missing intermediate live event is okay | **State Convergence** | resynchronization, source of truth |
| Two users update same DB row | **Optimistic Concurrency** | rowversion, conditional update |
| Query loads huge entity graph | **Projection** | IQueryable, N+1, Include, indexes |
| DB connections are all occupied | **Connection Pool Exhaustion** | saturation, bounded concurrency |
| Multiple independent I/O calls | **Task.WhenAll** | async I/O, business independence |
| Too many concurrent calls in one process | **SemaphoreSlim** | bounded local concurrency; can implement a local bulkhead |
| Multiple pods must obey a strict shared limit | **Distributed / system-wide capacity control** | local SemaphoreSlim alone is insufficient |
| Optional recommendation service dies | **Graceful Degradation** | return null/empty optional section; preserve core VDP |
| Authoritative price is unavailable | **Fail Closed** | business invariant, correctness |
| One bad message repeatedly fails | **Poison Message → DLQ** | bounded retries |
| Shared DB/service is broadly down | **Infrastructure Outage** | circuit breaker, delayed retry, backpressure; don't immediately DLQ |

---

## Resilience — Concrete Mental Model

```text
Circuit Breaker
"Is the dependency healthy enough to call?"
→ HttpClient resilience policy
→ OPEN = fail fast
→ HALF-OPEN = limited recovery probes

Bulkhead
"How much capacity may this dependency/workload consume?"
→ capacity isolation
→ local .NET example: SemaphoreSlim(20) per caller pod
→ worker example: separate/bounded worker pools

Backpressure
"Work is arriving faster than we can safely process it."
→ bounded Channel<T> / bounded queue
→ wait, reject, drop, slow producer or degrade
```

### Important bulkhead scope rule

```text
Downstream safe concurrency ≈ 100
5 stable caller pods
~20 slots per pod
```

A per-pod `SemaphoreSlim(20)` is a **local implementation of a bulkhead**. It does not create a strict global limit. If autoscaling changes the number of pods, aggregate concurrency changes too. Only introduce distributed/global coordination when the business/capacity invariant actually requires it.

### Backpressure example

```text
Producer: 2,000 req/s
Consumer capacity: 500 req/s
          ↓
unbounded accumulation
          ↓
latency + memory + timeouts + retries
          ↓
cascading failure
```

Backpressure is the **response to overload**, not the overload itself: bound the waiting work and slow/reject/degrade when capacity is exhausted.

---

## Concept Chains — Recall These Cold

### Duplicate delivery
```text
Crash before ACK
→ Redelivery
→ At-least-once delivery
→ Idempotency
→ Stable EventId
→ Inbox / Processed Messages
→ Local DB transaction
```

### Reliable event publication
```text
DB change
→ Transactional Outbox
→ Outbox relay/worker
→ Broker
→ Consumer
→ Eventual consistency
```

### Distributed business workflow
```text
Saga
→ independently committed business steps
→ later permanent failure
→ Compensation
```

### Dependency failure
```text
Timeout
→ bounded Retry
→ Exponential backoff
→ Jitter
→ Circuit Breaker
→ Graceful degradation when optional
```

### Overload
```text
Bounded concurrency
→ Bulkhead
→ bounded waiting
→ Backpressure
→ Load shedding / degradation
```

### Long-running work
```text
Durable Queue
→ Worker
→ Chunk
→ Checkpoint
→ Idempotency
```

### Read scaling
```text
Cache-aside
→ TTL
→ Invalidation
→ Bounded staleness
→ Cache stampede
→ Single-flight
→ TTL jitter
```

### Live presence
```text
Heartbeat
→ Lease / TTL
→ Ephemeral state
→ SSE
→ Pub/Sub
→ Resynchronization
```

---

## High-value Distinctions

| Don't confuse | Difference |
|---|---|
| **Inbox vs Outbox** | Safely consume/deduplicate vs reliably publish committed state |
| **Outbox vs Saga** | Reliable propagation of committed state vs distributed business workflow/compensation |
| **Checkpoint vs Idempotency** | Where to resume vs whether repeating work is safe |
| **Retry vs Redelivery** | Dependency attempt vs broker delivering message again |
| **Retry storm vs Backpressure** | Retry amplification is an overload failure; backpressure is a control response |
| **Poison message vs Infrastructure outage** | Bad individual input vs shared dependency failure |
| **Circuit breaker vs Bulkhead** | Dependency health/fail-fast vs capacity isolation |
| **Bulkhead vs Backpressure** | Bound/isolate capacity vs respond when arrival rate exceeds capacity |
| **SSE vs WebSocket** | Server→client vs bidirectional |
| **Pub/Sub vs Durable queue** | Ephemeral fan-out vs durable work delivery |
| **Hot key vs Hot partition** | Overloaded logical key vs overloaded broker/data shard |
| **Local vs Distributed coordination** | One process vs system-wide invariant |
| **Operational state vs Analytics** | Current/ephemeral truth vs durable historical data |

---

## The SDE3 Trigger

Whenever you draw two components with an arrow between them, ask:

> **What can go wrong between these two arrows?**

Then check:

**Loss → Duplicate → Ordering → Timeout → Retry → Capacity → Consistency → Durability → Recovery**

And for every unfamiliar pattern, attach it immediately to a concrete implementation:

> **Concept → failure it solves → .NET/AWS mechanism → scope → trade-off**
