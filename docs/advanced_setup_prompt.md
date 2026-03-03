# AMAI Advanced Layer Setup — Portable Prompt

**Platform-portable version of AMAI advanced layer setup.**
If you're using Claude Cowork, use `/amai:setup-advanced` instead — it writes
files and updates metrics directly.

---

## Prerequisites

Before running this, you should have completed Stage 1 onboarding:
`identity/values.yaml`, `identity/heuristics.yaml`, and
`goals/current_focus.yaml` must all have non-placeholder content.

---

## The Prompt

Copy the block below into any AI assistant that has access to your AMAI files,
or paste your key files as context before sending.

```
I want to activate AMAI's advanced layer — the signals and calibration system.
Walk me through the setup in five parts.

## Context files to read (if you have access):
- signals/MODULE.md
- calibration/protocol.md
- calibration/metrics.yaml
- signals/observations.jsonl
- identity/values.yaml
- identity/heuristics.yaml

---

## Part 1 — Signals

Explain what signals are and why they matter. Cover:
- The five signal types: Override, Friction, Positive, Pattern, Inference
- The trigger cue list (the words/phrases that flag a signal is worth logging)
- The difference between signals and memory/ entries (signals are raw and
  temporary; memory/ entries are significant and permanent)

Then ask me: "Thinking back over recent AI sessions, does any of this ring a
bell — overrides, friction, or patterns you've noticed?"

## Part 2 — First Signal Entries

Help me log 1–3 initial observations based on the conversation so far.
For each entry, use this exact format:

{
  "date": "YYYY-MM-DD",
  "context": "one line: what the session was about",
  "signals": [
    "Override: [what I rejected and why]",
    "Friction: [what kept going wrong]",
    "Positive: [what felt unusually right]",
    "Pattern: [nth time I've noticed X]",
    "Inference: [assumption worth examining]"
  ],
  "possible_divergence": null,
  "config_ref": null
}

Show me each entry and ask for confirmation before including it. Output all
confirmed entries as JSONL for me to append to signals/observations.jsonl.

If I can't think of specific examples, use this meta-entry:
{"date": "YYYY-MM-DD", "context": "AMAI advanced layer setup", "signals": ["Pattern: Setting up calibration system — first structured review of gap between declared and observed behaviour"], "possible_divergence": null, "config_ref": null}

## Part 3 — Calibration

Explain the calibration system:
- The core problem: config = who I intend to be; signals = what I actually do
- The four divergence types: Values, Identity, Operational, Relational
- The four disposition codes: CONFIRM, CANDIDATE, WARNING, DEFER
- The divergence spectrum (the 2×2: values/operational × high/low frequency)

Key message to land: "When declared and observed diverge, the system never
auto-updates your values. You decide which direction the correction goes."

## Part 4 — Initialise Metrics

Output a complete initialised calibration/metrics.yaml for me to copy, with:
- All counters set to 0
- A review_history entry for today:
    date: YYYY-MM-DD
    signals_reviewed: 0
    divergences_found: 0
    incorporated: 0
    rejected: 0
    deferred: 0
    health_note: "Advanced layer activated. Signal capture begins."
- last_updated: YYYY-MM-DD (today)

Use today's actual date. Output as a YAML code block.

## Part 5 — Maintenance Rhythm and Close

Explain the rhythm:
- After notable sessions: /amai:capture (60–90 seconds)
- Monthly: /amai:calibrate (30–60 minutes)
- Quarterly: deep review of calibration/divergence.jsonl for meta-patterns

Suggest a first calibration date 4 weeks from today. Summarise what we've set up.

---

## Red-Line Upgrade (if applicable)

After Part 5, check my identity/values.yaml ethical_red_lines. If they are
plain strings rather than structured objects, say:

"Your red lines are currently simple strings. The structured When/Do/Never/Except
format makes them machine-checkable and forces the edge-case thinking that strings
skip. Want to upgrade them now?"

If yes: for each existing string red line, walk me through converting it to:

  - id: snake_case_id
    when: "context where this applies"
    do: "required positive behaviour"
    never: "the specific prohibition"
    except: "legitimate exceptions, or 'none'"
    examples:
      - "concrete example phrase or scenario"
    severity: absolute

Show each converted entry for my confirmation, then output the full updated
ethical_red_lines block as YAML for me to copy into identity/values.yaml.
```

---

## After Running the Prompt

1. Append the confirmed JSONL entries to `signals/observations.jsonl`
2. Copy the initialised `calibration/metrics.yaml` output to your file
3. If you upgraded red lines, copy the updated `ethical_red_lines` block into
   `identity/values.yaml`
4. Run validation: `bash scripts/validate.sh`
5. Run staleness check: `bash scripts/staleness.sh`

Calibration should show as CURRENT. Validate should pass with 0 errors (and
no WARN:DEPRECATED_RED_LINE_FORMAT if you upgraded your red lines).

---

*Platform-portable version. If using Claude Cowork, use `/amai:setup-advanced`
instead — it handles file writes and validation automatically.*
