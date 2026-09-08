# Guardlane: Reverse-Engineered System Design

- Status: Baseline investigation
- Source systems: Guardlane and its buyer-service consumer
- Last verified: 2026-09-06

## System purpose

Guardlane provides moderation inference and durable moderation evidence for
short-lived buyer questions and seller broadcasts during a 45-minute bidding
flow.

Its purpose is broader than deciding whether one message is visible. Its
stored inference data supports targeted human review, model and policy
improvement, and identification of repeated problematic actors.

## Ownership boundary

```text
Buyer-service
  owns business context, persistence, and final product action
        ↓
Guardlane
  classifies content and stores moderation evidence
        ↓
Buyer-service
  applies contextual exceptions and persists or rejects content
```

Guardlane is not the source of truth for discussions or broadcasts. Buyer-
service owns those records. Guardlane is the source of truth for the inference
event and its moderation evidence.

## Synchronous runtime flow

```text
Client submits question or broadcast
  → buyer-service validates auction and actor permissions
  → buyer-service enriches moderation context
  → Guardlane classification call
  → buyer-service applies contextual policy
  → reject or persist content
  → link Guardlane inference to discussion/broadcast entity
```

Buyer-service sends Guardlane context including stock identity, party role,
broadcast status, sale state, As-Is information, VIN, username, and
organization information when available.

## Decision layers

The system should be reasoned about as three distinct values:

```text
raw model/category signal
  → Guardlane recommendation
  → buyer-service product action
```

Examples of buyer-service contextual rules:

- a negotiation block may be allowed for a seller broadcast;
- a negotiation block may be allowed after sale;
- contact information may be allowed after sale when it is the only category;
- mixed-category results remain blocked when another blocking category exists;
- an As-Is warning can be non-blocking.

These rules are product policy because their meaning depends on buyer-service
workflow state, not only on message text.

## Availability policy

The accepted product policy is:

| Guardlane outcome | Product action |
|---|---|
| Valid `BLOCK` | Reject and do not persist |
| Valid non-blocking result | Persist and display |
| Request timeout | Fail open to protect real-time chat |
| HTTP/server error | Fail closed |
| Malformed response | Fail closed |
| Request retry | None |

The timeout path must not be represented as a clean `ALLOW`. It is a
`MODERATION_UNAVAILABLE` outcome that happens to result in persistence for
availability reasons.

The initial request deadline is **750 ms**. Most observed requests complete in
under 400 ms, but the deadline must be validated against production p95/p99
latency, network variation, model cold starts, and buyer-service overhead.

## Evidence and learning loop

Guardlane stores moderation events keyed by business/entity context such as
stock and discussion or broadcast identity, with actor context including role,
username, and organization.

HITL is selective:

- obvious errors, reports, and suspicious behavior receive targeted review;
- a small random sample estimates silent quality problems;
- uncertainty sampling focuses on decisions near thresholds.

Review outcomes should remain distinguishable from the original inference so
they can improve data, thresholds, prompts, and models without rewriting what
the system originally decided.

## Evidence semantics

Guardlane records its own moderation result as the primary inference evidence.
For example:

```text
Guardlane result: BLOCK / FLAG_NEGOTIATION_BLOCK
Request metadata: isBroadcast=true
Buyer-service action: ALLOW and persist
```

The request metadata contract is extensible. `isBroadcast` is one known field;
other consuming services may provide different metadata needed to interpret
their workflow. Guardlane should preserve that metadata without making every
consumer's business rules part of the shared classifier contract.

The product-visible action is owned by the consuming service. Guardlane’s UI
may display the contextual outcome when it has enough metadata or a linked
consumer outcome, but it must not overwrite the original `BLOCK` inference.
This preserves the distinction between model evidence and downstream product
policy.

For the first and currently only consumer, the Guardlane UI may derive the
buyer-service product outcome from known metadata such as `isBroadcast`. This
is an intentional product requirement and a pragmatic exception to the ideal
of a completely generic moderation UI.

The boundary should remain explicit:

- the shared inference API stores generic prediction evidence and extensible
  metadata;
- the QNA/VDP UI applies a product-specific presentation adapter;
- the adapter must not mutate the raw inference result;
- new consumers should receive their own policy adapter rather than expanding
  the core UI with unrelated conditional rules.

The trade-off is that the derived UI outcome can drift from buyer-service if
the contextual policy changes independently. The policy rule and version used
for derivation should therefore be visible in the UI or audit metadata.

## Current implementation gap

The buyer-service Guardlane client currently configures a base URL but no
explicit timeout or Guardlane-specific resilience policy. It therefore
inherits the default .NET `HttpClient` timeout unless another layer cancels
the request. The intended real-time timeout/fail-open behavior is documented in
`ADRs/Guardlane/0001-guardlane-moderation-timeout-policy.md`, but is not yet
implemented.

## Open architecture questions

1. Does the 750 ms deadline hold at production p95/p99, including model and
   network tail latency?
2. How are timeout, HTTP error, cancellation, and malformed response metrics
   separated?
3. Does Guardlane retain stable actor IDs in addition to display names?
4. What retention and access controls apply to actor-level moderation evidence?
5. Which quality metrics can be estimated from targeted review plus random
   sampling?
