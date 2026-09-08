# ADR 0001: Serialize inspection association updates under independent events

- Status: Accepted through merged implementation
- Date: 2026-09-07
- Source: internal seller-service implementation
- Evidence: merged change and focused test coverage

## Context

Seller-service receives independent event streams that contribute different
parts of one appraisal relationship:

- `LeadAppraisalLinked` provides `InspectionId` and `AppraisalId`;
- `InspectionUpdated` and `ListingEvent` provide `InspectionId` and
  `ListingId`.

Pulsar provides at-least-once delivery and `KeyShared` ordering per key, but no
global ordering across topics. Events can arrive out of order, be redelivered,
or refer to a listing that has been replaced.

## Decision

Use an inspection-keyed partial cache and a shared transactional association
service.

For each mutation:

1. lock and reload the cache row by `InspectionId`;
2. lock and reload the relevant listing row;
3. mutate only fields supplied by the current event;
4. validate that the listing belongs to the inspection;
5. reconcile previous listing associations;
6. update `Listing.AppraisalId` only when both sides of the relationship are
   known;
7. commit using the consistent cache-then-listing lock order.

The local mutation policy retries `DbUpdateConcurrencyException` twice. If an
exception escapes, Pulsar redelivery is the broader retry mechanism. The
consumer allows up to seven retries with backoff up to ten minutes.

## Invariants

- One cache row exists per `InspectionId`.
- An event may contribute only the field it owns.
- A listing receives an appraisal only when its `InspectionId` matches the
  association being applied.
- Replayed events do not create duplicate cache rows or regress a correct
  association.
- A listing replacement clears the old projection before assigning the new
  valid association.
- A partial cache row is valid intermediate state, not a failed transaction.

## Consequences

The design supports out-of-order and at-least-once events without requiring
global topic ordering. It makes the convergence point explicit and keeps
listing reads independent of runtime Leads lookups.

Known limits:

- no dedicated deadlock retry exists in this change;
- no unresolved-partial-state metric or reconciliation job exists;
- no DLQ consumer or backfill process exists after Pulsar retries are
  exhausted;
- conflicting appraisal IDs for the same inspection use last processed event
  semantics because there is no event-version comparison;
- permanent missing events can leave a listing without `AppraisalId`.

## Verification

The merged change includes integration coverage for both event orders, replacement
listing cleanup, stale events, duplicate resolution, and appraisal projection
to listing responses. Production convergence is not yet measured.

## Re-evaluation triggers

Revisit this decision if:

- conflicting appraisal events become possible;
- deadlocks or lock contention appear in production;
- partial cache rows persist beyond an acceptable business window;
- event replay is operationally insufficient;
- a DLQ or reconciliation workflow is introduced; or
- a versioned event contract becomes available.
