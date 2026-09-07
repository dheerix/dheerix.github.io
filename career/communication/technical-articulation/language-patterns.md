# Technical Language Patterns

A small pattern library for making engineering thoughts precise. This is intentionally not a glossary.

| Vague thought | More precise technical expression |
| --- | --- |
| This could cause issues. | This introduces a failure mode where __. |
| These are tightly connected. | This couples X's lifecycle to Y. |
| Maybe we can do this later. | I'd defer this because it isn't on the critical path. |
| I think this is better. | I recommend X because __. The primary trade-off is __. |
| I don't know. | I haven't validated that assumption yet. My current expectation is X because Y; I'll verify Z. |
| This is getting complicated. | This increases implementation/operational complexity because __. |
| This could affect everything. | This increases the blast radius because __. |
| This may be slow. | The likely bottleneck is __; it adds latency on __ / constrains throughput at __. |
| We need to be careful changing this. | This contract requires backward compatibility because __. I'd migrate by __. |
| This service should own it. | X should own this invariant/state because __. Keeping the boundary here avoids __. |

## Concepts to reach for when they describe the actual problem

**Boundaries:** coupling, cohesion, ownership, contracts, invariants.

**Runtime behaviour:** failure modes, bottlenecks, latency, throughput, consistency, resilience, observability.

**Evolution:** scalability, complexity, operational cost, blast radius, backward compatibility, migration.

**Reasoning:** constraints, assumptions, alternatives, trade-offs.

Do not use terminology to sound technical. Use it when it makes the causal relationship or engineering position more exact.
