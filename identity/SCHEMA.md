# identity/ — Schema Reference

---

## values.yaml

**Schema version:** 1.0 (`_version` field)

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `_schema` | string | yes | `"values"` |
| `_version` | string | yes | `"1.0"` |
| `core_values[].id` | string | yes | Snake_case identifier, unique |
| `core_values[].label` | string | yes | Human-readable label |
| `core_values[].priority` | integer | yes | Positive integer; lower = higher priority |
| `core_values[].description` | string | yes | Multi-line text |
| `core_values[].in_practice` | list of strings | yes | Concrete behavioural examples |
| `core_values[].test` | string | yes | A decision-making question |
| `secondary_values[].id` | string | yes | Snake_case identifier |
| `secondary_values[].label` | string | yes | Human-readable label |
| `secondary_values[].description` | string | yes | Multi-line text |
| `ethical_red_lines` | list of strings | yes | Absolute constraints — no justification overrides |
| `last_updated` | ISO 8601 date or null | yes | Format: `YYYY-MM-DD` |

**Example entry:**
```yaml
- id: integrity_honesty
  label: Integrity & Honesty
  priority: 1
  description: >
    The most sustainable foundation for any relationship is trust.
  in_practice:
    - Never overstate capability
    - Admit mistakes early
  test: "Would I be comfortable if this decision were made public?"
```

---

## heuristics.yaml

**Schema version:** 1.0

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `_schema` | string | yes | `"heuristics"` |
| `_version` | string | yes | `"1.0"` |
| `universal[].id` | string | yes | Snake_case, unique within file |
| `universal[].rule` | string | yes | The heuristic as a one-sentence rule |
| `universal[].use_when` | string | yes | When to apply this rule |
| `universal[].source` | string | no | Reference to values or frameworks |
| `universal[].confidence` | string | yes | `high` \| `medium` \| `low` |
| `domain[].id` | string | yes | Snake_case, unique |
| `domain[].rule` | string | yes | Hyper-specific — include trigger condition |
| `domain[].rationale` | string | yes | Why this rule exists |
| `domain[].confidence` | string | yes | `high` \| `medium` \| `low` |
| `commercial[].confidence` | string | yes | `high` \| `medium` \| `low` |
| `people[].confidence` | string | yes | `high` \| `medium` \| `low` |
| `last_updated` | ISO 8601 date or null | yes | Format: `YYYY-MM-DD` |

**Confidence semantics:** `high` = firm constraint; `medium` = strong default; `low` = suggestion only.

---

## voice.md, story.md, principles.md

Markdown narrative files. No fixed schema — free text with recommended structure defined in the file template. No validation required beyond presence.
