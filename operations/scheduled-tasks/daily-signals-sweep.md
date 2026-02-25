# Scheduled Task: Daily Signals Sweep
*Task name: `daily-signals-sweep`*
*Schedule: Every day at your preferred end-of-day time (`0 18 * * *` for 6pm)*
*Belongs to: Advanced Layer*

---

## Purpose

End-of-day prompt to capture notable observations from the day's AI sessions into `signals/observations.jsonl`. Acts as a backstop for anything that wasn't captured in-session by the AI's proactive offer (BRAIN.md instruction 8).

---

## Prompt (self-contained — suitable for autonomous run)

```
You are running the daily end-of-day signals sweep for [Your name]'s AMAI system.

Objective: Capture notable observations from today's AI sessions into the signals log, so the calibration system has material to work with.

---

Step 1: Check what's already been captured today

Read the file at: [path to your AMAI folder]/signals/observations.jsonl

Note any entries dated today (YYYY-MM-DD format) so you don't duplicate them. If the file is empty or has no entries for today, proceed to Step 2.

---

Step 2: Ask about today's AI sessions

Say: "End-of-day signals sweep. Did anything happen in today's AI sessions worth capturing? I'm looking for: suggestions you overrode or edited heavily, anything that felt off-brand or kept needing correction, anything that felt surprisingly right, or a pattern you've noticed recurring. If today was uneventful, just say so and I'll close out."

If nothing notable happened, confirm there's nothing to log and end the task.

---

Step 3: Draft entries

For each notable session or observation described, draft a JSONL entry using this exact schema:

{"date": "YYYY-MM-DD", "context": "one line: what the session was about", "signals": ["Override: ...", "Friction: ...", "Positive: ...", "Pattern: ...", "Inference: ..."], "possible_divergence": "optional", "config_ref": "optional — e.g. identity/heuristics.yaml → rule_id"}

Signal prefixes:
- Override: — you rejected or significantly edited an AI suggestion
- Friction: — something required repeated correction or felt consistently off
- Positive: — something felt unexpectedly right or on-brand
- Pattern: — this is the nth time you've noticed the same thing
- Inference: — the AI made an assumption about you worth examining

Show the drafted entries before writing anything.

---

Step 4: Confirm before writing

Ask: "Shall I append these to signals/observations.jsonl?" Wait for explicit confirmation. Do not write without it.

---

Step 5: Append confirmed entries

Append each confirmed entry as a new line to:
[path to your AMAI folder]/signals/observations.jsonl

CRITICAL: Append only. Never overwrite or delete existing content.

---

Step 6: Confirm and close

Confirm how many entries were logged. Remind the user that the monthly calibration review will process these — no action needed until then.

---

Hard constraints:
- Never append without explicit confirmation
- Never overwrite, truncate, or delete existing JSONL content
- Never perform calibration review or update any config file — signal capture only
- If the user is vague, ask for a specific example rather than inferring
- If the user is not available, end the task gracefully without writing anything
```

---

## How to activate this task

Update `[path to your AMAI folder]` in the prompt above to your actual file path, then:

**Via a scheduling tool:** Use any task scheduler (cron, macOS Automator, Windows Task Scheduler) to run this prompt at your preferred time.

**Manually:** Run by saying to any AI assistant: "Run my daily signals sweep" and paste the prompt above.
