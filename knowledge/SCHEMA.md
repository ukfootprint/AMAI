# knowledge/ — Schema Reference

---

## learning.jsonl

**Schema version:** 1.0 (append-only log)

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `date` | ISO 8601 date | yes | Format: `YYYY-MM-DD` |
| `type` | string | yes | `correction` \| `preference` \| `pattern` \| `insight` |
| `source` | string | yes | `experience` \| `conversation` \| `reading` \| `observation` |
| `insight` | string | yes | The specific learning — be precise, not vague |
| `context` | string | yes | Brief description of the situation |
| `applies_to` | list of strings | no | Domain tags — e.g. `["commercial", "product"]` |
| `confidence` | string | yes | `high` \| `medium` \| `low` |

**Type semantics:**
- `correction` — you were wrong about something and updated your model
- `preference` — you discovered or clarified a working preference
- `pattern` — a recurring observation became visible across multiple situations
- `insight` — a new idea, framework, or perspective worth retaining

**Example entry:**
```jsonl
{"date": "2026-03-01", "type": "correction", "source": "conversation", "insight": "Buyers in this sector make decisions by committee — single-champion deals rarely close", "context": "Lost a deal where the champion had no internal support", "applies_to": ["commercial"], "confidence": "high"}
```

---

## frameworks.md, domain_landscape.md, reading_list.md

Markdown narrative files. No fixed schema — structured by template. No validation required beyond presence.
