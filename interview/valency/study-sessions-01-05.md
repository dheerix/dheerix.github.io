# Valency / Carve — Study Sessions 01–05
**November 2026 | Senior SWE (AI & Full-Stack) preparation**

> Study synthesis from this conversation; all architecture examples are **proposed scenarios, not assertions about Carve's current implementation**. Keep direct experience and hypotheticals distinct.

## Session 01 — Domain, evidence and trustworthy readiness
Carve supports project assurance for heavy industrial projects. Concepts: **PDRI** (Project Definition Rating Index; front-end scope definition), construction readiness, commissioning/operational readiness. A readiness assessment evaluates a domain criterion against sufficient, authoritative project evidence; it is not merely document summarization.

**Project Falcon illustration:** Is emergency shutdown philosophy documented, approved and free of unresolved related safety actions?
- Rev A approved but possibly superseded; Rev B newly issued for review; safety action open.
- A search hit saying "Approved" does **not** establish readiness.
- Distinguish **document exists → applicable governing revision → evidence supports requirement → expert authorizes assessment**.
- Define findings such as SUPPORTED, GAP, CONFLICTING_EVIDENCE, INSUFFICIENT_EVIDENCE, NEEDS_REVIEW (illustrative only).
- Structured proposal: requirement ID, proposed finding, source document/revision/page/span, gaps, contradictions, review-required.
- Verify **structural validity**, **source provenance** and **semantic support** independently.
- A model's self-reported 0.97 confidence is not a calibrated correctness probability.
- Audit through source and requirement versions, extraction/index/model/prompt versions, reviewer action; balance traceability with privacy.

**Conversation insight:** "The AI isn't the final product; a defensible readiness assessment is." Ask whether agents chiefly gather evidence, draft assessments or act on downstream project systems.

## Session 02 — Document intelligence and RAG
**Scenario:** 300 uploaded files across text PDFs, scans, drawings, tables and multiple revisions (hypothetical mix).

**Ingestion:** Authenticate/authorize upload → short-lived signed object upload → verify object and security checks → immutable source artifact + canonical metadata → durable processing job/queue → extraction → normalization → indexing. Do not leave long OCR/LLM processing in an HTTP request.

**Document schema:** Logical document ID ≠ uploaded file ≠ revision. Track project, artifact/hash, revision, governing/approval status, effective date/supersession rules, extracted element type, page/coordinates and search-chunk identity. Newest revision is not necessarily governing approved revision.

**Parsing:** Native text vs scanned OCR vs specialized drawings; preserve tables/headers, reading order, sections, bounds and confidence/quality signals. Flattening an engineering table can misattach values to equipment.

**Chunking:** Fixed-size, page or structure-aware; prefer section-aware boundaries with linked table context. Parent-child retrieval: index smaller search units; return relevant source section/table for grounded evaluation. Extraction chunking and retrieval chunking have different optimization goals. Overlap is not a solution to broken structural relationships.

**Hybrid search:** BM25 for exact terms/IDs, embedding vectors for semantics; metadata scoped by tenant/project/authorized revisions, merge/rerank, dedupe, verify evidence and expand source context. Search indices are derived views, not business truth; freshness matters. RRF fuses ranked lists. Recall@K measures known relevant evidence coverage.

**Basic RAG** (retrieve top K → generate) is insufficient if the task needs completeness, current revision rules, contradiction searches and approval.

**Reliability:** Per-page/stage checkpoints, idempotent writes, retry and DLQ policies, partial-index detection. Idempotent persistence does not guarantee exactly-once billable provider requests.

**Evaluation:** Separate OCR/table accuracy, metadata/revision accuracy, evidence retrieval recall, citation support, contradiction detection and criterion-level outcomes.

**Experience bridge:** Inventory Upload Anything: OCR → schema discovery → chunked extraction → reconciliation → structured output, with async job/SSE design. OneSearch: contributed to Oracle → Elasticsearch modernization and .NET search APIs at Holland & Barrett. Do not imply industrial CAD or revision-control production ownership.

## Session 03 — Bounded agents and orchestration
**Workflow:** Code chooses ordered stages. **Agent:** Model selects among approved actions based on observations, inside an application-controlled loop.

Proposed tools:
- `searchEvidence(project, query)`: scoped candidate retrieval
- `getDocumentRevision(document)`: authoritative governing/approval state
- `getOpenActions(...)`: action register
- `getEvidenceSpan(...)`: verifiable exact source text/table
- `proposeFinding(...)`: draft, never automatic authorization

**Execution:** Authorized requirement/context → model proposes tool call/finding → schema & authorization gate → execute tool with backend credentials → record structured observation/checkpoint → iterate up to step/time/token/cost limits → validate final proposal → expert review.

**Hard boundaries:** Model cannot set tenant scope, bypass allow-list or approve funding; documents are untrusted data, not instructions. Limit steps and costs; detect non-progress/repeated calls; permit safe cancellation; use durable state instead of treating context-window text as database truth.

**Failures:** timeout means unavailable, not "no open actions"; malformed arguments rejected; unavailable evidence triggers abstention or review; retries bounded. Side-effecting actions (e.g. create review task) use stable idempotency keys and explicit approval. Use read-only tools where possible.

**Autonomy trade-off:** Begin with deterministic baseline; introduce agentic investigation only if hard cases and measured evidence coverage, accuracy, latency and cost justify it. Multi-agent frameworks aren't inherently superior.

## Session 04 — Production full-stack and security
**Logical architecture:** UI/API; canonical relational database; private immutable object storage; durable queue & extraction/index workers; BM25/vector index; assessment orchestrator/model provider; deterministic citation/policy verifier; reviewer workflow.

**Responsibilities:** Database owns project/revision/job/assessment/approval state; object storage owns files; index owns retrieval projections; orchestrator owns checkpoints and limits; model proposes interpretations; app and authorized humans own policy/approval.

**Multi-tenancy:** Derive scope from authenticated claims and DB authorization; enforce in SQL, storage, index/vector retrieval and tool execution. Do not retrieve unauthorized data then filter model outputs. Shared index + filters vs per-tenant indexes vs dedicated infrastructure: trade operational overhead against isolation.

**Dual-write failure:** DB job inserted but queue publish fails → transactional outbox: atomically persist domain state and event, asynchronously publish, accept at-least-once duplicates; idempotent consumer. DLQ, jittered backoff, circuit breaker, bulkhead, backpressure for exhausted resources.

**Revision race:** Assessment starts on Rev B; Rev C arrives before review. Bind assessment to requirement/document evidence manifest; detect relevant changes at approval time, mark stale/re-evaluate. Optimistic concurrency alone is insufficient without evidence freshness validation.

**Observability:** Trace upload → queue → extraction → search → tool calls → model → validation → reviewer. Capture stage durations, retry/timeout category, token/cost, version IDs, citation results and override rates. Avoid raw sensitive prompts in logs. Distinguish infrastructure uptime from semantic decision correctness.

**Security baseline:** RBAC/ABAC and least privilege, tenant/project isolation, prompt-injection defense through permissioned tools, encryption, region/residency and retention controls, auditability, human authorization and secure model gateway/provider configuration.

**Architecture trade-offs:** Modular app + scalable workers vs many microservices; workflow vs agent; speed vs evidence completeness. Service names are not architecture.

## Session 05 — Partnership conversation and experience stories
**40-second introduction:** "My background is production full-stack and distributed systems, increasingly with applied AI. At Openlane, Guardlane involved production NLP moderation; Inventory Upload Anything addresses unstructured inputs using staged extraction. What interests me about Carve is making AI-generated evidence genuinely trustworthy for consequential decisions. I'd love to hear where the toughest challenges lie."

**Guardlane:** Production classification and quality investigation using DistilBERT/SageMaker; ~20% observed fewer risky buyer questions post-rollout. Differentiate observation from causal proof; do not invent exact thresholds, calibration or review queue implementation.

**Inventory Upload Anything:** OCR, schema discovery, chunk extraction and reconciliation; verify what actually shipped vs planned. Highlight completeness, consistency and asynchronous UX.

**OneSearch:** Holland & Barrett Oracle → Elasticsearch modernization with .NET APIs; contribution under Principal Engineer, no invented scale or sole ownership.

**PlanForge and Cost Mapping:** Plan/evidence/deviation concept and concrete cross-layer business-system migration, APIs, integrations and backward compatibility; label proposed vs implemented.

**Three discovery questions**
1. "What's hardest today—extracting data, reconciling conflicting evidence, or determining whether a readiness criterion is satisfied?"
2. "Where do you want autonomy: evidence investigation, requirement assessment or actions across external systems? What must stay deterministic?"
3. "What technical decisions are still open, and what would your engineering partner own in the first three to six months?"

**Culture question:** How do engineers collaborate with capital-project specialists to encode domain judgments and verify failures?

**If unfamiliar:** State honestly what you haven't built, identify input and correctness constraints, propose minimal evaluated baseline, then discuss safe scale-up.

**Conversation goal:** Mutual discovery rather than 30-minute technical monologue. Listen; ask few thoughtful questions; exchange trade-offs; assess scope and collaboration; naturally identify a next deep-dive.

## Priority recall
1. Relevant retrieval ≠ authoritative evidence ≠ approved readiness.
2. Original source and canonical version state > index or generated answer.
3. LLM proposes; code validates/tool-authorizes; experts approve.
4. Agent budget, allow-listed tools, checkpoints, idempotency and failure semantics.
5. Tenant isolation and prompt-injection defenses cannot rely on instructions to LLM.
6. Eval retrieval completeness and citation support separately from uptime/latency.


## Nov 18 addendum — PlanForge is the strongest assessment analogue

Reframe the engineering narrative into **three complementary systems**, not one generic AI experience:

1. **Inventory Upload Anything — evidence ingestion:** OCR → schema discovery → chunk extraction → reconcile → structure and persist. Focus on completeness and async pipeline reliability. It supplies the material that can later be assessed.
2. **PlanForge — evidence checking and deviations:** frozen plan + original product requirements + existing codebase are the baseline/context; actual PR changes are submitted evidence. Examine requirement coverage, contradictory implementation, missing tests/edge cases, unexpected deviations, evidence links, and TL review. **MVP/design exploration**: distinguish proposed verifier behavior from what is truly implemented or field-tested. This directly mirrors Carve's criterion → source evidence → gap/deviation → review pattern.
3. **Guardlane — policy above probabilistic predictions:** moderation model estimates; the surrounding application applies governed policy, quality checks, escalation/review as appropriate. This mirrors keeping final readiness authorization outside a model response.

### Working analogy

| Layer | Software workflow | Carve-like workflow |
|---|---|---|
| Requirement baseline | Frozen implementation plan + product requirements | Approved project-readiness criteria |
| Existing context | Existing codebase | Current authoritative engineering records |
| New evidence | PR diff, tests, changed contracts | New documents, drawings, revisions, approval records |
| Investigation | Locate code paths and compare evidence with plan | Search/reconcile source spans and check criteria |
| Gaps / deviations | Missing scope, incompatible behavior, unplanned changes | Missing evidence, contradictions, unresolved actions |
| Approval | Technical lead/reviewer | Authorized project-assurance specialist |

**A critical nuance:** a PR can conform to the frozen plan and still fail original product requirements; hence evaluate *plan + existing code + product intent* rather than only line-by-line plan adherence. Similarly, Carve evidence can align with a checklist item but fail the underlying readiness objective.

### Higher-value question for Brad

"How do you express a readiness criterion and its evidence contract? Is the agent tracing each criterion to supporting passages and identifying gaps or deviations, or does an expert still do most of that mapping manually?"

### A succinct positioning statement

"My experience spans the three stages of a trustworthy assessment: document extraction in Inventory Upload Anything, requirements-to-implementation evidence and deviations in PlanForge, and applying product policy over uncertain model predictions in Guardlane. PlanForge is agentless and exploratory, but the underlying verification problem feels directly relevant to Carve."


### PlanForge architecture clarification — November 18
**PlanForge is agentless.** It follows predefined instructions and a controlled verification process; it does **not** autonomously decide which tools to call or pursue iterative agent goals. Its key comparison is **frozen plan + product requirements + existing codebase vs actual PR changes**, recording supporting implementation evidence and gaps/deviations for review. Do not call it a bounded agent, an agentic implementation, or a production autonomous assessor. Carve may use bounded agents for *adaptive evidence discovery*, but its **verification and policy gates can use PlanForge-like deterministic/instruction-driven procedures**. This distinction makes the trade-off concrete: start with prescribed checks and introduce autonomy only when the evidence path genuinely requires it.
