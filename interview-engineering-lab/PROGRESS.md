# Progress

Last updated: 2026-11-14

This is the canonical resume point for curriculum, lab, and mock-interview chats.
Update it after every session. Keep observations evidence-based; do not mark a
skill strong because it merely feels familiar.

## Current focus

- **Topic:** Reliable asynchronous document processing
- **Interview competency:** Decompose a system, define delivery semantics, and
  reason about idempotency, retries, and failure recovery.
- **Lab:** [`labs/distributed-systems/`](labs/distributed-systems/)
- **Next action:** Complete Experiment 01 on paper and explain the design aloud in
  five minutes before writing implementation code.
- **Definition of done:** Can explain where duplicate delivery occurs, choose an
  idempotency key, describe retry/backoff behavior, and defend the dead-letter
  policy without notes.

## Provisional baseline

These observations come from repository artifacts and must be validated through
timed explanations and mocks.

| Area | Status | Evidence | Next validation |
|---|---|---|---|
| .NET and ASP.NET Core runtime | Practiced | Compact notes cover async, cancellation, DI, middleware, and configuration | 10-minute verbal technical screen |
| System-design vocabulary | Practiced | Existing terminology, foundations, and scenario notes | 35-minute end-to-end design mock |
| Distributed failure reasoning | Unassessed | Relevant study material exists, but no result is recorded here | Complete distributed Experiment 01 |
| Elasticsearch internals and relevance | Unassessed | No lab result recorded | Explain inverted indexes, analyzers, and BM25; then run Experiment 01 |
| Agent design and evaluation | Unassessed | AI notes exist, but no interview evidence is recorded | Design an eval set and failure taxonomy |
| Coding under time pressure | Unassessed | Prior practice exists outside this workspace | Run a 35-minute coding mock |
| Behavioral storytelling | Unassessed | Existing answer and story banks exist | Deliver two STAR answers with follow-ups |

Status vocabulary: `Unassessed`, `Learning`, `Practiced`, `Interview-ready`, or
`Needs repair`.

## Competency scorecard

Score only after observable practice: `0` unknown, `1` recall, `2` explain,
`3` apply, `4` defend trade-offs under follow-up.

| Competency | Score | Last evidence | Gap |
|---|---:|---|---|
| Requirements and scope | 0 | — | Run first design exercise |
| API and data modelling | 0 | — | Define ingestion and review contracts |
| Queues, delivery, and idempotency | 0 | — | Complete Experiment 01 |
| Consistency and failure recovery | 0 | — | Create failure matrix |
| Search indexing and relevance | 0 | — | Complete search Experiment 01 |
| Agent orchestration and context | 0 | — | Complete agent Experiment 01 |
| AI evaluation and guardrails | 0 | — | Build first eval rubric |
| Observability and operations | 0 | — | Define SLOs and signals |
| Clear technical communication | 0 | — | Record five-minute explanation |

## Session log

| Date | Type | Topic | Evidence produced | Gap discovered | Next action |
|---|---|---|---|---|---|
| 2026-11-14 | Setup | Interview lab | Curriculum, labs, company tracks, and ADR created | Baseline is not yet validated | Distributed Experiment 01 |

## Mistakes to revisit

Add only specific misconceptions or weak answers. Link to the correction in the
mock log.

| Due | Prompt | Mistake | Correct mental model | Result |
|---|---|---|---|---|
| — | — | — | — | — |

## Session closeout checklist

- [ ] Add one row to the session log.
- [ ] Update score only when evidence justifies it.
- [ ] Add mistakes that should be retested.
- [ ] Set exactly one concrete next action.
- [ ] Link the artifact, code, ADR, or mock that proves the work.
