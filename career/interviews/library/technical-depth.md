# Verily Technical Depth

This is a review map, not a claim that every technology has been used at the same depth.

For every topic, distinguish:

```text
Used directly
Understood through adjacent experience
Learning for the target role
```

## Priority 1 — Must Be Defensible

### Java

- collections and complexity
- immutability
- equality and hashing
- exceptions
- concurrency fundamentals
- thread pools and futures
- JVM memory and garbage collection concepts
- testing and dependency injection
- API and service design

### Node.js and TypeScript

- event loop
- promises and async/await
- CPU-bound versus I/O-bound work
- error propagation
- streams and backpressure
- module and package boundaries
- runtime validation versus static types
- API testing

### React

- render cycle
- state and derived state
- hooks and dependency arrays
- context
- component boundaries
- memoization
- list keys
- error boundaries
- data fetching
- accessibility
- performance diagnosis

### APIs and Distributed Systems

- REST semantics
- idempotency
- pagination
- versioning
- retries and timeouts
- circuit breakers
- eventual consistency
- duplicate and out-of-order events
- schema evolution
- caching
- rate limiting

### SQL and Data

- indexes
- query plans
- transactions
- isolation levels
- normalization and denormalization
- optimistic and pessimistic concurrency
- pagination
- migrations

## Priority 2 — Platform Roles

### Kubernetes

- pod, deployment, service, ingress
- requests and limits
- readiness and liveness
- config maps and secrets
- rolling deployment
- autoscaling
- service discovery
- namespaces and RBAC
- debugging an unhealthy workload

### Terraform

- providers and resources
- state
- remote backends and locking
- modules
- plan and apply
- drift
- lifecycle behavior
- imports
- secrets
- environment strategy
- safe changes and review

Be ready with one real example:

```text
Problem
Terraform boundary
State and environment model
Review and deployment path
Failure or rollback strategy
```

### ArgoCD and GitOps

- desired state
- reconciliation
- application health
- sync and rollback
- drift
- promotion between environments
- relationship with CI

### GCP

Map known AWS concepts to GCP without claiming they are identical:

| Capability | AWS Example | GCP Example |
| --- | --- | --- |
| Object storage | S3 | Cloud Storage |
| Serverless compute | Lambda | Cloud Functions / Cloud Run |
| Containers | EKS / ECS | GKE / Cloud Run |
| Messaging | SNS / SQS / Kinesis | Pub/Sub |
| Analytics warehouse | Redshift | BigQuery |
| Identity | IAM | Cloud IAM |
| Monitoring | CloudWatch | Cloud Monitoring and Logging |

Prepare a direct GCP project example covering architecture, deployment, access, and operations.

### Developer Platform

- platform as a product
- internal developers as customers
- golden paths
- service templates
- developer portals
- ownership catalogs
- self-service infrastructure
- guardrails
- adoption metrics
- platform SLOs

## Priority 3 — Healthcare and Security

### HIPAA-Aware Engineering

Be able to discuss:

- minimum necessary access
- least privilege
- encryption in transit and at rest
- auditability
- access review and revocation
- data retention
- secrets
- non-production data
- incident handling
- third-party dependencies

Do not claim organizational compliance ownership unless that was the actual responsibility.

### Identity and Access Management

- authentication versus authorization
- OAuth 2.0
- OpenID Connect
- SAML concepts
- RBAC and ABAC
- organization and tenant boundaries
- token expiry and revocation
- service identities
- policy decision and enforcement points
- immutable audit events

### FHIR

Discussion-level preparation:

- resource-oriented healthcare data standard
- common resources such as Patient, Observation, Encounter, and Practitioner
- references between resources
- validation
- profiles and implementation guides
- search and version history
- why interoperability does not eliminate source-data ambiguity

### Data Pipelines

- ETL versus ELT
- batch versus streaming
- event time versus processing time
- late data
- replay
- idempotent processing
- dead-letter handling
- schema evolution
- lineage
- data-quality monitoring

### Apache Beam and BigQuery

Know:

- Beam as a unified batch and streaming programming model
- pipeline, transform, PCollection, window, and trigger concepts
- BigQuery as an analytical warehouse
- partitioning and clustering concepts
- separation of operational and analytical workloads

## Priority 4 — Full-Stack Tooling

### Go Orientation

Do not switch interview-coding languages solely for the job description. Use Java for algorithm interviews unless Go is already equally fluent.

Build enough Go literacy to discuss and read team code:

- packages and exported names
- structs and methods
- interfaces and implicit implementation
- slices and maps
- pointers
- explicit error handling
- goroutines and channels
- context cancellation and deadlines
- testing
- HTTP services

State the experience level accurately. Java, C#, Node.js, Python, distributed systems, and API design are transferable evidence; they are not evidence of production Go experience.

### Microfrontends

- ownership boundaries
- shell responsibilities
- runtime and build-time integration
- shared dependencies
- independent deployment
- contract testing
- observability
- design-system governance

### NX

Know its purpose:

- monorepo organization
- project graph
- task orchestration
- affected builds and tests
- shared tooling

### single-spa

Know its purpose:

- registering independent frontend applications
- activation by route or condition
- lifecycle methods
- runtime composition

### Webpack and Package Management

- entry, output, loader, plugin, chunk
- code splitting
- tree shaking
- source maps
- dependency locking
- npm versus pnpm workspace concepts

### Cypress and Testing

- unit versus integration versus end-to-end
- test pyramid and practical trade-offs
- stable selectors
- avoiding timing-dependent tests
- contract tests
- BDD as communication, not only syntax

## Priority 5 — Production AI

- training, validation, and test separation
- precision, recall, and class imbalance
- model and dataset versioning
- deployment strategies
- shadow and canary evaluation
- drift
- human review
- fallbacks
- auditability
- cost and latency
- model output versus business policy

Use Guardlane as the primary evidence.

## Technical Answer Structure

For “How does X work?”:

```text
Definition
Core mechanism
When it is useful
Trade-off
Production example
```

For “Have you used X?”:

```text
Direct level of experience
Specific task
Decision or problem
Operational outcome
Remaining limitation
```

For an unfamiliar technology:

> I have not operated that technology directly at the same depth. I understand that it solves X through Y. The closest system I have used is Z, where the comparable concern was A. I would validate B before making the design decision.

That is stronger than bluffing and stronger than stopping at “I don’t know.”

## Rapid-Fire Question Bank

1. What makes an operation idempotent?
2. How do you prevent retry storms?
3. What is the difference between readiness and liveness?
4. How does Terraform state locking help?
5. What happens when ArgoCD detects drift?
6. RBAC versus ABAC?
7. How would you revoke access quickly across distributed services?
8. How do React keys affect reconciliation?
9. When does memoization make React slower?
10. Why can Node.js still suffer from blocked execution?
11. When would you use a queue instead of a stream?
12. How do database isolation levels affect correctness?
13. What is eventual consistency acceptable for?
14. How do you evolve an event schema?
15. What belongs in an audit event?
16. How do you keep PHI out of application logs?
17. What problem does FHIR address?
18. Batch versus streaming ingestion?
19. How would you measure an internal developer platform?
20. How do you roll back an infrastructure change?

## Rapid-Fire Reference Answers

Attempt each question aloud before reading its answer.

### 1. What makes an operation idempotent?

An operation is idempotent when repeating the same logical request produces the same externally observable result as performing it once.

`PUT` is commonly idempotent because it replaces a resource with a specified state. A payment or resource-creation request can be made idempotent by accepting an idempotency key, persisting the first result, and returning that result for later requests with the same key.

The key must represent the logical operation, not an individual network attempt. The stored result also needs a retention policy and protection against the same key being reused with a different payload.

### 2. How do you prevent retry storms?

Use:

- bounded retries
- exponential backoff
- random jitter
- retry budgets
- circuit breakers
- deadlines
- load shedding
- dead-letter handling for asynchronous work

Retry only transient failures. Do not retry validation errors or permanent authorization failures.

The server should expose enough information to distinguish overload from other failures, and clients should respect `Retry-After` where appropriate. Monitor retry volume separately because a stable request rate can hide rapidly increasing downstream attempts.

### 3. What is the difference between readiness and liveness?

Liveness answers:

> Should the process be restarted?

Readiness answers:

> Should this instance receive traffic?

A service may be alive but not ready while it is warming caches, waiting for required configuration, or temporarily unable to serve requests.

Liveness checks should avoid fragile downstream dependencies; otherwise a database outage can restart every application instance and make recovery worse. Readiness can include dependencies required to serve traffic, but it should still be designed to avoid synchronized flapping.

### 4. How does Terraform state locking help?

Terraform state maps configuration to real infrastructure and records resource identifiers and attributes. State locking prevents two writers from changing the same state concurrently.

Without locking, parallel applies can read the same old state, create conflicting changes, and overwrite each other’s results. A remote backend with locking, restricted access, encryption, versioning, and backup is preferable for team use.

Locking prevents concurrent writers; it does not prevent a logically incorrect plan. Review and controlled apply permissions are still required.

### 5. What happens when ArgoCD detects drift?

ArgoCD compares the desired state stored in Git with the live Kubernetes state.

When drift appears, it marks the application out of sync. Depending on policy, it can:

- report the difference for manual review
- automatically reconcile the cluster to Git
- prune resources removed from Git
- apply self-healing when live objects are modified

Automatic reconciliation is powerful but needs safeguards. Emergency runtime changes can be reverted unexpectedly, so break-glass procedures and a clear method for committing the intended state back to Git are important.

### 6. RBAC versus ABAC?

RBAC grants permissions through roles such as researcher, workspace administrator, or billing administrator. It is understandable and easy to audit but can create many specialized roles.

ABAC evaluates attributes such as organization, project, data sensitivity, region, user status, or resource ownership. It is more expressive but harder to reason about and test.

A practical design often uses RBAC for the stable permission model and ABAC for contextual restrictions:

```text
Role permits dataset.read
AND user.organization == dataset.organization
AND dataset.region is allowed
AND access has not expired
```

### 7. How would you revoke access quickly across distributed services?

Use short-lived access tokens and enforce authorization at every protected boundary.

For urgent revocation:

- disable the identity or membership in the source of truth
- invalidate server-side sessions or refresh tokens
- publish an access-change event
- invalidate policy caches
- require privileged operations to check authoritative state
- record the action in an audit log

There is a trade-off between authorization-cache performance and revocation speed. High-risk operations may require synchronous policy evaluation while lower-risk reads can use a short cache TTL.

### 8. How do React keys affect reconciliation?

Keys identify items across renders. React uses them to match previous elements with new elements and decide which component instances can be reused.

Stable keys preserve component state for the correct logical item. Array indexes are risky when items can be inserted, removed, or reordered because state can move to the wrong row.

Keys need to be unique among siblings and stable across renders; they do not need to be globally unique.

### 9. When does memoization make React slower?

Memoization adds comparison work, memory use, and cognitive complexity.

It can be slower when:

- the component is cheap to render
- props change almost every time
- dependency arrays create frequent invalidation
- large values are compared
- memoization forces more allocation or indirection than recomputation

Use profiling evidence. `useMemo`, `useCallback`, and `React.memo` are performance tools, not correctness tools.

### 10. Why can Node.js still suffer from blocked execution?

JavaScript execution usually runs on one event-loop thread. Asynchronous I/O prevents waiting on the event loop, but CPU-heavy JavaScript still occupies it.

Blocking sources include:

- large synchronous loops
- synchronous filesystem or crypto calls
- expensive serialization
- catastrophic regular expressions
- processing very large payloads

Mitigations include worker threads, separate services, streaming, bounded payloads, asynchronous APIs, and measuring event-loop delay.

### 11. When would you use a queue instead of a stream?

Use a queue when work should generally be processed once by one worker and removed after acknowledgement. It is a natural model for task distribution.

Use a stream when events form an ordered, replayable history that multiple independent consumers may process at different positions.

A queue emphasizes work ownership. A stream emphasizes durable event history and independent consumption.

The final choice also depends on ordering, replay, retention, consumer groups, throughput, and operational expertise.

### 12. How do database isolation levels affect correctness?

Isolation levels control which concurrent transaction effects can be observed.

- Read uncommitted can expose dirty reads.
- Read committed prevents dirty reads but allows non-repeatable reads.
- Repeatable read keeps previously read rows stable, though exact phantom behavior varies by database.
- Serializable provides behavior equivalent to a serial execution, usually with greater contention or retry cost.

Choose based on the business invariant. A read-only product listing may tolerate weaker isolation, while preventing duplicate financial or entitlement changes may require stronger coordination.

### 13. What is eventual consistency acceptable for?

It is appropriate when temporary divergence is acceptable and convergence is guaranteed.

Examples:

- search indexes
- analytics
- recommendations
- activity feeds
- cache replicas

It is less appropriate for:

- access revocation
- unique claims
- balance updates
- workflows where the user must immediately read their own write

If eventual consistency is chosen, explain user-visible behavior, staleness bounds, reconciliation, and monitoring.

### 14. How do you evolve an event schema?

Prefer additive, backward-compatible evolution:

1. Add optional fields.
2. Deploy tolerant consumers.
3. Update producers.
4. Observe adoption.
5. Remove old behavior only after migration.

Use schema validation, compatibility checks, contract tests, version ownership, and documented defaults.

For a breaking semantic change, create a new event type or explicit version rather than silently changing the meaning of an existing field.

### 15. What belongs in an audit event?

An audit event should answer:

- who acted
- what action occurred
- which resource was affected
- when it happened
- from which authenticated context
- whether it succeeded
- which policy or reason applied
- relevant before/after identifiers where appropriate

Audit logs should be append-only, access-controlled, tamper-evident, searchable, retained according to policy, and designed to avoid unnecessary sensitive payloads.

### 16. How do you keep PHI out of application logs?

- classify sensitive fields
- use structured logging with allowlisted fields
- avoid logging request and response bodies by default
- redact at shared logging boundaries
- use opaque identifiers
- restrict log access
- encrypt logs
- define retention
- scan for accidental leakage
- test logging behavior

Error handling should return or record correlation identifiers without copying sensitive business data into exception messages.

### 17. What problem does FHIR address?

FHIR provides a standard, resource-oriented way to represent and exchange healthcare information.

Resources such as Patient, Observation, Encounter, and Practitioner have defined structures and references. Profiles constrain those base resources for specific contexts.

FHIR improves interoperability, but it does not automatically solve:

- source-data quality
- patient matching
- terminology differences
- consent
- authorization
- local workflow semantics

### 18. Batch versus streaming ingestion?

Batch processing works on bounded collections and is usually easier to operate, replay, and optimize for throughput.

Streaming processes continuously arriving data and supports lower latency, but introduces event-time handling, windows, late data, backpressure, checkpointing, and more complex operational state.

Choose based on the required decision latency. Do not introduce streaming solely because the source can emit events.

### 19. How would you measure an internal developer platform?

Measure user outcomes rather than only infrastructure uptime:

- time to create a deployable service
- lead time for change
- deployment frequency
- change-failure rate
- mean time to restore
- platform adoption
- developer satisfaction
- support requests
- policy compliance
- percentage of services using supported golden paths

Combine quantitative telemetry with developer research. High adoption can still hide poor experience if teams are forced onto the platform.

### 20. How do you roll back an infrastructure change?

First determine whether the change is actually reversible.

For configuration and stateless resource changes:

- retain the previous reviewed configuration
- revert in version control
- generate and inspect a new plan
- apply through the controlled pipeline
- validate service and business health

For destructive data or state changes, rollback may require restoration, migration, or forward repair. Terraform state rollback alone does not necessarily restore real infrastructure safely.

Use small changes, versioned modules, backups, staged environments, feature flags where applicable, and explicit recovery procedures.
