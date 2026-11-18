# PlanForge → Carve: source-grounded architecture mapping



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


## Quick visual — current versus hypothetical

```mermaid
flowchart LR
    L["Linear requirements + frozen plan"] --> C["Codex skill: staged, confirmed inspection"]
    R["Repository + linked PR snapshots"] --> C
    C --> D["Deterministic validators / rule registry"]
    D --> H["Reviewable finding + human approval"]

    G["Hypothetical verification goal"] -.-> A["Bounded model-driven investigator"]
    A -.-> T["Authorized Linear / PR / code / test tools"]
    T -.-> A
    A -.-> D
```

Solid edges are current architectural responsibilities described in the repository; dashed edges are a **proposed agentic evolution**, not delivered functionality.

## Source links

- [PlanForge README](https://github.com/dheerix/planforge/blob/main/README.md)
- [PlanForge SKILL.md](https://github.com/dheerix/planforge/blob/main/skills/planforge/SKILL.md)
- [Deviation analyzer](https://github.com/dheerix/planforge/blob/main/skills/planforge/scripts/analyze_deviations.rb)
- [Deviation rule registry](https://github.com/dheerix/planforge/blob/main/skills/planforge/references/deviation-rules.json)
- [Evidence contract](https://github.com/dheerix/planforge/blob/main/skills/planforge/references/deviation-evidence-contract.md)
- [PR evidence collector](https://github.com/dheerix/planforge/blob/main/skills/planforge/scripts/collect_pull_request_evidence.rb)
- [Repository evidence collector](https://github.com/dheerix/planforge/blob/main/skills/planforge/scripts/collect_repository_evidence.rb)
- [Comparison input builder](https://github.com/dheerix/planforge/blob/main/skills/planforge/scripts/build_comparison_input.rb)

**Repository visibility:** PlanForge is private; only authenticated viewers with access can open these links. This mapping contains architecture descriptions but no private source copied into the public interview notes.

## How deviation detection actually works — source-verified

**Important architecture boundary:** PlanForge separates *candidate deviation discovery* from *deterministic validation of a supplied finding*. `analyze_deviations.rb` does **not** autonomously inspect arbitrary PR diffs and prove full requirement coverage.

### Four-step process

1. **Freeze the baseline.** The versioned `execution-plan.yaml` specifies the accepted implementation scope, repositories, plan identity/version, linked PRs and acceptance criteria. The original Linear product requirements remain the canonical product intent.
2. **Collect scoped implementation evidence.** `collect_repository_evidence.rb` reads Git checkout status, branch, commit and working-tree provenance; `collect_pull_request_evidence.rb` normalizes *supplied* PR snapshots but rejects PRs not linked to the frozen plan; `collect_linear_evidence.rb` normalizes *supplied* Linear snapshots; `build_comparison_input.rb` joins explicit evidence checks only when plan identity/version and source IDs match. These collectors don't themselves prove semantic requirement satisfaction.
3. **Discover candidate gaps or deviations upstream.** Codex following `SKILL.md` can inspect confirmed codebases and compare expectations with implementation; alternatively the findings are provided as structured evidence. This interpretive step may involve LLM reasoning. It is **not** automatically carried out by the deterministic analyzer.
4. **Validate, report and review.** `analyze_deviations.rb` validates each supplied finding's category, status, `expected`, `actual`, recommendation, evidence links and provenance against `deviation-rules.json` and the evidence/status contracts. It produces `deviation-analysis.json` and a draft `linear-comment.md`; it does **not** silently post to Linear. `validate_deviation_transitions.rb` enforces allowed status changes. Human review/disposition remains essential.

### What counts as a deviation?

The implemented rule registry includes:
- **`contract-drift`** — an expected request/response/event/terminology contract differs from evidence.
- **`missing-acceptance-coverage`** — evidence does not demonstrate one or more frozen acceptance criteria.
- **`scope-drift`** — implemented changes alter included or excluded scope.
- **`deferred-recovery-gap`** — deferred workflow lacks necessary durable recovery state.
- **`lifecycle-recovery-gap`** — required persistence/recovery/state-transition path isn't evidenced.

These categories constrain **how supplied findings are classified and validated**; the categories don't automatically discover violations.

### Example: AC-7 backward-compatibility requirement (illustrative)

**Expected:** `AC-7: Existing clients continue receiving the legacy response field.`

**Observed candidate evidence:** A linked PR changes the API response, but the reviewer finds no compatibility test or other proof that the original contract is preserved.

**Candidate finding:** `missing-acceptance-coverage`, with `expected`, `actual`, an evidence link pointing to the PR/contract, an owner, and a recommendation to verify the old contract and produce regression evidence.

**Do not infer actual incompatibility merely from missing tests.** Insufficient implementation evidence means the criterion has not yet been *demonstrated*, which is different from proving that it has been *violated*.

**After review:** A finding can move among statuses such as `detected`, `acknowledged`, `resolving`, `blocked`, `resolved`, `accepted_risk`, `dismissed`, and `stale`, subject to the registry's allowed transitions. A future evidence update may require re-evaluation.

### Carve analogy

`Approved readiness criterion → authorized engineering-source evidence → candidate gap/contradiction → evidence-backed structured finding → deterministic policy checks → domain-expert disposition`.

**Brad-ready phrasing:**

> "PlanForge uses a frozen plan and acceptance criteria as the baseline. Codex-guided investigation supplies candidate findings from scoped repository and PR evidence. Our scripts enforce plan identity, evidence contracts, deviation categories and status transitions, then prepare a human-reviewable report. The interesting agentic extension would be to adaptively discover sufficient evidence—not to let the model rewrite assessment policy or self-approve a finding."

**Source files:**
[PlanForge skill](https://github.com/dheerix/planforge/blob/main/skills/planforge/SKILL.md) ·
[analyze_deviations.rb](https://github.com/dheerix/planforge/blob/main/skills/planforge/scripts/analyze_deviations.rb) ·
[deviation-rules.json](https://github.com/dheerix/planforge/blob/main/skills/planforge/references/deviation-rules.json) ·
[deviation evidence contract](https://github.com/dheerix/planforge/blob/main/skills/planforge/references/deviation-evidence-contract.md) ·
[PR evidence collector](https://github.com/dheerix/planforge/blob/main/skills/planforge/scripts/collect_pull_request_evidence.rb) ·
[repository evidence collector](https://github.com/dheerix/planforge/blob/main/skills/planforge/scripts/collect_repository_evidence.rb) ·
[comparison input builder](https://github.com/dheerix/planforge/blob/main/skills/planforge/scripts/build_comparison_input.rb) ·
[status model](https://github.com/dheerix/planforge/blob/main/skills/planforge/references/deviation-status-model.json) ·
[transition validator](https://github.com/dheerix/planforge/blob/main/skills/planforge/scripts/validate_deviation_transitions.rb).

*The PlanForge repository is private. These links require repository access.*
