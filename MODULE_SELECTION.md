# MODULE_SELECTION.md
*Load this file alongside BRAIN.md at the start of every session.*

This file defines which modules to load for which tasks, which modules must never be loaded together, and what to do when task type is unclear. It exists because "load only what is relevant" is not a method — this file is.

---

## Default Minimal Set

Load these files **unconditionally for every session**, regardless of task type:

| File | Why always |
|------|-----------|
| `identity/values.yaml` | Ethical constraints apply to everything |
| `identity/heuristics.yaml` | Fast decision rules apply to everything |
| `goals/current_focus.yaml` | Ensures outputs align with what matters this week |

Do not load anything beyond this set until the task type is established.

---

## Trigger Table

Once the task type is clear, load the additional modules below. Load only what is listed — do not expand speculatively.

| Task Type | Load in addition to default set |
|-----------|--------------------------------|
| **Writing — any content, comms, copy** | `identity/voice.md` |
| **Writing — positioning or narrative** | `identity/voice.md`, `identity/story.md`, `identity/principles.md` |
| **Decision — fast, low-stakes** | *(default set sufficient)* |
| **Decision — complex or high-stakes** | `identity/principles.md`, `memory/decisions.jsonl` |
| **Strategic planning** | `goals/goals.yaml`, `goals/north_star.md`, `identity/principles.md` |
| **Weekly or monthly review** | `goals/goals.yaml`, `operations/rituals.md` |
| **Research or analysis** | `knowledge/frameworks.md`, `knowledge/domain_landscape.md` |
| **Learning capture** | `knowledge/learning.jsonl` |
| **Outreach — drafting a message** | `identity/voice.md`, `network/circles.yaml`, `network/rhythms.yaml` |
| **Meeting preparation** | `network/contacts.jsonl`, `network/interactions.jsonl` |
| **Relationship management** | `network/circles.yaml`, `network/rhythms.yaml`, `network/contacts.jsonl` |
| **Reflection on a past decision** | `memory/decisions.jsonl`, `memory/failures.jsonl`, `identity/principles.md` |
| **Product or feature thinking** | `goals/north_star.md`, `knowledge/frameworks.md` |
| **End-of-session signal capture** *(advanced)* | `signals/MODULE.md`, `signals/observations.jsonl` |
| **Calibration review** *(advanced)* | `calibration/MODULE.md`, `calibration/pending_review.md`, `calibration/metrics.yaml`, `signals/observations.jsonl` |

---

## Don't-Load List

These modules must **never** be loaded in the contexts below, regardless of apparent relevance.

| Module | Never load when |
|--------|----------------|
| `network/contacts.jsonl` | Any public-facing writing task — names and relationship details must not influence public content |
| `network/interactions.jsonl` | Any public-facing writing task — same reason as above |
| `memory/failures.jsonl` | Unless the task explicitly involves retrospective analysis or learning from past mistakes. Do not load speculatively. |
| `memory/experiences.jsonl` | Unless the task involves personal reflection or narrative work. Do not load for operational tasks. |
| `calibration/divergence.jsonl` | During active task work — this is a review-only file, not a working context file |
| `signals/observations.jsonl` | During active task work — load only at session end for capture, or at calibration review |

**Never load `memory/failures.jsonl` and `network/contacts.jsonl` in the same session** unless the task is explicitly a retrospective involving specific named relationships.

---

## Loading Instructions for the AI

1. **Start with the default set only.** Do not load any additional modules until the task type is established from the user's first message.

2. **If the task type is clear**, load the trigger table row that best matches. If a task spans two types (e.g. writing + decision), load the union of both rows, but apply the don't-load list as a veto.

3. **If the task type is ambiguous**, do not speculate. Ask: *"To load the right context for this session, can you tell me whether this is primarily [Type A] or [Type B]?"* Then load accordingly.

4. **Confirm what you have loaded.** At session start, state explicitly: *"Loaded: [list of files]."* This gives the user immediate visibility into whether context loaded as intended.

5. **Do not reload mid-session** unless the task materially changes. If scope shifts significantly, note it and ask whether to load additional modules.

6. **Staleness check.** Before loading any YAML module, check its `last_updated` field. If `last_updated` is null or more than 60 days ago, flag it: *"[filename] was last updated [date / never]. This context may be outdated — do you want to proceed with it or update it first?"* Then load as instructed.

---

## Quick Reference Card

```
Every session:
  identity/values.yaml
  identity/heuristics.yaml
  goals/current_focus.yaml

+ Writing?         → identity/voice.md
+ Big decision?    → identity/principles.md + memory/decisions.jsonl
+ Planning?        → goals/goals.yaml + goals/north_star.md
+ Relationship?    → network/circles.yaml + network/contacts.jsonl
+ Research?        → knowledge/frameworks.md + knowledge/domain_landscape.md
+ Session end?     → signals/MODULE.md + signals/observations.jsonl
+ Calibration?     → calibration/MODULE.md + calibration/pending_review.md

Never with public writing:
  network/contacts.jsonl
  network/interactions.jsonl

Never speculatively:
  memory/failures.jsonl
  memory/experiences.jsonl
  calibration/divergence.jsonl
  signals/observations.jsonl
```
