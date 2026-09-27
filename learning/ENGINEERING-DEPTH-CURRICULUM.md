# Dheerix Engineering Depth Curriculum

> Goal: convert years of practical engineering experience into explicit, retrievable, defensible engineering knowledge.
>
> This is not a deadline-driven syllabus. We will move through it gradually. A topic is "ironed" when I can explain it simply, name the pattern, state its guarantees and boundaries, reason through failure modes, compare alternatives, and connect it to a system I have actually built.

## How each concept is learned

Every concept should eventually have a compact concept card:

1. **Problem** — why does this concept exist?
2. **Mental model** — explain it without jargon.
3. **Terminology** — precise names and vocabulary.
4. **Mechanism** — what actually happens?
5. **Guarantees** — what does it guarantee, and what does it not?
6. **Failure modes** — where does the naive implementation break?
7. **Trade-offs** — when would I choose something else?
8. **Implementation** — code/query/architecture where useful.
9. **My example** — connect to real systems I have worked on.
10. **30-second answer** — interview/design-review articulation.
11. **Challenge** — defend the design when another engineer pushes back.

Progress labels: **Unseen → Familiar → Can Explain → Can Defend → Ironed**

---

# 1. Core Engineering Mental Models

- Abstraction and encapsulation
- Coupling vs cohesion
- Separation of concerns
- Composition vs inheritance
- Interface vs implementation
- Dependency inversion
- Immutability and side effects
- State and state transitions
- Invariants
- Preconditions / postconditions
- Fail-fast vs fault tolerance
- Defensive programming
- Pure vs impure functions
- Determinism
- Temporal coupling
- Local vs distributed state
- Source of truth
- Derived state
- Control plane vs data plane
- Push vs pull
- Sync vs async
- CPU-bound vs I/O-bound
- Latency vs throughput
- Concurrency vs parallelism
- Availability vs reliability vs durability
- Correctness vs resilience
- Backward/forward compatibility
- Graceful degradation
- Blast radius
- Failure domains
- Build vs buy
- Complexity budgets

# 2. C# and .NET Runtime Depth

## Language/runtime
- Value types vs reference types
- Stack vs heap: useful model and misconceptions
- Boxing/unboxing
- Records, classes, structs
- Equality: reference, value, structural
- Generics and variance
- Delegates, Func/Action, events
- Closures
- LINQ execution and deferred execution
- IEnumerable vs IQueryable vs IAsyncEnumerable
- Reflection and attributes
- Nullable reference types
- Exceptions and exception filters
- IDisposable / IAsyncDisposable
- using / await using
- GC generations, allocations, LOH
- Memory pressure and common leaks

## Async/concurrency
- Task vs Thread
- async/await state machine
- What actually happens at await
- I/O completion vs worker threads
- CPU-bound vs I/O-bound async
- Task.Run and when not to use it
- ThreadPool
- SynchronizationContext
- ConfigureAwait
- CancellationToken
- Task.WhenAll / WhenAny
- SemaphoreSlim
- locks / Monitor
- concurrent collections
- race conditions
- deadlocks
- starvation
- async-over-sync / sync-over-async
- exception propagation in async code

## ASP.NET Core
- Request lifecycle
- Middleware pipeline
- Dependency injection lifetimes
- Singleton / scoped / transient
- Controllers vs minimal APIs
- Model binding and validation
- Filters
- Authentication vs authorization
- Claims/policies
- HttpClientFactory
- Connection pooling
- BackgroundService / hosted services
- Configuration/options pattern
- Health checks
- Rate limiting
- Output caching
- API versioning
- Graceful shutdown

# 3. API and Service Design

- REST resource modeling
- HTTP semantics
- GET/POST/PUT/PATCH/DELETE
- Safe vs idempotent methods
- Status codes
- Headers
- Content negotiation
- Pagination: offset vs cursor
- Filtering/sorting/search
- API versioning
- Request validation
- Error contracts / Problem Details
- Idempotency keys
- Correlation/request IDs
- Optimistic concurrency with ETags
- Long-running operations
- Polling vs callbacks/webhooks
- Webhooks and webhook reliability
- GraphQL fundamentals
- GraphQL N+1
- BFF pattern
- API gateway
- Aggregation vs orchestration
- Service boundaries
- Contract-first design
- Backward-compatible API evolution
- Rate limits / quotas
- Authentication tokens
- OAuth/OIDC conceptual model
- JWT guarantees and misconceptions

# 4. Databases and Data Modeling

## Relational foundations
- Tables, rows, keys
- Primary/composite/foreign keys
- Constraints
- Normalization and denormalization
- One-to-one / one-to-many / many-to-many
- Index fundamentals
- B-tree mental model
- Composite indexes
- Covering indexes
- Selectivity/cardinality
- Query plans
- Full table scans
- Joins and join algorithms
- N+1 queries
- Pagination performance

## Transactions/concurrency
- ACID
- Atomicity
- Consistency
- Isolation
- Durability
- Transaction boundaries
- Autocommit
- Lost update
- Dirty read
- Non-repeatable read
- Phantom read
- Isolation levels
- MVCC
- Pessimistic locking
- SELECT FOR UPDATE
- Optimistic concurrency
- Version columns
- Atomic conditional updates
- Deadlocks
- Lock ordering
- Transaction retries

## Scaling/storage
- Read replicas
- Replication lag
- Partitioning
- Sharding
- Consistent hashing
- Hot partitions
- Connection pooling
- Database migrations
- Zero-downtime schema changes
- OLTP vs OLAP
- SQL vs NoSQL decision making
- Document/key-value/wide-column models
- Event sourcing basics
- CQRS basics

# 5. Distributed Systems — Core Depth

## Fundamental realities
- Partial failure
- Network unreliability
- Timeouts
- Retries
- Exponential backoff
- Jitter
- Retry storms
- Duplicate delivery
- Message loss
- Reordering
- Clock/time assumptions
- Split brain
- Network partitions

## Delivery/correctness
- At-most-once
- At-least-once
- Exactly-once: meaning and limitations
- Idempotency
- Idempotency keys
- Idempotent consumers
- Deduplication
- Atomicity across boundaries
- Transactional outbox
- Inbox pattern
- CDC
- Dual-write problem
- Distributed transactions
- Two-phase commit
- Saga pattern
- Choreography vs orchestration
- Compensating transactions
- Reconciliation

## Consistency
- Strong consistency
- Eventual consistency
- Read-your-writes
- Monotonic reads
- CAP theorem
- PACELC
- Quorum concepts
- Leader/follower
- Consensus conceptual model
- Conflict resolution

## Resilience
- Circuit breaker
- Bulkhead
- Timeout budgets
- Retry budgets
- Load shedding
- Backpressure
- Graceful degradation
- Health/readiness/liveness
- Poison messages
- Dead-letter queues
- Replay
- Disaster recovery
- RPO/RTO

# 6. Messaging and Event-Driven Architecture

- Queue vs stream
- Commands vs events
- Event notification vs event-carried state
- Kafka/Pulsar/Kinesis mental models
- Topics
- Partitions
- Ordering guarantees
- Consumer groups/subscriptions
- Offsets/cursors
- Acknowledgements
- Redelivery
- Retention
- Replay
- Compaction
- Partition keys
- Hot partitions
- Consumer lag
- Backpressure
- Schema evolution
- Avro/Protobuf/JSON trade-offs
- Schema registry
- Event versioning
- Event envelope
- Correlation/causation IDs
- Retry topics
- DLQ strategy
- Eventual consistency
- Outbox + broker
- CDC + broker
- Event-driven vs request-driven architecture
- Event choreography risks

# 7. Caching

- Why cache?
- Local vs distributed cache
- Browser/CDN/service/database caches
- Cache-aside
- Read-through
- Write-through
- Write-behind
- TTL
- Eviction policies
- Cache invalidation
- Stale data
- Cache stampede
- Cache penetration
- Cache warming
- Negative caching
- Hot keys
- Distributed cache consistency
- DB/cache race conditions
- Invalidation through events/CDC
- Versioned cache keys
- Redis data structures
- Redis persistence/replication basics
- When caching makes a system worse

# 8. Networking and Web Fundamentals

- DNS resolution
- IP/TCP/UDP mental models
- TCP connection lifecycle
- TLS handshake conceptual model
- HTTP/1.1 vs HTTP/2 vs HTTP/3
- Keep-alive
- Connection pooling
- Latency sources
- Proxies
- Reverse proxies
- Load balancers
- L4 vs L7
- NAT
- CDN
- CORS
- Cookies
- Sessions
- SameSite
- CSRF
- WebSockets
- SSE
- gRPC
- Compression
- Browser request lifecycle

# 9. Frontend and Browser Engineering

## JavaScript/TypeScript
- Event loop
- Call stack
- Microtasks vs macrotasks
- Promises
- async/await in JS
- Closures
- Scope
- this
- Prototypes
- Modules
- TypeScript structural typing
- Generics
- unions/intersections
- narrowing
- utility types
- type vs interface
- runtime vs compile-time types

## UI architecture
- React rendering model
- State vs props
- Derived state
- Hooks mental model
- Effects and effect misuse
- Memoization
- Context
- State management
- Server state vs client state
- React Query-style caching
- SSR/CSR/SSG
- Hydration
- Next.js mental model
- Svelte mental model
- Micro-frontends
- Design systems
- Component boundaries
- Accessibility
- Performance/Core Web Vitals
- Bundle splitting
- Browser caching

## UI quality
- Figma-to-implementation workflow
- Visual states
- Responsive states
- Empty/loading/error states
- Interaction states
- Accessibility validation
- Visual regression testing
- Screenshot testing
- Storybook/component isolation
- Design tokens
- Definition of done for AI-assisted frontend work

# 10. Testing and Software Quality

- Test pyramid
- Unit tests
- Integration tests
- Contract tests
- Component tests
- End-to-end tests
- Smoke tests
- Regression tests
- Property-based testing
- Mutation testing concept
- Test doubles
- Mock/stub/fake distinctions
- What not to mock
- Deterministic tests
- Flaky tests
- Test data
- Consumer-driven contracts
- Testing async/event-driven systems
- Testing eventual consistency
- Failure injection
- Chaos engineering concepts
- Load testing
- Performance testing
- Security testing
- Visual regression
- Shift-left vs production validation
- Definition of done
- AI-generated code verification

# 11. Observability and Production Engineering

- Logs vs metrics vs traces
- Structured logging
- Correlation IDs
- Distributed tracing
- Spans
- Context propagation
- OpenTelemetry
- RED method
- USE method
- SLIs
- SLOs
- SLAs
- Error budgets
- Golden signals
- Histograms/percentiles
- p50/p95/p99
- Cardinality
- Sampling
- Alert fatigue
- Symptom vs cause alerts
- Dashboards
- Honeycomb-style exploratory observability
- Production debugging
- Incident response
- Incident timeline
- Root cause vs contributing factors
- Blameless postmortems
- Runbooks
- Feature flags
- Canary releases
- Rollbacks

# 12. AWS and Cloud Architecture

## Foundations
- Regions/AZs
- VPC
- subnets
- route tables
- security groups
- NACLs
- IAM users/roles/policies
- AssumeRole
- least privilege
- KMS
- Secrets Manager/Parameter Store

## Compute
- EC2
- Lambda
- ECS/EKS
- serverless vs containers
- cold starts
- concurrency
- autoscaling

## Data/messaging
- S3
- RDS/Aurora
- DynamoDB
- ElastiCache
- SQS
- SNS
- Kinesis
- EventBridge

## Architecture
- ALB/NLB/API Gateway
- CloudFront
- Route 53
- Multi-AZ
- multi-region
- backup/restore
- DR
- cost/performance trade-offs
- Well-Architected pillars
- Infrastructure as Code
- Terraform/CDK concepts

# 13. Containers, Kubernetes and Delivery

- Container vs VM
- Image/layers
- Docker build/cache
- Registry
- Kubernetes pod
- deployment
- replica set
- service
- ingress
- configmap/secret
- requests/limits
- probes
- scheduling
- autoscaling
- rolling deployments
- graceful termination
- persistent volumes
- namespaces
- RBAC
- service discovery
- networking basics
- Helm
- GitOps
- ArgoCD
- CI vs CD
- deployment strategies
- blue/green
- canary
- feature flags
- rollback
- supply-chain basics

# 14. Security Engineering for Application Developers

- Threat modeling
- Authentication vs authorization
- OAuth 2.0 / OIDC
- JWT
- Session security
- RBAC/ABAC
- Least privilege
- OWASP Top 10 concepts
- Injection
- XSS
- CSRF
- SSRF
- Broken access control
- Secrets management
- Encryption in transit/at rest
- Hashing vs encryption
- Password hashing
- Key rotation
- Input validation
- Output encoding
- Dependency/supply-chain risk
- Audit logs
- PII handling
- Multi-tenant isolation
- Secure-by-default API design

# 15. System Design

## Method
- Clarify requirements
- Functional vs non-functional requirements
- Capacity estimation
- API/data model
- High-level architecture
- Critical flows
- Bottlenecks
- Scaling
- Reliability
- Security
- Observability
- Trade-offs
- Evolution path

## Building blocks
- Load balancing
- horizontal/vertical scaling
- stateless services
- caching
- databases
- replicas
- sharding
- queues/streams
- object storage
- CDN
- search
- rate limiting
- distributed locks
- unique ID generation
- schedulers
- batch processing
- stream processing

## Practice systems
- URL shortener
- notification system
- file upload/processing
- chat
- search/autocomplete
- feed
- payment/order workflow
- inventory/reservations
- analytics pipeline
- vehicle marketplace
- auction/bidding
- moderation pipeline
- "upload anything" assistant
- ML inference service

# 16. Architecture and SDE3/Tech-Lead Reasoning

- Modular monolith vs microservices
- Domain boundaries
- Bounded contexts
- DDD vocabulary
- Hexagonal/clean architecture
- Layered architecture
- Event-driven architecture
- CQRS
- Saga
- Strangler Fig
- Anti-corruption layer
- BFF
- API gateway
- Data ownership
- Shared database risks
- Service coupling
- Conway's Law
- Architecture Decision Records
- Evolutionary architecture
- Fitness functions
- Technical debt
- Migration strategies
- Build/buy/reuse
- Cost of complexity
- Reversibility of decisions
- One-way vs two-way doors
- Designing for team ownership
- Reviewing architecture proposals
- Challenging assumptions respectfully
- Explaining trade-offs to non-engineers

# 17. AI/ML Foundations

## Mathematical intuition
- Scalars/vectors/matrices
- Dot product
- cosine similarity
- distance metrics
- probability basics
- conditional probability
- Bayes theorem
- distributions
- mean/variance
- gradients
- loss functions
- optimization
- gradient descent

## Classical ML
- supervised/unsupervised learning
- classification/regression
- train/validation/test
- features/labels
- overfitting/underfitting
- bias/variance
- regularization
- class imbalance
- precision/recall/F1
- ROC/AUC
- confusion matrix
- threshold selection
- calibration
- cross-validation
- data leakage
- drift
- decision trees
- random forests
- boosting
- logistic regression
- embeddings conceptually

# 18. Deep Learning and Transformers

- Neural network intuition
- neurons/layers/activations
- forward pass
- backpropagation intuition
- embeddings
- tokenization
- positional information
- attention
- self-attention
- query/key/value
- multi-head attention
- transformer blocks
- encoder vs decoder
- BERT-style models
- GPT-style models
- fine-tuning
- transfer learning
- DistilBERT
- inference
- batching
- latency/throughput
- CPU/GPU concepts
- quantization
- model serving
- SageMaker endpoints
- model monitoring

# 19. LLM Application Engineering

- Tokens/context windows
- Prompt construction
- System/user/tool roles
- Structured outputs
- Function/tool calling
- Hallucination
- grounding
- temperature/sampling concepts
- embeddings
- vector databases
- chunking
- retrieval
- semantic search
- hybrid search
- reranking
- RAG architecture
- citations/provenance
- context engineering
- prompt injection
- data exfiltration risks
- guardrails
- moderation
- evals
- offline/online evaluation
- LLM-as-judge limitations
- latency/cost/quality trade-offs
- caching
- fallbacks
- model routing
- human-in-the-loop
- observability for LLM systems

# 20. Agents and Agentic Systems

- Workflow vs agent
- State machines
- Tool use
- Planning
- routing
- memory
- checkpoints
- human approval
- deterministic vs agentic steps
- retries
- idempotent tools
- durable execution
- LangGraph concepts
- multi-agent systems
- agent failure modes
- runaway loops
- permissions
- sandboxing
- evals
- observability
- cost controls
- when NOT to use an agent
- PlanForge as an agentic workflow case study
- upload-anything assistant architecture

# 21. ML/AI Production Engineering

- Training vs inference
- Dataset quality
- labeling
- weak/LLM-assisted labels
- human annotation
- train/serve skew
- model registry
- experiment tracking
- deployment
- shadow/canary models
- thresholds
- fallback models
- drift
- monitoring
- retraining
- rollback
- feature pipelines
- batch vs online inference
- latency budgets
- cost
- HITL
- Guardlane as a case study: regex → classifier → LLM fallback → human review
- Measuring product impact of moderation decisions

# 22. Data Engineering Foundations

- ETL vs ELT
- batch vs streaming
- data lake/warehouse/lakehouse
- schemas
- data quality
- lineage
- CDC
- event time vs processing time
- windows
- late/out-of-order data
- idempotent pipelines
- exactly-once claims
- partitioning
- orchestration
- backfills
- retention
- analytics vs operational data

# 23. Performance Engineering

- Profiling
- Benchmarking
- Big-O vs real performance
- CPU/memory/I/O bottlenecks
- Latency budgets
- Tail latency
- Throughput
- Queuing effects
- Connection pools
- Thread pools
- Database query performance
- Caching
- Batching
- Pagination
- Compression
- Allocation reduction
- Async scalability
- Load testing
- Capacity planning

# 24. DSA — Maintenance and Reasoning

- Complexity analysis
- Arrays/strings
- Hash maps/sets
- Two pointers
- Sliding window
- Prefix sums
- Stack/queue
- Linked lists
- Binary search
- Intervals
- Trees/BST
- DFS/BFS
- Heaps
- Tries
- Graphs
- Topological sort
- Union-find
- Backtracking
- Greedy
- Dynamic programming basics
- Recursion
- Recognizing patterns
- Explaining complexity
- Writing correct code without AI assistance

# 25. Engineering Communication and Articulation

For every technical area:
- 30-second explanation
- 2-minute explanation
- whiteboard/design-review explanation
- explain to PM
- explain to junior engineer
- explain failure mode
- defend chosen trade-off
- acknowledge uncertainty precisely
- distinguish fact from assumption
- ask clarifying questions
- disagree with senior engineer
- PR review language
- incident communication
- demo communication
- Frame → Fact → Direction
- "new information, not a verdict"

# 26. Engineering Leadership

- Ownership vs doing everything
- Delegation
- Mentoring
- PR review
- Raising engineering standards
- Decision making under uncertainty
- Driving alignment
- Cross-team communication
- Technical proposals
- ADRs
- Estimation
- Risk identification
- Dependency management
- Scope negotiation
- Incident leadership
- Postmortems
- Giving/receiving feedback
- Influencing without authority
- Balancing delivery speed and quality
- AI-assisted development governance
- Definition of done in high-throughput teams

# 27. Real-System Case Studies to Extract

These should become reusable architecture/articulation material rather than confidential implementation dumps:

- Legacy Oracle/Java → Lambda/Kinesis → .NET/Pulsar modernization
- GoldenGate/CDC bridge
- Vehicle Detail Page + BFF + micro-frontends
- Guardlane moderation architecture
- SageMaker inference and fallback flow
- Human-in-the-loop moderation
- Similar Listings/ranking
- Upload workflows
- Production observability with Honeycomb/OpenTelemetry
- IAM/AWS SDK migration
- ArgoCD/GitOps deployment
- Apollo Tyres field ecosystem
- FoodMesh/FoodGPT
- Rheumera/HIPAA-oriented systems
- Hardware/mobile integrations from earlier career

For each: requirements → constraints → architecture → decisions → alternatives → failures → observability → outcomes → what I would change now.

# 28. Concept Connections We Must Be Able to Traverse

Examples of the connected mental models we want:

```
retry
  → duplicate execution
  → idempotency
  → idempotency key
  → at-least-once delivery
  → idempotent consumer

DB update + publish event
  → dual-write problem
  → transactional outbox / CDC
  → broker
  → duplicate delivery
  → idempotent consumer

concurrent update
  → race condition
  → isolation
  → pessimistic lock / optimistic concurrency / atomic update

cache
  → stale state
  → invalidation
  → distributed consistency
  → event/CDC
  → eventual consistency

external side effect
  → uncertain outcome
  → provider idempotency
  → reconciliation

async I/O
  → non-blocking wait
  → thread-pool scalability
  → CPU-bound vs I/O-bound
  → Task.Run vs true async I/O
```

# 29. Current Diagnostic Notes

Initial diagnostic suggests the primary issue is **not lack of engineering experience**. The recurring gap is converting practical intuition into precise, named, defensible models.

Observed:
- Duplicate event → instinctively identified stable keys/upsert.
- Non-idempotent event → identified durable event tracking.
- Atomic business update + event record → identified transaction.
- Concurrent inventory → identified locking; needs precision on lock semantics and alternatives.
- Payment retry → identified stable provider/session identity and reconciliation.
- Cache staleness → identified TTL and invalidation; needs stronger failure-window reasoning.
- DB update + event publish → **genuine gap found: transactional outbox**.
- async/await → correct practical model; terminology/runtime mechanics need ironing.

This curriculum exists to fix exactly that distinction: **experience → concept → terminology → guarantee → failure mode → trade-off → articulation.**

---

## Rule for progressing

Do not try to finish this document.

Pick a concept when it becomes relevant. Learn it deeply enough to connect it to neighboring concepts. Revisit it later under pressure. The objective is not coverage; the objective is an engineering mental model that remains available during design reviews, incidents, interviews, and implementation.
