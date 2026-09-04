# SDE3 Depth Roadmap — Sep 2026 → Sep 2027

> **Real work. Real depth. Real impact.**
>
> Don't prepare to *look* like an SDE3 in an interview. Spend the year becoming difficult to interview below SDE3.

## Context

With roughly another year of runway at the current company, the priority shifts away from short-term interview grinding toward building durable engineering depth using real production work.

A particularly useful signal: after discussing production ML deployment with a company data scientist, it appears production ML deployment experience is relatively rare internally. Guardlane therefore becomes more than a completed feature — it is a foundation for building deeper ML/platform expertise.

The upcoming upload-anything/chatbot work can add a second dimension: LLM application engineering and potentially LangGraph/agentic workflows.

## Mind Map

```mermaid
mindmap
  root((Next 12 Months\nStrong SDE2 → Clear SDE3))
    Core Engineering Depth
      Architecture & service boundaries
      Distributed systems
      AWS & infrastructure
      Pulsar / event-driven systems
      Idempotency, retries, DLQ
      Reliability & observability
      Security
    Production ML
      Guardlane as production laboratory
      Data & labeling
      Training / retraining
      Evaluation & calibration
      Model versioning
      SageMaker deployment
      Inference & integration
      Drift / monitoring
      HITL feedback loop
      Collaborate with data scientist
    AI Application Engineering
      LLM foundations
      RAG & embeddings
      LangGraph / agentic workflows
      Tool use
      Upload-anything ingestion
      Retrieval & chunking
      Evaluation & grounding
      Cost / latency / security
    System Design
      One design every 1–2 weeks
      Use real company problems
      Scalability & consistency
      Failure modes
      Trade-offs
      Guardlane case study
      Upload-anything case study
      Event pipeline case study
    Full-Stack Execution
      React / TypeScript
      APIs & data design
      DevOps / CI-CD
      Product collaboration
      Ship end-to-end
    Cross-Team Influence
      Deeper PR reviews
      Architecture discussions
      Guardlane / DevOps demos
      Knowledge sharing
      Mentoring
      Stakeholder alignment
    DSA Maintenance
      About 2 problems per week
      Pattern recognition over memorization
      Monthly retrieval of old problems
      Arrays / hash maps / pointers
      Binary search
      Stack / monotonic stack
      Trees / graphs / DP
```

## Priority Model

| Area | Approx. learning emphasis | Purpose |
|---|---:|---|
| Core engineering / distributed systems | 35–40% | Build the technical depth expected at SDE3+ |
| Production ML | 20–25% | Turn rare production experience into genuine specialization |
| AI application engineering | 15–20% | Add RAG, LangGraph, agentic and LLM production skills |
| System design | 15% | Convert implementation experience into architectural reasoning |
| DSA | 5–10% | Stay interview-ready without making LeetCode the curriculum |

Full-stack delivery and leadership are primarily developed through normal project execution rather than treated as separate study tracks.

## DSA Rule

Grind 75 moves into **maintenance mode**.

Do not memorize individual solutions. Preserve recognition patterns and reconstruction ability.

Examples:

- next future element satisfying a condition → consider monotonic stack
- contiguous range + target → consider prefix sum / hash map
- ordered search space with eliminable halves → binary search
- overlapping intervals → sort + merge/sweep

Routine: roughly two problems per week, with periodic blind retrieval of older problems.

## Production ML Depth Loop

Use Guardlane to understand the complete lifecycle rather than stopping at deployment:

`data → labeling → training → evaluation → versioning → deployment → inference → telemetry → errors/drift → HITL → new labels → retraining`

Study where the current system is mature, where it is intentionally simple, and where a production ML platform would require additional capabilities.

## Chatbot / LangGraph Rule

Do **not** begin with the framework.

Reason in this order:

`requirements → constraints → architecture → failure modes → trade-offs → technology`

For upload-anything, investigate questions such as:

- accepted document types and sizes
- synchronous vs asynchronous ingestion
- extraction pipeline
- security and malware boundary
- tenant isolation
- document lifecycle / deletion
- chunking and indexing
- authorization inheritance
- retrieval quality
- grounding and citations
- evaluation
- cost and latency
- observability

Only then decide where LangGraph, RAG, vector stores, queues, workflows, or simpler components belong.

## 12-Month Outcome

By the end of this runway, aim to have evidence of:

- deep backend/distributed-systems reasoning
- genuine production ML lifecycle knowledge
- production LLM / LangGraph skills
- several documented system-design case studies from real work
- stronger PR and architectural reviews
- cross-team technical influence
- continued full-stack execution
- DSA pattern fluency without grind dependency

The target is not a larger list of technologies. It is a smaller set of capabilities understood deeply enough to **design, build, explain, review, operate, and teach**.
