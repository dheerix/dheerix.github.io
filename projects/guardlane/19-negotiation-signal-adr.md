# ADR: Negotiation as a moderation signal

- Status: **Under Investigation**
- Date opened: 2026-09-09
- Decision: TBD

## Context

Negotiation was originally treated as a risky signal because some marketplace
messages may attempt to bypass the intended purchase process. After Guardlane's
production rollout, an approximately 3% decrease in sale conversion was
observed. The timing created a hypothesis that moderation policy could be one
contributor, but it did not establish causality.

Some negotiation messages may represent legitimate price discussion, offers,
counter-offers, or purchase intent. The decision under investigation is whether
negotiation alone should remain sufficient to block a conversation.

## Evidence required

The decision requires:

- distribution of negotiation among all blocked decisions;
- size of the negotiation-only counterfactual cohort;
- multi-label co-occurrence patterns;
- reviewed intent taxonomy for benign, contact, circumvention, negative,
  other-violation, and ambiguous messages;
- exposure and conversion analysis;
- moderation-quality and safety guardrails;
- confounding analysis for concurrent product and marketplace changes.

See the [business-impact investigation](18-business-impact-investigation.md)
for the analysis framework.

## Options

### 1. Keep negotiation independently blocking

Preserves the existing risk posture and operational simplicity.

Trade-off: legitimate commercial conversations may continue to be blocked when
negotiation is the only detected signal.

### 2. Remove negotiation as a blocking flag

Negotiation no longer contributes to blocking.

Trade-off: simple policy, but it may allow negotiation that is actually part of
circumvention or another undesirable interaction.

### 3. Retain negotiation as contextual metadata

Preserve the signal for analysis and explanation, but block only when a
stronger independent signal or supported context justifies the action.

Trade-off: better distinction between topic and harmful intent, with additional
policy, versioning, and evaluation complexity.

### 4. Route ambiguous combinations to review

Allow clearly benign negotiation, block strong co-signals, and send uncertain
combinations to human review.

Trade-off: improves caution at the decision boundary but creates review volume,
latency, prioritization, and staffing concerns.

## Decision

TBD after the investigation establishes the affected population, business
plausibility, safety consequences, and validation design.

The decision must not be inferred solely from the observed conversion movement
or from offline classifier metrics.

## Consequences to evaluate

- marketplace safety and policy risk;
- legitimate conversation continuation;
- sale conversion and engagement;
- negotiation false positives and false negatives;
- reviewer disagreement and review volume;
- policy and consumer-integration complexity;
- monitoring, explainability, and rollback requirements;
- model, threshold, rule, and policy-version traceability.

## Rollout requirements

Any decision that changes production behavior should define:

1. eligible messages and context;
2. treatment and comparison populations;
3. conversion and moderation-quality measures;
4. guardrail and rollback thresholds;
5. staged rollout scope;
6. policy version and audit evidence;
7. accountable product, engineering, and operations owners;
8. criteria for keeping, reversing, or revising the change.

## Re-evaluation triggers

Revisit the decision when negotiation patterns, marketplace policy, user
behavior, reviewer disagreement, business impact, or the available contextual
signals change materially.
