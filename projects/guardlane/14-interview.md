# 13. Interview Guide

# Interview Guide

The [business-impact investigation](18-business-impact-investigation.md#interview-articulation)
adds the post-production story: observed business signal, hypothesis,
multi-label segmentation, counterfactual analysis, causal discipline, and
controlled policy validation.

This document provides a structured approach for presenting the Guardlane project during technical interviews, architecture discussions, and engineering leadership conversations.

---

# Project Summary

Guardlane is a hybrid AI moderation platform designed for Marketplace Q&A.

Rather than relying on a single AI model, the platform combines deterministic rules, machine learning, and LLMs to provide scalable, explainable, and production-ready moderation.

Core technologies include:

- Regex-based rule engine
- DistilBERT English classifier
- LLM fallback for unsupported languages
- SageMaker model hosting
- .NET orchestration service

---

# 30-Second Elevator Pitch

> Guardlane is a hybrid AI moderation platform for Marketplace Q&A. We initially built an LLM-based moderation pipeline but evolved the architecture into a production-ready system combining regex, an English DistilBERT classifier hosted on SageMaker, and an LLM fallback for unsupported languages. Guardlane orchestrates these components behind a single API while allowing Marketplace to own business enforcement decisions.

---

# 2-Minute Architecture Walkthrough

## Business Problem

Marketplace users can post questions containing:

- Spam
- Contact information
- Profanity
- Fraud attempts
- Policy violations

Moderation needed to be:

- Accurate
- Fast
- Cost-effective
- Explainable

---

## Evolution

### Phase 1

LLM-only moderation.

Advantages:

- Excellent semantic understanding
- No training pipeline

Challenges:

- High latency
- High inference cost
- Difficult evaluation
- Inconsistent outputs

---

### Phase 2

Introduced an English DistilBERT classifier.

Benefits:

- Faster inference
- Lower cost
- Repeatable evaluation
- Stable predictions

---

### Phase 3

Final hybrid architecture.

```text
Marketplace

↓

Guardlane

├── Regex
├── Language Detection
├── DistilBERT (English)
└── LLM (Fallback)

↓

Aggregation

↓

Marketplace Policy
```

---

# Key Engineering Decisions

- Hybrid moderation architecture
- Multi-label classification
- Language-aware routing
- Stable response contract
- Separation of prediction from business policy
- Asynchronous persistence
- Versioned model deployments

---

# Trade-offs

| Decision   | Benefit                  | Trade-off                          |
| ---------- | ------------------------ | ---------------------------------- |
| DistilBERT | Fast inference           | English only                       |
| Regex      | Deterministic            | Limited semantic understanding     |
| LLM        | Handles complex cases    | Higher latency and cost            |
| Hybrid     | Best overall performance | Increased orchestration complexity |

---

# Questions You Should Expect

## Why DistilBERT?

- Low latency
- Low cost
- Strong English performance
- Easy offline evaluation

---

## Why not use an LLM for everything?

- Higher inference cost
- Increased latency
- Less predictable outputs
- Difficult benchmarking

---

## Why Regex?

Regex is ideal for deterministic patterns such as:

- Phone numbers
- URLs
- Email addresses

Using AI for these cases would unnecessarily increase latency and cost.

---

## Why Multi-label Classification?

A question may violate multiple moderation categories simultaneously.

Example:

> "Call me. This dealer is a scam."

This requires multiple labels rather than a single classification.

---

## Why SageMaker?

- Managed model hosting
- Autoscaling
- Version management
- Blue-green deployment support
- Operational monitoring

---

## Biggest Technical Challenge

Balancing:

- Accuracy
- Latency
- Cost
- Maintainability

without coupling business policy to machine learning.

---

## What Would You Improve?

Potential future improvements:

- Native multilingual classifier
- Active learning
- Automatic drift detection
- Shadow deployments
- Provider-independent LLM routing

---

# Biggest Learnings

- Production AI is primarily an engineering challenge.
- Clear ownership boundaries simplify long-term maintenance.
- Versioning every artifact improves operational reliability.
- Human feedback is essential for continuous improvement.
- Hybrid architectures outperform one-size-fits-all solutions.

---

# Interview Takeaway

The success of Guardlane was not building a machine learning model—it was designing a production AI platform that balances performance, scalability, maintainability, and operational excellence.
