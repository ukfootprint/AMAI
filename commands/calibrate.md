---
description: Walk through the AMAI calibration protocol interactively
allowed-tools: Read, Write, Edit
---

Run an interactive AMAI calibration session.

1. Read `${CLAUDE_PLUGIN_ROOT}/calibration/protocol.md` — this is the authoritative source for the calibration steps. Follow it exactly.

2. Read `${CLAUDE_PLUGIN_ROOT}/calibration/metrics.yaml` to understand which modules are stale or due for review.

3. Read `${CLAUDE_PLUGIN_ROOT}/calibration/pending_review.md` to surface any items that were flagged for this calibration.

4. Walk the user through the calibration protocol step by step:
   - Present each step from protocol.md
   - Ask the relevant questions
   - Wait for answers before proceeding to the next step
   - Do not rush through multiple steps at once

5. For each module reviewed:
   - Ask the user to confirm whether the module content is still accurate
   - If changes are needed, read the current file content, make the edits, and confirm with the user before writing
   - Update `calibration/metrics.yaml` to reflect the new last-updated date and status

5a. Entry reference logging during calibration review:

   For each **specific entry** (individual value, heuristic, red line, belief, or goal) that the user explicitly discusses during the review, append an entry to `calibration/entry_references.jsonl` after the session completes:

   - User confirms it's still accurate → `event: "calibration_reviewed"`, `outcome: "confirmed"`
   - User updates the content → `event: "calibration_updated"`, `outcome: "updated"`
   - User flags it as a divergence candidate → `event: "calibration_reviewed"`, `outcome: "deferred"`

   ```jsonl
   {"date": "YYYY-MM-DD", "entry_id": "ENTRY_ID", "entry_type": "TYPE", "source_file": "FILE_PATH", "event": "calibration_reviewed", "context": "Monthly calibration — MODULE review", "outcome": "confirmed|updated|deferred"}
   ```

   Rules:
   - Only log entries the user **explicitly discussed or reviewed** — not every entry in a loaded file.
   - If the user updates a heuristic, log it with `event: "calibration_updated"` and `outcome: "updated"`.
   - The `entry_id` must match the `id` field in the source file.
   - Append all reference entries **after** the calibration session completes, not during.
   - If `calibration/entry_references.jsonl` does not exist, skip silently.
   - Include `calibration/entry_references.jsonl` in the `--files` list of the audit log command (step 9) if any entries were written.

6. Clear reviewed items from `calibration/pending_review.md` after they are addressed.

7. At the end of the calibration, update BRAIN.md with the new calibration date and overall system status.

8. Summarise what was updated and what the new system health is.

Do not skip steps in protocol.md. If the user wants to defer a step, add it to pending_review.md with a note.

9. After calibration completes, log a summary to the audit trail:
```bash
bash scripts/audit_log.sh \
  --actor ai \
  --actor-id calibrate \
  --module "calibration" \
  --category calibrate \
  --description "Monthly calibration: reviewed X modules, updated Y, deferred Z" \
  --files "calibration/metrics.yaml,calibration/pending_review.md"
```
Include all files that were actually modified. If the script isn't found, skip silently.
