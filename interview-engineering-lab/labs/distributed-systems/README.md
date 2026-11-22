# Distributed Systems Lab

Design the reliable backbone of the document platform.

## Interview competencies

- Service boundaries and API contracts
- Asynchronous messaging and delivery semantics
- Idempotency, retries, backoff, and dead-letter queues
- State transitions, consistency, and concurrency control
- Backpressure, capacity, observability, and incident recovery

## Experiment 01 — Duplicate-safe processing

**Question:** How does an at-least-once worker avoid creating duplicate approved
records when a message is delivered twice or a worker crashes after committing?

Produce:

1. A state transition diagram for `ProcessingJob`.
2. The idempotency key and where uniqueness is enforced.
3. A failure matrix covering crash-before-write, crash-after-write,
   acknowledgement loss, poison input, and dependency timeout.
4. Retry/backoff and dead-letter rules.
5. A five-minute spoken explanation with one rejected alternative.

Optional implementation: a minimal worker and persistence adapter with tests that
deliver the same message concurrently and repeatedly.

## Follow-up questions

- Why is "exactly once" usually a property we construct rather than a broker
  guarantee we simply enable?
- When would an inbox/outbox pattern be justified?
- What must be transactional, and what may be eventually consistent?
- How would you replay a dead-lettered job safely?
- What changes at 10x throughput?

## Exit criteria

- The same message can be processed repeatedly without duplicating effects.
- State transitions and ownership are explicit.
- Failure recovery is observable and testable.
- The design can be defended without code or cloud-product name-dropping.
