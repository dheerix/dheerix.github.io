# One-Week Accelerated Interview Plan

This is an intensive seven-day plan. It assumes approximately four focused hours per day.

If additional time is available, spend it on timed repetitions and mock interviews—not on collecting more reading material.

## Daily Operating Rhythm

```text
100 minutes  Coding and DSA
60 minutes   System design
45 minutes   Technical depth
30 minutes   Communication or project drill
15 minutes   Error log and next-day plan
```

For coding:

- solve two focused problems
- repeat one previously missed problem
- work without AI for the full attempt
- explain the approach aloud

For system design:

- use a blank page
- state assumptions
- drive the conversation
- finish with failure modes and trade-offs

## Day 1 — Restore Coding Fluency

### Coding

- Arrays and hash maps
- Two pointers
- Sliding window
- Complexity analysis

Suggested problems:

- Two Sum
- Group Anagrams
- Product of Array Except Self
- Longest Substring Without Repeating Characters

### System Design

Design Workbench user and account management.

Focus on:

- users, organizations, groups, roles, and permissions
- authentication versus authorization
- RBAC and ABAC
- tenant isolation
- audit logs
- access revocation
- HIPAA-sensitive operations

### Technical Depth

- HTTP and REST fundamentals
- authentication and authorization
- OAuth 2.0 and OpenID Connect concepts
- tokens, sessions, expiry, and revocation

### Communication Drill

Give the 30-second and two-minute self-introductions without reading.

## Day 2 — Core Data Structures and Health Data

### Coding

- Stacks and queues
- Binary search
- Linked lists

Suggested problems:

- Valid Parentheses
- Daily Temperatures
- Binary Search
- Reverse Linked List

### System Design

Design a precision-health ingestion and processing platform.

Focus on:

- batch and streaming ingestion
- validation and normalization
- FHIR awareness
- data lineage
- de-identification
- ETL orchestration
- data quality
- controlled research access

### Technical Depth

- GCP service mapping
- ETL principles
- BigQuery concepts
- Apache Beam concepts
- FHIR resources and interoperability

The objective is discussion-level competence where direct experience is limited.

### Communication Drill

Explain one unfamiliar technology using:

```text
What I know
What I have used directly
What is analogous in my experience
How I would validate the remaining uncertainty
```

## Day 3 — Trees, Graphs, and Developer Platforms

### Coding

- Tree traversal
- BFS and DFS
- Heaps

Suggested problems:

- Maximum Depth of Binary Tree
- Binary Tree Level Order Traversal
- Number of Islands
- Kth Largest Element in an Array

### System Design

Design a cloud-native developer platform for 600 engineers.

Focus on:

- service templates
- Backstage developer portal
- GitHub Actions
- Terraform
- Kubernetes
- ArgoCD and GitOps
- environment provisioning
- platform guardrails
- multi-team ownership
- SLOs and developer experience

### Technical Depth

- Kubernetes workload and networking fundamentals
- Terraform state, modules, plans, drift, and locking
- ArgoCD reconciliation and rollback
- CI versus CD
- platform-as-a-product principles

### Communication Drill

Explain one platform decision in this format:

```text
Developer problem
Constraint
Decision
Alternative rejected
Operational consequence
Success measure
```

## Day 4 — Graph Reasoning and Full-Stack Architecture

### Coding

- Graph dependencies
- Intervals
- Backtracking

Suggested problems:

- Course Schedule
- Clone Graph
- Merge Intervals
- Combination Sum

### System Design

Design a microfrontend application platform.

Focus on:

- React and TypeScript
- host and remote boundaries
- single-spa concepts
- NX monorepo concepts
- shared dependencies
- independent deployment
- contract and integration testing
- Cypress
- asset versioning and rollback

### Technical Depth

- React rendering and hooks
- state ownership
- frontend performance
- Node.js event loop
- package management with npm or pnpm
- Webpack and bundling fundamentals
- BDD, integration, and end-to-end testing

### Communication Drill

Explain a frontend performance problem from symptom to evidence, diagnosis, fix, and validation.

## Day 5 — Dynamic Programming and Production Systems

### Coding

- Recursion
- Basic dynamic programming
- Timed mixed review

Suggested problems:

- House Robber
- Coin Change
- Longest Increasing Subsequence
- one previously failed graph or tree problem

### System Design

Choose one:

- Guardlane moderation platform
- enterprise search platform
- vehicle-detail backend-for-frontend

Add what the existing project guides do not emphasize enough:

- scale assumptions
- data model
- API contracts
- security boundaries
- regional failure
- rollout and rollback
- cost
- SLOs

### Technical Depth

- logs, metrics, and traces
- retries, timeouts, and circuit breakers
- idempotency and duplicate delivery
- eventual consistency
- caching
- rate limiting
- incident response

### Communication Drill

Answer five technical questions with a two-minute limit per answer.

## Day 6 — Full Mock Loop and Remediation

### Mock 1

- 45-minute coding interview
- 10-minute review

### Mock 2

- 45-minute system-design interview
- 15-minute review

### Mock 3

- 45-minute technical and hiring-manager interview

Use [Mock Interviews](mock-interviews.md) for scoring.

After the mocks, classify every miss:

```text
Knowledge gap
Pattern-recognition gap
Coding-execution gap
Testing gap
Communication gap
Time-management gap
```

Spend the remaining session repairing only the highest-impact two gaps.

## Day 7 — Final Simulation

### Coding

- one unseen medium problem
- one 20-minute repeated problem

### System Design

Randomly select one of the four Verily designs and complete it in 45 minutes.

### Technical Round

Rapid-fire questions across:

- Java or Node.js
- React and TypeScript
- APIs and distributed systems
- GCP and AWS
- Kubernetes and Terraform
- IAM and HIPAA
- observability and production operations

### Hiring-Manager Round

Practice:

- why Verily
- why this role family
- technical leadership without title inflation
- a difficult decision
- a failure or changed opinion
- mentoring
- cross-functional disagreement
- first 90 days

### Final Rule

Stop studying several hours before the interview. Review the error log, story index, design framework, and coding checklist. Do not introduce new topics.

## One-Week Exit Criteria

Before applying the label “ready,” complete:

- at least 20 unaided coding attempts
- at least 8 clean re-solves
- four Verily-specific system designs
- two full coding mocks
- two full system-design mocks
- one technical-depth mock
- one hiring-manager mock
- one concise answer for every item in the STAR index
