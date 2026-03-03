# Identity Module
*Load for: writing, positioning, decisions, communications*

---

## What This Module Is For

This module defines who you are — your values, voice, decision logic, story, and principles. It is the lens through which every other module is filtered. Load it whenever the AI needs to write on your behalf, make recommendations aligned with your values, or check a decision against your principles.

---

## Files In This Module

| File | Format | Load When |
|------|--------|-----------|
| `values.yaml` | YAML | Any decision; any communication; checking ethical alignment |
| `heuristics.yaml` | YAML | Fast decisions; domain-specific judgment calls |
| `beliefs.yaml` | YAML | Decision-making, strategy, planning, analysis — when reasoning context matters |
| `voice.md` | Markdown | Writing content, emails, proposals, social posts |
| `story.md` | Markdown | Positioning, introductions, explaining your background |
| `principles.md` | Markdown | Complex decisions; explaining reasoning to others |

---

## AI Instructions

1. **Values are constraints, not suggestions.** `ethical_red_lines` in `values.yaml` are absolute. No commercial or strategic justification overrides them.
5. **Beliefs are reasoning context, not constraints.** `beliefs.yaml` informs how to frame analysis and recommendations — but never suppress evidence because a belief contradicts it. When evidence and a stated belief conflict, present the evidence and let the user decide.
2. **Priority order in values matters.** When values appear to conflict, higher priority wins. Check the `priority` field.
3. **Voice applies to all outputs.** Any text generated on your behalf must be filtered through `voice.md` — tone, word choices, sentence length, and structure.
4. **Heuristics are pre-made decisions.** When a heuristic covers the situation, use it rather than reasoning from scratch. The heuristics exist because first-principles reasoning under time pressure is unreliable.
5. **Story informs framing.** When positioning, pitching, or explaining, check `story.md` for the narrative context the AI should work within.
6. **Principles explain the why.** `principles.md` contains the reasoning behind the heuristics — useful for edge cases the heuristics don't cover cleanly.
