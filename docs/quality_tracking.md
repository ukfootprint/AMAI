# Quality Tracking for AMAI Pruning

Pruning removes context. This guide explains how to measure whether that removal helps or hurts AI interactions.

---

## Why It Matters

When you prune AMAI, you're making a bet: the removed content wasn't contributing usefully to responses. Without a quality check, that bet is invisible — you only notice a problem later, often mid-interaction when it matters.

Quality tracking gives you a before/after signal. It won't catch everything, but it will catch significant regressions.

---

## The Evaluation Workflow

**Before pruning:**
1. Run: `bash scripts/eval_quality.sh`
2. Open the generated file from `reports/quality_eval_<date>.md`
3. Load your AMAI context into your AI
4. Paste each task and record the confidence self-ratings

**After pruning:**
1. Run: `bash scripts/eval_quality.sh --output reports/quality_eval_<date>_post.md`
2. Repeat the same tasks with updated context
3. Compare ratings

---

## Interpreting Results

| Change | Meaning |
|--------|---------|
| All HIGH → HIGH | Safe prune — no quality impact |
| 1 task drops a level | Borderline — monitor next session |
| 2+ tasks drop a level | Regression — pruning removed critical context |
| Any task drops to LOW | Strong regression — restore immediately |

**Which tasks flag which context:**

- Task 1 (voice/values) — identity context was removed
- Task 2 (weekly priorities) — `current_focus.yaml` was corrupted or cleared
- Task 3 (heuristics under pressure) — decision rules were pruned too aggressively
- Task 4 (domain knowledge) — `knowledge/` module was thinned excessively
- Task 5 (decision framework) — beliefs or heuristics context was lost

---

## Restoring After a Regression

```bash
# Restore a file
mv _archive/[path] [original-path]

# Restore a JSONL entry
# Copy the archived line from _archive/[module]_archived.jsonl back to the source file

# Git restore (if committed before archiving)
git checkout HEAD -- [file]
```

Pruning decisions are logged in `memory/decisions.jsonl` — check there to see what was archived and when.

---

## Frequency

- Run before and after any session where 5+ items are archived
- Spot-check quarterly even without pruning — quality can drift as files go stale
- After any significant update to `identity/values.yaml` or `identity/heuristics.yaml`

---

## Limitations

Self-rated confidence is directional, not precise. The AI's ratings can vary between sessions for reasons unrelated to pruning. Because of this:

- Focus on multi-task trends, not individual task variations
- A single-task drop is a yellow flag; two or more is a red flag
- Treat this as a safety check, not a rigorous benchmark

---

*Run `bash scripts/eval_quality.sh` to generate an evaluation.*
*See `docs/pruning_prompt.md` for the full pruning workflow.*
