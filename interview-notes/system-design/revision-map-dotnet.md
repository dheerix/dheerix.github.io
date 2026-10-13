# System Design Revision Map — Architecture → Terminology → .NET

> One-page mental model for Senior/SDE3 revision. Start with the business requirement, identify the invariant/problem, then choose the mechanism. Technologies are answers only after the problem is named.

## 1. Generic production system

```
                         ┌──────────────────────┐
                         │   Browser / Mobile   │
                         └──────────┬───────────┘
                                    │ HTTP
                                    ▼
                         ┌──────────────────────┐
                         │ LB / API Gateway     │
                         └──────────┬───────────┘
                                    │
                       ┌────────────▼────────────┐
                       │ ASP.NET Core API Pods   │
                       │ auth / validation / API │
                       └──────┬───────┬─────────┘
                              │       │
             read/write       │       │ cache-aside
                              ▼       ▼
                       ┌──────────┐  ┌──────────┐
                       │   DB     │  │  Redis   │
                       │ source   │  │ cache /  │
                       │ of truth │  │ ephemeral│
                       └────┬─────┘  └──────────┘
                            │
                  same DB TX│ business state
                            │ + Outbox
                            ▼
                       ┌──────────┐
                       │ Outbox   │
                       └────┬─────┘
                            │ publish
                            ▼
                       ┌──────────┐
                       │ Durable  │
                       │ Queue /  │
                       │ Broker   │
                       └────┬─────┘
                            │ at-least-once
                            ▼
                    ┌────────────────┐
                    │ Worker Fleet   │
                    │ .NET workers   │
                    └───────┬────────┘
                            │
              idempotent effects / checkpoints
                            │
                ┌───────────┴────────────┐
                ▼                        ▼
             DB / APIs              Object Storage
                                    large files/reports

Server-side state/progress
        │
        └──────────── SSE ──────────────> Browser
```

This is not a mandatory architecture. It is a map for locating concepts.

---

## 2. Reasoning order

```
Business behavior
      ↓
Requirements / unknowns
      ↓
Invariants
      ↓
Independent technical problems
      ↓
State model + data lifecycle
      ↓
Communication model
      ↓
Consistency / ordering / concurrency
      ↓
Scale / skew / capacity
      ↓
Failure + recovery
      ↓
Mechanism / technology
      ↓
Trade-offs
      ↓
Verification
```

**Rule:** do not start with Redis, Kafka, WebSocket, Kubernetes, etc.

---

## 3. Request / async execution boundary

### Task.Run
**Problem it solves:** execute work concurrently/in background inside the current process.

**Does not provide:** durable business-work ownership.

If an ASP.NET pod dies, an in-memory fire-and-forget Task can disappear.

### BackgroundService / IHostedService
.NET mechanism for long-running hosted processing.

Useful for:
- consuming a durable queue,
- polling an outbox,
- periodic hosted work.

But the service itself is still tied to the process lifetime.

> BackgroundService + durable queue = durable work can survive worker death.
> BackgroundService alone != durable job system.

### Durable work queue
Use when work must survive API/worker restart and can execute asynchronously.

Provides:
- decoupling,
- durable work ownership,
- redelivery,
- independent worker scaling,
- load leveling,
- backpressure.

Examples: SQS, RabbitMQ, Pulsar/Kafka-like broker semantics depending on use case.

---

## 4. Messaging terminology

### At-least-once delivery
A message can be delivered more than once.

Therefore:

```
delivery != exactly one business effect
```

### ACK boundary
ACK before durable processing → potential message loss.

ACK after durable processing → crash before ACK can cause redelivery.

Therefore processing must be idempotent.

### Idempotency
Repeated execution produces the same intended business effect as one execution.

Possible mechanisms:
- stable idempotency key,
- processed-message/inbox table,
- unique constraint,
- conditional update,
- chunk status COMPLETED.

### Processing identity vs business identity
`(JobId, RowNumber)` → did this input operation run?

`(DealerId, VIN)` → is this the same business entity?

Do not automatically treat them as the same key.

### Poison message
A specific work item repeatedly fails even when the system/dependencies are otherwise healthy.

Use bounded attempts + quarantine/DLQ.

### DLQ
Destination for work that exhausted its processing policy and needs inspection/recovery.

Do not use DLQ as the normal response to a shared temporary DB outage.

### Consumer group
Multiple consumers cooperate to process partitions/work for one logical application.

In classic Kafka-style partition ownership, one partition is actively consumed by at most one consumer within a group.

### Ordering
Broker ordering does not automatically guarantee ordered business effects if processing becomes concurrent or downstream calls complete out of order.

### Partitioning / hot partition
Partition key determines distribution. Skew can overload one partition even when cluster-wide capacity is large.

---

## 5. Transactional consistency patterns

### Local DB transaction
Use when multiple state changes share one transactional database boundary.

.NET: EF Core transaction / SaveChanges transaction semantics.

Provides atomicity locally; it does not make Redis, another service, or broker part of the DB transaction.

### Transactional Outbox
Problem:

```
DB commit succeeds
publish/cache invalidation fails
service crashes
```

Solution:

```
BEGIN DB TX
  business change
  Outbox event
COMMIT

Outbox processor → external action/event
```

Use to **reliably propagate a committed state change**.

### Saga
Coordinates a multi-step distributed business workflow where each step can commit independently and later failure may require compensation.

Example:

```
reserve inventory → payment → shipment
                     ❌
release inventory ← compensation
```

**Recall:**
Outbox = committed state must eventually be propagated.
Saga = distributed business workflow must be coordinated/compensated.

### Eventual consistency
Different components may temporarily disagree but converge later.

Accept only where the business invariant allows it.

---

## 6. Retry / resilience

### Timeout
Bounds one wait/attempt.

.NET: CancellationToken/timeout policies depending on operation.

### Deadline / latency budget
Bounds the entire caller operation, including retries/backoff.

### Retry
Use for transient failures, not deterministic validation/business failures.

### Exponential backoff
Increasing delay between retries.

### Jitter
Randomizes retry timing to avoid synchronized retry waves / thundering herd.

### Circuit breaker
Stops repeatedly calling a dependency already known to be unhealthy.

States:

```
CLOSED → failures → OPEN → limited probes HALF-OPEN → CLOSED
```

.NET: Microsoft.Extensions.Http.Resilience / Polly-style resilience for HttpClient scenarios.

### Bulkhead
Limits how much resource/capacity one dependency/tenant/workload can consume.

.NET local implementation can use SemaphoreSlim.

### Graceful degradation
Drop/omit a non-critical capability while preserving useful core behavior.

### Fail closed
Stop when continuing without authoritative data could violate a critical invariant.

Example: purchase cannot proceed without authoritative price.

### Cascading failure
Failure in one dependency shifts load/failure into another until the system degrades broadly.

Example:

```
Redis down
  ↓
all 50k req/s → DB
  ↓
DB saturation
  ↓
timeouts
  ↓
retries
  ↓
more load
```

---

## 7. Concurrency and coordination

### lock
Mutual exclusion inside one .NET process.

Cannot coordinate other pods.

### SemaphoreSlim
Bounds/constrains concurrent operations inside one .NET process; also supports async WaitAsync.

Useful for:
- local bulkhead,
- bounded parallelism,
- local request coalescing.

Not a global distributed limit.

### Local vs distributed coordination

```
Pod A SemaphoreSlim(3)
Pod B SemaphoreSlim(3)
Pod C SemaphoreSlim(3)

global possible concurrency = 9
```

If the business invariant says globally 3, use shared scheduling/distributed coordination.

### Noisy neighbor / multi-tenant fairness
One tenant/workload consumes disproportionate shared capacity and harms others.

Solutions can include per-tenant limits, fair queues, scheduling and bulkheads.

---

## 8. Long-running job processing

### Durable job state
Store lifecycle independently from browser/API connection.

Example:

```
UPLOADED → QUEUED → VALIDATING → PROCESSING → COMPLETED
```

State and percentage are different dimensions.

### Checkpoint / processing cursor
Records where resumable work has progressed.

Checkpointing answers **where to resume**.

Idempotency answers **whether replay is safe**.

### Chunking
Split large work into independently retryable units.

> Checkpoint granularity should align with independently retryable work.

Parallel chunking requires checking business independence, ordering and downstream capacity.

### Load leveling
Queue absorbs bursts and workers process at sustainable rate rather than passing the burst directly to DB/downstream.

### Backpressure
Slow/limit upstream work when downstream capacity is saturated.

---

## 9. Large-file architecture

### Control plane vs data plane

Control plane:
- create job,
- authorization,
- status,
- metadata.

Data plane:
- large file bytes.

Instead of:

```
Browser → 1 GB → API pod → S3
```

prefer:

```
Browser → API: authorize/create job
Browser ───────────────→ Object Storage: file bytes
```

AWS: S3 presigned URL + multipart upload.

---

## 10. Realtime / client propagation

### Polling
Client periodically asks for latest state.

Simple but creates repeated requests and freshness interval.

### SSE
Server → browser push over long-lived HTTP connection.

Good for:
- progress,
- notifications,
- viewer-count snapshots.

ASP.NET Core can stream SSE responses.

### WebSocket
Bidirectional persistent communication. Use when genuine two-way realtime messaging is required.

Do not choose WebSocket merely because the requirement says “realtime.”

### Pub/Sub
Fan out ephemeral notifications across server instances.

Example: Pod A observes state change; clients are connected to Pods B/C.

### Durable event vs ephemeral notification
Durable business event may need replay/ordering/consumer progress.

Ephemeral current-state notification can often be missed if the consumer can resynchronize.

### Resynchronization / convergence
After reconnect/missed notifications, fetch authoritative latest state rather than replay every intermediate update when history is irrelevant.

> Durable state for correctness; push channel for responsiveness.

---

## 11. Presence / ephemeral state

### Heartbeat
Client periodically proves it is alive.

### Lease / TTL
Presence remains valid for a bounded period unless refreshed.

Example:

```
(VehicleId, UserId) → expiresAt
```

### Operational state vs analytical history
“Who is online now?” is ephemeral operational state.

“Who viewed last month?” is durable analytics.

Do not force both lifecycles into one model.

### Hot key
One logical key receives disproportionate traffic.

Different from total memory/capacity pressure.

---

## 12. Database / EF Core

### IQueryable / deferred execution
Query is composed until materialization/execution.

### N+1
One initial query followed by many per-row related queries.

### Projection
Select only the shape required by the read use case instead of loading a full entity graph.

.NET: LINQ `Select(...)`.

### Include / cartesian expansion
Large relationship graphs can generate expensive joins/result duplication. Inspect generated SQL/query plan rather than assuming ORM query is cheap.

### AsNoTracking
Useful for read-only EF Core queries when change tracking is unnecessary.

### Index
Trades write/storage cost for faster access paths.

### Query plan
Understand how DB actually executes the query: scans, seeks, joins, estimates.

### Connection pool
Bounded reusable DB connections.

Treat as scarce capacity. Long-held connections or uncontrolled fallback can exhaust it.

### Optimistic concurrency
Assume conflicts are uncommon; detect conflicting update at write time.

.NET/EF: rowversion/concurrency token.

### Pessimistic concurrency
Prevent conflicting access by locking earlier; stronger coordination but lower concurrency / possible blocking.

### Isolation
Controls visibility/interactions of concurrent transactions.

Recall anomalies:
- dirty read,
- non-repeatable read,
- phantom read.

### Offset vs keyset pagination
Offset is simple but can become expensive/unstable deep into changing datasets.

Keyset continues from stable ordered key and scales better for sequential pagination.

---

## 13. Caching

### First question: is cache solving the bottleneck?
Before Redis inspect:
- DB query latency,
- query plan,
- indexes,
- joins,
- CPU/I/O,
- EF query shape,
- connection-pool pressure,
- repeated-read/access skew.

### Cache granularity
Do not cache an entire object when fields have different consistency requirements.

Example:
- year/make/model → tolerant,
- auction status/current price → freshness critical.

### Read model / projection
Shape read data around client/read requirements, potentially composing cached static data with live authoritative state.

### Cache-aside / lazy loading

```
read cache
  HIT → return
  MISS → DB → populate cache → return
```

Only the active **working set** enters cache.

### Invalidation
When DB is authoritative:

```
DB commit
   ↓
invalidate cached projection
   ↓
next read rebuilds
```

### Bounded staleness
Accept temporary stale data when business semantics allow it, using TTL/invalidation/eventual convergence rather than expensive strong coordination.

### Cache stampede / thundering herd
Many requests simultaneously miss one hot entry and hammer origin.

### Request coalescing / single-flight
One request rebuilds a missing key while others wait/reuse result.

.NET local implementation: per-key SemaphoreSlim.

### TTL jitter
Randomize expiration around base TTL to avoid synchronized mass expiration.

### Working set
Subset of total data that is actively accessed enough to benefit from cache.

### Cache failure
Do not blindly send all cache traffic to DB. Use bounded fallback, circuit breaking, bulkheads and graceful degradation to prevent cascading failure.

---

## 14. Failure classification

Before choosing retry/DLQ/continue, classify the failure.

| Failure class | Typical action |
|---|---|
| deterministic business/data validation | record/reject; no retry |
| transient infrastructure | bounded retry + backoff + jitter |
| sustained dependency outage | circuit breaker + backpressure/pause |
| poison work item | bounded deliveries → DLQ |
| partial distributed business workflow | Saga/compensation where appropriate |
| lost propagation after DB commit | Transactional Outbox |
| optional dependency unavailable | graceful degradation |
| critical invariant unavailable | fail closed |

---

## 15. .NET concept → system-design meaning

| .NET concept | System-design meaning / boundary |
|---|---|
| `async/await` | release thread while waiting; improves request scalability, not downstream capacity |
| `Task` | represents an operation; not durable work ownership |
| `Task.Run` | in-process execution; dies with process |
| `CancellationToken` | cooperative cancellation; not durable recovery |
| `lock` | synchronous mutual exclusion inside one process |
| `SemaphoreSlim` | async-friendly local concurrency bound / bulkhead / single-flight primitive |
| `Task.WhenAll` | parallelize independent work; business independence must be proven first |
| `BackgroundService` | hosted worker loop; pair with durable source for durable work |
| ASP.NET middleware | request pipeline/cross-cutting behavior |
| `HttpClient` resilience | timeout/retry/backoff/jitter/circuit breaker around remote calls |
| EF Core transaction | local atomicity within DB boundary |
| EF concurrency token / rowversion | optimistic concurrency conflict detection |
| EF projection | purpose-built read model / reduce data/query cost |
| `AsNoTracking` | lower read-only ORM tracking overhead |
| DB connection pool | bounded scarce resource requiring capacity protection |
| `IDistributedCache` / Redis client | cache mechanism; consistency/invalidation still architecture decisions |
| SSE endpoint | server→client state/progress propagation |
| .NET Worker Service | scalable background consumer process |
| OpenTelemetry/Honeycomb instrumentation | verify latency, dependency failure, retries, queue lag, bottlenecks |

---

## 16. AWS / infrastructure mapping

| Need | Typical mechanism |
|---|---|
| large durable object | S3 |
| direct authorized upload | S3 presigned URL |
| durable work queue | SQS or chosen broker |
| ephemeral/cache state | Redis/ElastiCache |
| compute/API | containers/ECS/EKS/Lambda depending workload |
| relational source of truth | RDS/Aurora/Postgres etc. |
| metrics/traces/logs | OpenTelemetry + observability backend |

Technology is illustrative. Explain the requirement first.

---

## 17. Ten distinctions to recall cold

1. **Task vs Thread** — operation vs execution resource.
2. **Async scalability vs capacity** — await frees threads; it does not increase DB/service capacity.
3. **Checkpoint vs idempotency** — where to resume vs whether replay is safe.
4. **Processing identity vs business identity** — input operation vs domain entity.
5. **Retry count vs message delivery count** — dependency attempts vs broker redeliveries.
6. **Outbox vs Saga** — propagate committed state vs coordinate/compensate workflow.
7. **Circuit breaker vs bulkhead** — stop calls to unhealthy dependency vs isolate/limit capacity.
8. **Pub/Sub vs durable broker** — ephemeral fan-out vs durable/replayable processing.
9. **Local SemaphoreSlim vs distributed limit** — one process vs system-wide invariant.
10. **Cache TTL vs business consistency** — expiration policy cannot override correctness requirements.

---

## 18. Interview opening sentence

> “I’ll first clarify the business semantics, scale, freshness/consistency requirements and failure expectations. Then I’ll decompose the requirement into independent technical problems and invariants. After that I’ll choose mechanisms for each problem and test the design against concurrency, partial failure, skew, capacity and recovery.”

## 19. Final mental model

When stuck, ask:

```
What must be true?
What can be stale?
What can be lost?
What can be repeated?
What must survive a crash?
What is the source of truth?
Where is the transactional boundary?
What resource can saturate?
What happens when one dependency dies?
How does the system converge again?
```
