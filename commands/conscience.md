---
name: conscience
description: On-demand ethical red-line check against structured entries in identity/values.yaml
argument_hint: "[text or context to check — or empty to check current session content]"
allowed_tools:
  - Read
  - Bash
---

Invoke the conscience skill at `skills/conscience/SKILL.md` in **on-demand check mode**.

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

**Step 5 — Log the result:**

If any ALERT or CHECK was raised, note it for logging to `signals/observations.jsonl`
at session end. Use the conscience log format from the skill's Logging section.

If the check was fully compliant with no flags, no logging is required.
