---
name: conscience
description: On-demand ethical check against red lines (Phase 1) and high-confidence heuristics (Phase 2)
argument_hint: "[text or context to check] [--red-lines-only | --include-heuristics | --heuristics-only]"
flags:
  --include-heuristics: "Phase 2 mode (default) — check red lines + high-confidence heuristics"
  --red-lines-only: "Phase 1 mode — check only ethical_red_lines (skip heuristics)"
  --heuristics-only: "Check only high-confidence heuristics (skip red-line check)"
allowed_tools:
  - Read
  - Bash
---

Invoke the conscience skill at `skills/conscience/SKILL.md` in **on-demand check mode**.

**Mode detection:** Parse $ARGUMENTS for mode flags before running the check:
- `--red-lines-only` → run Phase 1 only (red lines)
- `--heuristics-only` → run Phase 2 only (heuristics)
- `--include-heuristics` or no flag → run Phase 1 + Phase 2 (default)

**Step 1 — Load red lines:**

Read `identity/values.yaml → ethical_red_lines`. Determine what you have:
- Structured entries (YAML objects with `id`, `when`, `never` fields): use for precise matching
- String entries: flag as legacy, apply best-effort matching
- Placeholder entries (containing "[Replace" or "[Example"): skip, count as not configured
- Empty array: report "no red lines configured"

If ALL entries are placeholders or the array is empty, output the no-red-lines message
from the skill (Section: No-Red-Lines Handling) and stop. Do not proceed with a check.

**Step 2 — Identify what to check:**

Parse $ARGUMENTS:
- If $ARGUMENTS contains a quoted string or pasted content: check that specific content
- If $ARGUMENTS is empty or just whitespace: check the current session's most recent
  work product (the last substantial content generated this session)
- If $ARGUMENTS references a file path (e.g. "check docs/proposal.md"): read that file
  and check its content

If nothing can be identified to check, ask:
> "What would you like me to check? Paste text, describe the situation, or tell me which file to review."

**Step 3 — Run the check:**

Follow the Red Line Matching Logic in the skill exactly:
1. For each structured red line: assess context match, constraint evaluation, exception check
2. For each legacy string: best-effort keyword match and legacy flag
3. Route each finding to ALERT, CHECK, LEGACY, or Compliant

**Step 4 — Output:**

Use the on-demand check output format from the skill:

```
Conscience check — [one-line description of what was checked]

Red lines in scope for this context:
─────────────────────────────────────
[id]: [summary of when field]
  Status: ✓ Compliant / ⚠️ POTENTIAL VIOLATION / 💭 CHECK RECOMMENDED
  [If flagged: concern + suggested action]

Red lines not in scope:
  [id] — [one line why it doesn't apply]
```

If a CONSCIENCE:ALERT is raised, use the full alert format from the skill.
If a CONSCIENCE:CHECK is raised, use the check format from the skill.

**Step 5 — Phase 2 heuristic check (if mode includes heuristics):**

Read `identity/heuristics.yaml`. Filter for entries where `confidence: high`.

For each high-confidence heuristic:
1. Check if the task's domain or context matches the heuristic's `use_when` field
2. If yes: does the current content or proposed action contradict the heuristic's `rule`?
3. If contradiction detected: surface a CONSCIENCE:HEURISTIC notice (softer format — see skill)

Add heuristic results to the on-demand output format:

```
High-confidence heuristics in scope for this context:
─────────────────────────────────────────────────────
[heuristic_id]: [rule — one line]
  Status: ✓ Consistent / 💡 POSSIBLE DEVIATION
  [If flagged: concern + note that deviation may be intentional]

Heuristics not in scope:
  [id] — [why it doesn't apply]
```

If no heuristics are `confidence: high`, note: "No high-confidence heuristics found —
heuristic checking requires at least one entry with `confidence: high` in heuristics.yaml."

**Step 6 — Log the result:**

If any ALERT, CHECK, or HEURISTIC notice was raised, note it for logging to
`signals/observations.jsonl` at session end. Use the conscience log formats from
the skill's Logging section — type `"conscience_alert"` for red lines,
`"conscience_heuristic"` for heuristic notices.

If the check was fully compliant with no flags, no logging is required.
