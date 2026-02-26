# memory/ — Schema Reference

All memory files are append-only JSONL logs. Never edit or delete existing entries. To correct a past entry, append a new entry with a `supersedes` field referencing the original.

---

## decisions.jsonl

**Schema version:** 1.0

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `date` | ISO 8601 date | yes | Format: `YYYY-MM-DD` |
| `decision` | string | yes | One sentence: what you decided |
| `context` | string | yes | What situation led to this decision |
| `options_considered` | list of strings | yes | Alternatives considered and why you didn't choose them |
| `reasoning` | string | yes | Why you made this choice — honest, not polished |
| `values_applied` | list of strings | no | References `id` values in `identity/values.yaml` |
| `outcome` | string or null | no | What happened — fill in later |
| `would_decide_same` | boolean or null | no | Retrospective assessment — fill in later |
| `notes` | string | no | Free text |

**Example entry:**
```jsonl
{"date": "2026-01-15", "decision": "Declined partnership with Acme Corp despite significant revenue potential", "context": "Acme approached us about a white-label deal; terms required exclusivity", "options_considered": ["Accept with exclusivity clause — rejected: limits strategic options for 3 years", "Negotiate non-exclusive — they declined"], "reasoning": "Exclusivity conflicts with long_term_thinking value. Short-term revenue not worth long-term constraint.", "values_applied": ["long_term_thinking", "integrity_honesty"], "outcome": null, "would_decide_same": null, "notes": ""}
```

---

## failures.jsonl

**Schema version:** 1.0

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `date` | ISO 8601 date | yes | Format: `YYYY-MM-DD` |
| `what_failed` | string | yes | One sentence: what went wrong |
| `context` | string | yes | What you were trying to do and why |
| `what_i_did` | string | yes | What you actually did |
| `what_went_wrong` | string | yes | What happened and why — be specific |
| `warning_signs_missed` | list of strings | yes | Signs that were present but ignored |
| `what_id_do_differently` | string | yes | Specific behavioural changes |
| `emotional_weight` | string | yes | `high` \| `medium` \| `low` |
| `lesson` | string | yes | The one thing to take forward |
| `notes` | string | no | Free text |

---

## experiences.jsonl

**Schema version:** 1.0

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `date` | ISO 8601 date | yes | Format: `YYYY-MM-DD` |
| `title` | string | yes | Short name for this experience |
| `what_happened` | string | yes | The facts |
| `why_it_matters` | string | yes | Why this experience was significant |
| `how_it_changed_you` | string | yes | What shifted in how you think or act |
| `emotional_weight` | string | yes | `high` \| `medium` \| `low` |
| `tags` | list of strings | no | e.g. `["formative", "professional", "personal"]` |
| `notes` | string | no | Free text |
