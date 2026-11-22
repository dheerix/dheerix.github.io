# Senior / SDE3 Interview Master Guide

Single reading and rehearsal document. The original sections are preserved below with their content, while technical exercise files remain separate.

## Contents
- [consolidated-interview-guide](#section-1)
- [self-introduction](#section-2)
- [behavioral](#section-3)
- [behavioral-answer-bank](#section-4)
- [star-index](#section-5)
- [project-deep-dives](#section-6)
- [mock-interviews](#section-7)

## Technical practice (separate)
- [Coding](coding-stories.md) · [Coding answer key](coding-answer-key.md)
- [Technical depth](technical-depth.md) · [System design](system-design.md)
- [One-week plan](one-week-plan.md)


---

<a id="section-1"></a>
## Section 1: consolidated-interview-guide.md

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
| Tell me about yourself / walk me through your resume | 14+ years; end-to-end ownership; modernization; production AI; target role | [Self introduction](#section-2) | Draft |
| Why are you looking to change roles? | Growth in scope, design ownership, engineering influence; avoid criticizing current employer | [Self introduction: follow-ups](#section-2) | Practice |
| Why this company and role? | Match a real company problem to a demonstrated capability; adapt per application | [Self introduction](#section-2) | Practice |
| Why senior / tech lead now? | Decisions influenced, cross-team clarity, production ownership; distinguish title from scope | [Behavioral](#section-3) | Practice |
| What are your strengths? | Breadth across boundaries, production ownership, modernization; support with one story | [STAR index](#section-5) | Practice |
| What is your weakness? | Bounded current improvement with observable repair practice; select what fits role | [Behavioral answers](#section-4) | Draft |
| Backend, frontend, AI or platform? | Full-stack/platform breadth with explicit strongest areas and limits | [Self introduction](#section-2) | Practice |
| What motivates you? | Complex business-to-production problems, reducing uncertainty, enabling others | [Project deep dives](#section-6) | Practice |
| What do you want in your next role? | Hands-on architecture, end-to-end responsibility, mentoring and impact | [Self introduction](#section-2) | Practice |
| What would you do in your first 90 days? | Learn workflows and ownership, ship safe improvement, own bounded initiative | [Behavioral answers](#section-4) | Draft |
| Compensation expectations / availability? | Prepare accurate current numbers, market range, and notice period privately; do not hardcode | — | Evidence needed |

## B. Behavioral and leadership

| Interview question | Primary example | Reference | Readiness |
| --- | --- | --- | --- |
| Tell me about end-to-end ownership | Dealer Operating System ownership transition | [Answer bank](#section-4) | Draft |
| Led without authority? | Guardlane stakeholder coordination | [Answer bank](#section-4) | Draft |
| Influenced a technical decision? | Incremental marketplace modernization | [Answer bank](#section-4) | Draft |
| Worked through ambiguity? | Similar Listings requirements | [STAR index](#section-5) | Evidence needed |
| Disagreed with a colleague or product? | Find exact competing options, decision and outcome | [Behavioral questions](#section-3) | Evidence needed |
| Made a mistake / received difficult feedback? | Large PR review friction; changed review discipline | [Answer bank](#section-4) | Draft |
| Responded to a production incident? | Select a specific investigation with timeline and verification | [STAR index](#section-5) | Evidence needed |
| Mentored or onboarded an engineer? | System-map onboarding; add a specific person and observable outcome | [Answer bank](#section-4) | Evidence needed |
| Balanced technical debt with delivery? | Compatibility boundaries and incremental rollout | [Answer bank](#section-4) | Draft |
| Challenged a requirement constructively? | Similar Listings edge case | [STAR index](#section-5) | Evidence needed |
| Managed a risky deadline? | Select verified delivery with scope/risk decision | [Behavioral questions](#section-3) | Evidence needed |
| Changed an engineering habit? | Smaller PRs, deeper self-review, earlier requirement clarification | [Answer bank](#section-4) | Draft |
| Explained risk to non-engineers? | Guardlane policy, fallback, human review | [Guardlane guide](../../projects/guardlane/14-interview.md) | Practice |
| Handled security or privacy responsibility? | Choose a verified healthcare or AI governance decision | [STAR index](#section-5) | Evidence needed |

## C. Project deep dives

| Project | Essential prompt | Reference |
| --- | --- | --- |
| Marketplace modernization | Why incremental migration instead of a rewrite? What did *you* own? | [Project deep dives](#section-6) |
| Guardlane | Why hybrid rules + classifier + fallback? How evaluate and operate? | [Guardlane interview](../../projects/guardlane/14-interview.md) |
| AI Upload | What was the business workflow, validation boundary, and measurable result? | [Project deep dives](#section-6) |
| Vehicle Detail BFF | What belongs in the BFF, and how handle latency/partial failure? | [Project deep dives](#section-6) |
| Enterprise search | Why Elasticsearch; how do relevance and indexing work? | [H&B interview](../../projects/holland-barrett-platform/09-interview-guide.md) |
| Promotion engine | Why ANTLR grammar; how were rules validated and tested? | [Project deep dives](#section-6) |

For every project: **30-second overview → 2-minute ownership/decision → 5-minute architecture/trade-offs → production failures and lessons**.

## D. Technical interview tracks

- [Coding and DSA](coding-stories.md) and [answer key](coding-answer-key.md): solve without AI first.
- [System design](system-design.md): requirements, invariants, data flows, scale, reliability, security, trade-offs.
- [Technical depth](technical-depth.md): mechanisms and production implications, not vocabulary lists.
- [Mock interviews and rubric](#section-7): timed performance and error log.
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
- [Self-introduction variants](#section-2)
- [Behavioral question inventory](#section-3)
- [Behavioral answer bank](#section-4)
- [STAR evidence index](#section-5)
- [Project deep dives](#section-6)
- [Mock interview scoring](#section-7)

Older supporting repository: [dheeraj-portfolio interview flashcards](https://github.com/dheerix/dheeraj-portfolio/tree/main/interview_flashcards) and [STAR stories](https://github.com/dheerix/dheeraj-portfolio/blob/main/story_bank/star_stories.md). Treat historical claims as unverified until reconciled with current project evidence.


---

<a id="section-2"></a>
## Section 2: self-introduction.md

# Self Introduction

The introduction should position the candidate without reciting the resume.

The narrative is:

```text
14+ years across technologies
    ↓
end-to-end system ownership
    ↓
platform modernization and production systems
    ↓
current focus on AI, cloud, and technical leadership
    ↓
alignment with Verily
```

## 30-Second Version

I’m a senior software engineer with more than 14 years of experience across backend, frontend, cloud, distributed systems, and production AI. At OPENLANE, I work on marketplace modernization, backend-for-frontend services, microfrontends, and AI-assisted workflows such as Guardlane and AI Upload. The common thread in my career is following problems across the system and helping production platforms evolve safely. I’m now looking for a role where I can combine hands-on delivery with system design and technical leadership.

## 90-Second Version

I’m a senior software engineer with more than 14 years of experience building software across commerce, healthcare, sustainability, and automotive marketplaces.

My early career gave me a broad implementation foundation across Java, .NET, mobile, web, and databases. At Holland & Barrett, I worked on enterprise search, promotion rules, backend APIs, React experiences, and production investigations. That work showed me how platform decisions directly affect customer experience and business outcomes.

At OPENLANE, my scope expanded across legacy-to-cloud modernization, event-driven services, backend-for-frontend architecture, microfrontends, production operations, and AI-enabled workflows. I have worked on systems where Oracle and Java coexist with AWS, Node.js, .NET, Kinesis, Pulsar, Kubernetes, React, Svelte, and Stencil. I also helped evolve Guardlane and AI Upload from model capabilities into operational product workflows with evaluation, fallbacks, human review, and observability.

What I bring is the ability to move between architecture and implementation while keeping production behavior and cross-team delivery visible. That is why Verily’s platform, full-stack, and technical-lead roles are a strong fit.

## Technical-Lead Version

I’m a hands-on senior engineer who leads by reducing uncertainty. My strongest work has involved systems that cross team and technology boundaries—legacy integration, cloud services, frontend platforms, production operations, and AI workflows.

At OPENLANE, I have driven technical discussions, clarified requirements, supported onboarding, worked through production incidents, and kept cross-functional initiatives moving when formal technical leadership was unavailable. I do not treat leadership as separate from implementation. I use design clarity, documented trade-offs, review quality, and operational ownership to help the team make better decisions.

The Workbench role interests me because user and account management combines system design, security, reliability, product collaboration, and sensitive-data responsibility.

## Developer-Platform Version

I have spent much of my career helping products move across technology generations while keeping delivery and production stable. At OPENLANE, that has included legacy integration, AWS services, event-driven systems, Kubernetes, ArgoCD, backend-for-frontend services, shared frontend patterns, and production observability.

That experience made me interested in the platform capabilities behind engineering delivery: safe defaults, reusable patterns, deployment confidence, service ownership, and observability. I also have experience with GCP and Terraform. The Developer Platform role is attractive because it treats internal engineering workflows as a product and creates leverage across hundreds of developers.

## Precision-Health Version

My background combines platform engineering, distributed systems, production AI, and healthcare software. I have built within HIPAA-sensitive environments and understand that healthcare platforms require more than technical scalability: access control, data handling, auditability, reliability, and clear ownership are central design concerns.

I am interested in Verily because its platform work connects cloud engineering and data systems to meaningful research and care workflows. I would bring strong adjacent experience while being explicit about the healthcare standards and data-platform areas I am continuing to deepen.

## Delivery Guidance

- Speak naturally; do not memorize punctuation.
- Keep the first answer under two minutes.
- Pause after the current-role summary.
- Let the interviewer choose the deep-dive direction.
- Do not list every technology.
- Do not describe team outcomes as personal accomplishments.
- Adjust the final paragraph to the specific role.

## Common Follow-Ups

Prepare concise answers for:

- Why are you leaving?
- Why Verily?
- Why this specific team?
- Are you more backend, frontend, or platform?
- What level of technical leadership have you exercised?
- Which healthcare systems have you built?
- How deep is your GCP, Terraform, and Kubernetes experience?
- Why not specialize in one technology?


---

<a id="section-3"></a>
## Section 3: behavioral.md

# Senior Behavioral Interviews

Behavioral rounds at senior level evaluate judgment, ownership, influence, and learning—not only whether an event fits the STAR acronym.

## Answer Structure

Use:

```text
Headline
    ↓
Situation and stakes
    ↓
My responsibility
    ↓
Decision and alternatives
    ↓
Action and communication
    ↓
Result
    ↓
Reflection
```

Keep the initial answer between two and three minutes.

## Senior-Level Question Set

### Ownership

- Tell me about an ambiguous problem you took ownership of.
- Tell me about a system you supported beyond launch.
- When did you identify work that nobody had assigned?

### Technical Leadership

- Describe a technical direction you influenced.
- How have you led without formal authority?
- Tell me about a time the technical lead was unavailable.
- How did you create clarity for other engineers?

### Disagreement

- Tell me about a design disagreement.
- When did you challenge a product requirement?
- Describe a time your preferred solution was not selected.

### Failure and Reflection

- Tell me about a mistake.
- Describe a pull request or delivery that became harder than expected.
- When did production evidence change your opinion?
- What engineering habit have you deliberately changed?

### Mentoring

- How do you onboard engineers?
- Describe feedback that helped another engineer.
- How do you review code without taking ownership away from the author?

### Cross-Functional Communication

- Tell me about a difficult product or stakeholder conversation.
- How do you explain risk without blocking delivery?
- How do you communicate during an incident?

### Delivery and Prioritization

- How do you balance technical debt and product work?
- Describe a deadline with significant technical risk.
- When did you reduce scope to protect the outcome?

### Security and Responsibility

- Tell me about a security or privacy-sensitive decision.
- How do you ensure sensitive data is handled correctly?
- What would you do if a requested feature introduced unacceptable risk?

## Primary Evidence

Use the [STAR Story Index](#section-5) to select the correct example.
Use [Behavioral Answer Bank](#section-4) for reference responses based on the currently documented evidence.

Strong stories include:

- Dealer Operating System ownership transition
- Guardlane coordination while the technical lead was unavailable
- Marketplace incremental modernization
- AWS SDK migration
- Similar Listings requirement edge case
- difficult or oversized pull request
- production incident investigation
- Holland & Barrett search and promotion work

## Communication Rules

### Lead With the Answer

Avoid spending one minute establishing background before revealing the point.

Start with:

> A useful example is when our small team took ownership of dealer-facing capabilities previously owned by another group.

### Separate Team and Personal Work

Use:

> The team delivered several initiatives. I personally owned…

### Include the Decision

An answer that contains activity but no decision usually sounds mid-level.

State:

- what options existed
- what you recommended
- who needed alignment
- what risk remained

### Include Reflection

Reflection should describe changed behavior:

> After that experience, I began decomposing broad changes earlier and documenting review boundaries before implementation.

## Difficult-Question Guidance

### Failure

Choose a real event with recoverable consequences and a genuine behavioral change. Do not disguise a success as a failure.

### Conflict

Do not portray the other person as irrational. Explain the competing incentives.

### Leadership

Do not rely on title. Show how the decision, team, or delivery became clearer because of your actions.

### Weakness

Use a current, bounded weakness with an active repair mechanism. Coding fluency after extensive AI-assisted development is valid if framed around deliberate unaided practice and measurable improvement.

## Questions for the Hiring Manager

- What decisions would this engineer be expected to lead in the first six months?
- How are technical direction and people management separated on this team?
- What creates the most delivery uncertainty today?
- How does the team balance platform standards with product-team autonomy?
- What distinguishes strong performance at this level?
- How are reliability, privacy, and developer experience prioritized when they compete with roadmap work?


---

<a id="section-4"></a>
## Section 4: behavioral-answer-bank.md

# Behavioral Answer Bank

These are reference answers, not scripts.

Preserve the decision points and evidence, then speak naturally. Replace any general wording with more precise facts when they are confirmed in the source material.

## Tell Me About a Time You Took End-to-End Ownership

> A strong example was when our small team took ownership of dealer-facing capabilities that had previously belonged to another group.
>
> The challenge was not simply implementing a new ticket. We had to understand the existing product workflows, frontend and backend code, dependent services, deployment process, and production behavior while continuing to deliver new initiatives.
>
> I worked across requirements clarification, implementation, technical discussions, frontend and backend dependencies, QA coordination, and production-readiness concerns. When I found ambiguity or edge cases, I raised them during grooming rather than allowing them to become implementation defects.
>
> The team delivered several dealer-domain initiatives during the transition. My main learning was that ownership is a system property: the feature is not complete because one code path works. The surrounding dependencies, observability, rollout, and operational understanding also need an owner.

Likely follow-ups:

- What did you personally implement?
- Which dependency was hardest to understand?
- What would you do differently during another ownership transfer?

## How Have You Led Without Formal Authority?

> During the Guardlane initiative, the technical lead was unavailable for part of the work while several product and engineering questions still needed decisions.
>
> I did not try to replace the role or make every decision alone. I focused on keeping the engineering conversation structured. I brought together the relevant product and engineering stakeholders, clarified the current working flow, identified production-readiness gaps, and separated immediate delivery questions from longer-term architecture concerns.
>
> The important topics included evaluation, fallback behavior, human review, observability, deployment, governance, and ownership boundaries between model output and marketplace policy.
>
> That work kept the initiative moving and gave stakeholders a clearer shared view of what “production ready” meant. It reinforced my view that technical leadership often means reducing uncertainty so the team can make and execute a sound decision.

Likely follow-ups:

- Which decision did you influence?
- How did you handle disagreement?
- How did you prevent meetings from replacing execution?

## Tell Me About a Failure or a Piece of Difficult Feedback

> One useful example involved a large pull request. The implementation covered a broad surface and still contained some static-analysis comments, which made the change harder to review than it should have been.
>
> The code was not the only issue. I had allowed too much implementation surface to accumulate before creating clear review boundaries.
>
> I took the feedback seriously and changed how I prepare broad work. I now decompose earlier where possible, use logical commits, write a clearer PR description, identify risk areas explicitly, include test evidence, and perform a deeper self-review of assumptions and edge cases before requesting review.
>
> The lasting result was a stronger review discipline. My question changed from “Does the code work?” to “Is this the correct solution, and have I made it safe and understandable for another engineer to review and operate?”

Do not weaken this answer by claiming the PR was secretly a success. The value is the changed behavior.

## Tell Me About a Significant Modernization Decision

> At OPENLANE, the marketplace depended on mature Oracle and Java systems while the organization needed cloud-native delivery and modern customer experiences.
>
> A complete rewrite would have combined application redesign, data migration, contract migration, production cutover, and continued feature delivery into one high-risk program.
>
> The architecture evolved incrementally instead. Oracle remained authoritative for core workflows, integration services transformed and routed legacy changes, and newer Node.js, AWS, .NET, messaging, backend-for-frontend, and frontend capabilities were introduced behind clearer boundaries.
>
> My work crossed several of those layers, including integration and shared services, the AWS SDK migration, Vehicle Detail, frontend experiences, and later AI workflows.
>
> The trade-off was that multiple technology generations had to coexist and be operated for longer. The benefit was that the business could continue running while individual boundaries were modernized and validated.
>
> The main lesson was that modernization is not a technology replacement exercise. It is the controlled evolution of ownership, contracts, compatibility, and production risk.

Likely follow-ups:

- What would trigger migration of the system of record?
- Where did the integration layer become a liability?
- How did you validate backward compatibility?

## How Do You Mentor or Onboard Engineers?

> I start with the system and business workflow rather than dropping a new engineer into an isolated code file.
>
> My preferred sequence is to explain the user or business flow, draw the architecture and request or event path, identify service ownership, show where logs and traces live, and then walk through the code related to one safe change.
>
> This gives the engineer a model for why the code exists and how to investigate it in production. During the first change, I use review questions to make assumptions visible rather than simply rewriting the solution for them.
>
> The objective is not only to help someone merge one pull request. It is to help them become independently effective within the system.

To strengthen this answer before the interview, add one specific engineer, first task, feedback moment, and observable outcome.

## How Do You Balance Delivery and Architecture?

> I treat architecture as a way to manage delivery risk, not as a separate phase that must be completed before implementation.
>
> I first identify the business outcome and the most expensive decisions to reverse. Those decisions deserve explicit design and alignment. Lower-risk details can be implemented incrementally.
>
> In modernization work, that has meant introducing compatibility boundaries and backward-compatible contracts instead of attempting a complete rewrite. In AI workflows, it has meant making fallback, review, and observability part of the initial production path rather than postponing them.
>
> I prefer small releases with clear telemetry and rollback behavior. That allows the architecture to evolve using production evidence while preserving a deliberate direction.

## Tell Me About Your Current Weakness

> One area I am actively rebuilding is unaided coding speed under interview conditions.
>
> Over the last year I have used AI-assisted development extensively. It improved throughput and gave me another review tool, but I noticed that it reduced how often I practiced retrieving standard data-structure patterns and writing complete solutions from a blank editor.
>
> I am addressing that directly through timed, no-AI coding sessions. I solve the problem, explain the invariant and complexity aloud, test it manually, and only then use Codex to review the attempt. I also re-solve missed problems from a blank editor within a few days.
>
> I do not see the lesson as “avoid AI.” The lesson is to use it without outsourcing the fundamental reasoning and execution skills that I still need to own.

This answer works because it includes a bounded weakness, its cause, and a measurable repair mechanism.

## Why Verily?

> Verily sits at the intersection of several areas that have become central to my work: platform engineering, distributed systems, production AI, modern product experiences, and healthcare software.
>
> I am particularly interested in systems where technical quality has a direct trust consequence. Workbench identity and access, governed health-data pipelines, and developer platforms all require strong boundaries, auditability, reliability, and clear operational ownership.
>
> My background includes incremental marketplace modernization, backend and frontend platform work, GCP and Terraform experience, HIPAA-sensitive healthcare engineering, and AI workflows with evaluation and human review.
>
> The role family would let me apply that breadth to a domain where responsible engineering matters, while deepening areas such as precision-health data standards and Verily’s platform architecture.

Adjust the middle paragraph for the exact role.

## Why Are You Applying to Several Roles at Verily?

> The roles emphasize different parts of the same engineering profile rather than unrelated career directions.
>
> My experience crosses backend services, React and TypeScript applications, cloud platforms, distributed systems, infrastructure, production operations, and technical leadership. The Technical Lead, Precision Health Platform, Full-Stack, and Developer Platform positions each use a different combination of those capabilities.
>
> I would not claim identical depth in every preferred technology. I am looking for the team where my platform breadth and hands-on ownership solve the most important current problems.

## What Would You Do in Your First 90 Days?

### First 30 Days

- understand users and critical workflows
- map architecture and ownership
- learn security, privacy, and compliance boundaries
- understand deployment and incident processes
- build relationships with product and adjacent engineering teams
- ship one small, low-risk improvement

### Days 31–60

- own a bounded feature or platform improvement
- participate in production support
- identify one recurring source of delivery or operational friction
- document the current system and trade-offs
- validate assumptions using telemetry and user feedback

### Days 61–90

- deliver a meaningful change through production
- propose an evidence-backed improvement to reliability, developer experience, or architecture
- contribute to reviews and onboarding
- align with the team on longer-term technical priorities

Reference answer:

> My first objective would be to understand the system before prescribing changes. I would map the critical user workflow, architecture, ownership, security boundaries, deployment path, and production telemetry. I would also ship a small change early so that I learn the real development process.
>
> By the second month I would want to own a bounded initiative and participate in production support. By 90 days, I would aim to have delivered a meaningful production improvement and developed an evidence-based view of one longer-term opportunity in reliability, developer experience, or architecture.

## Answers That Are Not Yet Ready

The current source material does not support complete, specific answers for:

- an exact production incident with mitigation and verified root cause
- a disagreement where your preferred design lost
- the Similar Listings edge case
- a concrete mentoring outcome
- a specific HIPAA-sensitive design decision
- a detailed GCP and Terraform project

Complete those facts before using the stories. Do not fill the gaps with generic process.


---

<a id="section-5"></a>
## Section 5: star-index.md

# STAR Story Index

Use this index to avoid inventing a new story during the interview.

## Core Story Map

| Interview Theme | Primary Story | Backup Story | Evidence |
| --- | --- | --- | --- |
| End-to-end ownership | Dealer OS ownership transition | Vehicle Detail BFF | Marketplace interview guide |
| Technical leadership | Guardlane coordination | onboarding and design discussions | Guardlane story |
| Architecture | Marketplace modernization | Vehicle Detail BFF | Marketplace interview guide |
| Ambiguous requirements | Similar Listings edge case | AI Upload workflow | Marketplace guide / AI Upload |
| Production reliability | distributed incident investigation | AWS SDK migration | production stories / Marketplace guide |
| Modernization | Oracle-to-cloud coexistence | enterprise search modernization | Marketplace / H&B guides |
| AI system design | Guardlane | AI Upload | Guardlane / AI Upload guides |
| Cross-functional work | Guardlane stakeholder coordination | H&B product collaboration | project guides / recommendations |
| Difficult pull request | large PR and review friction | SDK migration | Marketplace interview guide |
| Changed engineering habit | deeper self-review | PR decomposition | Marketplace interview guide |
| Mentoring | system-map onboarding | code and design reviews | Marketplace interview guide |
| Customer impact | enterprise search | Vehicle Detail experience | H&B / Marketplace guides |
| Security and privacy | healthcare platform work | Guardlane governance | healthcare experience / Guardlane |
| Learning new technology | polyglot career transitions | AWS SDK migration | career history / Marketplace guide |

## Story Cards

### Dealer Operating System Ownership

Use for:

- ownership
- learning a new domain
- delivery under pressure
- working across the stack

Proof points:

- small team
- transferred ownership
- multiple initiatives
- frontend, backend, QA, deployment, and production scope

Avoid:

- claiming every initiative personally
- using an unverified exact count as the only evidence of impact

### Guardlane Coordination

Use for:

- leading without authority
- cross-functional communication
- AI production readiness
- ambiguity

Proof points:

- working flow needed production readiness
- technical lead unavailable during part of the initiative
- coordination across product and engineering stakeholders
- reliability, evaluation, fallback, governance, and operational concerns

### Marketplace Modernization

Use for:

- architecture
- trade-offs
- long-lived systems
- incremental migration

Proof points:

- Oracle and Java legacy platform
- integration and event boundaries
- multiple cloud generations
- uninterrupted business operation

### AWS SDK Migration

Use for:

- technical execution
- risk management
- testing
- production compatibility

Proof points:

- foundational services
- client and command changes
- mocks, packaging, credentials, IAM, and runtime behavior
- production validation

### Similar Listings Requirement Edge Case

Use for:

- requirement clarification
- constructive challenge
- product collaboration
- preventing defects early

Prepare:

- the exact edge case
- the initial proposed behavior
- the question you raised
- the resulting design change

Do not use until those facts can be stated precisely.

### Large Pull Request

Use for:

- failure
- feedback
- review quality
- changed behavior

Proof points:

- broad implementation surface
- review friction
- remaining static-analysis issues
- later use of decomposition, logical commits, self-review, and explicit risk notes

### Enterprise Search

Use for:

- customer impact
- full-stack delivery
- product collaboration
- production investigation

Proof points:

- OneSearch
- Elasticsearch
- APIs
- React
- promotion and ANTLR rules
- globally distributed team

## Questions Still Requiring Exact Evidence

Before interviews, complete:

- exact incident used for the production story
- exact Similar Listings requirement edge case
- specific mentoring example and recipient outcome
- strongest Terraform project example
- strongest GCP project example
- strongest HIPAA-sensitive engineering decision
- one disagreement where your recommendation was not selected
- one verified result for AI Upload

## Story Practice Format

For each primary story, prepare:

- a one-sentence headline
- a two-minute answer
- a five-minute technical expansion
- three likely follow-up questions
- one trade-off
- one thing you would change

Do not memorize a script. Memorize the decision points and evidence.


---

<a id="section-6"></a>
## Section 6: project-deep-dives.md

# Project Deep Dives

Project explanation is already a strength. The objective is to make each project usable in progressively deeper technical interviews without over-answering the first question.

## Response Ladder

```text
30 seconds   Business problem and outcome
2 minutes    Architecture, ownership, and decision
5 minutes    Critical flow, trade-offs, and production result
Deep dive    Failure modes, alternatives, operations, and learning
```

## Primary Project Set

### 1. Marketplace Modernization

Use for:

- distributed systems
- legacy modernization
- event-driven architecture
- platform evolution
- system design
- production reliability

Primary guide:

- [Marketplace Platform Interview Guide](../projects/marketplace/07-interview-guide.md)

Questions to rehearse:

- Why not perform a big-bang rewrite?
- Why keep Oracle as the system of record?
- What did the integration layer protect?
- How were duplicate and out-of-order events handled?
- How did multiple platform generations coexist?
- What was your personal contribution?

### 2. Vehicle Detail BFF

Use for:

- API design
- frontend/backend boundaries
- partial failure
- latency
- service aggregation
- customer experience

Questions to rehearse:

- Which dependencies were required?
- Which could degrade?
- How were calls parallelized?
- What belonged in the BFF rather than domain services?
- How did tracing influence performance work?
- How would the BFF evolve at greater scale?

### 3. Guardlane

Use for:

- production AI
- MLOps
- model evaluation
- fallbacks
- human review
- governance
- technical leadership

Primary guide:

- [Guardlane Interview Guide](../projects/guardlane/14-interview.md)

Questions to rehearse:

- Why use a hybrid architecture?
- Why DistilBERT?
- Why retain deterministic rules?
- Why not use an LLM for everything?
- How were model and business-policy ownership separated?
- How would drift and disagreement be monitored?

### 4. AI Upload

Use for:

- cross-stack delivery
- AI workflow integration
- validation
- human review
- operational readiness
- product collaboration

Primary source:

- [AI Upload Story](../stories/01_OPENLANE/AI_UPLOAD.md)

Questions to rehearse:

- What was the operating workflow?
- Where could input quality fail?
- How was model uncertainty exposed?
- What required human judgment?
- What did you own?
- What remains unverified in the current documentation?

### 5. Enterprise Search

Use for:

- search architecture
- Elasticsearch
- APIs
- relevance and product discovery
- production debugging
- business rules

Primary guide:

- [Holland & Barrett Interview Guide](../projects/holland-barrett-platform/09-interview-guide.md)

Questions to rehearse:

- Why not query Elasticsearch from React?
- Why not use SQL for search?
- What is an inverted index?
- How do analyzers and tokenization affect relevance?
- How would indexing and query traffic scale?
- How did search affect the business?

### 6. Promotion Engine

Use for:

- parsing and domain rules
- ANTLR
- frontend/backend delivery
- requirements ambiguity
- stakeholder communication

Questions to rehearse:

- Why use a grammar?
- How were invalid rules reported?
- Where did validation occur?
- How were business changes tested?
- What was the relationship between the definition UI and backend evaluation?

## Five-Minute Deep-Dive Template

### Situation

Describe the system and why the business needed change.

### Constraint

Explain what made the problem difficult:

- production continuity
- legacy dependency
- uncertainty
- latency
- sensitive data
- cross-team ownership

### Architecture

Describe the critical flow and boundaries.

### Personal Ownership

State what you personally:

- analyzed
- designed
- implemented
- communicated
- operated

### Decision and Trade-Off

Name one real alternative and why it was not selected.

### Result

Use verified evidence. If a precise metric is unavailable, describe the operational or product outcome without manufacturing a number.

### Reflection

Explain what you would repeat or change.

## Deep-Dive Quality Gate

Before using a project in an interview, confirm:

- the first answer is concise
- the architecture can be drawn from memory
- personal ownership is distinct from team scope
- at least two trade-offs are available
- at least three failure modes are understood
- one production or operational example exists
- unsupported metrics have been removed
- a clear learning closes the answer


---

<a id="section-7"></a>
## Section 7: mock-interviews.md

# Mock Interviews and Scoring

Mock interviews should reproduce the constraints of the real interview:

- camera or in-person posture
- blank editor or whiteboard
- no AI assistance
- fixed time
- explanation aloud
- follow-up questions

## Coding Mock — 45 Minutes

### Structure

- 0–5: clarify and work an example
- 5–10: derive the approach
- 10–32: implement
- 32–40: test and correct
- 40–45: complexity and follow-ups

### Scoring

Score 0–3:

| Category | Score |
| --- | --- |
| Problem clarification | |
| Algorithm selection | |
| Correctness | |
| Code quality | |
| Testing | |
| Complexity | |
| Communication | |

Pass target:

- no zero
- correctness at least 2
- total at least 15/21

## System-Design Mock — 45 Minutes

Randomly choose:

- Workbench identity and accounts
- precision-health data platform
- developer platform
- microfrontend platform
- Guardlane
- enterprise search

Use the rubric in [System Design](system-design.md).

Pass target:

- average at least 2
- no zero in security, reliability, trade-offs, or communication

## Technical-Depth Mock — 45 Minutes

### Round 1 — Core Engineering

- Java or Node.js
- APIs
- SQL
- distributed systems

### Round 2 — Target Role

Select one:

- IAM and HIPAA
- GCP and health-data pipelines
- Kubernetes, Terraform, and GitOps
- React, TypeScript, and microfrontends

### Round 3 — Production

- incident investigation
- observability
- rollout
- rollback
- capacity
- cost

Score each answer:

```text
0  incorrect or unable to engage
1  vocabulary without mechanism
2  correct mechanism and reasonable example
3  correct mechanism, trade-off, and production consequence
```

Pass target: average at least 2.

## Hiring-Manager Mock — 45 Minutes

Questions:

1. Tell me about yourself.
2. Why Verily?
3. Why this role?
4. Tell me about a technically ambiguous initiative.
5. Describe a design decision you influenced.
6. Describe a disagreement.
7. Describe a failure or changed opinion.
8. How do you mentor?
9. How do you balance delivery and architecture?
10. What would you want to understand in your first 30 days?

Evaluate:

- directness
- evidence
- personal ownership
- trade-offs
- reflection
- role alignment

## Communication Rubric

Score 0–3:

| Dimension | 0 | 1 | 2 | 3 |
| --- | --- | --- | --- | --- |
| Structure | incoherent | answer emerges late | clear sequence | concise headline and adaptive depth |
| Reasoning | hidden | conclusions only | reasoning visible | assumptions and alternatives explicit |
| Collaboration | defensive | waits for prompts | responds productively | actively aligns with interviewer |
| Precision | exaggerated | vague | accurate | distinguishes facts, inference, and uncertainty |
| Ownership | unclear | team-only language | personal role clear | contribution tied to system outcome |
| Trade-offs | absent | generic | concrete | technical and organizational consequences |

## Error Log

After every mock:

| Moment | What happened? | Miss type | Better response | Repair exercise | Re-test date |
| --- | --- | --- | --- | --- | --- |
| | | | | | |

Miss types:

- knowledge
- recognition
- execution
- testing
- communication
- time management
- confidence

## Codex Review Prompt

Use this only after completing the mock:

```text
Act as a senior engineering interviewer.

Review this transcript without rewriting it into a perfect answer.

Score:
- technical correctness
- problem solving
- senior-level trade-off reasoning
- communication
- personal ownership
- production awareness

Identify:
1. the first point where the answer weakened
2. missing clarification questions
3. unsupported claims
4. missed failure modes
5. one exercise that would repair the underlying gap
```
