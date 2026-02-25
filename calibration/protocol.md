# Calibration Protocol
*The architecture for monitoring the gap between declared self and observed self*

---

## The Core Problem

Your AMAI config and your AI session behaviour solve different problems:

**Config** answers: *Who am I, and how should I act?*
**Session behaviour** answers: *What have I actually been doing, and what did I respond well to?*

The first is intentional architecture. The second is behavioural observation. Both are valuable, but they can diverge — and when they do, it matters which direction the correction goes.

If session observations show you've been making decisions that contradict your heuristics, there are two interpretations:
1. The heuristics are wrong and your instincts have evolved → update the config
2. You've been drifting from your principles under pressure → correct the behaviour

Treating all divergence as "the config needs updating" is how values erode. Treating all divergence as "I've drifted" is how systems become rigid and out of date. This protocol distinguishes between them.

---

## The Four Divergence Types

### TYPE 1: Values (`type: values`)
Divergence involving core values, secondary values, or ethical red lines.

**Sources:** Pattern signals, session observations, direct decision observation
**Config refs:** `identity/values.yaml`

**Default disposition:** WARNING unless the observation clearly strengthens (rather than softens) values.

**Rule:** Ethical red lines are never candidates for revision through observed behaviour alone. If a red line needs revisiting, that is a deliberate, explicit decision made in a calm moment — not a calibration action.

---

### TYPE 2: Identity (`type: identity`)
Divergence involving voice, story, communication style, or self-presentation.

**Sources:** Friction signals, positive signals, inference signals
**Config refs:** `identity/voice.md`, `identity/story.md`, `identity/principles.md`

**Default disposition:** CANDIDATE — identity evolves and the config should reflect that, but always reviewed.

---

### TYPE 3: Operational (`type: operational`)
Divergence involving heuristics, workflows, decision patterns, or working habits.

**Sources:** Override signals, pattern signals, session outcome patterns
**Config refs:** `identity/heuristics.yaml`, `operations/workflows.md`, `goals/current_focus.yaml`

**Default disposition:** DEFER until pattern is clear (3+ signals), then CANDIDATE or WARNING depending on values alignment.

---

### TYPE 4: Relational (`type: relational`)
Divergence involving network priorities, contact management, or relationship rhythms.

**Sources:** Pattern signals, interaction frequency observation
**Config refs:** `network/circles.yaml`, `network/rhythms.yaml`

**Default disposition:** CANDIDATE — relationship reality often differs from planned structure, and the config should reflect reality.

---

## The Divergence Spectrum

```
                  HIGH FREQUENCY
                       │
        DRIFT ZONE     │     EVOLUTION ZONE
   (behaviour is off)  │  (config is outdated)
                       │
VALUES ────────────────┼──────────────── OPERATIONAL
CRITICAL               │               LOW STAKES
                       │
        WARNING ZONE   │     CALIBRATION ZONE
   (urgent, check now) │  (routine tune-up)
                       │
                  LOW FREQUENCY
```

- **Top left (DRIFT ZONE):** Frequent divergence from values → active WARNING, course-correct
- **Top right (EVOLUTION ZONE):** Frequent divergence in operational patterns → likely CANDIDATE
- **Bottom left (WARNING ZONE):** Rare but values-adjacent divergence → log and watch carefully
- **Bottom right (CALIBRATION ZONE):** Occasional operational divergence → routine CANDIDATE, low urgency

---

## When to Run Calibration

| Trigger | Depth |
|---|---|
| After any notable session | Quick scan — log any new signals |
| Monthly review | Full review of `pending_review.md`, disposition all items |
| Quarterly review | Deep review — check `divergence.jsonl` for meta-patterns |
| After any significant decision | Values check: did the decision align with declared config? |

---

## Meta-Patterns to Watch

Beyond individual divergences, watch for patterns *across* divergences:

- **Repeated exceptions to the same heuristic** → heuristic may need an exception clause, not deletion
- **Divergence clustering around one domain** → possible stress in that area
- **Long periods with no divergence** → either excellent coherence or the system isn't being used
- **High CANDIDATE rate** → config is out of date; schedule a refresh session
- **High WARNING rate** → values are under pressure; examine root causes, not just symptoms

---

*The goal is not a system where observed and declared always match. It's a system where you always know when they don't — and can choose what to do about it.*
