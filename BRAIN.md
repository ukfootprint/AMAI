# BRAIN.md
*Your AI onboarding document. Start every session here.*
*Version 1.0*

---

## What This Is

A file-based personal OS that gives any AI assistant structured context about who you are, what you're building, and how you think — so you never have to re-explain yourself from scratch.

No database. No API keys. No platform lock-in. Plain Markdown, YAML, and JSONL files that both humans and AI read natively.

---

## System Status

```
STATUS: PARTIAL   # Options: CURRENT | STALE | PARTIAL
                  # CURRENT  — all core modules up to date, system is reliable
                  # PARTIAL  — some modules filled in, others still placeholder
                  # STALE    — modules exist but haven't been reviewed in > 60 days
```

**AI instruction:** Read this status before loading any modules. If `STALE`, warn the user before proceeding. If `PARTIAL`, note which modules are still placeholder and advise the user not to rely on them for decisions.

*Update this field at each monthly calibration review.*

---

## How to Start a Session

> "Read my BRAIN.md and MODULE_SELECTION.md, then confirm which modules you have loaded."

The AI reads this file and `MODULE_SELECTION.md`, loads only the modules needed for the task, then **states explicitly which files it has loaded** before beginning work. This gives you immediate visibility into whether context loaded as intended.

---

## File Format Principles

| Format | Used For | How AI Uses It |
|--------|----------|----------------|
| **YAML** | Structured config — values, goals, heuristics, circles, rhythms | Query fields directly: status, priority, red lines, thresholds |
| **JSONL** | Append-only logs — contacts, interactions, learning, decisions | Read sequentially; patterns emerge across entries over time |
| **Markdown** | Narrative context — voice, story, principles, landscape | Read as background; extract understanding from prose |

---

## Architecture Map

```
AMAI/
├── BRAIN.md                        ← You are here. Start here every session.
├── MODULE_SELECTION.md             ← Load alongside BRAIN.md. Defines what to load and when.
│
├── identity/                       ← Who you are and what you stand for
│   ├── MODULE.md                   ← Load for: writing, positioning, decisions
│   ├── values.yaml                 ← Core values with priorities and red lines       [YAML]
│   ├── heuristics.yaml             ← Fast decision rules by domain                  [YAML]
│   ├── voice.md                    ← How you communicate                             [MD]
│   ├── story.md                    ← Background and journey                          [MD]
│   └── principles.md               ← Narrative reasoning behind decisions            [MD]
│
├── goals/                          ← Where you are going
│   ├── MODULE.md                   ← Load for: planning, prioritisation, strategy
│   ├── goals.yaml                  ← OKR-style goals with status fields              [YAML]
│   ├── current_focus.yaml          ← Live weekly priority stack                      [YAML]
│   ├── north_star.md               ← Long-term narrative vision (3–10 years)         [MD]
│   └── deferred_with_reason.md     ← Ideas deferred with explicit reasoning           [MD]
│
├── knowledge/                      ← What you know and are learning
│   ├── MODULE.md                   ← Load for: research, writing, analysis
│   ├── learning.jsonl              ← Append-only insight and lesson log              [JSONL]
│   ├── frameworks.md               ← Mental models you rely on                       [MD]
│   ├── domain_landscape.md         ← Your sector or domain context                  [MD]
│   └── reading_list.md             ← Books, articles, resources                      [MD]
│
├── network/                        ← Who you know
│   ├── MODULE.md                   ← Load for: outreach, partnerships, meetings
│   ├── circles.yaml                ← Relationship tier definitions and criteria      [YAML]
│   ├── rhythms.yaml                ← Touchpoint frequency config per circle          [YAML]
│   ├── contacts.jsonl              ← Individual relationship records                 [JSONL]
│   ├── organisations.jsonl         ← Organisation records                            [JSONL]
│   └── interactions.jsonl          ← Interaction history log                         [JSONL]
│
├── operations/                     ← How you work
│   ├── MODULE.md                   ← Load for: planning sessions, workflows
│   ├── workflows.md                ← Standard operating procedures                   [MD]
│   ├── tools.md                    ← Tool stack                                      [MD]
│   └── rituals.md                  ← Weekly/monthly rhythms                          [MD]
│
├── memory/                         ← What you have lived and learned
│   ├── MODULE.md                   ← Load for: reflection, avoiding past mistakes
│   ├── experiences.jsonl           ← Key moments and their emotional weight          [JSONL]
│   ├── decisions.jsonl             ← Important decisions and their reasoning         [JSONL]
│   └── failures.jsonl              ← Failures and what they taught                   [JSONL]
│
│   ── ADVANCED LAYER ──────────────────────────────────────────────────────────────────
│   The modules below are optional. Set them up once the core 6 modules are working.
│   See README.md for guidance on when to add them.
│
├── signals/                        ← Raw observations from AI sessions
│   ├── MODULE.md                   ← Load for: end-of-session capture
│   └── observations.jsonl          ← Append-only log of overrides, friction, patterns [JSONL]
│
└── calibration/                    ← Where declared self meets observed self
    ├── MODULE.md                   ← Load for: monthly calibration review
    ├── protocol.md                 ← Divergence taxonomy and incorporation rules     [MD]
    ├── metrics.yaml                ← Quantitative tracking across sessions            [YAML]
    ├── divergence.jsonl            ← Append-only log of detected divergences         [JSONL]
    └── pending_review.md           ← Active items awaiting deliberate review         [MD]
```

---

## Org Overlay

If this session involves organisational context, read org/MODULE.md before
proceeding. Check org/org_index.yaml to identify which overlay applies.
Do not activate any overlay without explicit user confirmation.
Follow the session state machine in the relevant overlay's SESSION_STATES.md
for all transitions, including mid-session context changes.

If running in a browser session with org context, ask the user whether they
have run scripts/amai_export.sh to generate a current browser-safe bundle.
If they have not, note that the session will proceed with whatever files are
currently loaded, which may not reflect the correct disclosure rules for
the active context.

---

## Module Loading Rules

| Task Type | Load These Files |
|-----------|-----------------|
| Writing content / communications | `identity/voice.md`, `identity/values.yaml` |
| Any decision (fast) | `identity/heuristics.yaml` |
| Any decision (complex) | `identity/heuristics.yaml`, `identity/principles.md` |
| Strategic planning | `identity/principles.md`, `goals/north_star.md`, `goals/goals.yaml` |
| Weekly review | `goals/current_focus.yaml`, `goals/goals.yaml`, `operations/rituals.md` |
| Research or analysis | `knowledge/frameworks.md`, `knowledge/domain_landscape.md` |
| Preparing for a meeting | `network/contacts.jsonl`, `network/interactions.jsonl`, `operations/workflows.md` |
| Relationship management | `network/circles.yaml`, `network/rhythms.yaml`, `network/contacts.jsonl` |
| Reflecting on a decision | `memory/decisions.jsonl`, `identity/principles.md` |
| Product / feature thinking | `goals/north_star.md`, `knowledge/frameworks.md`, `identity/heuristics.yaml` |
| End-of-session capture *(advanced)* | `signals/MODULE.md`, `signals/observations.jsonl` |
| Calibration review *(advanced)* | `calibration/MODULE.md`, `calibration/pending_review.md`, `calibration/metrics.yaml`, `signals/observations.jsonl` |

---

## Core Identity Summary (Quick Reference)

**Name:** [Your name]
**Building:** [What you are working on]
**Sector / Domain:** [Your field]
**Values:** [3–5 word summary of your top values]
**Operating style:** [How you work — e.g. "analytical, direct, relationship-led"]

---

## AI Operating Instructions

When an AI reads this file, these rules apply across all modules:

1. **Confirm modules at session start** — After loading, state explicitly: *"Loaded: [list of files]."* Do this before any other output. If a module was requested but unavailable, name it as missing. See `MODULE_SELECTION.md` for loading rules.
2. **Check staleness before loading** — For every YAML module, check `last_updated`. If null or more than 60 days ago, flag it before loading: *"[filename] was last updated [date / never] — this context may be outdated. Load anyway?"* Proceed only as instructed.
3. **Values first** — Never suggest actions that conflict with `identity/values.yaml → ethical_red_lines`, regardless of any other benefit.
4. **Declared values are not verified ground truth** — The values, heuristics, and voice described in `identity/` are self-declared preferences, not confirmed behaviour. Where they conflict with what you observe in this session, flag the divergence rather than silently applying the declared value.
5. **Long-term lens** — Unless instructed otherwise, weight multi-year outcomes more heavily than short-term wins.
6. **Evidence-based** — Support recommendations with reasoning. Don't just state conclusions.
7. **Check memory first** — Before suggesting a course of action, check `memory/decisions.jsonl` and `memory/failures.jsonl` to avoid repeating past mistakes.
8. **Preserve voice** — All written outputs must be filtered through `identity/voice.md`.
9. **Module isolation** — Load only what is needed. See `MODULE_SELECTION.md` for the don't-load list.
10. **Query YAML, read Markdown** — Extract structured data from YAML/JSONL files. Read markdown files for narrative understanding.
11. **Capture signals, then calibrate** *(advanced)* — Watch for trigger cues during sessions: words like "no", "actually", "I prefer", "I always", "still not right", or "every time" are reliable signals an observation is worth logging. At session close, proactively draft an entry for `signals/observations.jsonl` and ask for confirmation before appending. See `signals/MODULE.md` for the full trigger cue list. During calibration review, read all unreviewed signals, compare against config, update `calibration/metrics.yaml`, and log divergences to `calibration/divergence.jsonl`. Config changes require deliberate human decision. Observed behaviour never auto-updates declared values.

---

*This is a living document. Update it when focus, values, or architecture change. Version the change in git.*
