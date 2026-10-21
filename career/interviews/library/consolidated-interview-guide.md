# Consolidated Senior / SDE3 Interview Guide

> Canonical navigation and rehearsal checklist. Existing answer banks remain the source of detailed answers. Do not memorize scripts or invent outcomes.
> Status: **Draft** = existing answer not yet rehearsed; **Evidence needed** = verify details; **Practice** = rehearse aloud.

## How to use this
1. Answer the question aloud first (30–90 seconds for generic questions; 2–3 minutes for behavioral).
2. Compare against the linked reference, noting one concrete personal decision and outcome.
3. Record a score: 0 unable, 1 generic, 2 clear/evidenced, 3 concise with trade-offs and follow-up depth.
4. Update readiness only after a timed, unaided attempt.

## A. Recruiter / generic questions

| Question | Answer anchor | Source | Readiness |
| --- | --- | --- | --- |
| Tell me about yourself / walk me through your resume | 14+ years; end-to-end ownership; modernization; production AI; target role | [Self introduction](self-introduction.md) | Draft |
| Why are you looking to change roles? | Growth in scope, design ownership, engineering influence; avoid criticizing current employer | [Self introduction: follow-ups](self-introduction.md) | Practice |
| Why this company and role? | Match a real company problem to a demonstrated capability; adapt per application | [Self introduction](self-introduction.md) | Practice |
| Why senior / tech lead now? | Decisions influenced, cross-team clarity, production ownership; distinguish title from scope | [Behavioral](behavioral.md) | Practice |
| What are your strengths? | Breadth across boundaries, production ownership, modernization; support with one story | [STAR index](star-index.md) | Practice |
| What is your weakness? | Bounded current improvement with observable repair practice; select what fits role | [Behavioral answers](behavioral-answer-bank.md) | Draft |
| Backend, frontend, AI or platform? | Full-stack/platform breadth with explicit strongest areas and limits | [Self introduction](self-introduction.md) | Practice |
| What motivates you? | Complex business-to-production problems, reducing uncertainty, enabling others | [Project deep dives](project-deep-dives.md) | Practice |
| What do you want in your next role? | Hands-on architecture, end-to-end responsibility, mentoring and impact | [Self introduction](self-introduction.md) | Practice |
| What would you do in your first 90 days? | Learn workflows and ownership, ship safe improvement, own bounded initiative | [Behavioral answers](behavioral-answer-bank.md) | Draft |
| Compensation expectations / availability? | Prepare accurate current numbers, market range, and notice period privately; do not hardcode | — | Evidence needed |

## B. Behavioral and leadership

| Interview question | Primary example | Reference | Readiness |
| --- | --- | --- | --- |
| Tell me about end-to-end ownership | Dealer Operating System ownership transition | [Answer bank](behavioral-answer-bank.md) | Draft |
| Led without authority? | Guardlane stakeholder coordination | [Answer bank](behavioral-answer-bank.md) | Draft |
| Influenced a technical decision? | Incremental marketplace modernization | [Answer bank](behavioral-answer-bank.md) | Draft |
| Worked through ambiguity? | Similar Listings requirements | [STAR index](star-index.md) | Evidence needed |
| Disagreed with a colleague or product? | Find exact competing options, decision and outcome | [Behavioral questions](behavioral.md) | Evidence needed |
| Made a mistake / received difficult feedback? | Large PR review friction; changed review discipline | [Answer bank](behavioral-answer-bank.md) | Draft |
| Responded to a production incident? | Select a specific investigation with timeline and verification | [STAR index](star-index.md) | Evidence needed |
| Mentored or onboarded an engineer? | System-map onboarding; add a specific person and observable outcome | [Answer bank](behavioral-answer-bank.md) | Evidence needed |
| Balanced technical debt with delivery? | Compatibility boundaries and incremental rollout | [Answer bank](behavioral-answer-bank.md) | Draft |
| Challenged a requirement constructively? | Similar Listings edge case | [STAR index](star-index.md) | Evidence needed |
| Managed a risky deadline? | Select verified delivery with scope/risk decision | [Behavioral questions](behavioral.md) | Evidence needed |
| Changed an engineering habit? | Smaller PRs, deeper self-review, earlier requirement clarification | [Answer bank](behavioral-answer-bank.md) | Draft |
| Explained risk to non-engineers? | Guardlane policy, fallback, human review | [Guardlane guide](../../projects/guardlane/14-interview.md) | Practice |
| Handled security or privacy responsibility? | Choose a verified healthcare or AI governance decision | [STAR index](star-index.md) | Evidence needed |

## C. Project deep dives

| Project | Essential prompt | Reference |
| --- | --- | --- |
| Marketplace modernization | Why incremental migration instead of a rewrite? What did *you* own? | [Project deep dives](project-deep-dives.md) |
| Guardlane | Why hybrid rules + classifier + fallback? How evaluate and operate? | [Guardlane interview](../../projects/guardlane/14-interview.md) |
| AI Upload | What was the business workflow, validation boundary, and measurable result? | [Project deep dives](project-deep-dives.md) |
| Vehicle Detail BFF | What belongs in the BFF, and how handle latency/partial failure? | [Project deep dives](project-deep-dives.md) |
| Enterprise search | Why Elasticsearch; how do relevance and indexing work? | [H&B interview](../../projects/holland-barrett-platform/09-interview-guide.md) |
| Promotion engine | Why ANTLR grammar; how were rules validated and tested? | [Project deep dives](project-deep-dives.md) |

For every project: **30-second overview → 2-minute ownership/decision → 5-minute architecture/trade-offs → production failures and lessons**.

## D. Technical interview tracks

- [Coding and DSA](coding-stories.md) and [answer key](coding-answer-key.md): solve without AI first.
- [System design](system-design.md): requirements, invariants, data flows, scale, reliability, security, trade-offs.
- [Technical depth](technical-depth.md): mechanisms and production implications, not vocabulary lists.
- [Mock interviews and rubric](mock-interviews.md): timed performance and error log.
- [System-design foundations](../../../interview-notes/system-design/foundations.md): reasoning from business requirements.
- [Architecture / .NET revision map](../../../interview-notes/system-design/revision-map-dotnet.md): production concepts and terminology.

## E. Questions to ask the interviewer

1. What are the most consequential technical decisions this person would own in the first six months?
2. Where does delivery currently lose predictability: requirements, dependencies, reviews, deployment, or production?
3. What separates strong senior performance from technical-lead performance here?
4. How does the team balance modernization with ongoing feature commitments?
5. Which operational metric would you most like this hire to improve?

Adapt to the role and avoid asking questions already answered.

## F. Evidence gaps to close

- [ ] Exact Similar Listings requirement edge case and resulting decision
- [ ] One disagreement with alternatives and outcome
- [ ] One incident timeline, investigation, and verified fix
- [ ] One named mentoring example with observable improvement
- [ ] Verified AI Upload result and personal contribution
- [ ] One security/privacy-sensitive decision
- [ ] Current role-specific motivation (avoid Verily-only wording)
- [ ] Unaided spoken rehearsal of generic answers
- [ ] Timed behavioral mock with follow-up questions

## Existing detailed resources

- [Library home](README.md)
- [Self-introduction variants](self-introduction.md)
- [Behavioral question inventory](behavioral.md)
- [Behavioral answer bank](behavioral-answer-bank.md)
- [STAR evidence index](star-index.md)
- [Project deep dives](project-deep-dives.md)
- [Mock interview scoring](mock-interviews.md)

Older supporting repository: [dheeraj-portfolio interview flashcards](https://github.com/dheerix/dheeraj-portfolio/tree/main/interview_flashcards) and [STAR stories](https://github.com/dheerix/dheeraj-portfolio/blob/main/story_bank/star_stories.md). Treat historical claims as unverified until reconciled with current project evidence.
