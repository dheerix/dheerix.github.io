# Valency — Senior Software Engineer (AI & Full-Stack)

**Interview control notes | Updated 2026-11-16 | 30-minute engineering-lead introduction**

> This folder is a private-preparation *subject* in a **public repository**. Do not store confidential employer architecture, candidate contact details, proprietary prompts, private source code, or customer data here. Distinguish published company information from hypotheses and proposed designs.

## Opportunity and current checkpoint

- **Organization:** Valency (Waterloo, Ontario); product: **Carve**, for capital-project assurance/readiness.
- **Contact:** Brad, engineering leader who directly approached the candidate, describing the opening as a *technical partner* opportunity.
- **Conversation:** **Wednesday, November 18, 2026, 11:00 AM EST**, **30 minutes** (scheduled introduction / mutual technical discovery).
- **Hiring context (from outreach):** building production AI agents to examine messy engineering documents and support defensible capital-project readiness assessments. The outreach says organizations using Carve manage **more than $65B in annual CAPEX**; this is a company-provided figure, not independently verified here.
- **Parallel opportunities:** MaintainX recruiter call **Friday, November 20, 2026, 2:00 PM EST**; Foci reply pending.
- **Prep priority:** Valency first until this conversation. Keep mock technical interviews and deep teaching in separate chat; this folder records roadmap/checkpoints.

## Purpose of the 30-minute call

Treat this as **two engineers exploring a possible partnership**, not a one-way examination. Brad's outreach conveys interest in production AI judgment, not just AI tool fluency.

Desired outcome: both sides understand enough about product direction, collaboration habits, technical ownership and remaining challenges to naturally want a deeper follow-up. Do not try to force a second call or deliberately withhold answers.

### Conversation pacing (guidance, not a script)

| Approx. time | Objective | Focus |
|---|---|---|
| 0–5 min | Establish context | What prompted the direct outreach; shared engineering experience |
| 5–12 min | Understand Carve and direction | Existing assurance workflow, AI-agent opportunity and current maturity |
| 12–22 min | Exchange technical perspectives | Trusted evidence extraction, revision tracking, system boundaries and production lessons |
| 22–27 min | Explore technical partnership | Ownership, decision process, domain experts, delivery habits |
| 27–30 min | Natural continuation | Identify a concrete unresolved problem worth exploring together |

Do not rigidly follow the clock. Two good observations, with genuine follow-ups, are stronger than ten rehearsed questions.

## Preparation emphasis

| Focus | Suggested share |
|---|---:|
| Product, company publications and domain | 40% |
| Engineering philosophy and collaboration | 30% |
| Relevant past production experience | 20% |
| Baseline technical refresh | 10% |

These are **preparation allocations, not an estimate of the interview agenda**.

## Company/product research

Study the official material, not merely secondary summaries:

1. [Carve project assurance software](https://valencyinc.com/carve-project-assurance-software/) — What decisions does the software help customers make? What is the core product value?
2. [Carve and PDRI](https://valencyinc.com/carve-for-pdri/) — How does defined project scope become a structured assessment?
3. [Generative AI Governance Framework (2025 PDF)](https://valencyinc.com/wp-content/uploads/2025/06/Valency-Generative-AI-Governance-Framework.pdf) — Read carefully and verify current applicability. Earlier discussion highlighted human review, AWS Bedrock and privacy/data-residency controls; confirm the precise wording before quoting in a call.

**Working hypothesis (not confirmed current design):** Carve combines structured expert-led readiness criteria with AI-powered document interpretation. Ask how deterministic assessment logic and probabilistic model output are separated.

## Three high-value conversation starters

**A. Deterministic readiness versus model reasoning**

> "What interested me is that the AI isn't the final product—the defensible readiness assessment is. How are you thinking about the boundary between established assessment criteria and model-generated evidence or judgments?"

Listen for: framework ownership, current product maturity, evidence quality, specialist signoff and flexibility needed from agents.

**B. Traceability versus privacy**

> "I noticed the governance emphasis on human approval and privacy. With document-reading agents, how are you approaching evidence provenance and reproducibility while minimizing sensitive model-interaction logging?"

Listen for: immutable source references, revisions, access controls, audit artifacts, model versions, retention and human approval.

**C. Engineering–domain partnership**

> "How closely do engineers work with capital-project specialists when encoding readiness criteria? What tends to be hardest: extracting reliable evidence, judging whether it satisfies a criterion, or operationalizing the reviewer workflow?"

Listen for: product feedback loops, domain onboarding and whether the senior hire owns end-to-end product decisions.

### Partnership discovery questions

- "What would you want your technical partner to own in the first three to six months?"
- "Which architecture decisions are settled, and where would you welcome a different perspective?"
- "How do you decide when to use a deterministic pipeline versus an agent?"
- "How are engineering, product and domain experts involved in reviewing failure cases?"
- "What does excellent engineering collaboration look like on your team?"

Use questions selectively based on the conversation.

## Candidate positioning

A grounded introduction:

> "My background is in production full-stack and distributed systems. More recently I've worked on NLP moderation and LLM-assisted ingestion workflows, where the interesting problems begin after a model produces an output: validation, trust, review, integration and operational behavior. The Carve challenge appeals to me because it connects probabilistic extraction to decisions that need to be defensible."

Project connections (avoid inflated claims):

| Carve concern | Prior project | Safe framing |
|---|---|---|
| Noisy documents, structured extraction | Inventory Upload Anything | OCR, schema discovery, chunked extraction and reconciliation; share only personally verified/approved details |
| Trusting classification outputs | Guardlane | DistilBERT/SageMaker moderation, error analysis, operational review |
| Search and evidence retrieval | OneSearch | Contributed to Oracle-to-Elasticsearch modernization and .NET search APIs under a Principal Engineer |
| Requirements, plan and deviation tracking | PlanForge | Plan-first engineering concept; distinguish implemented features from proposed roadmap |
| Complex feature delivery and backward compatibility | Cost Mapping | Cross-layer architecture and coordinating data, API, UI and external integration changes |

Avoid claiming direct industrial project-assurance domain expertise. Demonstrate how you learn domains and collaborate with experts.

## Conversation success checklist

- [ ] I can describe what Carve helps customers accomplish in plain English.
- [ ] I have read one substantive governance/product publication and formed two real questions.
- [ ] I can explain why extracting evidence is different from approving readiness.
- [ ] I can describe two verified examples from my own work with honest ownership boundaries.
- [ ] I understand how Brad wants to collaborate and what he expects from the role.
- [ ] We identify a real technical/product challenge that deserves a deeper conversation.
- [ ] I leave knowing whether the opportunity is compelling **for me**, too.

## Mandatory technical foundations

See [technical-confidence-checklist.md](technical-confidence-checklist.md). The priority is **grounding and trust**, then **production execution**, then **engineering judgment**; learn these in a separate study/interview-simulator chat.

## Interview status notes

- 2026-11-16: Valency elevated to primary focus; introductory meeting reframed as mutual engineering discovery rather than a formal exam.
- 2026-11-16: Mandatory technical concept groups defined and captured in dedicated notes.
- After the meeting: record Brad's actual product/architecture statements, technical uncertainties, follow-up commitments and next steps here—without copying sensitive details into this public repo.

## Consolidated study material (November 18)

- [Sessions 01–05 — technical study and discussion notes](study-sessions-01-05.md): Carve domain, evidence trust, document intelligence/RAG, bounded agents, full-stack architecture, security and partnership conversation.
- [Dense interview cheat sheet](interview-cheatsheet.md): Brad's outreach mapped to verified experience, key questions, five-stage architecture, technical terminology, guardrails and opening/closing.

The handwritten visual cheat sheet was generated in the conversation but is **not yet uploaded to this repository**.

## Three-project interview framing (November 18)

Use this as the primary map in the conversation:

1. **Inventory Upload Anything → Ingestion:** OCR, schema discovery, chunk extraction, reconciliation, async pipelines.
2. **PlanForge → Evidence verification:** frozen plan + product requirements + existing code compared with PR changes to find gaps/deviations and support review (**MVP/design exploration; do not overstate implementation**).
3. **Guardlane → Policy over prediction:** NLP model quality and application-enforced decisions.

**Shared pattern:** `Ingestion → Evidence verification → Governed decision`.

The [dense interview cheat sheet](interview-cheatsheet.md) and [study notes](study-sessions-01-05.md) contain the complete revised mapping.


### PlanForge architecture clarification — November 18
**PlanForge is agentless.** It follows predefined instructions and a controlled verification process; it does **not** autonomously decide which tools to call or pursue iterative agent goals. Its key comparison is **frozen plan + product requirements + existing codebase vs actual PR changes**, recording supporting implementation evidence and gaps/deviations for review. Do not call it a bounded agent, an agentic implementation, or a production autonomous assessor. Carve may use bounded agents for *adaptive evidence discovery*, but its **verification and policy gates can use PlanForge-like deterministic/instruction-driven procedures**. This distinction makes the trade-off concrete: start with prescribed checks and introduce autonomy only when the evidence path genuinely requires it.

## PlanForge source review

The [study notes](study-sessions-01-05.md) and [cheat sheet](interview-cheatsheet.md) have been updated following direct inspection of the private `dheerix/planforge` implementation. **Current PlanForge is a Codex-operated, instruction-driven skill with deterministic collectors/validators and human confirmation gates; bounded autonomous investigation remains a proposed extension.** The current deviation analyzer validates submitted findings, rather than independently proving complete PR requirement coverage. See [PlanForge vs Carve — source-grounded comparison](planforge-carve-mapping.md).

## Post-interview checkpoint — November 18, 2026

- **Outcome:** Candidate reported the introductory conversation with Brad went well. No offer or confirmed next round yet.
- **Team described in conversation:** one engineering director and two junior engineers; hiring for an **in-person senior engineer**.
- **Decision gates if an offer arrives:** (1) salary relative to current CAD 125K base and opportunity cost, (2) senior-level title and scope, (3) acceptance of an in-office schedule ending around **3:00 PM**, and (4) an actual offer. No decision before these are known.
- **Open questions:** compensation range, exact title/ownership, office schedule flexibility, next steps.
- **Next preparation priority:** MaintainX — Senior Search Developer; recruiter conversation recorded for **Friday, November 20 at 2:00 PM EST**. Confirm timing against latest recruiter correspondence.
