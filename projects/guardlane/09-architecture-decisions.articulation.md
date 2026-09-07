# Guardlane Architecture Decisions — Articulation Companion

Source: [Architecture Decisions (ADRs)](./09-architecture-decisions.md)

This is not a second ADR. It practices expressing selected Guardlane decisions at different levels of compression and for different engineering audiences.

## Hybrid moderation architecture

### Core technical position

No single moderation mechanism fit all production cases efficiently. The architecture therefore specializes the decision path: deterministic patterns are handled deterministically, supported semantic moderation uses the trained classifier, and unsupported-language cases use an LLM fallback. The trade-off is additional routing/orchestration complexity in exchange for specialization across latency, cost and capability.

### 30-second explanation

The problem wasn't simply choosing the most capable model; it was choosing the right moderation mechanism for each class of request. Deterministic patterns don't require probabilistic inference, the trained classifier gives predictable and measurable English moderation, and the LLM covers languages the classifier doesn't support. We accepted orchestration complexity to avoid paying the latency and cost of an LLM for every request.

### Design-meeting version

An LLM-first and a classifier-first architecture are both simpler conceptually, but each forces one engine to handle cases where another mechanism has a better fit. I recommend preserving the hybrid boundary while those workloads remain meaningfully different. The cost is routing and normalization complexity; the benefit is that each engine can evolve against the problem it is responsible for.

### PR-review version

Keep engine-specific behavior behind the moderation boundary. Exposing regex/classifier/LLM details to consumers would couple integrations to the current implementation and make future engine changes harder.

### Likely challenges

**Why not use an LLM for everything?**  
Because capability alone isn't the only constraint. For stable, labeled English moderation, the classifier provides faster, cheaper and more predictable inference with repeatable evaluation. The LLM remains useful where the classifier's capability boundary is explicit.

**Why not send low-confidence English predictions to the LLM?**  
Low confidence and unsupported capability are different conditions. Language-aware routing handles a known capability boundary. Confidence-based escalation would require its own calibrated policy and evidence that escalation improves the desired outcome.

**What breaks?**  
The hybrid design introduces orchestration failure modes: incorrect routing, inconsistent engine outputs, fallback availability and contract normalization. Those risks belong at the orchestration boundary rather than being leaked to consumers.

**What would make you reconsider the architecture?**  
A material change in model capability, latency/cost economics, taxonomy stability, language requirements, or evidence that one engine can meet the same reliability and evaluation requirements with materially lower system complexity.

### Interview-story version

We started from a moderation problem where different request classes had different characteristics. The key architectural realization was that model capability wasn't the only optimization target: deterministic patterns, stable English semantic classification and unsupported languages had different cost, latency and evaluation profiles. We chose a hybrid architecture rather than forcing everything through one model. That improved specialization but introduced orchestration complexity, so we normalized outputs behind one service contract and kept product policy outside model prediction. The lesson was to design around capability boundaries and operational constraints rather than around a preferred AI technology.

### Stakeholder version

We avoided using the most expensive AI path for every request. The system routes each request to the moderation mechanism best suited to it while presenting one consistent result to the product. That keeps moderation responsive and cost-conscious while still supporting cases the primary model cannot handle.

---

## Separate prediction from business policy

### Core technical position

The moderation service should return evidence; the consuming product should own the user-facing action. This preserves a boundary between probabilistic prediction and business policy, allowing either side to evolve without requiring the other to be retrained or redeployed for every policy change.

### 30-second explanation

The model answers, “What moderation evidence do we see?” It should not decide, “What should the product do to this user?” Keeping allow/warn/block policy in the product prevents business rules from becoming embedded in model behavior and lets policy change independently of retraining.

### Design-meeting version

I recommend keeping prediction and enforcement as separate ownership boundaries. Putting allow/warn/block inside the AI service looks simpler initially, but couples product policy to the model lifecycle. The trade-off is that the consumer has some policy logic; that's acceptable because policy belongs to that domain.

### PR-review version

This looks like product policy rather than prediction logic. I'd keep it in the consuming domain so a policy change doesn't require changing the moderation engine contract or model lifecycle.

### Likely challenges

**Doesn't this duplicate logic across consumers?**  
It can if multiple consumers truly share the same policy. That would justify a policy abstraction, but it still doesn't imply that enforcement belongs inside the prediction model/service.

**What invariant does the boundary protect?**  
A prediction remains evidence, not a user-facing business action. Consumers can interpret that evidence according to their own policy while the moderation contract remains stable.

### Stakeholder version

The AI identifies risk signals; the product decides the customer experience. That means business policy can change without retraining the model and the AI team doesn't become the owner of product rules.
