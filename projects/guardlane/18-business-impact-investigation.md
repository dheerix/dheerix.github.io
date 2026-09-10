# Guardlane: Business-impact investigation

- Status: Ongoing investigation
- Stage: Post-production observation and policy analysis
- Evidence boundary: A business movement was observed after rollout; causality
  has not been established.

## Why this chapter exists

Guardlane's production lifecycle did not end at deployment or offline model
evaluation. After rollout, the team observed an approximately **3% decrease in
sale conversion**. The timing created a reason to investigate Guardlane and its
moderation policy as possible contributors, but it did not prove that Guardlane
caused the movement.

This chapter records the next engineering stage:

```text
Build → Deploy → Observe → Investigate → Adjust policy → Measure
```

The investigation asks whether technically accurate moderation signals were
being translated into product actions that unintentionally suppressed useful
commercial conversations.

## Model quality is not product quality

Production ML operates through several connected layers:

```text
Model metrics
  precision / recall / F1
        ↓
Decision policy
  how labels become ALLOW / BLOCK / REVIEW
        ↓
User behaviour
  how moderation changes conversations
        ↓
Business outcomes
  conversion / engagement / trust / safety
```

A classifier can perform well against its evaluation dataset while the policy
around its outputs remains poorly calibrated to product behaviour. The model
answers whether a signal is present. The product still must decide whether that
signal is sufficient to block an interaction.

## Investigation hypothesis

The working hypothesis is that some blocked conversations containing
negotiation or contact-related language may still express legitimate purchase
intent. Examples include offers, counter-offers, questions about price
flexibility, and attempts to continue a commercial discussion.

The investigation therefore asks:

> Is negotiation alone a sufficiently strong blocking signal, or should it
> remain contextual unless a stronger harmful or policy-violation signal is
> also present?

This is a hypothesis to test, not a conclusion about the production policy.

## Investigation flow

```text
Business signal
  approximately 3% conversion decrease observed
        ↓
Hypothesis generation
  could moderation suppress legitimate commercial conversations?
        ↓
Decision extraction
  select Guardlane BLOCK decisions
        ↓
Segmentation
  isolate decisions containing negotiation
        ↓
Subclassification
  benign / contact / circumvention / negative / other / ambiguous
        ↓
Counterfactual
  which messages would pass if negotiation alone were non-blocking?
        ↓
Business plausibility
  is the affected population large and relevant enough to explain movement?
        ↓
Policy option
  keep / relax / contextualize / review
        ↓
Validation
  measure conversion and moderation-quality effects after a controlled change
```

## Negotiation taxonomy

The taxonomy preserves the difference between conversational topic and harmful
intent.

| Segment | Interpretation | Candidate treatment for investigation |
|---|---|---|
| Negotiation — benign | Ordinary price discussion, offers, counter-offers, flexibility questions, or legitimate purchase intent | `ALLOW` candidate |
| Negotiation + contact | Negotiation combined with contact exchange or an attempt to continue elsewhere | Investigate separately; do not assume intent |
| Negotiation + circumvention | Apparent attempt to bypass a marketplace rule or process | `BLOCK` candidate |
| Negotiation + negative | Negotiation combined with abusive, manipulative, hostile, or otherwise undesirable behaviour | `BLOCK` or `REVIEW`, depending on policy |
| Negotiation + another violation | Negotiation is present, but an independent signal supplies the blocking reason | Follow the independent violation |
| Ambiguous | Available message and context do not establish intent confidently | `REVIEW` or further analysis |

These treatments are analysis candidates. They are not recorded here as the
final production policy.

## Preserve multi-label evidence

Guardlane is a multi-label system, so the analysis must not force every message
into one mutually exclusive class.

A negotiation-only population can be represented conceptually as:

```text
negotiation=true
contact=false
negative=false
circumvention=false
other_violation=false
```

This population is a strong candidate for counterfactual analysis. It must be
contrasted with combinations such as:

```text
negotiation=true
negative=true
```

or:

```text
negotiation=true
circumvention=true
```

The important design principle is:

> Separate conversational topic from harmful intent.

## Counterfactual analysis

Counting negotiation blocks alone does not answer the product question. The
important population is the set of decisions whose product outcome would
change under a different policy.

Conceptually, compare:

```text
Current policy candidate
BLOCK = negotiation OR negative OR circumvention OR other_violation

Alternative policy candidate
BLOCK = negative OR circumvention OR other_violation
negotiation = retained as evidence and context
```

The counterfactual cohort contains messages blocked only because negotiation
was independently sufficient. Analysis should retain all original labels,
scores, versions, available workflow context, and downstream outcomes.

The comparison must answer two different questions:

1. How many messages would change from blocked to allowed or reviewed?
2. Is that population sufficiently large, exposed, and commercially relevant
   to plausibly contribute to the observed business movement?

Even a plausible population does not establish causality. Other product,
marketplace, seasonal, inventory, pricing, and measurement changes may explain
some or all of the conversion movement.

## Investigation questions

1. What percentage of blocked messages contain the negotiation flag?
2. What percentage are blocked only because of negotiation?
3. What percentage of negotiation messages appear commercially legitimate?
4. Which moderation labels most commonly co-occur with negotiation?
5. Are conversion changes concentrated among users or dealers exposed to
   negotiation blocks?
6. Is the affected population large enough to plausibly explain an
   approximately 3% movement?
7. What undesirable interactions would become allowed if negotiation stopped
   being independently blocking?
8. Can negotiation become contextual evidence rather than a blocking signal?
9. Which experiment and guardrails should validate a policy change?

## Correlation and causation

The conversion decrease occurred after rollout. That is a temporal correlation
and a useful trigger for investigation. It is not proof of causal impact.

Stronger evidence would combine:

- exposure analysis comparing workflows affected and unaffected by a
  negotiation block;
- counterfactual replay of historical multi-label decisions;
- review of negotiation-only messages for legitimate intent;
- a controlled, reversible policy change;
- measurement of both conversion and moderation-quality guardrails;
- checks for concurrent product or marketplace changes.

The conclusion should remain proportional to the evidence. If confounding
cannot be removed, report the result as directional rather than causal.

## Policy and validation plan

The policy options are recorded in
[Negotiation as a moderation signal](19-negotiation-signal-adr.md). A selected
option should be validated through a controlled rollout rather than a silent
global configuration change.

Before rollout, define:

- the eligible negotiation-only population;
- the expected product action;
- conversion and conversation-continuation measures;
- safety, policy-violation, report, and reviewer-disagreement guardrails;
- segmentation by relevant workflow context;
- an observation window;
- rollback thresholds and an accountable decision owner.

After rollout, compare the affected cohort with an appropriate control or
baseline. A useful result must report both business movement and moderation
quality. Improving conversion while materially weakening marketplace safety is
not a successful policy change.

## Interview articulation

### 30-second version

After deploying our ML moderation system, we observed roughly a 3% movement in
sale conversion. Rather than assuming causality, I investigated Guardlane as
one possible contributor. I analyzed blocked decisions and decomposed
negotiation into benign and harmful combinations to understand whether
legitimate commercial conversations were being suppressed. The goal was to
determine whether negotiation should remain independently blocking or become
contextual, then validate any policy change against both moderation quality
and conversion.

### Deep-dive prompts

- Why were precision, recall, and F1 insufficient to judge product impact?
- How was the business signal detected and bounded?
- Why did negotiation become a plausible hypothesis?
- How were blocked decisions extracted and segmented?
- Why did multi-label combinations matter?
- How was the counterfactual population defined?
- How were correlation and causation kept separate?
- Which experiment would validate a policy change?
- Which monitoring and rollback criteria should guard the rollout?

## Evidence boundary

Observed:

- an approximately 3% post-rollout conversion decrease;
- the resulting need to investigate blocked negotiation decisions.

Under investigation:

- whether Guardlane or its decision policy contributed to that movement;
- the size and intent distribution of the negotiation-only cohort;
- the appropriate future policy;
- the conversion and moderation-quality result of any policy change.

No final causal conclusion or post-change outcome is claimed.
