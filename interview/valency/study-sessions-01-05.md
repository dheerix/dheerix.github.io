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


## November 18 — Actual PlanForge repository audit: deterministic vs agentic

**Source reviewed:** private `dheerix/planforge` on `main` (README, `skills/planforge/SKILL.md`, deviation scripts, evidence collectors, comparison-input builder, deviation rule/status models).

**Do not call current PlanForge a production bounded agent.** It is a **Codex-operated, instruction-driven skill with deterministic support scripts and human gates**. Its skill directs Codex to read Linear context and inspect user-confirmed repositories; some discovery/interpretation is model-assisted and therefore not inherently deterministic. The checked-in Ruby/Python analysis, normalization, rendering and validation utilities are deterministic for the same inputs.

### Implemented mechanisms and boundaries

| Current code | What it demonstrably does | What it does NOT by itself demonstrate |
|---|---|---|
| `skills/planforge/SKILL.md` | Prescribed intake → confirmed repo scope → design → frozen plan, explicit human confirmation before advancing or external writes | Self-contained autonomous model tool loop with persisted decision budget |
| `collect_repository_evidence.rb` | Read-only Git branch, commit, worktree state and provenance across listed repositories | Semantic verification of all changed code and acceptance criteria |
| `collect_pull_request_evidence.rb` | Normalizes supplied PR snapshot and rejects PR URLs absent from frozen repository plan | Fetching arbitrary live PRs or independently analyzing every diff |
| `collect_linear_evidence.rb` | Normalizes provided Linear snapshot bound to frozen project identity | Arbitrary model-directed Linear access |
| `build_comparison_input.rb` | Checks frozen plan ID/version across inputs; rejects unknown source IDs and joins explicit checks/evidence | Discovering missing criteria automatically |
| `deviation-rules.json` | Defined categories: contract-drift, missing-acceptance-coverage, scope-drift, deferred-recovery-gap, lifecycle-recovery-gap | A learned or autonomous violation detector |
| `analyze_deviations.rb` | Validates **supplied** findings against rules/status/evidence fields; emits JSON and reviewable Linear comment | Proving each PR satisfies every original requirement |
| `deviation-status-model.json` | Allowed lifecycle transitions for detected, acknowledged, resolving, blocked, resolved, accepted risk, dismissed, stale | Final approval by an AI model |
| `prepare_linear_handoff.rb` | Reviewable handoff; external posting not automatic | Unapproved Linear writes |

The important implementation gap is **upstream evidence discovery and semantic requirement-coverage determination**. The deterministic deviation analyzer expects structured candidate findings rather than generating them from an arbitrary code diff. The README's broader experience language describes the product ambition; distinguish verified script behavior from workflow aspirations.

### End-to-end analogy with Carve

| Dimension | PlanForge now | Carve-like assessment |
|---|---|---|
| Canonical criteria | Frozen Linear implementation plan + original product requirements | Approved readiness criteria / domain methodology |
| Existing context | Repository code/contracts | Governing engineering documents, approvals, action registers |
| Changed/submitted evidence | PR metadata/diffs, tests, repository snapshots | Uploaded project deliverables and revisions |
| Evidence discovery | Codex-guided repo inspection + supplied snapshots; deterministic collectors | Search/inspect current authorized engineering sources |
| Comparison/checking | Structured checks + explicit deviation rule registry | Explicit criterion-to-evidence evaluation, gaps and conflicts |
| Governance | Human gates, approval/transition logic, no silent Linear posting | Domain expert review, policy gate, traceable readiness approval |

**Hypothetical bounded-agent evolution, NOT shipped:** Given "verify PR #1842 against frozen requirements", model selects among allow-listed `accessLinearProject`, `checkPR`, `checkRepoCode`, `runTests`, and narrowly scoped `accessBrowser`; backend validates permissions, tool arguments and time/step/cost budgets; each tool result is checkpointed; loop stops at evidence sufficiency, non-progress or budget exhaustion; findings are passed to the **existing deterministic analysis and human review layer**. Browser/network access and test execution are higher-risk and require isolation/allow-listing. Merely providing tools doesn't make the pipeline agentic; model-directed adaptive sequencing does.

### Carve conversation positioning

> "PlanForge currently follows a structured Codex skill with deterministic evidence collectors, rule-driven deviation analysis and human approval gates. We've built the verification scaffolding; the more adaptive question is how to discover sufficient PR/code evidence and decide what to investigate next. An agentic evolution could select scoped Linear, PR, code and test tools while preserving deterministic assessment rules. I see a parallel with Carve's engineering requirements, revisioned documents and readiness evidence."

Ask Brad: **"Does Carve already have a strong criterion/evidence contract, with agents primarily investigating sources, or are agents also expected to define how evidence is evaluated?"**

**Interview distinction:** Inventory Upload Anything = acquiring structured evidence; PlanForge = plan/requirements-to-evidence checks and deviations; Guardlane = product policy over uncertain model predictions.
