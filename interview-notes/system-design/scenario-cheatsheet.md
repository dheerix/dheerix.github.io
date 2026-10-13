# System Design Scenario Cheat Sheet

> **See the situation → name the concept → connect the surrounding concepts.**

## Scenario → Terminology → Connected Concepts

| Scenario / smell | Terminology to recall | Connected concepts |
|---|---|---|
| Same message arrives twice | **At-least-once delivery → Idempotency** | ACK, Inbox, stable/business identity |
| DB saved; event must definitely publish | **Transactional Outbox** | local transaction, eventual consistency, broker |
| Multi-service workflow partially succeeds | **Saga** | compensation, orchestration, choreography |
| Dependency temporarily fails | **Retry** | bounded retry, exponential backoff, jitter |
| Dependency keeps failing | **Circuit Breaker** | timeout, HALF-OPEN probes, graceful degradation |
| One dependency consumes all resources | **Bulkhead** | bounded concurrency, SemaphoreSlim, failure isolation |
| System is overloaded | **Backpressure** | load shedding, queueing, load leveling |
| One customer dominates workers | **Noisy Neighbor** | fairness, per-tenant limits, bulkhead |
| Worker crashes halfway | **Checkpointing** | processing cursor, chunks, idempotency |
| Worker finishes but crashes before ACK | **Redelivery + Idempotency** | at-least-once, processed-message record |
| Huge background operation | **Durable Queue + Worker** | BackgroundService, checkpoint, retry |
| Huge file upload | **Control Plane / Data Plane** | presigned URL, S3/object storage, multipart, async processing |
| Read-heavy endpoint | **Cache-aside** | working set, TTL, invalidation |
| Cached value may be slightly old | **Bounded Staleness** | TTL, eventual consistency |
| Thousands miss same cache key | **Cache Stampede** | single-flight, request coalescing |
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
| Too many concurrent calls | **SemaphoreSlim** | bounded concurrency, bulkhead |
| Multiple pods must obey same limit | **Distributed Coordination** | local SemaphoreSlim is insufficient |
| Optional recommendation service dies | **Graceful Degradation** | failure isolation |
| Authoritative price is unavailable | **Fail Closed** | business invariant, correctness |
| One bad message repeatedly fails | **Poison Message → DLQ** | bounded retries |
| Shared DB/service is broadly down | **Infrastructure Outage** | circuit breaker, delayed retry, backpressure; don't immediately DLQ |

---

## Concept Chains — Recall These Cold

### Duplicate delivery
```text
At-least-once delivery
        ↓
   Idempotency
        ↓
 Stable identity
```

### Reliable event publication
```text
DB change
   ↓
Transactional Outbox
   ↓
Broker
   ↓
Consumer
   ↓
Eventual consistency
```

### Distributed business workflow
```text
Saga
 ↓
Multiple committed steps
 ↓
Failure
 ↓
Compensation
```

### Dependency failure
```text
Timeout
  ↓
Retry
  ↓
Exponential backoff
  ↓
Jitter
  ↓
Circuit Breaker
```

### Overload
```text
Bounded concurrency
       ↓
    Bulkhead
       ↓
  Backpressure
       ↓
 Load shedding
```

### Long-running work
```text
Durable Queue
     ↓
   Worker
     ↓
   Chunk
     ↓
Checkpoint
     ↓
Idempotency
```

### Read scaling
```text
Cache-aside
    ↓
   TTL
    ↓
Invalidation
    ↓
Bounded staleness
    ↓
Cache stampede
    ↓
Single-flight
    ↓
TTL jitter
```

### Live presence
```text
Heartbeat
   ↓
Lease / TTL
   ↓
Ephemeral state
   ↓
SSE
   ↓
Pub/Sub
   ↓
Resynchronization
```

---

## High-value Distinctions

| Don't confuse | Difference |
|---|---|
| **Outbox vs Saga** | Reliable propagation of committed state vs distributed business workflow/compensation |
| **Checkpoint vs Idempotency** | Where to resume vs whether repeating work is safe |
| **Retry vs Redelivery** | Dependency attempt vs broker delivering message again |
| **Poison message vs Infrastructure outage** | Bad individual input vs shared dependency failure |
| **Circuit breaker vs Bulkhead** | Stop calls to unhealthy dependency vs constrain resource consumption |
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

That question naturally exposes most of the system-design concepts above.
