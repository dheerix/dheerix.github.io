# System Design — Requirements to Architecture

> Revision note for Senior/SDE3 interviews. The goal is not to memorize architectures. Move from business requirement → invariant → technical problem → mechanism → trade-off → failure/recovery.

## 1. The reasoning flow

1. **Requirement Hat** — What behavior does Product actually need? What is explicit, unknown, or assumed?
2. **System-Design Hat** — Translate behavior into independent technical problems and invariants.
3. **Implementation Hat** — Only now choose mechanisms, patterns, protocols, and datastores.
4. **Verification Hat** — How will we know the invariant still holds under concurrency, failure, scale, and recovery?

Avoid solution-first reasoning such as "use Redis", "use Kafka", or "use WebSockets" before identifying the problem they solve.

## 2. Requirement questions

For most systems clarify:

- **Identity:** what is the business entity / uniqueness boundary?
- **Semantics:** what exactly counts as success, active, complete, duplicate, etc.?
- **Freshness / latency:** realtime, seconds, minutes, eventual?
- **Accuracy / consistency:** exact or approximate? Which invariants cannot be violated?
- **Scale:** reads, writes, concurrency, data size, hot keys / skew.
- **Availability:** what can degrade and what must fail closed?
- **Durability:** ephemeral state or business history?
- **Clients / boundaries:** web, mobile, services, third parties.
- **Recovery:** what happens after disconnect, crash, retry, or missed update?
- **Analytics / retention:** actually required, or speculative future tracking?

## 3. Translate requirements into problems, not tools

Example requirement: **"Show how many users are currently viewing each vehicle."**

Technical problems:
1. viewer identity and deduplication,
2. liveness detection,
3. expiration when a client disappears,
4. concurrent state updates,
5. efficient count computation,
6. count propagation to connected VDPs,
7. multi-tab / multi-device semantics,
8. hot vehicles / skew,
9. optional historical analytics.

Bad decomposition:
- Redis
- WebSocket
- Kafka

Those are possible mechanisms, not the problems.

## 4. Worked design — live vehicle viewer count

### Product assumptions

- Count unique logged-in users.
- Multiple tabs for the same vehicle count as one viewer.
- User remains active while at least one relevant tab remains alive.
- Disappeared clients should stop counting within ~30 seconds.
- Approximate count is acceptable.
- UI freshness of ~5–10 seconds is acceptable.
- Viewer count is informational, not a purchase/business invariant.
- Potentially very large concurrent audience.

### Identity

Minimum business identity:

```
(VehicleId, UserId)
```

A TabId is unnecessary if any tab may refresh the same user's presence and Product only cares whether the user is present at least once.

**Rule:** model the minimum identity required by the business invariant.

### Liveness: heartbeat + lease / TTL

Do not rely on a clean "user left" event. Browsers crash, networks disappear, devices sleep.

Client periodically provides evidence of liveness:

```
heartbeat(V123, U456)
```

Conceptual state:

```
(V123, U456)
lastSeen = ...
expiresAt = now + 30s
```

Every heartbeat refreshes the lease. If all tabs disappear, heartbeats stop and the presence expires.

**Canonical terms:** heartbeat, lease, TTL-based presence.

### Operational state vs analytical history

These are different lifecycles:

**Operational presence**
- "Who is active now?"
- ephemeral,
- high churn,
- low latency,
- seconds of relevance.

**Historical analytics**
- "How many users viewed this vehicle last week?"
- durable,
- retention-oriented,
- analytical queries.

Do not automatically capture platform/user history "because it might be useful later." That adds privacy, retention, schema, and storage obligations.

### RDBMS vs ephemeral store

An RDBMS could model:

```
VehicleId | UserId | LastSeen
UNIQUE(VehicleId, UserId)
```

`Expired` need not be persisted because it is derived from LastSeen.

But frequent heartbeat UPSERTs plus cleanup are high-churn ephemeral work. A TTL-capable in-memory store fits the semantics better.

Reason to choose Redis-style storage is not merely "Redis is fast":

> **Ephemeral state + high write rate + natural expiration + low-latency access.**

### Presence TTL vs count freshness

Do not confuse:

```
Presence TTL       ≈ 30 sec
Count/UI freshness ≈ 5–10 sec
```

Presence TTL defines when a user is considered gone. Count freshness defines how stale the displayed aggregate may be.

### Avoid scanning per-user keys

A representation like:

```
presence:V123:U1
presence:V123:U2
...
```

makes identity/expiry simple but counting 50k users by key scan is a poor hot-path design.

A separate derived counter is fast but creates a consistency problem: automatic TTL expiration must also decrement the counter, otherwise state can drift.

A useful representation is conceptually:

```
Vehicle V123
  U1 → expiresAt
  U2 → expiresAt
  U3 → expiresAt
```

A sorted collection can use `expiresAt` as score:
- heartbeat updates the user's expiry score,
- remove entries whose score < now,
- count remaining members.

This keeps expiry information and countable membership together rather than maintaining an independently drifting counter.

### Hot keys / skew

A viral vehicle can concentrate enormous heartbeat traffic into one logical vehicle state.

Distinguish:

- **Memory capacity:** can the cluster hold all presence state?
- **Hot-key / hot-partition throughput:** can one logical key/node sustain one viral vehicle's traffic?

This is the same distribution principle encountered in message partitioning: skew can bottleneck one partition even when total cluster capacity looks healthy.

Approximate-count requirements may justify aggregation/coalescing rather than processing every heartbeat into an exact global count.

## 5. Propagating count to the UI

### Polling vs SSE

The viewer count is primarily server → browser communication.

SSE is a natural candidate:
- one-way server push,
- simpler than full bidirectional WebSockets for this requirement,
- eliminates repeated polling requests.

But SSE does **not** eliminate server load:
- 50k viewers still mean ~50k long-lived connections.
- client → server heartbeat remains a separate path.

**Decision rule:** choose protocol based on communication semantics, not popularity of the technology.

### Multi-instance fan-out

With a load balancer:

```
             Load Balancer
          /       |       \
       Pod A    Pod B    Pod C
       SSE      SSE      SSE
```

A presence update handled by Pod A must reach clients connected to B and C.

Need a **Publish–Subscribe** fan-out mechanism:
- count/aggregate component publishes latest vehicle count,
- SSE-serving pods subscribe,
- each pod pushes updates to its locally connected clients.

### Durable event vs ephemeral state notification

Do not automatically use Kafka/Pulsar for every pub/sub need.

Business events such as:
- OrderCreated,
- PaymentCompleted

may require durability, replay, ordering, consumer progress, and at-least-once processing.

Viewer-count updates such as:

```
49,999 → 50,000 → 49,998
```

are ephemeral state propagation. Missing an intermediate value is acceptable if the consumer can retrieve the latest authoritative state.

A lightweight Pub/Sub mechanism can therefore be appropriate.

### Coalescing

Do not publish on every heartbeat.

If 50k users heartbeat every 10 seconds, there may be ~5k heartbeat writes/sec while the displayed count barely changes.

Given a 5–10 second freshness requirement:

```
many heartbeat/presence changes
        ↓
aggregate / coalesce
        ↓
latest V123 count snapshot
        ↓
Pub/Sub
        ↓
SSE pods
        ↓
clients
```

## 6. Recovery and convergence

If an SSE pod loses Pub/Sub connectivity for 20 seconds, replaying every missed count is unnecessary.

On recovery:

```
stale local value
      ↓
read authoritative current count
      ↓
48,712
      ↓
push latest state
```

**Key distinction:** when only current state matters, recover by **resynchronization / convergence**, not event replay.

This contrasts with durable business-event processing where missing historical events may be unacceptable.

## 7. Resilience decision rules from Distributed Systems II

- **Retry** → transient failure.
- **Exponential backoff** → progressively delay retries.
- **Jitter** → prevent synchronized retry waves / thundering herd.
- **Timeout** → bound one wait/attempt.
- **Deadline / latency budget** → bound the complete operation.
- **Circuit breaker** → stop repeatedly calling persistently unhealthy dependency.
- **Bulkhead** → isolate resource consumption / blast radius.
- **Fallback / graceful degradation** → preserve useful functionality.
- **Fail closed** → stop when proceeding could violate a critical business invariant.

Example:
- Recommendations unavailable on VDP → hide/degrade optional section.
- Pricing unavailable on informational VDP → page may render with price unavailable/retry.
- Authoritative pricing unavailable during purchase → fail closed rather than violate purchase invariant.

## 8. Interview articulation template

When given a design problem:

> "Before choosing infrastructure, I'd clarify the business semantics, freshness/consistency requirements, scale, and failure expectations. Then I'd decompose the requirement into independent technical problems and identify the invariants. After that I'd choose mechanisms for each problem and test the design against concurrency, partial failure, hot keys, and recovery."

Then make decisions explicitly:

> "I'm choosing X because this state is ephemeral/high-churn..."

rather than:

> "I'd use X because it's fast."

## 9. Cold-recall prompts

1. Requirement says "users viewing now." What ambiguities must be resolved before design?
2. Why is a clean disconnect insufficient for presence?
3. When is `(VehicleId, UserId)` enough, and when would a TabId/SessionId become necessary?
4. Why are presence TTL and UI count freshness different?
5. Why can a derived counter drift from TTL-based membership?
6. What is the difference between memory-capacity pressure and a hot-key problem?
7. Why might SSE fit better than WebSocket here?
8. What scaling problem does SSE still retain?
9. Why do multiple SSE pods require fan-out?
10. When is lightweight Pub/Sub enough versus a durable broker?
11. Why can a disconnected viewer-count consumer resynchronize instead of replaying events?
12. Which business invariant would make graceful degradation inappropriate?

## 10. Mental checklist

```
Business behavior
    ↓
Requirements / unknowns
    ↓
Invariants
    ↓
Independent technical problems
    ↓
Data lifecycle + state model
    ↓
Communication model
    ↓
Consistency / ordering / concurrency
    ↓
Scale + skew
    ↓
Failure + recovery
    ↓
Mechanism / technology
    ↓
Trade-offs
    ↓
Verification
```


## 11. Worked design — large asynchronous vehicle CSV import

### Requirements and assumptions

Scenario: a dealer uploads up to ~500,000 vehicles / potentially ~1 GB. Processing may take minutes. Each row is validated/imported, progress must survive browser reloads, and a detailed success/failure report is produced.

Clarify before choosing infrastructure:
- synchronous completion or asynchronous job?
- fixed/versioned schema?
- partial success or atomic import?
- duplicate and re-upload semantics?
- row-level error reporting?
- progress definition?
- concurrency / multi-tenant scale?
- report retention?

Assume async processing, versioned schema, partial success, detailed failed-row reporting, idempotent re-upload, durable progress, and hundreds of concurrent jobs.

### Architecture

```
Browser ── create job ──> API ──> Job DB
   |
   └── large CSV ──> Object Storage
                         |
                   file validation
                         |
                    split/chunk
                         |
                         v
                   Durable Queue
                         |
                 fairness / limits
                         |
                    Worker Fleet
                         |
                  Vehicle DB + chunk state
                         |
                  progress aggregation
                         |
                        SSE
                         |
                      Browser
```

### Control plane vs data plane

Avoid proxying a ~1 GB byte stream through API instances when the API only needs to authorize and coordinate the upload.

- **Control plane:** create job, authorize upload, query status.
- **Data plane:** browser uploads file bytes directly to object storage.

AWS example: S3 presigned upload; multipart upload for large objects.

### Durable job state

Model state separately from progress:

```
UPLOADED → QUEUED → VALIDATING → PROCESSING → COMPLETED
                                  └──────────→ FAILED
```

A job can be QUEUED at 0%; state and percentage are different dimensions.

### Checkpointing and retry granularity

Sequential processing can use a processing cursor such as LastProcessedRow.

Parallel chunk processing requires chunk-level checkpoints:

```
ImportJob
  JobId, Status, TotalChunks, CompletedChunks

ImportChunk
  JobId, ChunkId, StartRow, EndRow,
  Status, RetryCount, SucceededRows, FailedRows
```

**Rule:** checkpoint granularity should align with the independently retryable work unit.

Before parallelizing, establish business independence: duplicate business keys across chunks, ordering dependencies, cross-row references, and downstream capacity can invalidate naive parallelism.

### Checkpointing vs idempotency

Checkpointing answers **where to resume**.

Idempotency answers **whether replay around the checkpoint boundary is safe**.

Example failure:

```
persist vehicle row
      ↓
worker crashes
      ↓
checkpoint was not advanced
      ↓
row is replayed
```

Useful identities:
- `(JobId, RowNumber)` — processing identity,
- `(DealerId, ExternalVehicleId/VIN)` — business identity.

An idempotency key and a business uniqueness constraint are related but not necessarily identical.

### At-least-once chunk delivery

If a worker completes C2 and crashes before ACK, C2 may be redelivered.

Consumer behavior:

```
receive J100:C2
      ↓
is chunk already COMPLETED?
   yes → skip effect + ACK
   no  → process idempotently
```

Chunk-level completion is an idempotent-consumer boundary. Row-level idempotency still protects partial chunk replay.

### Failure classification

Do not retry every failure identically.

| Failure | Treatment |
|---|---|
| deterministic business/data validation error | record row failure; continue if partial success allowed |
| transient dependency timeout | bounded retry + exponential backoff + jitter |
| file-wide schema/structural error | reject during file validation |
| recoverable malformed row | row failure only if parser can safely recover the next record boundary |
| repeatedly unrecoverable/poison work item | bounded deliveries, then quarantine/DLQ |

**Rule:** validate failures at the earliest boundary where they can be determined.

### Dependency retry vs broker redelivery

These are independent loops.

```
Queue delivers chunk
      ↓
worker DB attempt/retry policy
      ↓
message processing fails
      ↓
broker may redeliver entire chunk later
```

Therefore:

> Dependency retry count != message delivery count.

For a sustained shared DB outage:
- circuit breaker protects the DB,
- pause/slow consumption or delayed redelivery protects workers and queue from useless churn,
- do not rapidly DLQ valid chunks merely because a shared dependency is temporarily unavailable.

Infrastructure outage and poison-message handling are different failure classes.

### Multi-tenant fairness and backpressure

One dealer submitting many huge jobs can become a noisy neighbor.

A local `SemaphoreSlim` can bound work inside one .NET process, but it does not create a cluster-wide per-dealer limit.

Need scheduling/queueing/coordination semantics that enforce the desired global fairness boundary.

> Correct algorithm locally does not imply correct coordination globally.

The durable queue also provides **load leveling**: a burst of uploads becomes backlog processed at a sustainable rate rather than immediate pressure on the Vehicle DB.

### Progress and SSE

Progress can aggregate from chunk completion rather than writing one shared job counter for every imported row.

SSE is a natural fit for live server → browser progress, but the SSE stream is not the source of truth.

```
durable Job/Chunk state → current progress
                       ↘ SSE notification → browser
```

After reconnect, fetch current state and converge; replaying every intermediate percentage is unnecessary.

> Durable state for correctness; push channel for responsiveness.

### Why not Task.Run from ASP.NET?

A fire-and-forget `Task.Run` couples business-critical work lifetime to the API process.

Pod restart, deployment, crash, or scale-down can destroy the in-memory task. Durable job state alone does not preserve the fact that work still needs execution; otherwise a separate scanner/scheduler must rediscover it.

A durable work queue provides:
- durable work ownership,
- redelivery after worker failure,
- decoupling from API/request lifetime,
- independent worker scaling,
- load leveling,
- backpressure.

### .NET / AWS implementation mapping

| System-design concept | Concrete grounding |
|---|---|
| API request should not own long job | Avoid fire-and-forget `Task.Run` from ASP.NET request |
| In-process hosted work | `BackgroundService` / `IHostedService`; still process-lifetime scoped unless work source is durable |
| Worker implementation | .NET Worker Service / `BackgroundService.ExecuteAsync` consuming durable messages |
| Local bounded concurrency | `SemaphoreSlim`; per-process, not distributed |
| Graceful shutdown | host `CancellationToken`; unacked durable work can be redelivered |
| Transient HTTP dependency failures | `HttpClient` resilience / Polly-style retry, backoff, jitter, circuit breaker |
| Atomic same-DB changes | EF Core transaction where vehicle effect, row result and checkpoint share one transactional boundary |
| Idempotency | unique constraints, processed-operation records, conditional updates |
| Large file handoff | S3 presigned URL / multipart upload |
| Durable work dispatch | SQS / RabbitMQ / Pulsar-style queue |
| Live progress | ASP.NET Core SSE; Job DB remains authoritative |

### Interview answer — durable queue vs in-process background task

> “I would not use an in-process Task.Run for a long-running business-critical import because the work lifetime becomes coupled to the API instance. A durable queue decouples request handling from processing and gives us durable work ownership, redelivery after worker failure, independent worker scaling, load leveling, and backpressure. Workers still need idempotent processing because delivery is typically at least once.”

## 12. Additional cold-recall prompts

13. Why should a 1 GB upload bypass the API data path?
14. What is the difference between checkpointing and idempotency?
15. Why does one LastProcessedRow stop working when chunks execute in parallel?
16. Why can a completed chunk be delivered again?
17. How do processing identity and business identity differ?
18. Why should a DB timeout be treated differently from an invalid price?
19. Why can an open circuit breaker still leave a queue-churn problem?
20. When should a failed chunk go to DLQ, and when should consumption simply be delayed?
21. Why is SemaphoreSlim insufficient for a global per-dealer concurrency limit?
22. Why is SSE not the source of truth for job progress?
23. What does a durable queue provide that Task.Run does not?
24. How does a queue protect downstream capacity during a burst?
