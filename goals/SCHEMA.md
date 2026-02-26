# goals/ — Schema Reference

---

## goals.yaml

**Schema version:** 1.0

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `_schema` | string | yes | `"goals"` |
| `_version` | string | yes | `"1.0"` |
| `goals[].id` | string | yes | Snake_case, unique — e.g. `goal_1` |
| `goals[].label` | string | yes | One-line goal description |
| `goals[].status` | string | yes | `active` \| `on_hold` \| `completed` \| `abandoned` |
| `goals[].horizon` | string | yes | Timeframe — e.g. `Q1 2026` |
| `goals[].why` | string | yes | Why this goal matters |
| `goals[].key_results` | list of strings | yes | Measurable outcomes (min 1) |
| `goals[].constraints` | list of strings | no | Constraints on how goal is pursued |
| `goals[].notes` | string | no | Free text |
| `last_updated` | ISO 8601 date or null | yes | Format: `YYYY-MM-DD` |

**Example entry:**
```yaml
- id: goal_1
  label: "Launch v1 to first 10 customers"
  status: active
  horizon: "Q2 2026"
  why: >
    First revenue validates the model and funds the next build cycle.
  key_results:
    - "10 signed contracts by end of quarter"
    - "NPS > 7 from first cohort"
  constraints:
    - "No discounting to win early customers"
  notes: ""
```

---

## current_focus.yaml

**Schema version:** 1.0

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `_schema` | string | yes | `"current_focus"` |
| `_version` | string | yes | `"1.0"` |
| `week_of` | ISO 8601 date or null | yes | Monday of current week — `YYYY-MM-DD` |
| `last_updated` | ISO 8601 date or null | yes | AI flags if null or > 7 days ago |
| `priorities[].rank` | integer | yes | Positive integer; 1 = highest |
| `priorities[].item` | string | yes | What must get done this week |
| `priorities[].goal_ref` | string or null | yes | References `id` in `goals.yaml` |
| `priorities[].why_now` | string | no | Why this is the priority this specific week |
| `not_this_week` | list of strings | yes | Explicitly parked items |
| `the_one_thing` | string | yes | Single most critical outcome if nothing else gets done |

---

## north_star.md, deferred_with_reason.md

Markdown narrative files. No fixed schema — structured by template. `deferred_with_reason.md` requires a `Why not now` entry for every item (enforced by convention, not validation).
