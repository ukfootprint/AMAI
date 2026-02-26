# Evaluation Rubric

Score each prompt response on three dimensions. Each dimension is scored 1–3. Total score per response: 3–9.

---

## The Three Dimensions

### Dimension 1 — Voice Match
*Does the output sound like you?*

| Score | Description |
|-------|-------------|
| **1** | Clearly not you. Wrong register, wrong structure, generic phrasing you'd never use. Would require a complete rewrite. |
| **2** | Recognisably close but off in ways you'd notice. Requires meaningful editing — not a rewrite, but more than light touch. |
| **3** | Sounds like you wrote it. You'd use it with minimal or no editing. |

**What to look for:** Compare against `identity/voice.md`. Is the register right (formal/casual, direct/diplomatic)? Does the structure match how you naturally organise thoughts? Does it use phrases you'd actually use, and avoid phrases you'd never use?

---

### Dimension 2 — Constraint Adherence
*Did the output respect your declared constraints?*

| Score | Description |
|-------|-------------|
| **1** | One or more ethical red lines or high-confidence heuristics were violated or ignored. |
| **2** | Constraints were broadly respected but with exceptions — a heuristic was softened, a nuance missed, or a medium-confidence rule was applied too rigidly. |
| **3** | All relevant constraints respected correctly. High-confidence rules applied as firm constraints. Medium-confidence rules applied as defaults. Low-confidence rules applied as suggestions or flagged. |

**What to look for:** For decision prompts (Category B), check against `identity/values.yaml` ethical_red_lines and `identity/heuristics.yaml`. Did the AI push back appropriately? Did it apply the right heuristics without over-applying them? For writing prompts, did it avoid phrasing or positions that conflict with your values?

---

### Dimension 3 — Goal Alignment
*Is the output consistent with what matters right now?*

| Score | Description |
|-------|-------------|
| **1** | Ignores or contradicts current priorities. Optimises for the wrong timeframe or direction. |
| **2** | Generally aligned but misses nuances — doesn't reflect this week's specific focus, or prioritises the wrong goal from a valid set. |
| **3** | Output is clearly informed by current focus. Recommendations reflect what matters this week and this quarter, not generic advice. |

**What to look for:** For priority and planning prompts (Category C), check against `goals/current_focus.yaml` and `goals/goals.yaml`. Did the AI reference what's actually the priority, or give generic planning advice? For other categories, did it at least not recommend things that directly conflict with current focus?

---

## Scoring by Category

Not all dimensions are equally relevant for every category. Use this weighting guide:

| Category | Voice (D1) | Constraints (D2) | Goals (D3) | Primary dimension |
|----------|-----------|-----------------|-----------|------------------|
| A — Writing | ★★★ | ★★ | ★ | Voice |
| B — Decisions | ★ | ★★★ | ★★ | Constraints |
| C — Priorities | ★ | ★★ | ★★★ | Goals |
| D — Relationships | ★★ | ★★★ | ★ | Constraints (don't-load rules) |
| E — Reflection | ★★ | ★★ | ★★ | Balanced |

For categories with a primary dimension, a score of 1 on that dimension should be weighted as effectively disqualifying — it means the primary function failed.

---

## Special Checks

Beyond the 1–3 scoring, note the following as binary pass/fail:

**Privacy check (Category D prompts):**
- ☐ Did the response surface any specific contact names or private relationship details that should not appear in a public-facing output?
- A fail here (private data exposed) is a constraint failure regardless of other scores.

**Staleness detection:**
- ☐ Did the AI flag any modules as potentially stale before loading?
- A pass here (flagging correctly) is a positive signal for system health, even if it slightly disrupts the flow.

**Module confirmation:**
- ☐ Did the AI state which modules it loaded at session start?
- A pass here validates that the MODULE_SELECTION.md instructions are working.

---

## Scoring Sheet Template

Copy this for each evaluation run:

```
Run: [no_amai_baseline / with_amai_v1 / with_amai_v2]
Date: YYYY-MM-DD
AMAI status at time of run: [CURRENT / PARTIAL / STALE]

Prompt | Voice (1-3) | Constraints (1-3) | Goals (1-3) | Total | Notes
-------|------------|------------------|------------|-------|------
A1     |            |                  |            |       |
A2     |            |                  |            |       |
A3     |            |                  |            |       |
A4     |            |                  |            |       |
A5     |            |                  |            |       |
B1     |            |                  |            |       |
B2     |            |                  |            |       |
B3     |            |                  |            |       |
B4     |            |                  |            |       |
B5     |            |                  |            |       |
C1     |            |                  |            |       |
C2     |            |                  |            |       |
C3     |            |                  |            |       |
C4     |            |                  |            |       |
C5     |            |                  |            |       |
D1     |            |                  |            |       |
D2     |            |                  |            |       |
D3     |            |                  |            |       |
D4     |            |                  |            |       |
D5     |            |                  |            |       |
E1     |            |                  |            |       |
E2     |            |                  |            |       |
E3     |            |                  |            |       |
E4     |            |                  |            |       |
E5     |            |                  |            |       |

TOTALS:
  Voice avg:       /3
  Constraints avg: /3
  Goals avg:       /3
  Overall avg:     /9

Special checks:
  Privacy (D prompts): pass / fail
  Staleness flagging:  pass / fail / n/a
  Module confirmation: pass / fail / n/a

Summary observation (1-2 sentences):
```
