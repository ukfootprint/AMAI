---
name: critique
description: Multi-level AMAI-aware critique — from supportive review to hostile examination
argument_hint: "[level] [text or context]"
allowed_tools:
  - Read
  - Bash
---

Invoke the critique skill at `skills/critique/SKILL.md`. Parse $ARGUMENTS as follows:

**Level detection (parse from $ARGUMENTS):**
- If a number 1–5 is present ("level 3", "L4", "3"), use that critique level
- If a level name is present ("critical friend", "devil's advocate", "hostile critic", "rigorous examiner", "supportive review"), match it to the corresponding level (see the skill's Level Detection table)
- If no level is specified, **default to Level 2 (Critical Friend)** and tell the user:
  > "Running at Level 2 (Critical Friend). Say 'level 5' if you want the hostile version."
- Remaining text after the level indicator is the content to critique
- If no content is provided in $ARGUMENTS, ask: "What would you like me to critique? Paste text, describe your idea, or tell me which file to review."

**Before running critique:**

Load AMAI context modules as specified in the skill's Context Loading section. The set of modules loaded escalates with level — always load values and heuristics; add frameworks at Level 2+, domain landscape at Level 3+, decisions at Level 4+, north_star at Level 5.

If any relevant module contains only placeholder data or has not been updated in > 60 days, note it before proceeding — but do not refuse to proceed. Critique still has value without full AMAI context.

**Running the critique:**

Follow the level's specified Structure, Tone, Output format, and AMAI context application rules exactly as defined in the skill. Ground every observation in the user's own declared context (values as criteria, heuristics as tests, frameworks as lenses) — never critique generically.
