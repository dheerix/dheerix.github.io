# QNA/VDP policy adapter

This adapter derives the buyer-service product outcome for the first Guardlane
consumer. It does not change or replace the raw Guardlane inference.

## Inputs

- raw Guardlane decision: `ALLOW`, `WARN`, or `BLOCK`
- flagged categories
- `isBroadcast`
- `isSold`
- As-Is context
- policy adapter version

## Outputs

```text
rawDecision          // unchanged Guardlane result
productDecision      // contextual UI/product outcome
appliedRule          // explanation for the derivation
policyVersion        // adapter version
```

## Decision precedence

The adapter evaluates specific contextual exceptions before applying the raw
blocking decision:

| Context and result | Product decision | Rule |
|---|---|---|
| `isBroadcast=true` and only `FLAG_NEGOTIATION_BLOCK` | `ALLOW` | Seller broadcast negotiation exception |
| `isSold=true` and only `FLAG_NEGOTIATION_BLOCK` | `ALLOW` | Post-sale negotiation exception |
| `isSold=true` and only `FLAG_CONTACT_INFO` | `ALLOW` | Post-sale contact exception |
| `WARN` with `FLAG_AS_IS_BLOCK` | `WARN`/non-blocking | As-Is warning handling |
| Any `BLOCK` with another category present | `BLOCK` | Blocking category takes precedence |
| Any remaining `BLOCK` | `BLOCK` | Default blocking behavior |
| Valid non-blocking result | raw result | No exception required |

An exception applies only when the permitted category is the sole flagged
category. A mixed result must not be converted to `ALLOW` merely because one
of its categories is permitted in isolation.

## Unknown or incomplete context

If the adapter cannot establish the required context, it must not infer an
exception. It should display the raw Guardlane recommendation and record that
the contextual rule was not applied.

This keeps missing metadata from becoming an accidental bypass.

## Versioning

The adapter should have an explicit version, for example:

```text
qna-vdp-policy-v1
```

The version should be visible in the derived UI result or audit metadata. When
an exception changes, the new adapter version must be distinguishable from
historical results so HITL analysis does not compare outcomes across silently
changed rules.

## Ownership

Buyer-service remains the authority for the actual persisted product action.
This adapter exists to make the first consumer’s outcome explainable in the
Guardlane UI. It should not be promoted into the generic Guardlane inference
contract unless multiple consumers converge on the same policy semantics.
