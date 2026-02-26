# MAINTENANCE_BUDGET.md
*The minimum viable contract for keeping AMAI useful over time.*

The risk in a system like this is not that it is hard to set up. It is that it gets set up once, goes stale, and then produces authoritative-sounding AI outputs based on outdated context. Stale files are worse than no files — the model treats them as current.

This document defines what upkeep actually looks like, what you can safely skip, and what staleness looks like in practice so you can catch it before it costs you.

---

## The Maintenance Tiers

### Tier 1 — 5 minutes per week (minimum viable)

Do this at the start of each week. If you do nothing else, do this.

| Task | File | Time |
|------|------|------|
| Update this week's priorities | `goals/current_focus.yaml` | 3 min |
| Set `week_of` to today's Monday | `goals/current_focus.yaml` | 30 sec |
| Update `last_updated` in current_focus.yaml | `goals/current_focus.yaml` | 30 sec |
| Glance at `goals/goals.yaml` — anything completed or blocked? | `goals/goals.yaml` | 1 min |

**Why this is the minimum:** The AI's default set includes `goals/current_focus.yaml`. If this file is stale, every session is optimising for last week's priorities.

---

### Tier 2 — 30 minutes per week (recommended)

Do this at your weekly review. Replaces Tier 1 for that week.

| Task | File | Time |
|------|------|------|
| Everything in Tier 1 | — | 5 min |
| Log any notable interactions | `network/interactions.jsonl` | 5 min |
| Log any significant learning | `knowledge/learning.jsonl` | 5 min |
| Note any AI session overrides or friction (signals capture) | `signals/observations.jsonl` | 5 min |
| Review `goals/goals.yaml` — update status fields | `goals/goals.yaml` | 5 min |
| Quick scan of `goals/deferred_with_reason.md` — anything become timely? | `goals/deferred_with_reason.md` | 5 min |

---

### Tier 3 — Monthly review (60–90 minutes)

Do this at month end. This is where the system earns its keep.

| Task | File | Time |
|------|------|------|
| Everything in Tier 2 | — | 30 min |
| Run calibration review | `calibration/pending_review.md`, `calibration/metrics.yaml` | 20 min |
| Update `memory/decisions.jsonl` for any significant decisions this month | `memory/decisions.jsonl` | 10 min |
| Update `last_updated` fields on any modules reviewed this month | All relevant YAML files | 5 min |
| Update `STATUS` in `BRAIN.md` | `BRAIN.md` | 2 min |
| Run `scripts/validate.sh` | terminal | 2 min |

---

### Tier 4 — Quarterly review (2–3 hours)

Do this at quarter-end, alongside quarterly planning.

| Task | File | Time |
|------|------|------|
| Everything in Tier 3 | — | 90 min |
| Review and update identity files | `identity/values.yaml`, `identity/heuristics.yaml`, `identity/voice.md` | 20 min |
| Update goals for the new quarter | `goals/goals.yaml`, `goals/north_star.md` | 20 min |
| Review and update network circles and rhythms | `network/circles.yaml`, `network/rhythms.yaml` | 10 min |
| Calibration meta-review | `calibration/divergence.jsonl` | 15 min |
| Review `memory/failures.jsonl` and `memory/decisions.jsonl` | `memory/` | 15 min |

---

## What Is Safe to Skip

Not everything degrades at the same rate. This table tells you what is safe to miss and for how long.

| File | Safe to skip for | Risk of skipping longer |
|------|-----------------|------------------------|
| `goals/current_focus.yaml` | 1 week | AI optimises for stale priorities — high impact |
| `goals/goals.yaml` | 1 month | Minor drift in strategic context |
| `signals/observations.jsonl` | 2 weeks | Calibration becomes data-sparse; monthly review less useful |
| `network/interactions.jsonl` | 1 month | Relationship context drifts; contact prep less accurate |
| `knowledge/learning.jsonl` | 2 months | Reduces pattern recognition over time; low immediate impact |
| `memory/decisions.jsonl` | 3 months | Increases risk of repeating past mistakes; gradual impact |
| `memory/failures.jsonl` | 3 months | Same as above |
| `identity/` files | 6 months | Low short-term impact; high long-term drift risk |
| `calibration/` | 2 months | Divergences accumulate unreviewed; silent config drift |

**Never safe to skip indefinitely:** `goals/current_focus.yaml`. Every other file has a graceful degradation path. This one doesn't — it is the AI's map for what matters right now.

---

## What Staleness Looks Like in Practice

These are the failure signals that tell you the system has drifted:

**The AI keeps getting your priorities wrong.** It optimises for things you no longer care about. → `goals/current_focus.yaml` is stale.

**The AI's tone is off.** It writes in a style that feels slightly wrong — too formal, too casual, wrong register. → `identity/voice.md` hasn't been reviewed recently, or you have changed.

**The AI suggests things you've already tried and rejected.** → `memory/decisions.jsonl` and `memory/failures.jsonl` are underpopulated.

**The AI applies a rule you've started to disagree with.** → A heuristic in `identity/heuristics.yaml` has become aspirational rather than operational. Either lower its confidence field to `low`, or update the rule.

**The AI recommends someone you've deprioritised.** → `network/contacts.jsonl` circle or `network/interactions.jsonl` hasn't been updated since the relationship changed.

**Calibration review finds nothing.** → Either the system is perfectly coherent (unlikely, especially early on) or `signals/observations.jsonl` is empty because signals aren't being logged. Run `scripts/validate.sh` to check.

---

## The Minimum Sustainable System

If life is demanding and you can only maintain one thing, maintain this:

1. Update `goals/current_focus.yaml` every Monday — 5 minutes
2. Run `scripts/validate.sh` once a month — 2 minutes
3. Do one full Tier 3 review every quarter instead of monthly — 90 minutes four times a year

This is not ideal. But it keeps the core functional. When things calm down, return to Tier 2 weekly.

---

## STATUS Field Guide

Update `BRAIN.md → STATUS` honestly at each review:

| Status | When to use it |
|--------|---------------|
| `CURRENT` | Core modules filled in, reviewed within 60 days, calibration up to date |
| `PARTIAL` | Setup incomplete — some modules still placeholder; or some modules current but others not |
| `STALE` | Files exist but haven't been reviewed in > 60 days; or known to be outdated |

When in doubt, choose `PARTIAL` over `CURRENT`. An AI that knows context may be incomplete will ask before assuming. An AI that is told context is current will not.
