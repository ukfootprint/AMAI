---
name: advanced-setup
description: Guided activation of AMAI signals and calibration layer — teaches the concepts, seeds first entries, configures the feedback loop
version: 0.1.0
triggers:
  - "setup advanced layer"
  - "activate signals"
  - "start calibration"
  - "setup signals"
  - "advanced setup"
  - "setup advanced"
  - "calibration setup"
tools:
  - Read
  - Write
  - Edit
  - Bash
---

# Advanced Layer Setup

A guided 30-minute session that activates the signals and calibration layer.
Five parts: understanding signals → first entries → understanding calibration →
initialise metrics → schedule and close.

Do not rush between parts. Each part has a specific conversation goal.

---

## Prerequisites Check

Before starting, read the following files and verify:

1. `identity/values.yaml` — must have non-placeholder content in `core_values`
   and `ethical_red_lines`. Placeholder text contains phrases like "EXAMPLE" or
   "Replace this".
2. `identity/heuristics.yaml` — must have at least one real heuristic in any
   category (universal, domain, commercial, or people).
3. `goals/current_focus.yaml` — must have a non-null `week_of` date.

If any check fails, stop and tell the user:

> "The advanced layer calibrates against your core identity. Before we continue,
> please run `/amai:setup 1` to populate your values, heuristics, and current
> focus. Come back here once those are complete."

Also check whether `identity/values.yaml → ethical_red_lines` contains plain
strings rather than structured objects. If so, note this — the red-line upgrade
step applies at the end of this session (see Upgrade Red Lines section below).

---

## Part 1 — Understanding Signals (~10 minutes)

**Opening:**

> "AMAI's advanced layer creates a feedback loop between how you describe yourself
> and how you actually work. It has two parts: signals (raw observations captured
> at the end of sessions) and calibration (periodic review of those signals against
> your config). Let's set both up.
>
> You'll come away with a clear picture of what signals are, how to capture them,
> and how calibration works — and the system will be initialised and ready to use."

**Explain signals:**

> "A signal is a moment in an AI session where something notable happened — you
> overrode a suggestion, the AI tone felt wrong, you noticed yourself breaking your
> own rules, or the output felt surprisingly right. These moments are gold for
> understanding whether your AMAI config matches reality."

**Show the signal types:**

Walk the user through the five types from `signals/MODULE.md`:

- **Override** — you rejected or changed an AI suggestion
- **Friction** — something required repeated correction; the AI kept getting something wrong
- **Positive** — output felt unusually aligned, better than expected
- **Pattern** — this is the nth time you've noticed the same thing across sessions
- **Inference** — the AI made an assumption about you worth examining

**Show the trigger cue list:**

> "Here's a practical shortcut. When you notice yourself saying any of these
> during a session, that's usually a signal worth logging:
>
> **Override cues:** 'No', 'Actually', 'Not that', 'That's not right', 'Instead
> do X', 'Let me reframe this', 'Start again'
>
> **Preference cues:** 'I prefer', 'I always', 'I never', 'Make it more X',
> 'That's too formal / casual / long'
>
> **Friction cues:** Second or third edit of the same thing, 'Still not right',
> 'You keep doing X', 'Why does it always do this?'
>
> **Pattern cues:** 'Every time', 'This always happens', 'Third time this week
> I've had to fix this'"

**Ask:**

> "Thinking back over your recent AI sessions — any of those ring a bell? Have you
> noticed overrides, friction, or patterns?"

If the user gives examples, great — keep them in mind for Part 2.
If not, that's fine — they'll start noticing now.

---

## Part 2 — First Signal Entries (~5 minutes)

**Opening:**

> "Let's log your first observations. Even if you don't have a perfect example,
> we'll seed the file so the system is live."

**Seed observations.jsonl:**

Help the user log 1–3 initial observations. For each entry:

1. Ask about the context: "What was the session about?"
2. Ask what happened: "Which type fits — override, friction, positive, pattern, or inference?"
3. Construct the JSONL entry using the signal prefix format:
   - `"Override: [what you rejected and why]"`
   - `"Friction: [what kept going wrong]"`
   - `"Positive: [what felt unusually right]"`
   - `"Pattern: [the recurring thing — nth occurrence]"`
   - `"Inference: [the assumption the AI made]"`
4. Show the full entry to the user and get confirmation before appending.
5. Append to `signals/observations.jsonl`.

Entry format (must match `schemas/observations.schema.json`):
```json
{
  "date": "YYYY-MM-DD",
  "context": "One line: what the session was about",
  "signals": [
    "Override: rejected suggestion to X because it felt like Y",
    "Friction: AI kept framing Z in a way that required editing"
  ],
  "possible_divergence": null,
  "config_ref": null
}
```

If the user cannot think of any specific sessions, create a single meta-observation
with their confirmation:
```json
{
  "date": "YYYY-MM-DD",
  "context": "AMAI advanced layer setup — activating signals and calibration",
  "signals": [
    "Pattern: Setting up calibration system — first time reviewing gap between declared and observed behaviour"
  ],
  "possible_divergence": null,
  "config_ref": null
}
```

**Explain /amai:capture:**

> "From now on, at the end of any notable session, use `/amai:capture` to log what
> happened. The key question is: did anything feel off, or surprisingly right? Aim
> for 2–3 signals per week — it takes under 90 seconds and makes calibration
> genuinely useful."

---

## Part 3 — Understanding Calibration (~10 minutes)

**Explain the calibration concept:**

> "Signals are raw observations. Calibration is where you review them against your
> declared values, heuristics, and goals to see if they match. When they don't, you
> get a divergence — and you decide what to do about it.
>
> The key insight: not all divergence means your config is wrong. Sometimes your
> config is correct and your behaviour has drifted. The system distinguishes between
> these — but you make the call."

**Walk through the four divergence types:**

Read `calibration/protocol.md` to confirm these before presenting. Then walk through:

1. **Values divergence** (`type: values`) — your behaviour contradicts a stated
   value. Sources: pattern signals, direct decision observation. Default disposition:
   WARNING — the config is correct; the behaviour needs checking. Red lines are
   never candidates for revision through observed behaviour alone.

2. **Identity divergence** (`type: identity`) — your voice, tone, or
   self-presentation is evolving. Sources: friction signals, positive signals,
   inference signals. Default disposition: CANDIDATE — identity evolves and the
   config should reflect that, but always reviewed deliberately.

3. **Operational divergence** (`type: operational`) — you're breaking your own
   heuristics or working patterns. Sources: override signals, pattern signals.
   Default disposition: DEFER until the pattern is clear (3+ signals), then
   CANDIDATE or WARNING depending on values alignment.

4. **Relational divergence** (`type: relational`) — your relationship patterns
   differ from your network plan. Sources: pattern signals, interaction frequency.
   Default disposition: CANDIDATE — relationship reality often differs from planned
   structure, and the config should reflect reality.

**Show the disposition codes:**

> "When calibration reviews a signal, it assigns one of these dispositions:
>
> - **CONFIRM** — behaviour matches config. You're aligned. Log and move on.
> - **CANDIDATE** — config might need updating. Requires deliberate review.
> - **WARNING** — behaviour is drifting from values. Course-correct the behaviour,
>   not the config.
> - **DEFER** — not enough data yet. Watch for recurrence."

**Show the divergence spectrum:**

> "There's a useful 2×2 to think about divergence:
>
> ```
>               HIGH FREQUENCY
>                    │
>     DRIFT ZONE     │     EVOLUTION ZONE
>  (behaviour off)   │  (config is outdated)
>                    │
> VALUES ────────────┼──────────────── OPERATIONAL
> CRITICAL           │               LOW STAKES
>                    │
>     WARNING ZONE   │     CALIBRATION ZONE
>  (urgent, act now) │  (routine tune-up)
>                    │
>               LOW FREQUENCY
> ```
>
> Top-left: frequent values divergence → active WARNING, course-correct now.
> Top-right: frequent operational divergence → likely your config needs updating.
> Bottom-left: rare values divergence → watch carefully.
> Bottom-right: occasional operational divergence → low-urgency candidate."

**Key message:**

> "Observed behaviour documents how you act. Config documents who you intend to be.
> When they diverge, YOU decide what to do — the system never auto-updates your
> values."

---

## Part 4 — Initialise Metrics (~3 minutes)

Read `calibration/metrics.yaml` to confirm its current state, then update it:

1. Confirm all counters are 0 (they should be from the template).
2. Replace the placeholder `review_history` entry with a real activation entry:

```yaml
review_history:
  - date: YYYY-MM-DD   # today's date
    signals_reviewed: 0
    divergences_found: 0
    incorporated: 0
    rejected: 0
    deferred: 0
    health_note: "Advanced layer activated. Signal capture begins."
```

3. Set `last_updated` to today's date.

Show the user the updated metrics.yaml before writing. Get confirmation.

---

## Part 5 — Schedule and Close (~2 minutes)

**Explain the maintenance rhythm:**

> "Here's how the advanced layer runs once it's live:
>
> - **After notable sessions:** Use `/amai:capture` to log signals — 60–90 seconds.
> - **Monthly:** Run `/amai:calibrate` to review accumulated signals against your
>   config — 30–60 minutes.
> - **Quarterly:** Deep review of `calibration/divergence.jsonl` for meta-patterns,
>   as part of your quarterly AMAI review."

**Suggest first calibration date:**

Calculate 4 weeks from today. Then say:

> "Plan your first calibration for [date 4 weeks from today]. By then you'll have
> 8–12 signals to review, which is enough to be meaningful. Want me to note that
> date in your current focus or ops files?"

If the user agrees, add a note to `goals/current_focus.yaml → notes` field or
`operations/rituals.md` with the first calibration date.

---

## Post-Setup Verification

After completing all five parts:

1. Run `bash scripts/validate.sh --quiet` — must pass with 0 errors.
2. Run `bash scripts/staleness.sh` — calibration should show as CURRENT.
3. Confirm `signals/observations.jsonl` has at least 1 real entry.
4. Confirm `calibration/metrics.yaml` has today's date in `last_updated` and
   a populated `review_history` entry.

Summarise:

> "Advanced layer is active. Here's what's set up:
> - Signals: [N] observations logged in `signals/observations.jsonl`
> - Calibration: metrics initialised, first review scheduled for [date]
> - Status: validate passes, staleness clear
>
> Your first calibration is [date]. Use `/amai:capture` at the end of any
> session where something felt notable."

---

## Upgrade Red Lines (If Applicable)

If the user's `identity/values.yaml → ethical_red_lines` contains plain strings
(rather than structured When/Do/Never/Except objects):

1. Read `docs/red_line_migration.md` so you have the migration guidance.
2. Tell the user:
   > "Your red lines are currently simple strings. The structured format makes them
   > machine-checkable and forces the edge-case thinking that simple strings skip.
   > Want to upgrade them now? It takes about 10 minutes."
3. If yes: walk through each existing red line conversationally:
   - "Your red line is: '[existing string]'. Let's break that down into the structured
     format. What context does this apply to? (when)"
   - "What should you actively do in that context? (do)"
   - "What specifically should you never do? (never)"
   - "Any legitimate exceptions? (except)"
   - "Give me a concrete example of this rule in action."
4. Construct the structured YAML for each red line, show for confirmation, then
   write to `identity/values.yaml`.
5. Run `bash scripts/validate.sh` to confirm no more WARN:DEPRECATED_RED_LINE_FORMAT.

---

## Audit Logging

After each part of the advanced setup that writes files, log the change:

```bash
bash scripts/audit_log.sh \
  --actor ai \
  --actor-id advanced-setup \
  --module "MODULE_AREA" \
  --category onboard \
  --description "DESCRIPTION" \
  --files "FILE1,FILE2"
```

**Examples:**
- After seeding signals: `--module "signals" --description "Advanced setup: seeded first observation entries" --files "signals/observations.jsonl"`
- After initialising metrics: `--module "calibration" --description "Advanced setup: initialised calibration metrics" --files "calibration/metrics.yaml"`
- After red-line upgrade: `--module "identity/values" --description "Advanced setup: upgraded red lines to structured format" --files "identity/values.yaml"`

If the script isn't found, skip silently — never block setup over audit logging.
