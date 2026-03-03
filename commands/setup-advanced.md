---
name: setup-advanced
description: Activate AMAI signals and calibration layer with guided setup
allowed_tools:
  - Read
  - Write
  - Edit
  - Bash
---

Invoke the `advanced-setup` skill to run a guided 30-minute session that activates
the signals and calibration layer.

## Prerequisites

Before starting the skill, check:

1. Read `identity/values.yaml` — confirm `core_values` has non-placeholder content.
2. Read `identity/heuristics.yaml` — confirm at least one real heuristic exists.
3. Read `goals/current_focus.yaml` — confirm `week_of` is non-null.

If any check fails, stop and redirect:

> "The advanced layer calibrates against your core identity. Please run
> `/amai:setup 1` first to populate values, heuristics, and current focus.
> Come back here once those are complete."

## If Prerequisites Pass

Read `skills/advanced-setup/SKILL.md` and follow the full setup flow:

- **Part 1** — Explain signals and the trigger cue list
- **Part 2** — Seed first observations in `signals/observations.jsonl`
- **Part 3** — Explain calibration, divergence types, and dispositions
- **Part 4** — Initialise `calibration/metrics.yaml` with today's date
- **Part 5** — Schedule first calibration date and close

Also check whether `ethical_red_lines` are plain strings — if so, offer the
red-line upgrade at the end of the session (see SKILL.md Upgrade Red Lines section).

Do NOT run the setup or modify any data files until the prerequisites are confirmed
and the user is ready to begin.
