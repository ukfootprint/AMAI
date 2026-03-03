# AMAI Pruning Review — Interactive Archive Assistant

**Platform-portable version of AMAI pruning.**
If you're using Claude Cowork, use `/amai:prune` instead — it runs the report and
guides the review automatically.

---

## What Pruning Does

Over time, AMAI accumulates completed goals, placeholder entries, stale content, and
JSONL files that grow without review. Pruning is a human-in-the-loop process: a script
identifies candidates, you decide what to archive, and the AI records your decisions.
**Archive, never delete** — every archived item stays in `_archive/` and is restorable.

---

## Step 1 — Run the Report

In your terminal, run:

```bash
bash scripts/prune_report.sh --mode review
```

Paste the full output into the conversation below. Then paste this prompt.

To also generate a patch script for archive actions:
```bash
bash scripts/prune_report.sh --mode patch
```

---

## The Pruning Prompt

Copy the block below and paste it as a system prompt or before the report output:

```
You are running an AMAI pruning review. The user has pasted a pruning report above.
Your job is to walk them through each candidate category and help them decide what
to archive, keep, or defer.

PROTECTED — NEVER suggest archiving:
- identity/values.yaml, identity/heuristics.yaml — core identity
- identity/beliefs.yaml — user updates directly
- goals/current_focus.yaml — active weekly priorities
- memory/failures.jsonl — lessons learned, append-only
- Any entry created or modified in the last 30 days
- Any entry with keep: true that hasn't passed its keep_until date

CATEGORIES (work through in this order):
1. Archive candidates — completed goals, abandoned items, stale DEFER divergences
2. Consolidation candidates — placeholder entries, redundant items
3. Size warnings — JSONL files that are getting large
4. Freshness reviews — narrative files not updated recently
5. Module usage warnings — modules never loaded

FOR EACH CATEGORY:
Say: "[Category name] — [N] items. [One-line explanation]"
Options: Accept all | Reject all | Walk through | Skip

FOR EACH ITEM (when walking through):
- State what it is and where it lives
- State why it was flagged (exact evidence from the report)
- State what archiving means: "moved to _archive/[original-path] — restorable"
- Ask: "Archive, keep, or defer? (defer = revisit in 90 days)"
- Record the decision

DECISION RULES:
- Archive: item is moved to _archive/; a log entry is created
- Keep: no action taken
- Defer: note the item with a 90-day revisit date in the log

NARRATIVE FILES (freshness warnings):
Do NOT archive these — they contain unique context. Instead, flag them as needing
a content review: "This file hasn't been updated in [N] days — worth reviewing for
accuracy."

AFTER REVIEW:
Show the action plan before executing anything. Wait for explicit confirmation.
Then tell the user exactly which commands to run. Don't execute commands yourself —
instruct the user.
```

---

## Step 2 — Guided Review

Paste the pruning report output after the prompt above and ask:
> "I have my pruning report. Please guide me through the review."

The AI will walk through each category. For each decision:
- **Archive**: the AI will tell you which command to run
- **Keep**: no action
- **Defer**: the AI notes it with a 90-day revisit date

---

## Step 3 — Apply Archive Actions

The AI will instruct you to run commands like:

```bash
# Create archive directory
mkdir -p _archive

# Archive a completed goal entry (example)
echo '{"archived_from":"goals/goals.yaml","archive_date":"YYYY-MM-DD","id":"goal_id","label":"Goal label","status":"completed"}' >> _archive/goals_archived.jsonl
# Then manually remove the goal entry from goals/goals.yaml

# Archive a stale JSONL entry (example — copy the line from the source file)
echo '{"date":"...","context":"..."}' >> _archive/signals_archived.jsonl
# Then manually remove that line from the source file
```

---

## Step 4 — Log the Decisions

After completing the review, append one entry to `memory/decisions.jsonl`:

```json
{
  "date": "YYYY-MM-DD",
  "type": "pruning_decision",
  "context": "AMAI pruning review — balanced mode",
  "decisions": {
    "archived": ["item1", "item2"],
    "kept": ["item3"],
    "deferred": ["item4"]
  },
  "space_recovered_estimate": "brief description",
  "run_by": "portable prompt"
}
```

---

## Step 5 — Validate

Run validation after any changes:

```bash
bash scripts/validate.sh
```

Surface and fix any new ERRORs before closing the session.

---

## Restoring Archived Items

Archived items are in `_archive/`. To restore:

```bash
# File-based restore
mv _archive/[path] [original-path]

# Git restore (if committed before archiving)
git checkout HEAD -- [file]
```

Archive decisions are logged in `memory/decisions.jsonl`.

---

*Platform-portable AMAI pruning prompt. For Cowork: use `/amai:prune`.*
