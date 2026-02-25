# Calibration Module
*Advanced Layer — set up after core modules and signals/ are working*
*Load for: calibration reviews, quarterly self-audits*

---

## What This Module Is For

This module monitors the gap between **declared self** (your AMAI configuration — intentional, curated, values-led) and **observed self** (raw session observations from `signals/observations.jsonl` — behavioural, emergent).

That gap is signal. But signal of what depends entirely on its type:

- Behaviour confirming declared configuration → **validation**
- Behaviour revealing something genuinely true and new → **evolution candidate**
- Behaviour diverging from values → **drift warning** — do not auto-incorporate
- Behaviour suggesting a rule needs nuancing → **heuristic refinement candidate**

**The governing principle:** Observed behaviour documents how you actually act. Your AMAI config documents who you intend to be. When they diverge, the question is not "which is right?" but "what does this divergence mean, and who gets to decide?"

The answer is always you. This module surfaces the decision — it never makes it.

---

## Sources of Observed-Self Data

**Default:** `signals/observations.jsonl` — a lightweight session log capturing overrides, friction, positive patterns, and notable AI inferences. See `signals/MODULE.md` for the capture protocol.

**Optional — automated capture tools:** Tools like Daniel Miessler's [PAI](https://github.com/danielmiessler/Personal_AI_Infrastructure) can provide a richer and more continuous signal stream via automated hooks. `signals/observations.jsonl` supplements automated capture with qualitative observations hooks may miss.

In both cases, raw signals are reviewed here and dispositioned — they do not update your AMAI config directly.

---

## Files In This Module

| File | Format | Purpose |
|------|--------|---------|
| `protocol.md` | Markdown | Divergence taxonomy, decision trees, incorporation rules |
| `divergence.jsonl` | JSONL | Append-only log of all detected divergences |
| `pending_review.md` | Markdown | Active CANDIDATEs and WARNINGs awaiting deliberate review |

---

## AI Instructions

### When to load this module
- When you ask to run a calibration review
- During monthly or quarterly reviews (see `operations/rituals.md`)
- When `signals/observations.jsonl` has unreviewed entries (check for entries with no `reviewed` field)

### How to log a divergence
Log to `calibration/divergence.jsonl` using this format:

```jsonl
{
  "date": "YYYY-MM-DD",
  "type": "values|identity|operational|relational",
  "source": "signals_override|signals_friction|signals_pattern|signals_inference|automated_capture|other",
  "signal": "What was observed",
  "brained_ref": "path/to/relevant/file → field or section",
  "tension": "Plain English description of the divergence",
  "disposition": "CONFIRM|CANDIDATE|WARNING|DEFER",
  "notes": ""
}
```

### Disposition definitions

| Code | Meaning | Action |
|---|---|---|
| `CONFIRM` | Observed matches declared. System is coherent. | Log. No review needed. |
| `CANDIDATE` | Possible config improvement. Needs deliberate review. | Add to `pending_review.md` |
| `WARNING` | Behaviour diverging from values. Config is correct; behaviour needs review. | Add to `pending_review.md` as high priority. Do NOT propose config change. |
| `DEFER` | Signal unclear or insufficient data. | Log. Monitor for recurrence. |
| `INCORPORATED` | CANDIDATE reviewed and incorporated into config. | Archive in `divergence.jsonl`. Remove from `pending_review.md`. |
| `REJECTED` | CANDIDATE or WARNING reviewed and rejected. Config unchanged. | Archive. Remove from `pending_review.md`. |

### Hard rules

1. **Never auto-incorporate a WARNING into config.** A WARNING means behaviour diverged from values — the config is correct, the behaviour needs correction.
2. **Never reclassify a WARNING as a CANDIDATE without explicit instruction.**
3. **A CANDIDATE requires at least 2 independent observations before recommending incorporation.** One-off signals are noise; patterns are signal.
4. **Ethical red lines are never candidates for softening.** If observed behaviour involves crossing a red line (see `identity/values.yaml → ethical_red_lines`), classify as WARNING regardless of frequency.
5. **Recommend, don't decide.** Present the tension, the evidence, and two options. The user makes the call.

---

## Signal Source → Config File Mapping

| Signal Source | Config File(s) | Possible Divergence Type |
|---|---|---|
| Override entries | `identity/heuristics.yaml` | Heuristic exception or new rule candidate |
| Friction entries | `identity/voice.md`, `identity/heuristics.yaml` | Voice calibration or heuristic refinement |
| Pattern entries | `identity/values.yaml`, `goals/current_focus.yaml` | Drift warning or focus reprioritisation |
| Inference entries | `identity/story.md`, `identity/voice.md` | Identity model correction |
| Positive entries | Any config file | Confirmation signal — validates config |

---

## Incorporation Decision Protocol

When a CANDIDATE has 2+ independent signals and is ready for review:

```
1. Does this touch an ethical red line?
      YES → Reclassify as WARNING. Stop here.
      NO  → Continue.

2. Is this consistent (3+ signals) or still emerging (1–2 signals)?
      EMERGING → Keep as CANDIDATE, continue watching.
      CONSISTENT → Continue.

3. Does incorporating this strengthen or weaken values alignment?
      WEAKENS → Reclassify as WARNING. Stop here.
      NEUTRAL/STRENGTHENS → Continue.

4. What exactly would change in config?
      Identify the specific field, file, and proposed change.

5. Present to the user with:
      - The pattern observed
      - The current config
      - The proposed change
      - Why this strengthens (or at least doesn't weaken) the system

6. If approved:
      - Update the relevant config file
      - Update disposition in divergence.jsonl to INCORPORATED
      - Remove from pending_review.md
      - Add a memory/decisions.jsonl entry explaining what changed and why
```

---

*This module is the immune system of AMAI. It doesn't prevent change — it ensures change is deliberate.*
