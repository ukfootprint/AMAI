# Goals Module
*Load for: planning, prioritisation, strategy, weekly and quarterly review*

---

## What This Module Is For

This module tracks where you are going — from long-term vision down to this week's priority stack. Load it when the AI needs to evaluate whether something is aligned with your current direction, or when planning and prioritisation are involved.

---

## Files In This Module

| File | Format | Load When |
|------|--------|-----------|
| `north_star.md` | Markdown | Strategic planning; evaluating major decisions |
| `goals.yaml` | YAML | Quarterly planning; checking goal status; prioritisation |
| `current_focus.yaml` | YAML | Weekly review; daily planning; deciding what to work on |
| `backlog.md` | Markdown | Reviewing parked ideas; quarterly planning |

---

## AI Instructions

1. **Direction check first.** Before recommending a course of action, check whether it moves toward `north_star.md`. If not, flag the misalignment.
2. **Status fields are live.** Query `goals.yaml` for current status (`active`, `on_hold`, `completed`) before assuming something is still a priority.
3. **Current focus is the weekly ground truth.** `current_focus.yaml` is what matters this week. Don't load the full goals file for tactical decisions — just current focus.
4. **Backlog is potential, not commitment.** Items in `backlog.md` are parked ideas, not active goals. Do not treat them as current priorities.
