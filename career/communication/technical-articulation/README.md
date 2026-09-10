# Technical Articulation

> **Depth × Articulation = Demonstrated Technical Capability**

This area turns real engineering knowledge and decisions into clearer technical expression. It is not a communication curriculum, roadmap, dashboard, or daily tracker.

The practice loop is:

```text
Engineering thought
    ↓
Precise technical language
    ↓
Clear position
    ↓
Reasoning / trade-off
    ↓
Recommendation
```

## Source real engineering work

Start from artifacts that already exist: ADRs, architecture decisions, production incidents, PR/design decisions, debugging investigations, AI/ML decisions, system trade-offs and retrospectives. Do not manufacture architecture scenarios merely for practice.

When a real decision is worth practicing, express it in whichever forms are useful—not necessarily all of them.

### Architecture / ADR

**Context → Constraint → Options → Decision → Trade-off → Consequence**

> We selected X because A and B. Y would simplify C, but introduces D. Given constraint E, I recommend X.

### PR review

**Observation → Technical consequence → Recommendation**

> This couples X's lifecycle to Y. I'd keep this boundary at Z so the two can evolve independently.

### Design discussion

**Options → Position → Reason → Trade-off**

> Both approaches are viable. I recommend X because __. The trade-off is __, which is acceptable here because __.

### Technical challenge / defence

Be ready to answer concisely: Why X? Why not Y? What breaks? What assumption are we making? What happens at scale? What is the failure mode? What would make us reconsider?

The goal is reasoning, not defensiveness.

### 30-second explanation

**Problem → Constraint → Decision → Why**

Make it understandable to an engineer with little project context.

### Technical storytelling

**Context → Tension/ambiguity → Options → Decision → Trade-off → Result → Learning/change**

Keep engineering reasoning central rather than forcing it into a generic STAR format.

### Stakeholder / leadership explanation

**Problem → Risk → Decision → Business/product consequence**

Remove implementation detail that the audience does not need without removing the reasoning.

## Companion artifacts

An important ADR may optionally have an articulation companion, for example:

```text
guardlane-<decision>.md
guardlane-<decision>.articulation.md
```

A companion should reference the source decision rather than reproduce it. Useful sections are: core technical position, 30-second explanation, design-meeting version, PR-review version, likely challenges, defence/reasoning, interview-story version and stakeholder version.

Do **not** create one for every ADR. Create one when the decision is important enough to discuss, defend, teach or reuse.

## Language patterns

Keep the vocabulary library small and evidence-led. Add terminology only when it arises from real work. See [language-patterns.md](./language-patterns.md).

The recurring test is simple:

> **Am I expressing the engineering judgment I already possess more clearly?**

## Applied articulation

- [Guardlane business-impact investigation](../../../projects/guardlane/18-business-impact-investigation.md#interview-articulation) — explaining a post-production business signal through hypothesis, counterfactual analysis, correlation-versus-causation discipline, and controlled validation.
