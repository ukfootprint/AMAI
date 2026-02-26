# CHANGELOG

All notable changes to the AMAI schema and structure are documented here.

Format: `[version] — date — description`. Schema changes that affect existing data files are marked **BREAKING** if they require migration.

---

## [1.4] — 2026-02-26 — Phase 3: Durability

### Added
- `operations/MAINTENANCE_BUDGET.md` — maintenance tiers (5 min/week through quarterly), skip-safety table, staleness indicators, minimum sustainable system definition, STATUS field guide
- `scripts/validate.sh` — validation script checking YAML required fields, date format validity (ISO 8601), JSONL parse integrity; skips `_example` template entries
- `CHANGELOG.md` — this file
- `identity/SCHEMA.md` — field reference for values.yaml and heuristics.yaml
- `goals/SCHEMA.md` — field reference for goals.yaml and current_focus.yaml
- `knowledge/SCHEMA.md` — field reference for learning.jsonl including type field semantics
- `network/SCHEMA.md` — field reference for circles.yaml, rhythms.yaml, contacts.jsonl, organisations.jsonl, interactions.jsonl
- `memory/SCHEMA.md` — field reference for decisions.jsonl, failures.jsonl, experiences.jsonl
- `operations/SCHEMA.md` — schema notes for Markdown-only module
- `signals/SCHEMA.md` — field reference for observations.jsonl including signal prefix conventions
- `calibration/SCHEMA.md` — field reference for divergence.jsonl and metrics.yaml

### Notes
- `_version: "1.0"` was already present in all YAML files from initial release. This satisfies the schema_version requirement — no additional field needed.

---

## [1.3] — 2026-02-26 — Phase 2: Trust and safety

### Added
- `SECURITY.md` — sensitivity tiering of all files (Tier 1/2/3), .gitignore guidance, storage guidance, redaction patterns, multi-device and collaboration notes
- Standing instruction comment blocks in `identity/values.yaml` and `identity/heuristics.yaml`: declared preferences are not verified ground truth; flag divergences rather than silently applying declared values; ethical red lines remain unconditional constraints

### Changed
- `calibration/pending_review.md` — explicit 3-session promotion rubric added; CANDIDATE requires: (1) 3 independent sessions, (2) no values conflict, (3) deliberate human decision. WARNING items cannot use rubric — correction only.

---

## [1.2] — 2026-02-26 — Phase 1: Structural integrity

### Added
- `MODULE_SELECTION.md` — trigger table (14 task types), don't-load list, default minimal set, loading instructions, quick reference card
- `calibration/metrics.yaml` — quantitative tracking (signal volume, divergence counts, override frequency by domain, module load frequency, learning type distribution, review history)
- `goals/deferred_with_reason.md` — replaces `goals/backlog.md`; requires explicit deferral reasoning per entry

### Changed
- `BRAIN.md` — STATUS field added (CURRENT/STALE/PARTIAL); session-start instruction updated to reference MODULE_SELECTION.md and require explicit module confirmation; AI operating instructions expanded to 11 rules including staleness check and declared-vs-observed stance; architecture map updated
- `identity/heuristics.yaml` — `confidence` field added to all heuristics (high/medium/low); instruction block added to file header
- `identity/values.yaml`, `identity/heuristics.yaml`, `goals/goals.yaml`, `goals/current_focus.yaml`, `network/circles.yaml`, `network/rhythms.yaml` — `last_reviewed` standardised to `last_updated` with inline AI staleness instructions; `current_focus.yaml` uses 7-day threshold, others 60-day
- `operations/rituals.md` — meta-learner prompt added to monthly calibration review; `calibration/metrics.yaml` added to calibration files list

### Removed
- `goals/backlog.md` — replaced by `goals/deferred_with_reason.md`

---

## [1.1] — 2026-02-26 — BMO-derived improvements

### Added
- `signals/MODULE.md` — explicit trigger cue list (override, preference, friction, pattern cues)
- `calibration/metrics.yaml` — initial creation (superseded by Phase 1 above)

### Changed
- `knowledge/learning.jsonl` — `type` field added to schema: `correction | preference | pattern | insight`
- `knowledge/MODULE.md` — type field semantics and calibration signal guidance added
- `identity/heuristics.yaml` — domain heuristic examples rewritten to model hyper-specific rules with explicit trigger conditions
- `operations/rituals.md` — meta-learner prompt added to monthly calibration ritual
- `BRAIN.md` — signal capture instruction updated with trigger cue list reference

### Removed
- `goals/backlog.md` — renamed to `goals/deferred_with_reason.md`

---

## [1.0] — 2026-02-26 — Initial release

### Added
- Core module structure: `identity/`, `goals/`, `knowledge/`, `network/`, `operations/`, `memory/`
- Advanced layer: `signals/`, `calibration/`
- `BRAIN.md`, `README.md`, `LICENSE`, `.gitignore`
- All MODULE.md files per module
- Example JSONL schema entries in all data files
- AI Compatibility section in README covering Claude Projects, ChatGPT, and Gemini browser session workarounds

---

## Migration Guide

### v1.0 → v1.1+
- Rename `goals/backlog.md` to `goals/deferred_with_reason.md`
- Add `type` field to any existing `knowledge/learning.jsonl` entries (retroactively classify as `correction`, `preference`, `pattern`, or `insight`)
- Add `confidence` field to any custom heuristics in `identity/heuristics.yaml`

### v1.1 → v1.2+
- Rename `last_reviewed` to `last_updated` in all YAML files (if you created personal copies based on v1.1 or earlier templates)
- Add `week_of` and `last_updated` fields to `goals/current_focus.yaml` if missing
- Update `BRAIN.md` session-start instruction to reference `MODULE_SELECTION.md`
