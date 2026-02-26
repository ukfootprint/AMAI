# network/ — Schema Reference

---

## circles.yaml

**Schema version:** 1.0

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `_schema` | string | yes | `"circles"` |
| `_version` | string | yes | `"1.0"` |
| `circles[].id` | string | yes | Snake_case — e.g. `inner`, `active`, `warm`, `sector` |
| `circles[].label` | string | yes | Human-readable tier name |
| `circles[].description` | string | yes | What this tier means |
| `circles[].criteria` | list of strings | yes | What qualifies someone for this tier |
| `circles[].capacity` | integer or null | no | Hard limit for the tier; null = unlimited |
| `circles[].touchpoint_type` | string | yes | `personal` \| `professional` \| `either` |
| `circles[].current_count` | integer | yes | How many contacts are currently in this tier |
| `last_updated` | ISO 8601 date or null | yes | Format: `YYYY-MM-DD` |

---

## rhythms.yaml

**Schema version:** 1.0

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `_schema` | string | yes | `"rhythms"` |
| `_version` | string | yes | `"1.0"` |
| `rhythms[].circle` | string | yes | Must reference a valid `circles.yaml` id |
| `rhythms[].label` | string | yes | Human-readable tier name |
| `rhythms[].target_frequency` | string | yes | e.g. `monthly`, `quarterly`, `as_relevant` |
| `rhythms[].max_gap` | string or null | yes | e.g. `6_weeks`, `6_months`; null = no obligation |
| `rhythms[].touchpoint_types` | list of strings | yes | What counts as a touchpoint |
| `rhythms[].notes` | string | no | Additional context |
| `last_updated` | ISO 8601 date or null | yes | Format: `YYYY-MM-DD` |

---

## contacts.jsonl

**Schema version:** 1.0 (append-only log — update by appending revised entry with same `id`)

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `id` | string | yes | Unique — e.g. `contact_001`; stable across updates |
| `name` | string | yes | Full name |
| `organisation` | string | no | References `id` in `organisations.jsonl` |
| `circle` | string | yes | Must match a valid `circles.yaml` id |
| `role` | string | yes | Job title or role description |
| `relationship_context` | string | yes | How you know them and what the relationship is about |
| `last_interaction` | ISO 8601 date | yes | Format: `YYYY-MM-DD` |
| `next_touchpoint` | ISO 8601 date or null | no | Planned next contact date |
| `notes` | string | no | Anything AI should know for conversation prep |
| `tags` | list of strings | no | e.g. `["customer", "advisor", "investor"]` |

---

## organisations.jsonl

**Schema version:** 1.0

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `id` | string | yes | Unique — e.g. `org_001` |
| `name` | string | yes | Organisation name |
| `type` | string | yes | `customer` \| `prospect` \| `partner` \| `investor` \| `competitor` \| `other` |
| `sector` | string | yes | Their sector |
| `size` | string | no | e.g. `50-200 employees` |
| `relationship_status` | string | yes | `active` \| `warm` \| `cold` |
| `key_contacts` | list of strings | no | References `id` values in `contacts.jsonl` |
| `context` | string | yes | What you know and why it matters |
| `notes` | string | no | Free text |

---

## interactions.jsonl

**Schema version:** 1.0

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `date` | ISO 8601 date | yes | Format: `YYYY-MM-DD` |
| `contact_id` | string | yes | References `id` in `contacts.jsonl` |
| `type` | string | yes | `call` \| `meeting` \| `email` \| `message` \| `event` \| `other` |
| `summary` | string | yes | What was discussed or what happened |
| `outcomes` | list of strings | no | Agreed actions or next steps |
| `sentiment` | string | no | `positive` \| `neutral` \| `mixed` \| `negative` |
| `follow_up_by` | ISO 8601 date or null | no | Deadline for any follow-up action |
| `notes` | string | no | Free text |

**Example entry:**
```jsonl
{"date": "2026-03-01", "contact_id": "contact_001", "type": "meeting", "summary": "Discussed Q2 roadmap priorities and budget constraints", "outcomes": ["Send revised proposal by 2026-03-07"], "sentiment": "positive", "follow_up_by": "2026-03-07", "notes": ""}
```
