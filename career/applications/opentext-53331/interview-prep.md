# Interview preparation — OpenText Senior AI Developer

## Priority 1: LangGraph hands-on gap
- Build a small runnable LangGraph prototype with state, nodes, conditional edges, tool calls, retries, checkpoints, and human review.
- Explain the difference between a deterministic multi-stage LLM workflow and an agent deciding its next tool/action. Do not retroactively label existing work as LangGraph.
- Practice failure recovery, idempotency, evaluation, and prompt-injection defenses.

## Priority 2: RAG architecture reconstruction
- Known sources: GitHub repositories, READMEs, Slack messages, wiki pages; goal: cross-repository architecture questions.
- Reconstruct ingestion, document metadata, chunk boundaries, embedding model, vector store, retrieval/reranking, source citations, access control, and evaluation.
- Vector DB is **not verified** (Chroma was suggested tentatively); do not present it as a confirmed historical fact.
- Practice freshness, permission-aware retrieval, hallucination mitigation, and golden-question evaluations.

## Priority 3: Production intelligent document processing
- OPENLANE Inventory Upload Anything: document ingestion → OCR/text extraction → first LLM pass for column/schema discovery → chunked extraction → overlapping adjacent context → reconciliation/deduplication → persistence.
- Asynchronous background jobs, SSE and current job progress.
- Discuss known limitation candidly: chunk boundaries could still miss a small number of records; explain mitigations and future improvements.
- Distinguish shipped workflow from any LLM elements that remained design-only; verify production architecture before claiming particular model/provider.

## Priority 4: Other defensible examples
- Guardlane: production DistilBERT moderation with regex prefilter; LLM fallback was designed, not deployed to production.
- Internal organizational RAG knowledge base.
- Azure DevOps MCP integration: issue retrieval/update, notifications, mentions, assignments.
- PlanForge: internal tool used by the team; explain actual scope without claiming a deployed agent framework.
- Rheumera: LLM-supported patient summaries used by doctors in HIPAA-conscious workflows; avoid unsupported certification claims.

## System design rehearsal
Design an enterprise content AI assistant: ingestion pipelines, tenant isolation, authorization at retrieval, encryption, audit trails, async queues, container deployment, observability, tracing, offline/online evaluation, cost and latency budgets.

## Practice prompts
1. Walk through Upload Anything end to end, including overlapping chunks and missed-record tradeoffs.
2. How would you turn your existing orchestration into LangGraph, and why?
3. How would you ensure RAG citations and ACLs across Slack, wiki and GitHub?
4. What do you measure for extraction completeness, precision, latency and cost?
5. What happens when an LLM times out halfway through a background job?
