# Integrated Engineering + AI + Interview Curriculum

**Goal:** One real engineering problem studied through three tracks, using Six Thinking Hats to make decisions explicit and interview-ready.

## Session cycle (90 minutes)
1. **15m Frame (Blue + White):** business problem, requirements, assumptions, unknowns.
2. **30m Engineer (Black + Green):** implement/design core mechanism; explore failure cases and alternatives.
3. **20m AI dimension (Yellow + Black):** retrieval/model/tool workflow, benefits, evaluation and safety.
4. **15m Interview:** explain the decision without naming hats; handle follow-ups and trade-offs.
5. **10m Log:** what was learned, gaps, evidence, next exercise.

Do **not** force every DSA or .NET fundamentals session into an AI example; retain dedicated unaided practice.

## Five integrated sprints
| Sprint | AI engineering | General engineering | Interview artifact |
| --- | --- | --- | --- |
| 1. Retrieval | Chunking, lexical/vector search, reranking | Indexes, API design, data modeling | Design knowledge assistant |
| 2. Reliability | Fallback, evaluation, latency | async/await, cancellation, retries | Explain failure and latency budgets |
| 3. Production AI | Guardrails, HITL, drift | Queues, observability, incidents | Guardlane deep dive |
| 4. Tool use | MCP, LangChain, agent/tool boundaries | Auth, permissions, transactions | Safe agent system design |
| 5. Delivery at scale | Cost, caching, eval pipeline | Deployment, CI/CD, architecture | Full senior mock |

## Hats in practice
- **Blue:** What decision are we making?
- **White:** What facts and unknowns constrain it?
- **Red:** What intuition or stakeholder concern matters?
- **Black:** What could go wrong?
- **Yellow:** What benefit justifies it?
- **Green:** What alternatives can we test?
- **Blue again:** Decide, validate, communicate.

Use hats one at a time for reflection; interview answers should sound like ordinary clear engineering reasoning.

## Completion criteria per sprint
- [ ] A small implementation or architecture sketch
- [ ] A written trade-off with alternative and risk
- [ ] Tests or evaluation criteria
- [ ] A two-minute spoken walkthrough
- [ ] One interview follow-up answered unaided
- [ ] An error log and next action

[Master interview guide](README.md) · [Five-minute cheat sheet](CHEAT-SHEET.md) · [Technical depth](technical-depth.md) · [System design](system-design.md)
