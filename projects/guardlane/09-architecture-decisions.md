# Architecture Decisions (ADRs)

This document captures the major architectural decisions that shaped Guardlane.

Each decision records:

- Context
- Decision
- Rationale
- Consequences

---

# ADR-001: Hybrid Moderation Architecture

### Context

No single moderation technique handled every production scenario efficiently.

### Decision

Build Guardlane as a hybrid moderation platform combining:

- Regex
- DistilBERT
- LLM fallback

### Rationale

Each engine solves a different class of problems.

- Regex → deterministic patterns
- DistilBERT → English semantic moderation
- LLM → unsupported languages

### Consequences

✅ Better latency

✅ Lower cost

✅ Better specialization

⚠️ More orchestration complexity

---

# ADR-002: DistilBERT for English Moderation

### Context

The English moderation taxonomy became stable and well labeled.

### Decision

Use DistilBERT as the primary English semantic classifier.

### Rationale

Compared with an LLM-first solution:

- faster
- cheaper
- predictable output
- measurable performance

### Consequences

✅ Efficient inference

✅ Repeatable evaluation

⚠️ Requires retraining when taxonomy evolves

---

# ADR-003: Multi-Label Classification

### Context

Questions frequently violate multiple moderation categories.

Example:

> "Call me. This dealer is a scam."

### Decision

Treat moderation as a multi-label problem.

### Rationale

Categories are independent.

### Consequences

✅ Better representation of real behaviour

⚠️ Threshold tuning required per category

---

# ADR-004: Separate Prediction from Business Policy

### Context

Model predictions should not directly determine user-facing actions.

### Decision

Guardlane returns moderation evidence only.

Marketplace Q&A decides:

- Allow
- Warn
- Block

### Rationale

Separates AI from product policy.

### Consequences

✅ Policy changes without retraining

✅ Cleaner ownership boundaries

---

# ADR-005: Language-Aware Routing

### Context

The classifier supports English only.

### Decision

Detect language before semantic moderation.

```text
English
    ↓
DistilBERT

Non-English
    ↓
LLM
```

### Rationale

Unsupported language is not equivalent to low confidence.

### Consequences

✅ Better multilingual behaviour

⚠️ Requires routing logic

---

# ADR-006: Unified Response Contract

### Context

Consumers should not understand internal engine implementations.

### Decision

Normalize all engine outputs into one response contract.

### Rationale

Allows internal evolution without API changes.

### Consequences

✅ Stable integrations

✅ Easier future expansion

---

# ADR-007: Asynchronous Persistence

### Context

Operational records are valuable but should not increase buyer latency.

### Decision

Persist moderation events asynchronously.

### Rationale

Separate operational concerns from request latency.

### Consequences

✅ Faster responses

✅ Rich operational history

⚠️ Requires retry handling

---

# ADR-008: Version Everything

### Context

Models alone do not define runtime behaviour.

### Decision

Version:

- model
- thresholds
- regex rules
- taxonomy
- routing
- inference code

### Rationale

Production behaviour must be reproducible.

### Consequences

✅ Easier rollback

✅ Better incident investigation

---

# ADR-009: Human Review Drives Improvement

### Context

Offline metrics alone cannot capture production quality.

### Decision

Persist moderation results for dashboard review.

### Rationale

Human validation provides the highest-quality feedback for future iterations.

### Consequences

✅ Continuous improvement

✅ Better future datasets

---

# ADR-010: Guardlane as an Orchestrator

### Context

Marketplace should consume moderation, not individual AI services.

### Decision

Guardlane owns orchestration between:

- regex
- routing
- classifier
- LLM
- aggregation

### Rationale

The orchestration layer becomes the stable product capability.

### Consequences

✅ Clear service boundary

✅ Easier engine replacement

✅ Supports future moderation engines

---

# Summary

| Decision            | Why It Matters             |
| ------------------- | -------------------------- |
| Hybrid architecture | Best tool for each problem |
| DistilBERT          | Fast English moderation    |
| Multi-label         | Real-world moderation      |
| Policy separation   | Clean ownership            |
| Language routing    | Correct model selection    |
| Unified contract    | Stable API                 |
| Async persistence   | Lower latency              |
| Version everything  | Safe deployments           |
| Human review        | Continuous learning        |
| Orchestrator        | Future-proof architecture  |

---

# Engineering Principle

> Good architecture is not choosing one technology. It is assigning each responsibility to the component best suited to perform it while keeping the overall system simple, observable, and replaceable.

## Decision under investigation

- [Negotiation as a moderation signal](19-negotiation-signal-adr.md) examines
  whether negotiation should remain independently blocking or become contextual
  evidence. No final policy decision is recorded yet.
