---
description: Show AMAI system status, calibration health, and active context
allowed-tools: Read, Bash
---

**Path convention:** All user data files are in `${AMAI_USER_ROOT}` — the user's personal AMAI directory, resolved at session start from `~/.amai/config.yaml`. If not resolved, fall back to `${CLAUDE_PLUGIN_ROOT}`.

Report the current AMAI system status. Read the following files:

1. `${AMAI_USER_ROOT}/BRAIN.md` — overall system status and entry point
2. `${AMAI_USER_ROOT}/calibration/metrics.yaml` — freshness metrics per module
3. `${AMAI_USER_ROOT}/calibration/pending_review.md` — items awaiting review
4. `${AMAI_USER_ROOT}/org/org_index.yaml` — available and active org overlays

Then produce a concise status report in this format:

---
**AMAI System Status**

**Health:** [CURRENT / PARTIAL / STALE] — [one-line explanation]
**Last calibration:** [date from metrics.yaml]

**Default context loaded this session:**
- identity/values.yaml ✓
- identity/heuristics.yaml ✓
- goals/current_focus.yaml ✓

**Additional modules loaded:** [list any triggered this session, or "none"]

**Calibration — module freshness:**
[For each module in metrics.yaml: name, last updated, status]

**Pending reviews:** [count and brief list, or "none"]

**Org overlays:** [active overlay if any, or "none active — available: X, Y"]
---

If status is STALE, add a clear warning: "⚠️ AMAI is stale. Run `/amai:calibrate` to update."
If there are pending reviews, list them with brief descriptions.
Keep the report scannable — use the structure above, do not add prose paragraphs.
