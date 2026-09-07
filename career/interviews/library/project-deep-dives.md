# Project Deep Dives

Project explanation is already a strength. The objective is to make each project usable in progressively deeper technical interviews without over-answering the first question.

## Response Ladder

```text
30 seconds   Business problem and outcome
2 minutes    Architecture, ownership, and decision
5 minutes    Critical flow, trade-offs, and production result
Deep dive    Failure modes, alternatives, operations, and learning
```

## Primary Project Set

### 1. Marketplace Modernization

Use for:

- distributed systems
- legacy modernization
- event-driven architecture
- platform evolution
- system design
- production reliability

Primary guide:

- [Marketplace Platform Interview Guide](../projects/marketplace/07-interview-guide.md)

Questions to rehearse:

- Why not perform a big-bang rewrite?
- Why keep Oracle as the system of record?
- What did the integration layer protect?
- How were duplicate and out-of-order events handled?
- How did multiple platform generations coexist?
- What was your personal contribution?

### 2. Vehicle Detail BFF

Use for:

- API design
- frontend/backend boundaries
- partial failure
- latency
- service aggregation
- customer experience

Questions to rehearse:

- Which dependencies were required?
- Which could degrade?
- How were calls parallelized?
- What belonged in the BFF rather than domain services?
- How did tracing influence performance work?
- How would the BFF evolve at greater scale?

### 3. Guardlane

Use for:

- production AI
- MLOps
- model evaluation
- fallbacks
- human review
- governance
- technical leadership

Primary guide:

- [Guardlane Interview Guide](../projects/guardlane/14-interview.md)

Questions to rehearse:

- Why use a hybrid architecture?
- Why DistilBERT?
- Why retain deterministic rules?
- Why not use an LLM for everything?
- How were model and business-policy ownership separated?
- How would drift and disagreement be monitored?

### 4. AI Upload

Use for:

- cross-stack delivery
- AI workflow integration
- validation
- human review
- operational readiness
- product collaboration

Primary source:

- [AI Upload Story](../stories/01_OPENLANE/AI_UPLOAD.md)

Questions to rehearse:

- What was the operating workflow?
- Where could input quality fail?
- How was model uncertainty exposed?
- What required human judgment?
- What did you own?
- What remains unverified in the current documentation?

### 5. Enterprise Search

Use for:

- search architecture
- Elasticsearch
- APIs
- relevance and product discovery
- production debugging
- business rules

Primary guide:

- [Holland & Barrett Interview Guide](../projects/holland-barrett-platform/09-interview-guide.md)

Questions to rehearse:

- Why not query Elasticsearch from React?
- Why not use SQL for search?
- What is an inverted index?
- How do analyzers and tokenization affect relevance?
- How would indexing and query traffic scale?
- How did search affect the business?

### 6. Promotion Engine

Use for:

- parsing and domain rules
- ANTLR
- frontend/backend delivery
- requirements ambiguity
- stakeholder communication

Questions to rehearse:

- Why use a grammar?
- How were invalid rules reported?
- Where did validation occur?
- How were business changes tested?
- What was the relationship between the definition UI and backend evaluation?

## Five-Minute Deep-Dive Template

### Situation

Describe the system and why the business needed change.

### Constraint

Explain what made the problem difficult:

- production continuity
- legacy dependency
- uncertainty
- latency
- sensitive data
- cross-team ownership

### Architecture

Describe the critical flow and boundaries.

### Personal Ownership

State what you personally:

- analyzed
- designed
- implemented
- communicated
- operated

### Decision and Trade-Off

Name one real alternative and why it was not selected.

### Result

Use verified evidence. If a precise metric is unavailable, describe the operational or product outcome without manufacturing a number.

### Reflection

Explain what you would repeat or change.

## Deep-Dive Quality Gate

Before using a project in an interview, confirm:

- the first answer is concise
- the architecture can be drawn from memory
- personal ownership is distinct from team scope
- at least two trade-offs are available
- at least three failure modes are understood
- one production or operational example exists
- unsupported metrics have been removed
- a clear learning closes the answer
