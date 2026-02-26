# signals/ — Schema Reference

---

## observations.jsonl

**Schema version:** 1.0 (append-only log)

| Field | Type | Required | Valid values / notes |
|-------|------|----------|----------------------|
| `date` | ISO 8601 date | yes | Format: `YYYY-MM-DD` |
| `context` | string | yes | One line: what the session was about |
| `signals` | list of strings | yes | One or more signal entries with prefix (see below); min 1 |
| `possible_divergence` | string or null | no | If any signal might relate to a specific config item |
| `config_ref` | string or null | no | e.g. `identity/heuristics.yaml → no_discount_growth` |
| `reviewed` | ISO 8601 date or null | no | Set by calibration module when processed; never set during capture |

**Signal prefix conventions:**
- `Override:` — you rejected or significantly changed an AI suggestion
- `Friction:` — something required repeated correction
- `Positive:` — something felt unexpectedly right or aligned
- `Pattern:` — this is the nth time you've noticed the same thing
- `Inference:` — the AI made an assumption about you worth examining

**Example entry:**
```jsonl
{"date": "2026-03-01", "context": "Drafting a proposal for a new client", "signals": ["Override: rejected suggestion to include a discount offer — felt wrong given no_discount_growth heuristic", "Friction: AI kept defaulting to formal register despite voice.md specifying direct and plain"], "possible_divergence": "voice.md register spec may need tightening", "config_ref": "identity/voice.md", "reviewed": null}
```

**Retention:** Entries remain until dispositioned in calibration review. Archive reviewed entries periodically to keep the file manageable.
