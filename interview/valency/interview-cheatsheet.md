# Valency × Carve — Dense Interview Cheat Sheet
**Brad | Wed Nov 18, 2026 · 11 AM EST · 30 min**
**Context:** Senior Software Engineer (AI & Full-Stack), technical-partner opportunity.

## Outreach → Experience → Implication → Ask

| His message | My evidence | Likely engineering issue | Question |
|---|---|---|---|
| "Fine-tuned NLP guardrails" | Guardlane: DistilBERT/SageMaker moderation, model behavior; ~20% observed fewer risky buyer questions | False positives/negatives, policy gating, quality evals | "Where do missed evidence or false readiness assertions hurt most?" |
| "LLM-assisted workflows with human review" | Inventory Upload Anything staged OCR/schema/extraction/reconciliation; Guardlane production safeguards | Structured proposals, review UX, traceability | "What does expert verification look like today?" |
| "Trusting a model's output" | Classification quality investigation and reconciliation | Citations, abstention, contradictions, audit | "What makes the finding defensible to customers?" |
| "Messy engineering documents" | Inventory Upload Anything; OneSearch **Holland & Barrett** Oracle→Elasticsearch + .NET APIs | Layout, tables, supersession, hybrid search | "PDFs, tables, drawings or conflicting revisions—which is hardest?" |
| "Production agents" | .NET/AWS distributed workflows; PlanForge concepts | Tool policies, budgets, safe retry, failure recovery | "Where is autonomy useful vs deterministic workflow?" |
| "Readiness call" | Guardlane policy boundary; Cost Mapping business rules | Methodology vs model judgment vs human approval | "Which parts of readiness are rule-based vs expert judgment?" |
| "Technical partner" | Cross-layer ownership, API/DB/UI migration, production debugging | Design choices, delivery, domain collaboration | "What decisions are open and what would I own?" |

## Domain
- **PDRI:** front-end project scope definition; **construction readiness:** execution preparedness; **commissioning/operational readiness:** startup/handover.
- Carve offers structured project assurance; next-gen agent plans described in outreach are not evidence of implemented architecture.
- **Source exists ≠ correct governing revision ≠ support for criterion ≠ approval.**
- Need source spans, revision, criterion ID, gaps/conflicts, abstention and reviewer authorization.

## Five-zone evidence flow
```text
UPLOAD/INGEST       PARSE/NORMALIZE          SEARCH/RETRIEVE           BOUNDED AGENT            TRUST/HITL
Auth + signed URL → OCR / layout / tables → BM25 + vector + filters → Tool choose/observe → Schema/citation checks
Immutable source    Doc identity/revision     Hybrid + rerank           Step/time/cost budgets    Contradictions/rules
DB job + outbox      Structured elements       Parent-child context     Durable checkpoints       Human approval/audit
```
**Source of truth:** canonical DB + versioned artifact; index is a derived projection.

## Retrieval jargon
- OCR, layout-aware tables/coordinates, immutable source, provenance, document vs revision identity.
- Chunking (structure-aware > blind token chunks where layout matters); parent-child; overlap doesn't fix split tables.
- **BM25:** exact identifiers/terms; **embeddings:** semantic match; **hybrid:** candidate merge; **RRF:** rank fusion; **reranker:** stronger second stage.
- **Recall@K:** fraction of known relevant evidence found; assess retrieval separately from reasoning.
- Revisions: latest ≠ governing approved; check document-control rules and changes mid-assessment.

## Agent jargon
- **Workflow:** fixed code-directed stages. **Agent:** model selects among tools, app executes.
- Example: `searchEvidence` → `getDocumentRevision` → `getOpenActions` → `getEvidenceSpan` → `proposeFinding`.
- Typed args, permission check, tool allow-list, read-only first, finite iterations/time/tokens/cost, checkpoints, non-progress detection, cancellation.
- Tool timeout **≠** zero results. Side effects need idempotency/authorization; model cannot approve consequential outcome.
- Proposed finding statuses: SUPPORTED / GAP / CONFLICTING_EVIDENCE / INSUFFICIENT_EVIDENCE / NEEDS_REVIEW (illustrative only).

## Validation + evals
1. **Structural:** schema, required properties, allowed enum.
2. **Provenance:** authorized source exists, correct revision/page/span.
3. **Semantic:** evidence actually supports claim; no crucial contrary evidence.
- Valid JSON ≠ valid citation ≠ true claim. LLM confidence ≠ calibrated truth probability.
- Metrics: precision, recall, F1; Recall@K, citation correctness, unsupported-claim rate, contradiction misses, correct abstentions, reviewer overrides, latency and cost per assessment.
- Evaluate with expert-labeled cases, old/new conflicting revisions, missing tables, adversarial document instructions.

## Distributed systems + reliability
- Async workers, durable queue, transactional outbox (DB-write/queue dual-write), at-least-once delivery, consumer idempotency.
- Per-page/stage checkpoints, bounded retry + jitter, DLQ, circuit breaker, bulkhead/backpressure.
- Snapshot requirement/document/revision versions; stale-detection before review; optimistic concurrency for competing updates.
- Provider timeout vs malformed JSON vs fake citation vs evidence ambiguity: distinct statuses and response policy.
- Tracing spans across upload→worker→index→retrieval→agent→verification→review; observe quality **and** uptime.
- Idempotent persistence does not guarantee no repeated LLM charges after uncertain external response.

## Enterprise must-haves
- AuthN/AuthZ, tenant/project RBAC/ABAC; enforce across DB, objects, index, vector retrieval and all tools.
- Prompt injection: document text is **data**, not operational authority. Never depend on "ignore instructions" prompt alone.
- Least privilege, allow-listed tool actions, no unrestricted network/DB access.
- Encryption, regional processing and residency, retention, sensitive log redaction, versioned audit, reviewer signoff.

## Quick AI terms
Tokens/subwords; context window; transformer attention; logits → softmax; temperature affects sampling not correctness; embeddings; RAG retrieves changing authorized evidence; fine-tuning adapts model behavior; DistilBERT is a compact encoder classifier; classification calibration; HITL; grounding; abstention; evals.

## Three questions for Brad
1. **Problem:** "What's actually hardest—document extraction, conflicting evidence, or interpreting readiness criteria?"
2. **Architecture:** "Where is the boundary between deterministic assessment logic and agent-driven investigation?"
3. **Partnership:** "What important technical decisions are open, and where would you want your partner to lead?"

## Opening and positioning
**Intro:** "My experience is in production full-stack and distributed systems, increasingly applied AI: Guardlane moderation, Inventory Upload Anything's staged unstructured-data extraction. Carve interests me because model output has to become evidence-backed, trustworthy business decisions. I'd love to understand your hardest engineering challenges."

**One-line technical posture:** "I'd separate engineering reliability from decision reliability: idempotent jobs, tenant isolation and observability **plus** revision-aware evidence, validated citations, contradiction handling and expert review."

**If unfamiliar:** "I haven't built that exact industrial workflow; I'd clarify formats, domain rules, expected error costs and evaluation data, then establish a small baseline before introducing autonomy."

**Close:** "I'd enjoy exploring these decisions in more depth and understanding how your engineering and domain specialists work together."

## REMEMBER
**Listen first.** Don't recite everything. No fictitious CAD/industrial experience, model calibration, exact review queue features or sole OneSearch ownership. Trustworthiness > impressive agent count. Be a curious engineering partner, not a memorized presenter.


## FINAL THREE-PILLAR MAP — the main story (Nov 18 revision)

**Inventory Upload Anything = EVIDENCE INGESTION.** OCR → schema discovery → chunked extraction → reconciliation → asynchronous processing. The transferable challenge is turning inconsistent external inputs into structured, usable evidence. Do not confuse extraction chunking with RAG retrieval chunking or assert industrial drawing expertise.

**PlanForge = EVIDENCE VERIFICATION + DEVIATIONS.** Compare a frozen implementation plan **and original product requirements** with the **existing codebase** and the **actual PR/diff**; trace requirement-to-code evidence, identify missing implementation and justified/unjustified deviations, then present results to a TL/reviewer. This is the **closest conceptual analogue to Carve's criterion-to-evidence assessment**, but PlanForge is an instruction-driven, **agentless** MVP/design exploration, **not an autonomous agent or established production deployment**. Example: approved plan requires backward compatibility, API changes, and tests; PR looks plausible but lacks a required migration/contract/test. The assessor must identify the uncovered requirement rather than say "done". Carve analogue: approved readiness criterion vs current engineering documents/revisions, evidence gaps, contradictions, expert approval.

**Guardlane = POLICY OVER MODEL PREDICTION.** DistilBERT/SageMaker produces probabilistic moderation classifications; deterministic application policy, validation, review and quality monitoring govern downstream action. Never imply a model score alone grants authority. Only claim specific threshold/calibration/HITL queue mechanisms if verified. Observed post-rollout ~20% fewer risky buyer questions is not a randomized causal estimate.

**Unified pattern:** `INGESTION → EVIDENCE / DEVIATION VERIFICATION → GOVERNED DECISION`.

**Preferred discovery question:** "How explicitly do you model readiness criteria and their supporting evidence? Do agents evaluate gaps and deviations against that baseline, while domain rules and expert approval govern the final decision?"

**Natural example:** "In PlanForge we're exploring a frozen plan and product requirements as a baseline, then checking a PR and existing code for implementation evidence and deviations. I see a similar problem in Carve with engineering criteria and document evidence—though PlanForge is an MVP we're developing, not a deployed capital-project assessor."


### PlanForge architecture clarification — November 18
**PlanForge is agentless.** It follows predefined instructions and a controlled verification process; it does **not** autonomously decide which tools to call or pursue iterative agent goals. Its key comparison is **frozen plan + product requirements + existing codebase vs actual PR changes**, recording supporting implementation evidence and gaps/deviations for review. Do not call it a bounded agent, an agentic implementation, or a production autonomous assessor. Carve may use bounded agents for *adaptive evidence discovery*, but its **verification and policy gates can use PlanForge-like deterministic/instruction-driven procedures**. This distinction makes the trade-off concrete: start with prescribed checks and introduce autonomy only when the evidence path genuinely requires it.
