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

## beliefs.yaml

**Schema version:** 1.0 (`_version` field) — optional file, validated when present

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `_schema` | string | yes | `"beliefs"` |
| `_version` | string | yes | `"1.0"` |
| `beliefs[].id` | string | yes | Snake_case, unique; pattern `^[a-z][a-z0-9_]*$` |
| `beliefs[].belief` | string | yes | The claim you hold to be true; minLength 20 |
| `beliefs[].confidence` | string | yes | `foundational` \| `held` \| `working` |
| `beliefs[].domain` | string | yes | Domain(s) the belief applies to; minLength 3 |
| `beliefs[].evidence` | string | no | Why you believe this (WARN if missing) |
| `beliefs[].last_tested` | ISO 8601 date or null | no | When last challenged (WARN if null for held/foundational) |
| `last_updated` | ISO 8601 date or null | yes | Format: `YYYY-MM-DD`; threshold: 90 days |

**Confidence tiers:** `foundational` (frames everything, rarely changes) → `held` (strong conviction, revisable) → `working` (current best understanding, actively revisable)

**Distinction:** Values say "I care about X." Beliefs say "I think X is true." Heuristics say "When X, do Y."

**Validation:** WARN:PLACEHOLDER_BELIEF, WARN:BELIEF_MISSING_EVIDENCE, WARN:BELIEF_NEVER_TESTED, WARN:TOO_MANY_BELIEFS (>10), INFO:BELIEF_COUNT

---

## voice.md, story.md, principles.md

Markdown narrative files. No fixed schema — free text with recommended structure defined in the file template. No validation required beyond presence.
