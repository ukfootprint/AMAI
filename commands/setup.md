---
name: setup
description: Run AMAI progressive onboarding to populate core modules
argument_hint: "[stage]"
allowed_tools:
  - Read
  - Write
  - Edit
  - Bash
---

Invoke the onboarding skill to populate AMAI's core modules through conversation.

$ARGUMENTS may contain a stage number or name (e.g., `/amai:setup 1`, `/amai:setup stage 2`,
`/amai:setup foundation`). If no stage is specified, auto-detect the appropriate stage.

**Stage routing:**

1. Read the onboarding skill at `${CLAUDE_PLUGIN_ROOT}/skills/onboarding/SKILL.md`.

2. Determine the stage from $ARGUMENTS:
   - "1", "stage 1", "quickstart", or empty → **Stage 1** (Values, Heuristics, Current Focus)
   - "2", "stage 2", "foundation" → **Stage 2** (Voice, North Star, Goals, Knowledge)
   - "3", "stage 3", "full core" → **Stage 3** (Story, Principles, Operations, Network, Memory seeds)
   - Anything else or empty → **auto-detect**: read `identity/values.yaml`,
     `identity/heuristics.yaml`, and `goals/current_focus.yaml` to check for placeholder
     data (look for `[Replace`, `[Example`, `TODO`). Suggest the lowest incomplete stage
     and confirm with the user before starting.

3. Follow the SKILL.md instructions exactly for the detected stage.

**Important constraints:**
- Never show raw YAML to the user during the conversation phase.
- Always confirm what was captured in plain language before writing files.
- Always run `bash scripts/validate.sh --quiet` after writing files and report results.
- If validation flags WARNs, offer to address them before finishing.
