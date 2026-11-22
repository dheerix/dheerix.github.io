# System Design Terminology Bank

> Fast-revision vocabulary from the Senior/SDE3 study sprint. Learn the **problem behind the term**, not only the definition.

## Cold Recall — know these without prompting

- Idempotency
- At-least-once delivery
- ACK / acknowledgement
- Transactional Outbox
- Saga
- Eventual consistency
- Optimistic concurrency
- Checkpoint / processing cursor
- Backpressure
- Load leveling
- Consumer group
- Partitioning / partition key
- Hot partition / skew
- Retry / bounded retry
- Exponential backoff
- Jitter
- Circuit breaker
- Bulkhead
- Graceful degradation
- Fail closed
- Cascading failure
- Cache-aside
- Cache invalidation
- Cache stampede / thundering herd
- Request coalescing / single-flight
- TTL jitter
- Working set
- Heartbeat
- Lease / TTL
- SSE
- Pub/Sub
- Source of truth
- Transactional boundary
- Bounded staleness
- Noisy neighbor
- Local vs distributed coordination

---

## Async / Concurrency

| Term | Quick recall |
|---|---|
| Process | OS-level running program/resource boundary |
| Thread | Execution resource |
| ThreadPool | Reusable worker threads managed by .NET |
| Task | Representation of an asynchronous/concurrent operation |
| async/await | Suspend method while asynchronous work completes; does not inherently create a thread |
| I/O-bound | Time dominated by waiting on external I/O |
| CPU-bound | Time dominated by computation |
| ThreadPool starvation | Available pool threads are blocked/busy faster than they can service work |
| Blocking | Execution resource waits synchronously |
| Task.Run | Schedule work on ThreadPool; not durable background ownership |
| Task.WhenAll | Await multiple independent tasks concurrently |
| CancellationToken | Cooperative cancellation signal |
| Race condition | Result depends on uncontrolled timing/interleaving |
| Atomicity | Operation/state transition appears indivisible |
| lock | Process-local synchronous mutual exclusion |
| Interlocked | Atomic operations on simple shared values |
| SemaphoreSlim | Process-local concurrency/mutual-exclusion primitive with async WaitAsync |
| Bounded concurrency | Explicit cap on simultaneously active work |
| ConcurrentDictionary | Thread-safe individual operations; compound workflows may still race |
| Deadlock | Participants wait indefinitely for resources held by one another |
| Lock ordering | Consistent acquisition order used to avoid deadlocks |

## Database / EF Core

| Term | Quick recall |
|---|---|
| IQueryable | Composable query expression usually translated by provider |
| Deferred execution | Query executes when materialized/enumerated, not necessarily when composed |
| Materialization | Execute query and create in-memory results |
| Change Tracker | EF Core tracks entity state for persistence |
| AsNoTracking | Skip tracking for read-only queries |
| N+1 | One query followed by many per-item related queries |
| Projection | Select only the read shape needed |
| Include | Eager-load related entities; can create expensive query shapes |
| Cartesian expansion | Joined collections multiply result rows |
| Index | Extra data structure improving selected access paths at write/storage cost |
| Query plan | Database's execution strategy for a query |
| Connection pool | Bounded reusable DB connections |
| Optimistic concurrency | Detect conflicts at write time rather than locking early |
| Pessimistic concurrency | Prevent conflicts using locks/coordination before write |
| rowversion / concurrency token | Version used to detect concurrent modification |
| Transaction | Unit of database work with transactional guarantees |
| Isolation | Controls interactions/visibility among concurrent transactions |
| Dirty read | Read another transaction's uncommitted data |
| Non-repeatable read | Same row read twice gives changed committed value |
| Phantom read | Repeated range query returns added/removed matching rows |
| Offset pagination | Skip N rows then take page |
| Keyset pagination | Continue after last stable ordered key |

## Messaging

| Term | Quick recall |
|---|---|
| Producer | Publishes messages/events |
| Consumer | Processes messages/events |
| Broker | Infrastructure carrying/storing messages |
| Topic | Named stream/category of messages |
| Queue | Work waiting for consumers |
| Partition | Ordered/distributed shard of a stream |
| Partition key | Determines partition placement |
| Consumer group | Consumers cooperating as one logical consumption group |
| ACK | Consumer confirms message processing/ownership completion |
| At-least-once delivery | Message may be delivered multiple times |
| Redelivery | Broker sends unacknowledged/failed work again |
| Idempotent consumer | Duplicate delivery does not duplicate intended effect |
| Idempotency key | Stable operation identity used to detect replay |
| Inbox / Processed Messages | Durable record that a message was already handled |
| Transactional Outbox | Atomically persist business change + event to publish later |
| DLQ | Quarantine for work that exhausted processing policy |
| Poison message | Specific item repeatedly fails despite healthy infrastructure |
| Ordering | Required sequence of messages/effects |
| Consumer lag | Distance between produced and consumed work |
| Backpressure | Slow/limit incoming work when downstream capacity is saturated |
| Hot partition | One partition receives disproportionate load |
| Partition skew | Uneven distribution across partitions |

## Distributed Consistency / Workflow

| Term | Quick recall |
|---|---|
| Source of truth | Authoritative state owner |
| Transactional boundary | State that can commit atomically together |
| Strong consistency | Reads observe required latest/serialized state semantics |
| Eventual consistency | Components may temporarily differ but converge |
| Bounded staleness | Stale data acceptable only within defined limit |
| Saga | Coordinate multi-step distributed workflow, often using compensation |
| Compensation | Business action that semantically reverses/offsets an earlier committed step |
| Orchestration | Central coordinator directs workflow steps |
| Choreography | Participants react to events without central workflow controller |
| State convergence | Replicas/components eventually reach compatible current state |
| Resynchronization | Fetch authoritative current state after missed/interrupted updates |

## Resilience

| Term | Quick recall |
|---|---|
| Transient failure | Temporary failure worth retrying |
| Deterministic/permanent failure | Same input will continue failing without change |
| Timeout | Maximum wait for an attempt/operation |
| Deadline / latency budget | Maximum time for the entire caller operation |
| Retry | Repeat transiently failed operation |
| Bounded retry | Retry only a limited number/time budget |
| Exponential backoff | Increase delay between attempts |
| Jitter | Randomize retry/expiry timing to prevent synchronized waves |
| Retry storm | Retries amplify load on an unhealthy system |
| Thundering herd | Many clients simultaneously perform the same expensive action |
| Circuit breaker | Stop calling a dependency known to be unhealthy |
| CLOSED | Circuit permits calls normally |
| OPEN | Circuit fails calls fast |
| HALF-OPEN | Limited probes test dependency recovery |
| Bulkhead | Isolate/bound capacity so one failure/workload cannot consume everything; e.g. per-pod `SemaphoreSlim`, bounded worker pool, separate resource pool |
| Failure isolation | Contain failure to limited components/capabilities |
| Graceful degradation | Preserve useful core behavior while dropping optional capability |
| Fail closed | Refuse operation when missing data could violate critical invariant |
| Cascading failure | One overloaded/failed dependency causes failures across others |
| Backpressure | Response when arrival rate exceeds safe processing capacity: bound waiting work and slow/reject/drop/degrade producers; e.g. bounded `Channel<T>` / bounded queue |
| Resource saturation | Resource demand reaches/exceeds available capacity |
| Load shedding | Reject/drop lower-priority work to protect system health |

## Long-running Jobs

| Term | Quick recall |
|---|---|
| Durable job state | Job lifecycle persists independently of browser/process |
| Job lifecycle | States such as QUEUED → PROCESSING → COMPLETED |
| Durable work ownership | Work survives worker/API process death |
| Work queue | Durable buffer of work for workers |
| Load leveling | Queue smooths bursts into sustainable processing rate |
| Checkpoint | Durable progress marker used to resume work |
| Processing cursor | Position representing resumable progress |
| Chunking | Split work into independently manageable units |
| Retryable work unit | Smallest unit that can safely be retried independently |
| Processing identity | Identity of an input operation, e.g. JobId+Row |
| Business identity | Identity of domain entity, e.g. DealerId+VIN |
| Worker fleet | Multiple processes consuming background work |
| Multi-tenant fairness | Allocate shared capacity fairly across tenants |
| Noisy neighbor | One tenant/workload harms others by consuming shared capacity |
| Per-tenant limit | Capacity/concurrency bound scoped to a tenant |
| Graceful shutdown | Stop accepting work and safely release/recover in-flight work |

## Large Files / Data Processing

| Term | Quick recall |
|---|---|
| Control plane | Authorization, metadata, job creation/status |
| Data plane | Actual high-volume payload/data transfer |
| Object storage | Durable blob/file storage such as S3 |
| Presigned URL | Time-limited authorized direct object-storage operation |
| Multipart upload | Upload large object in independently transferred parts |
| Schema versioning | Explicitly evolve input/output schema versions |
| Backward compatibility | New system continues accepting/understanding supported older contracts |
| Partial success | Some items can succeed while others fail |
| Validation boundary | Earliest layer where a rule/failure can be determined |

## Realtime / Propagation

| Term | Quick recall |
|---|---|
| Polling | Client repeatedly asks for current state |
| SSE | Long-lived HTTP server→client event stream |
| WebSocket | Persistent bidirectional connection |
| Pub/Sub | Publish ephemeral notifications to interested subscribers |
| Fan-out | Distribute one update to many consumers/connections |
| Durable event | Event retained/replayable according to broker semantics |
| Ephemeral notification | Intermediate notification may be lost if latest state can be fetched |
| Push channel | Server proactively sends update to client |
| Resynchronization | Re-fetch current truth after reconnect/missed notification |

## Presence / Ephemeral State

| Term | Quick recall |
|---|---|
| Heartbeat | Periodic signal proving client/entity remains active |
| Lease | Right/presence valid until deadline unless renewed |
| TTL | Automatic expiry lifetime |
| Presence state | Current active/inactive operational state |
| Deduplication | Collapse multiple observations into one logical identity |
| Ephemeral state | Short-lived state that need not become permanent history |
| Operational state | State required to operate system now |
| Analytical history | Durable events/data retained for later analysis |
| Hot key | One logical key receives disproportionate traffic |

## Caching

| Term | Quick recall |
|---|---|
| Cache hit | Requested value found in cache |
| Cache miss | Value absent; origin must be consulted |
| Cache-aside | App reads cache, loads origin on miss, then populates cache |
| Lazy population | Cache values only when requested |
| Cache invalidation | Remove/expire cached state when authoritative state changes |
| Cache granularity | Decide which fields/projections should share caching policy |
| Read model | Data shape optimized for a read use case |
| Working set | Actively accessed subset worth retaining in cache |
| Cache stampede | Many requests miss a hot entry simultaneously |
| Request coalescing | Merge concurrent requests for same missing data |
| Single-flight | One execution rebuilds a key while peers share/wait |
| TTL jitter | Randomize expiry to avoid synchronized expiration |
| Cache warming | Populate likely-hot data before demand |
| Refresh-ahead | Refresh hot data before it expires |
| Stale-while-revalidate | Serve acceptable stale data while refreshing asynchronously |

## Scaling / Capacity

| Term | Quick recall |
|---|---|
| Horizontal scaling | Add instances |
| Vertical scaling | Increase resources of an instance |
| Stateless service | Request handling does not rely on process-local durable session state |
| Load balancing | Distribute traffic across instances |
| Throughput | Work completed per unit time |
| Latency | Time required for one operation/request |
| Capacity | Maximum sustainable workload under target SLO |
| Bottleneck | Resource/component limiting system throughput/latency |
| Connection-pool exhaustion | All DB connections occupied; callers queue/fail |
| Bounded concurrency | Cap simultaneous work to protect capacity |
| Coordination scope | Boundary over which synchronization/limit is actually enforced |

## System-design Reasoning

| Term | Quick recall |
|---|---|
| Functional requirement | Business behavior the system must provide |
| Non-functional requirement | Scale, latency, availability, security, durability etc. |
| Constraint | Boundary the design must respect |
| Assumption | Unconfirmed condition deliberately chosen for design |
| Invariant | Property that must remain true |
| Domain model | Business concepts and relationships |
| Bounded context | Domain boundary within which a model/meaning is consistent |
| Data lifecycle | Creation → mutation → retention → expiry/deletion |
| Consistency requirement | How synchronized/current observations must be |
| Freshness requirement | How old data is allowed to be |
| Availability | Ability to serve acceptable requests |
| Durability | Committed state survives failures |
| Liveness | System/entity continues making progress/is active |
| Failure mode | Specific way the system can fail |
| Trade-off | Benefit gained by accepting another cost/limitation |
| Coordination scope | Local process, node, partition, tenant or distributed system boundary |

---

## Distinctions to recall cold

**Task vs Thread** — operation vs execution resource.

**Async scalability vs downstream capacity** — await can free threads; it cannot make PostgreSQL/SageMaker faster.

**Checkpoint vs Idempotency** — where to resume vs whether replay is safe.

**Processing identity vs Business identity** — input operation vs domain entity.

**Retry count vs Message delivery count** — dependency attempts vs broker redelivery.

**Outbox vs Saga** — reliably propagate committed state vs coordinate/compensate distributed workflow.

**Circuit breaker vs Bulkhead** — dependency health/fail-fast vs capacity isolation. Circuit breaker can wrap `HttpClient`; a local bulkhead can be implemented with `SemaphoreSlim` or bounded worker capacity.

**Bulkhead vs Backpressure** — bulkhead decides how much capacity a workload may consume; backpressure decides what to do when work arrives faster than that capacity can process it.

**Retry storm vs Backpressure** — retry amplification creates additional overload; backpressure is a mechanism used to control overload.

**Pub/Sub vs Durable broker** — ephemeral fan-out vs durable/replayable processing.

**Local SemaphoreSlim vs Distributed limit** — process-local coordination vs system-wide invariant.

**Cache TTL vs Consistency** — expiry is a cache policy; business correctness decides acceptable staleness.

**Ordered delivery vs Ordered effects** — broker sequence alone does not guarantee completion/effect sequence.

**Operational state vs Analytics** — current ephemeral state and durable historical data have different lifecycles.
