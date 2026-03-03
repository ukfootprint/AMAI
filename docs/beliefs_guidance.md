# beliefs_guidance.md
# Writing Good Beliefs — AMAI Identity Module

---

## Beliefs vs Values vs Heuristics

| File | The question it answers | Example |
|------|------------------------|---------|
| `values.yaml` | What do I care about? | "I care about long-term client relationships over short-term revenue." |
| `heuristics.yaml` | What do I do in X situation? | "If a client can't explain what they want in one sentence, they don't know yet." |
| `beliefs.yaml` | What do I think is actually true? | "Most strategy failures are execution failures — the strategy was fine." |

The test: if it's a *preference or commitment*, it's a value. If it's a *rule of action*,
it's a heuristic. If it's a *claim about how reality works*, it's a belief.

---

## Confidence Tiers

**Foundational** — rarely changes; shapes how you see everything else. If this belief
were wrong, your worldview would need significant revision.

**Held** — strong conviction, but you've updated similar beliefs before and would again
given compelling evidence. An active prior, not an axiom.

**Working** — current best understanding; still gathering evidence, expecting to revise.
Surface as a hypothesis, not a conclusion.

---

## Common Mistakes

**Too vague:** "I believe people matter most." Can't inform a decision. Push to the
specific claim: what specifically is true about people that others might disagree with?

**Actually a value:** "I believe in doing the right thing." If it's a commitment or
priority, put it in values.yaml. The word "believe" doesn't make it a belief.

**Actually a fact:** "I believe the market is growing." That's observable — not a
contested claim worth tracking. Beliefs should be where reasonable people can disagree.

**Actually a heuristic:** "I believe you should always get a written contract." That's
a rule of action — it belongs in heuristics.yaml.

**Too broad:** "I believe organisations are complex." Push deeper: "I believe most
organisation complexity is self-inflicted through poor prioritisation at the top."

---

## When to Review

Review quarterly, or when evidence directly challenges a belief. Key triggers:
- A project outcome contradicted a declared belief
- You significantly shifted your view after reading or experience
- A belief surfaced as a calibration divergence (Type 2: Identity)

Update `last_tested` after any meaningful review, even if the belief is unchanged.

---

## How Beliefs Feed Into Calibration

If the AI observes you making decisions that contradict a declared belief, or you
adjust a belief mid-session, this surfaces as a **Type 2: Identity** divergence in
calibration. This is intentional — beliefs should influence how the AI reasons on
your behalf. See `calibration/protocol.md` for the divergence taxonomy.

---

*Related: `identity/beliefs.yaml`, `schemas/beliefs.schema.json`, `calibration/protocol.md`*
