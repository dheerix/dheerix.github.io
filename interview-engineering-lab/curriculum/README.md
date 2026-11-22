# Master Curriculum

The curriculum is shared across companies. Company pages change emphasis, not the
underlying concepts.

## Learning sequence

1. **Frame the system:** functional requirements, constraints, scale, SLOs, and
   explicit non-goals.
2. **Model the workflow:** API contracts, state transitions, ownership, and data
   boundaries.
3. **Make it reliable:** queues, delivery semantics, idempotency, retries,
   backpressure, and dead-letter handling.
4. **Make it searchable:** document shape, inverted indexes, analyzers, mappings,
   ranking, and relevance evaluation.
5. **Add AI deliberately:** extraction contracts, tool use, context budgets,
   confidence, human review, and deterministic fallbacks.
6. **Operate it:** logs, metrics, traces, SLOs, alerting, incident diagnosis,
   privacy, and cost.
7. **Defend it:** alternatives, trade-offs, failure scenarios, and evolution at
   10x scale.

Do not wait to finish the sequence before running mocks. Use a mock after each
topic to reveal whether knowledge survives follow-up questions.

## Study session protocol

A normal session is 60 minutes:

- 5 minutes — recall the prior mental model without notes
- 15 minutes — learn one narrow concept
- 20 minutes — run or design one focused experiment
- 10 minutes — explain the decision and trade-off aloud
- 10 minutes — answer one timed follow-up and update `PROGRESS.md`

## Mastery test

A topic is interview-ready only when you can:

1. State the mental model in one sentence.
2. Explain how it works precisely.
3. Identify at least two failure modes.
4. Choose between realistic alternatives using stated constraints.
5. Apply it to the document platform.
6. Handle a follow-up without retreating into memorized definitions.

## Supporting sources

- [Engineering depth](../../engineering/README.md)
- [Compact interview notes](../../interview-notes/README.md)
- [System-design foundations](../../interview-notes/system-design/foundations.md)
- [System-design terminology](../../interview-notes/system-design/terminology.md)
- [General interview library](../../career/interviews/README.md)
