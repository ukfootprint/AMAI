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

6. Clear reviewed items from `calibration/pending_review.md` after they are addressed.

7. At the end of the calibration, update BRAIN.md with the new calibration date and overall system status.

8. Summarise what was updated and what the new system health is.

Do not skip steps in protocol.md. If the user wants to defer a step, add it to pending_review.md with a note.
