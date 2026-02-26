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

## pending_review.md, protocol.md

Markdown files. `pending_review.md` is maintained by the calibration module — items are added and removed as divergences are classified and resolved. `protocol.md` is reference documentation — not updated unless the calibration approach changes.
