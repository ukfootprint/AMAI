# Evaluation Guide

## When to run

Run the full evaluation suite at three points:
- At setup, before you have filled in any modules (establishes your true baseline)
- At 30 days, once your core modules are populated
- At 90 days, after your first calibration cycle

After 90 days, run a spot check of 5 prompts (one from each task category) at each monthly calibration.

## How long it takes

Full suite (15 prompts × 2 runs × scoring): approximately 90 minutes the first time, 60 minutes once you are familiar with the rubric.

Spot check (5 prompts × 2 runs × scoring): approximately 25 minutes.

## What to do with the results

If delta is strong (average +0.5 or more across all dimensions): your core modules are working. Focus maintenance on keeping them current.

If delta is weak on Voice Match only: revisit identity/voice.md. It is likely too abstract. Add more concrete examples of your actual phrasing.

If delta is weak on Constraint Adherence only: revisit identity/heuristics.yaml. Check the confidence fields — low-confidence entries may be diluting the signal. Check that BRAIN.md instructs the AI to treat high-confidence heuristics as rules.

If delta is weak on Goal Alignment only: check goals/current_focus.yaml is current. This is the most frequently stale file in the system.

If delta is weak across all dimensions: check whether modules are actually loading. Run a session, ask the AI to list every file it loaded, and verify the list matches what you expected from MODULE_SELECTION.md. Misloading is the most common systemic failure.

If no-AMAI scores are already high: your natural communication style and working patterns are already well-aligned. AMAI will provide less marginal uplift for you. Focus on the decision and planning tasks, where context tends to matter most.

## Storing results

Save scored outputs to evaluation/results/ as:
- YYYY-MM-DD_no_amai.md
- YYYY-MM-DD_with_amai.md

Keep a running summary in evaluation/results/SUMMARY.md with one row per evaluation cycle: date, average no-AMAI score, average with-AMAI score, delta, and one-line note on what changed since last cycle.
