---
name: pruning
description: >
  Interactive AMAI pruning review — wraps prune_report.sh to walk the user through
  archive, consolidation, size, staleness, and usage candidates. Always archives,
  never deletes. Every decision is logged.
  Trigger phrases include: "prune", "clean up my AMAI", "archive old entries",
  "review what to keep", "trim my AMAI", "run prune", "what can I archive".
version: 0.1.0
triggers:
  - "prune"
  - "clean up my AMAI"
  - "archive old entries"
  - "review what to keep"
  - "trim my AMAI"
  - "run prune"
  - "what can I archive"
tools:
  - Read
  - Write
  - Edit
  - Bash
---

The pruning skill runs a structured three-phase interactive review of AMAI content.
It identifies archive candidates, consolidation opportunities, size warnings, and
stale entries — then walks the user through decisions one category at a time. It
archives, never deletes. Every decision is logged to `memory/decisions.jsonl`.

---

## Pruning Preferences

Before running the report, determine the review mode. If the user specified one via
command arguments, use that. Otherwise, default to **balanced** and mention it:

> "Running in balanced mode — I'll flag completed goals, placeholder entries, stale
> entries, and low-usage modules. Want conservative (clear evidence only), balanced,
> or aggressive (anything inactive 60+ days)?"

| Mode | What it flags |
|------|--------------|
| **conservative** | Completed/abandoned goals; explicit placeholder text; expired TTL entries; stale DEFER divergences (90+ days) |
| **balanced** (default) | Conservative items + staleness flags (180+ days no update) + modules with zero load frequency |
| **aggressive** | Balanced items + anything not accessed in 60+ days without a `keep: true` flag |
| **data-driven** | Only items that are BOTH stale (180+ days) AND unused (0 loads in 90-day period) — recommended once usage data has been collecting for 90+ days |

Check `calibration/metrics.yaml → module_load_frequency` to see if 90+ days of real data is available.
If all values are 0 (fresh install), note: "Usage data not yet available — data-driven mode requires 90+ days of session history."

---

## Protected Items

**NEVER suggest these for pruning**, regardless of mode or any other factor:

| Item | Reason |
|------|--------|
| `identity/values.yaml` | Core identity — simplification only, never deletion |
| `identity/heuristics.yaml` | Decision rules — simplification only |
| `identity/beliefs.yaml` | Beliefs — user reviews and updates directly |
| `goals/current_focus.yaml` | Active priorities — always current |
| `memory/failures.jsonl` | Lessons learned — append-only, never prune |
| Any item with `keep: true` (before `keep_until` date) | User explicitly kept this item |
| Any entry created or modified in the last 30 days | Too recent to archive |

If a user asks to prune a protected item, say:
> "[item] is protected and can't be pruned through this skill. If you want to
> simplify it directly, I can help you edit it instead."

---

## Quality Baseline (Optional)

Before generating the pruning report, offer a quality baseline:

> "Would you like to run a quality evaluation first? This captures baseline confidence
> ratings across 5 standard tasks so you can compare before and after pruning."

If the user says yes:
```bash
bash scripts/eval_quality.sh
```
Open the generated file (`reports/quality_eval_<date>.md`), load AMAI context into your
AI, paste each task, and record the confidence ratings before proceeding.

See `docs/quality_tracking.md` for how to interpret results.

If the user says no or skips this offer, proceed directly to Phase 1.

---

## Phase 1: Generate and Present Report

**Step 1 — Run the report:**

```bash
bash scripts/prune_report.sh --mode review --json
```

If the script fails or is not found:
> "I can't run prune_report.sh — it may not exist or there may be an error.
> Run `bash scripts/prune_report.sh` in your terminal to check. If this is a fresh
> AMAI setup, there may be nothing to prune yet."

**Step 2 — Parse the JSON output:**

Identify candidates in each category:
- `archive_candidates` — completed goals, abandoned items, stale DEFER divergences
- `consolidation_candidates` — placeholder entries, redundant entries
- `size_warnings` — JSONL files exceeding size thresholds
- `freshness_reviews` — narrative files not updated in 180+ days
- `frequency_warnings` — modules with zero load frequency

**Step 3 — Present the summary:**

```
Pruning scan complete — [DATE]
─────────────────────────────────────────
Archive candidates:       [N] items
Consolidation candidates: [N] items
Size warnings:            [N] files
Freshness reviews:        [N] files
Module usage warnings:    [N] modules
─────────────────────────────────────────
Mode: balanced | conservative | aggressive
```

If all counts are zero:
> "System is lean — no pruning candidates found under [mode] mode. Nothing to do."
> Run validate.sh and stop.

If candidates exist: "Ready to review? I'll walk through each category." Then proceed to Phase 2.

If the user says `--report-only`: display the full report and stop. Do not enter Phase 2.

---

## Phase 2: Interactive Review

Work through **one category at a time**, in this order (safest first):

1. Archive candidates
2. Consolidation candidates
3. Size warnings
4. Freshness reviews
5. Module usage warnings

For each category, announce it:

> "**[Category name]** — [N] items. [One-sentence explanation of this category.]
> Options: [A]ccept all, [R]eject all, [W]alk me through each, [S]kip category"

If user chooses "Walk through", present each item:

```
Item: [item identifier — file path, entry ID, or goal ID]
Location: [file]
Flagged because: [specific reason from the report — e.g. "status: completed, horizon: Q1 2025"]
Usage: [X loads in last 90 days (Y% of total) — Category: Stale AND unused / Stale BUT used / etc.]
If archived: moved to _archive/[original-path] — restorable via git or by moving the file back
Recommendation: [archive | keep | defer] — [adjusted if usage data changes the call]

Your decision: [archive / keep / defer]
```

**Usage-adjusted recommendations:**
- Stale AND unused → archive (strongest signal — safe to remove)
- Stale BUT used → keep with a note to update the content, not archive it
- Fresh AND unused → defer (monitor — may be recently added or context-specific)
- Fresh AND used → keep (no action)

**Valid responses:**
- `archive` / `a` / `yes` — accept the recommendation, queue for Phase 3
- `keep` / `k` / `no` — skip this item, no action
- `defer` / `d` — add to deferred list; if the entry format supports it, flag with `keep: true`, `keep_until: [90 days from today]`
- `skip` — skip remaining items in this category

**Batch operations:** When the user says "Accept all" for a category, confirm:
> "Accept all [N] [category] items? This will queue them for archiving. [List of items]"
> Wait for confirmation before queueing.

---

## Phase 3: Execute Decisions

After all categories reviewed (or when user says "done" or "apply"):

**Step 1 — Confirm before applying:**

Show the full action plan:

```
Ready to apply — here's what I'll do:

ARCHIVE ([N] items):
  - [item] → _archive/[path]
  - ...

DEFER ([N] items — keep flags will be set):
  - [item] → keep: true, keep_until: [date]

KEEP ([N] items — no changes):
  - [item]
```

Ask: "Proceed with these changes? This will modify files in your repository."

**Step 2 — Execute archives:**

For each item marked for archiving:

- **Completed/abandoned goals** (in `goals/goals.yaml`): Remove the goal entry from
  goals.yaml and append to `_archive/goals_archived.jsonl` as:
  ```json
  {"archived_from": "goals/goals.yaml", "archive_date": "YYYY-MM-DD", "id": "...", "label": "...", "status": "..."}
  ```

- **JSONL entries** (in `memory/`, `calibration/`, `signals/`): Remove the specific
  line from the source file and append to `_archive/[module]_archived.jsonl`.

- **Narrative files** marked stale (freshness review): Do NOT delete or archive
  these — instead note in the session summary that the user should update or simplify
  them. Narrative files contain unique context that cannot safely be auto-archived.

- **Create `_archive/` if needed:** `mkdir -p _archive` before any archive operation.

**Step 3 — Set defer flags:**

For entries where `defer` was chosen, if the entry is a JSON object, add:
```json
"keep": true, "keep_until": "YYYY-MM-DD"
```
(90 days from today). If the entry format doesn't support this (e.g. plain YAML),
add a comment noting the deferral and note it in the session log.

**Step 4 — Log decisions:**

Append one entry to `memory/decisions.jsonl` for the pruning session:

```json
{
  "date": "YYYY-MM-DD",
  "type": "pruning_decision",
  "context": "AMAI pruning review — [mode] mode",
  "decisions": {
    "archived": ["[item1]", "[item2]"],
    "kept": ["[item1]"],
    "deferred": ["[item1]"]
  },
  "space_recovered_estimate": "[e.g. ~3 goal entries removed from goals.yaml]",
  "run_by": "interactive review"
}
```

**Step 5 — Validate:**

```bash
bash scripts/validate.sh --quiet
```

Surface any new ERRORs or WARNs that weren't present before pruning. If errors appear,
flag them immediately — do not let the session end with broken validation.

**Step 6 — Summary:**

```
Pruning complete — [DATE]
────────────────────────────────────────
Archived:  [N] items
Deferred:  [N] items (keep_until set)
Kept:      [N] items
────────────────────────────────────────
Validation: [N errors, N warnings]
```

If anything was archived, remind the user:
> "Archived items are in `_archive/`. To restore anything, move it back to its
> original location or check git history."

**Quality check offer (if a quality baseline was recorded before pruning):**

> "Pruning complete. Run the quality evaluation again to check for regressions?"

If yes:
```bash
bash scripts/eval_quality.sh --output reports/quality_eval_<date>_post.md
```
Compare with the pre-pruning baseline. If 2+ tasks drop a confidence level, consider
restoring the most recently archived items from `_archive/`. See `docs/quality_tracking.md`.

---

## Undo Instructions (include when archiving)

Any archive action is reversible:

1. **File-based restore:** `mv _archive/[path] [original-path]`
2. **JSONL restore:** Copy the archived line from `_archive/[module]_archived.jsonl`
   back to the original file
3. **Git restore:** `git checkout HEAD -- [file]` if the file was committed before archiving

---

## Category Quick Reference

| Category | Source | Default threshold | Safe to auto-accept? |
|----------|--------|------------------|---------------------|
| Archive candidates | `prune_report.sh` | Completed/abandoned status, 90d stale DEFER | Yes — clear evidence |
| Consolidation | `prune_report.sh` | Placeholder text present | Verify first |
| Size warnings | `prune_report.sh` | JSONL > 50KB | Review only — don't auto-archive |
| Freshness reviews | `prune_report.sh` | Narrative > 180 days | Flag for update, not archive |
| Module usage | `calibration/metrics.yaml` | zero load frequency | Verify before removing |

---

## Audit Logging

After executing pruning decisions (Phase 3), log a summary to the audit trail:

```bash
bash scripts/audit_log.sh \
  --actor ai \
  --actor-id pruning \
  --module "AFFECTED_MODULES" \
  --category prune \
  --description "Pruning review: archived X items, kept Y, deferred Z" \
  --files "FILE1,FILE2"
```

List all files that were moved to `_archive/` in the `--files` argument. Log once per pruning session (not per item). The pruning skill already logs individual decisions to `memory/decisions.jsonl` — the audit log captures the session-level summary.

If the script isn't found, skip silently — never block pruning over audit logging.
