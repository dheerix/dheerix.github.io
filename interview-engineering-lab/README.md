# Interview Engineering Lab

This workspace turns interview preparation into one evolving engineering system.
It exists to improve interview performance, not to become a portfolio project with
an unlimited scope.

## The system we will build

A document-processing platform that accepts documents, extracts and validates
structured content, routes uncertain results for human review, and makes approved
content searchable.

The same system creates evidence for three interview tracks:

| Track | Primary company | What we must be able to explain |
|---|---|---|
| Search engine | MaintainX | Indexing, mappings, analyzers, ranking, relevance evaluation, and operations |
| Agentic workflows | Foci and Valency | Tool boundaries, context, orchestration, evaluation, failure handling, and human review |
| Distributed systems | All three | APIs, queues, idempotency, consistency, retries, observability, and scaling |

## Operating rules

1. Every activity must map to a competency in
   [the competency map](curriculum/competency-map.md).
2. Prefer a small experiment that answers a concrete question over adding product
   features.
3. A lab is not complete until its decisions can be explained without looking at
   the code.
4. Record misconceptions and corrected answers in
   [the mock interview log](interviews/mock-log.md).
5. Update [PROGRESS.md](PROGRESS.md) at the end of every study or mock session.
6. Time-box infrastructure work. The default lab session is 60 minutes.

## Workflow

```text
Learn one concept
      ↓
Run one focused experiment
      ↓
Explain the trade-off aloud
      ↓
Answer a timed interview question
      ↓
Record the gap and next action
```

## Directory guide

- `curriculum/` — shared concepts, sequence, and session method
- `labs/search-engine/` — search and Elasticsearch experiments
- `labs/agentic-workflows/` — extraction and agent reliability experiments
- `labs/distributed-systems/` — shared platform and distributed-systems experiments
- `interviews/` — company-specific preparation and mock results
- `decisions/` — architectural decision records worth explaining in interviews
- `PROGRESS.md` — the resume point for every future session

## Existing material

This workspace is an interview-focused control plane over the existing repository.
Deep notes stay in [`../engineering/`](../engineering/), compact revision notes stay
in [`../interview-notes/`](../interview-notes/), and the general interview library
stays in [`../career/interviews/`](../career/interviews/). Link to those sources;
do not duplicate them here.

## Start here

Begin with the next action in [PROGRESS.md](PROGRESS.md), then use the
[study session protocol](curriculum/README.md#study-session-protocol).
