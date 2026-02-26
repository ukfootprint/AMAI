# Evaluation Guide

*How to verify that AMAI is actually improving your AI interactions.*

AMAI makes an implicit promise: an AI that knows your context will behave more like you, respect your constraints, and stay aligned with your current goals. This guide tells you how to test that promise — in under two hours, twice a year.

---

## When to Run

| When | Why |
|------|-----|
| **Setup** — after filling in your core identity modules | Establishes your baseline before any context is loaded |
| **90-day mark** | First meaningful check: has context improved alignment? |
| **Annually** | Ongoing verification; also surfaces whether AMAI has drifted |

Don't run an evaluation during a period when your AMAI context is significantly stale (`STATUS: STALE`). Fix the staleness first — otherwise you're measuring stale context, not the system.

---

## Step 1 — Run the Baseline (45 minutes)

Open a fresh AI session with **no AMAI context loaded** — no Projects files, no custom instructions, no file uploads. You want the model's default behaviour.

Run all 25 prompts from `baseline_prompts.md` in one session. Copy each response into a new file:

```
evaluation/results/no_amai_baseline.md
```

Format: paste each prompt as a header, then the response below it. Don't edit responses. Label the file with the date and model used.

---

## Step 2 — Run with AMAI Context (45 minutes)

Open a new session and load your AMAI context. For desktop/code assistant environments: point the AI at your BRAIN.md. For browser sessions: upload your core files per the AI Compatibility section in README.md.

Start the session with:

> "Read my BRAIN.md and MODULE_SELECTION.md, then confirm which modules you have loaded."

Verify the confirmation lists the modules you expect. If modules are missing or stale flags appear, note them — don't abort, but record the issue.

Run the same 25 prompts in the same order. Save results to:

```
evaluation/results/with_amai_v[n].md
```

Where `[n]` is your version number (start at 1, increment each time you run).

---

## Step 3 — Score Both Sets (30 minutes)

Use `rubric.md` to score each response on three dimensions (1–3 each):

- **Voice** — does it sound like you?
- **Constraints** — did it respect your values and heuristics?
- **Goals** — is it aligned with your current focus?

Score the baseline first, then the AMAI version. Use the scoring sheet template in `rubric.md`. Save your completed scoring sheet in:

```
evaluation/results/scores_v[n].md
```

---

## Step 4 — Interpret the Delta

### What a meaningful improvement looks like

A delta of **+1.5 or more per dimension** (averaged across all 25 prompts) represents a meaningful improvement. Below that, the difference may be within normal variation.

| Delta | Interpretation |
|-------|---------------|
| +2 or more | Strong signal — AMAI context is significantly improving alignment |
| +1 to +1.9 | Solid improvement — context is working, especially in primary dimensions |
| +0.5 to +0.9 | Marginal — context is loading but not strongly influencing output |
| < +0.5 | Weak or negligible — likely a context quality or loading problem |
| Negative | Context may be hurting — stale or conflicting modules |

### What to look at by dimension

**Voice delta is low:** Your `identity/voice.md` may be under-specified. Add more concrete examples of phrasing you do and don't use. Hyper-specific beats vague.

**Constraints delta is low:** Check that `identity/values.yaml` red lines are filled in (not placeholder), and that `identity/heuristics.yaml` has real rules with high confidence set. Generic placeholders won't influence outputs.

**Goals delta is low:** `goals/current_focus.yaml` may be stale or too vague. Specific, concrete priorities ("close the contract with [company type] this week") give the AI more to work with than general goals.

**Privacy fail on Category D:** `MODULE_SELECTION.md` don't-load rules are not being followed. Check your session-start confirmation — was `network/contacts.jsonl` listed as loaded for a writing task?

---

## Step 5 — Record and Act

After scoring, write 2–3 sentences summarising what you found. Save to your scores file. Then:

- If Voice is weak → refine `identity/voice.md`
- If Constraints is weak → populate or sharpen `identity/values.yaml` and `identity/heuristics.yaml`
- If Goals is weak → update `goals/current_focus.yaml` and check `goals/goals.yaml` is current
- If a module was flagged stale → update it and log the update date
- If the overall delta is strong → note this in `memory/decisions.jsonl` as evidence the system is working

---

## Practical Notes

**Don't prompt-engineer between runs.** Run the prompts as written. The point is to measure the system, not your prompting skill.

**Use the same model for both runs.** Different models have different default behaviours. A delta from switching models is not a delta from AMAI.

**Score independently.** Score the baseline before you score the AMAI version. Looking at both simultaneously introduces bias toward seeing improvement.

**20 manually-scored prompts run twice a year is enough.** You don't need automation. You need consistency. Same prompts, same model, same rubric, same scorer.

**The most important single check:** Category B (decision prompts) scored on constraints. If AMAI context isn't moving the needle on constraint adherence, the core promise isn't being kept.
