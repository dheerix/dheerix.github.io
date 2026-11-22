# Foci

## Working hypothesis

Prioritize AI coding agents, context engineering, architecture judgment, and
evaluation/testing discipline. Validate this against the current role and loop.

## Best evidence from the shared system

- Explicit workflow-versus-agent boundary
- Typed tool contracts and constrained permissions
- Context selection strategy and trace
- Evaluation harness with adversarial cases
- ADRs that show alternatives and reversibility

## Questions to rehearse

1. Design an agent that changes a repository safely from a natural-language task.
2. Decide what repository context to provide under a strict token budget.
3. Detect whether a change is correct beyond tests merely passing.
4. Recover safely when an agent partially edits a workspace or a tool fails.
5. Evaluate an agent across correctness, cost, latency, and intervention rate.

## Unknowns to resolve

- [ ] Exact interview stages and duration
- [ ] Live coding versus architecture emphasis
- [ ] Agent frameworks or model providers in scope
- [ ] Expected depth in evaluation/research concepts
- [ ] Product scenarios used in interviews
