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
