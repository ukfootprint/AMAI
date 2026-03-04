# calibration/ — Schema Reference

---

## divergence.jsonl

**Schema version:** 1.0 (append-only log)

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `date` | ISO 8601 date | yes | Format: `YYYY-MM-DD` |
| `type` | string | yes | `values` \| `identity` \| `operational` \| `relational` |
| `source` | string | yes | `signals_override` \| `signals_friction` \| `signals_pattern` \| `signals_inference` \| `other` |
| `signal` | string | yes | What was observed (from signals/observations.jsonl) |
| `brained_ref` | string | yes | Path to the relevant config file and field — e.g. `identity/heuristics.yaml → no_discount_growth` |
| `tension` | string | yes | Plain English description of the divergence |
| `disposition` | string | yes | `CONFIRM` \| `CANDIDATE` \| `WARNING` \| `DEFER` \| `INCORPORATED` \| `REJECTED` |
| `notes` | string | no | Free text — reasoning, context, decision rationale |

**Disposition semantics:**
- `CONFIRM` — observed matches declared; validation signal
- `CANDIDATE` — possible config improvement; requires 3-session promotion rubric
- `WARNING` — behaviour diverging from values; config is correct, behaviour needs correction
- `DEFER` — insufficient data; monitor for recurrence
- `INCORPORATED` — CANDIDATE reviewed and incorporated; config updated
- `REJECTED` — CANDIDATE or WARNING reviewed; config unchanged

**Example entry:**
```jsonl
{"date": "2026-03-01", "type": "operational", "source": "signals_override", "signal": "Rejected AI suggestion to include discount offer in proposal — third time this month", "brained_ref": "identity/heuristics.yaml → no_discount_growth", "tension": "Heuristic is marked high-confidence and is being consistently applied. This confirms the rule.", "disposition": "CONFIRM", "notes": "Pattern consistent with declared heuristic. No action needed."}
```

---

## metrics.yaml

**Schema version:** 1.0

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `signal_volume.total_observations` | integer | yes | Running total |
| `signal_volume.by_type.*` | integer | yes | Counts per signal prefix type |
| `signal_volume.sessions_with_no_signal` | integer | yes | Running count |
| `divergence_volume.total_detected` | integer | yes | Running total |
| `divergence_volume.by_disposition.*` | integer | yes | Counts per disposition |
| `divergence_volume.pending_review_count` | integer | yes | Current pending items |
| `overrides_by_domain` | map of string→integer | no | Domain-keyed override counts |
| `module_load_frequency.*` | integer | yes | Counts per module |
| `learning_log.total_entries` | integer | yes | Running total |
| `learning_log.by_type.*` | integer | yes | Counts per learning type |
| `review_history[].date` | ISO 8601 date or null | yes | Date of review |
| `review_history[].signals_reviewed` | integer | yes | Signals processed in this review |
| `review_history[].health_note` | string | no | One-line system health observation |
| `last_updated` | ISO 8601 date or null | yes | Updated at each monthly review |

---

## entry_references.jsonl

**Schema version:** 1.0 (append-only log)
**JSON Schema:** `schemas/entry_references.schema.json`

### What it tracks

Explicit, observable interactions with specific AMAI entries at five defined action touchpoints:

1. **Conscience alerts** — which `red_line_id` or `heuristic_id` fired during a session
2. **Critique framework usage** — which named frameworks, values, or heuristics were applied as critique lenses
3. **Calibration touches** — which specific entries were reviewed or updated during a calibration session
4. **Goal status changes** — which `goal_id` changed status (active → complete/deferred/abandoned)
5. **Belief challenges** — which `belief_id` was challenged by evidence during a session

### What it does NOT track

Passive LLM reference — what the model happened to "think about" when loading a file. This file only captures deterministic, auditable events where a specific entry's `id` field participated in a logged action. No inference about LLM reasoning is attempted.

### How it's populated

Automatically appended by:
- `skills/conscience/SKILL.md` — when red line alerts or heuristic notices fire
- `skills/critique/SKILL.md` — when frameworks, values, or heuristics are explicitly applied as lenses
- `commands/calibrate.md` — when specific entries are reviewed or updated during calibration
- `commands/goal-update.md` — when a goal status changes

### How it's consumed

- `scripts/usage_report.sh` — "Entry Reference Summary" section shows per-entry reference counts and identifies entries with zero references
- `scripts/prune_report.sh` — "Entry Reference Analysis" section uses this data in pruning recommendations (stale AND unreferenced = strongest prune signal)

### Schema fields

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `date` | ISO 8601 date | yes | Format: `YYYY-MM-DD` |
| `entry_id` | string | yes | Must exactly match the `id` field in the source file — pattern `^[a-z][a-z0-9_]*$` |
| `entry_type` | string | yes | `red_line` \| `heuristic` \| `framework` \| `goal` \| `belief` \| `value` |
| `source_file` | string | yes | Relative path, e.g. `identity/values.yaml` |
| `event` | string | yes | `conscience_alert` \| `conscience_heuristic` \| `critique_applied` \| `calibration_reviewed` \| `calibration_updated` \| `goal_status_change` \| `belief_challenged` |
| `context` | string | yes | Brief description of the session/task (min 10 chars) |
| `outcome` | string | no | `fired` \| `applied` \| `reviewed` \| `updated` \| `completed` \| `deferred` \| `challenged` \| `confirmed` \| `dismissed` |

**Example entry:**
```jsonl
{"date": "2026-03-15", "entry_id": "integrity_honesty", "entry_type": "value", "source_file": "identity/values.yaml", "event": "calibration_reviewed", "context": "Monthly calibration — identity/values review", "outcome": "confirmed"}
```

---

## pending_review.md, protocol.md

Markdown files. `pending_review.md` is maintained by the calibration module — items are added and removed as divergences are classified and resolved. `protocol.md` is reference documentation — not updated unless the calibration approach changes.
