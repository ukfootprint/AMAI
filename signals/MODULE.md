# Signals Module
*Advanced Layer — set up after core modules are working*
*Load for: end-of-session capture, calibration review preparation*

---

## What This Module Is For

This module captures **raw observations from AI sessions** — uninterpreted, low-deliberation, lightweight. It feeds the calibration system with observed-self data to compare against your declared configuration.

It is deliberately not the same as `memory/`:

| | `memory/` | `signals/` |
|---|---|---|
| **What** | Significant conclusions — decisions, failures, experiences | Raw observations — overrides, friction, notable patterns |
| **Frequency** | Low — only when something is genuinely significant | High — end of most AI sessions |
| **Deliberation** | High | Low — fast capture, under 90 seconds |
| **Purpose** | Permanent record | Temporary source material for calibration |
| **Retention** | Indefinite | Until dispositioned in calibration; archive periodically |

---

## Files In This Module

| File | Format | Purpose |
|------|--------|---------|
| `observations.jsonl` | JSONL | Append-only log of raw session observations |

---

## When to Log

Log an entry at the end of any AI session where at least one of the following happened:

- You overrode, significantly edited, or rejected an AI suggestion
- Something the AI produced felt noticeably off-brand or misaligned
- Something the AI produced felt surprisingly right — better than expected
- You noticed yourself behaving differently from how your config says you behave
- The AI inferred something about you that you'd disagree with
- You made a decision that you'd want to check against your heuristics later

Do not log if the session was routine and nothing felt notable. Signal, not volume.

---

## Trigger Cue List

The following words and phrases in your own responses are reliable signals that a log entry is warranted. When you say any of these during a session, treat it as an automatic flag:

**Override cues** — you rejected or changed a suggestion:
- "No", "Actually", "Not that", "That's not right", "Ignore that"
- "Instead, do X", "Let me reframe this", "Start again"

**Preference cues** — you stated how you like things done:
- "I prefer", "I always", "I never", "I tend to", "I don't like it when"
- "Make it more X", "Make it less Y", "That's too [formal / casual / long / short]"

**Friction cues** — something required repeated correction:
- Second or third edit of the same output
- "Still not right", "Again", "You keep doing X"
- "Why does it always do X?"

**Pattern cues** — recurring observation across sessions:
- "Every time", "This always happens", "Again with the X"
- "Third time this week", "I keep having to fix this"

When any of these surface, note it — even informally. The formal log entry happens at session end.

---

## Log Format

```jsonl
{
  "date": "YYYY-MM-DD",
  "context": "One line: what the session was about",
  "signals": [
    "Override: rejected suggestion to X because it felt like Y",
    "Friction: AI kept framing Z in a way that required editing",
    "Positive: output on [topic] felt unusually on-brand",
    "Pattern: third session this week where I've noticed [behaviour]"
  ],
  "possible_divergence": "Optional — if any signal might relate to a specific config item",
  "config_ref": "Optional — e.g. identity/heuristics.yaml → no_discount_growth"
}
```

**Signal prefixes:**
- `Override:` — you rejected or significantly changed an AI suggestion
- `Friction:` — something required repeated correction
- `Positive:` — something felt unexpectedly right or aligned
- `Pattern:` — this is the nth time you've noticed the same thing
- `Inference:` — the AI made an assumption about you worth examining

---

## AI Instructions

1. **Proactive logging.** At the close of any session with notable overrides, friction, or patterns, draft a signals entry and ask for confirmation before appending. Do not wait to be asked.
2. **Low bar for logging.** When in doubt, log it. Empty signals files make calibration useless.
3. **Never interpret here.** Signals are raw observations. Classification and calibration happen in `calibration/MODULE.md`.
4. **Append only.** Never edit or delete existing entries.
5. **Mark as reviewed.** When the calibration module processes an entry, it adds `"reviewed": "YYYY-MM-DD"`. Do not add this field during capture.

---

## Relationship to PAI *(optional integration)*

If you are using Daniel Miessler's [Personal AI Infrastructure (PAI)](https://github.com/danielmiessler/Personal_AI_Infrastructure), its automated capture hooks provide a richer and more continuous signal stream. `signals/observations.jsonl` supplements automated capture by recording qualitative observations that hooks may miss.

If not using an automated capture tool, `signals/observations.jsonl` is the sole source of observed-self data for calibration.
