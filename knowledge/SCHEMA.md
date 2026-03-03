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

---

## knowledge/domains/domain_index.yaml

**Schema version:** 1.0 — see `schemas/domain_index.schema.json` for full validation schema.

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `_schema` | string | yes | Must be `"domain_index"` |
| `_version` | string | no | Schema version string |
| `last_updated` | ISO date or null | no | When the registry was last changed |
| `domains` | list of domain objects | yes | At least one entry recommended |

**Per-domain fields:**

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `id` | string | yes | snake_case — e.g. `edtech`, `ai_infrastructure` |
| `label` | string | yes | Human-readable domain name |
| `description` | string | yes | What this domain covers — at least 20 words |
| `path` | string | yes | Relative path to domain directory — must end with `/` |
| `active` | boolean | yes | `true` if domain is currently in use |
| `last_updated` | ISO date or null | no | When the domain files were last meaningfully updated |
| `tags` | list of strings | no | Keywords for task-type matching |

**Example entry:**
```yaml
- id: edtech
  label: "Education Technology"
  description: "EdTech market, school data systems, learning platforms, UK education policy"
  path: "knowledge/domains/edtech/"
  active: true
  last_updated: null
  tags: ["education", "technology", "schools", "data", "MIS"]
```

---

## knowledge/domains/{id}/ — Directory Structure

Each domain directory may contain these files (all optional except README.md):

| File | Purpose | Notes |
|------|---------|-------|
| `README.md` | What's in this directory and how to use it | Template provided at creation |
| `frameworks.md` | Domain-specific mental models | Supplements `knowledge/frameworks.md` |
| `landscape.md` | Market/sector analysis for this domain | Domain-specific version of `domain_landscape.md` |
| `terminology.md` | Domain vocabulary and shorthand | Optional but recommended for jargon-heavy domains |
| `resources.md` | Key references and reading for this domain | Optional |

All files are Markdown narrative format. No fixed schema — structured by the README.md
template. No validation required beyond presence of README.md.
