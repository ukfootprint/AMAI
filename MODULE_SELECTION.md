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
| **Decision — complex or high-stakes** | `identity/principles.md`, `identity/beliefs.yaml`, `memory/decisions.jsonl` |
| **Strategic planning** | `goals/goals.yaml`, `goals/north_star.md`, `identity/principles.md`, `identity/beliefs.yaml` |
| **Weekly or monthly review** | `goals/goals.yaml`, `operations/rituals.md` |
| **Research or analysis** | `knowledge/frameworks.md`, `knowledge/domain_landscape.md`, `identity/beliefs.yaml` |
| **Learning capture** | `knowledge/learning.jsonl` |
| **Outreach — drafting a message** | `identity/voice.md`, `network/circles.yaml`, `network/rhythms.yaml` |
| **Meeting preparation** | `network/contacts.jsonl`, `network/interactions.jsonl` |
| **Relationship management** | `network/circles.yaml`, `network/rhythms.yaml`, `network/contacts.jsonl` |
| **Reflection on a past decision** | `memory/decisions.jsonl`, `memory/failures.jsonl`, `identity/principles.md` |
| **Product or feature thinking** | `goals/north_star.md`, `knowledge/frameworks.md` |
| **End-of-session signal capture** *(advanced)* | `signals/MODULE.md`, `signals/observations.jsonl` |
| **Calibration review** *(advanced)* | `calibration/MODULE.md`, `calibration/pending_review.md`, `calibration/metrics.yaml`, `signals/observations.jsonl` |
| **Content generation — writing, advice, plans, proposals** *(advanced — conscience Phase 1)* | `skills/conscience/SKILL.md` in background scan mode — **only if** `ethical_red_lines` contains at least one structured entry (not all placeholders or strings) |
| **org: internal communication** | `org/MODULE.md` + org overlay (internal) + `identity/voice.md` + `identity/heuristics.yaml` |
| **org: client-facing deliverable** | `org/MODULE.md` + org overlay (client_facing) — personal Tier 1/2 excluded |
| **org: thought leadership** | `org/MODULE.md` + org overlay (thought_leadership) + `identity/voice.md` |
| **org: executive communication** | `org/MODULE.md` + org overlay (executive_comms) + `goals/current_focus.yaml` |
| **org: context switch mid-session** | Follow `SESSION_STATES.md` transition rules — flag before reloading |

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
| `skills/conscience/SKILL.md` | Pure research or reading tasks where no content is being generated — conscience monitors generation, not reading |
| `identity/beliefs.yaml` | Pure writing or editing tasks, network/relationship tasks, and operations tasks — beliefs are reasoning context, not communication style or operational guidance |

**Never load `memory/failures.jsonl` and `network/contacts.jsonl` in the same session** unless the task is explicitly a retrospective involving specific named relationships.

---

## Loading Instructions for the AI

1. **Start with the default set only.** Do not load any additional modules until the task type is established from the user's first message.

2. **If the task type is clear**, load the trigger table row that best matches. If a task spans two types (e.g. writing + decision), load the union of both rows, but apply the don't-load list as a veto.

3. **If the task type is ambiguous**, do not speculate. Ask: *"To load the right context for this session, can you tell me whether this is primarily [Type A] or [Type B]?"* Then load accordingly.

4. **Confirm what you have loaded.** At session start, state explicitly: *"Loaded: [list of files]."* This gives the user immediate visibility into whether context loaded as intended.

5. **Do not reload mid-session** unless the task materially changes. If scope shifts significantly, note it and ask whether to load additional modules.

6. **Staleness check.** Before loading any YAML module, check its `last_updated` field. If `last_updated` is null or more than 60 days ago, flag it: *"[filename] was last updated [date / never]. This context may be outdated — do you want to proceed with it or update it first?"* Then load as instructed.

7. **For org-context sessions:** always confirm which org and context type before loading any overlay. Never activate an overlay speculatively. Follow the state machine in `org/overlays/<org_id>/SESSION_STATES.md` for all transitions. Run `scripts/amai_export.sh` to generate a browser-safe bundle before any browser-based org session.

---

## Org-Aware Loading Rules

When the user indicates they are working in a specific organisational context (e.g. "we're writing for [org name]", "activate [org] overlay", "this is for a client deliverable"), load the following in addition to the trigger table row:

| Org file | When to load |
|----------|-------------|
| `org/overlays/{org}/brand_voice.md` | Any writing, communication, or content task for that org |
| `org/overlays/{org}/behaviour_bands.yaml` | Any session where personal defaults need to flex for org context |

**Brand voice takes priority over personal voice for org-facing content.** When both `identity/voice.md` and an org `brand_voice.md` are loaded, apply the org brand voice for all content produced for that org. Personal voice applies to everything outside that org context.

**Behaviour bands narrow the operating range — they never expand it.** If a band would require acting against a personal value or red line, the personal value wins. Behaviour bands adjust *how* you work, not *what* you will or won't do.

**Loading order in an org session:**
1. Default set (values, heuristics, current_focus)
2. `org/overlays/{org}/brand_voice.md` — apply immediately to all content
3. `org/overlays/{org}/behaviour_bands.yaml` — apply to behaviour calibration
4. Task-specific modules from trigger table (voice.md loaded but deferring to brand voice)

**If no org overlay is active**, these files are not loaded and do not affect the session.

---

## Domain-Aware Knowledge Loading

When a task clearly relates to a specific domain, load domain-specific knowledge files alongside the general knowledge files.

### Domain Detection

Match tasks to domains using any of these signals:

| Signal | Example |
|--------|---------|
| User explicitly names the domain | "this is for an EdTech client", "re: the AMAI build" |
| Task vocabulary matches domain tags | "MIS", "academy trust", "Pupil Premium" → edtech |
| Task context matches domain description | competitive analysis of LMS platforms → edtech |
| User mentions a domain ID directly | "load the ai_infrastructure domain" |

Check `knowledge/domains/domain_index.yaml` for the active domain list and their tags.

### Loading Rules

1. **If a single domain matches clearly**: load `{domain}/frameworks.md` and `{domain}/landscape.md` (if it exists) alongside `knowledge/frameworks.md`.
2. **If multiple domains match**: load the most specific one. If genuinely ambiguous, ask: *"This task seems to relate to both [Domain A] and [Domain B] — which should I use for context?"*
3. **If no domain matches**: load general knowledge files only. Do not load all domains speculatively.
4. **Domain files supplement, not replace, general files.** Always load `knowledge/frameworks.md`; domain files add depth on top.

### Domain Loading Confirmation

When loading a domain, say: *"Loaded [domain label] knowledge overlay alongside general frameworks."*

### Inactive Domains

Domains with `active: false` in `domain_index.yaml` are not loaded. If a task clearly relates to an inactive domain, note it: *"I have a [domain] knowledge directory, but it's marked inactive. Want me to load it anyway?"*

---

## Mid-Session Scope Changes

Real sessions frequently shift scope. A task that starts as writing becomes strategy; a strategy conversation surfaces a relationship consideration. The trigger table handles session start — this section handles scope drift.

### The rule

If the nature of the task changes significantly mid-session, the AI should flag the shift explicitly before loading new modules or continuing with the existing set.

### What "significantly" means

A scope change is significant if it crosses a module boundary — that is, if the new task type would require loading a module not currently loaded, or if it makes a currently loaded module actively misleading (e.g. a writing task that becomes a retrospective analysis would now warrant loading memory/failures.jsonl, which is on the don't-load-by-default list).

### The flagging protocol

When the AI detects a significant scope change, it should say:

"This looks like it has shifted from [original task type] to [new task type]. To handle this well I should [load X / unload Y / add Z]. Should I do that, or would you prefer to keep the current context?"

Do not load additional modules silently. Do not ignore the shift and continue with an incomplete module set. Always ask.

### When not to flag

Minor expansions within the same task type do not require flagging. If a writing task expands to cover a related topic but remains a writing task, continue without interruption. Use judgement — the goal is to catch genuine boundary crossings, not to ask permission for every small turn.

### Unloading

If a scope change makes a currently loaded module actively unhelpful or potentially misleading, note this in the flag: "I also have [module] loaded from the earlier task — this may not be relevant now and could conflict. Should I set it aside?" The human decides.

---

## Quick Reference Card

```
Every session:
  identity/values.yaml
  identity/heuristics.yaml
  goals/current_focus.yaml

+ Writing?         → identity/voice.md
+ Big decision?    → identity/principles.md + identity/beliefs.yaml + memory/decisions.jsonl
+ Planning?        → goals/goals.yaml + goals/north_star.md + identity/beliefs.yaml
+ Research?        → knowledge/frameworks.md + knowledge/domain_landscape.md + identity/beliefs.yaml
+ Relationship?    → network/circles.yaml + network/contacts.jsonl
+ Session end?     → signals/MODULE.md + signals/observations.jsonl
+ Calibration?     → calibration/MODULE.md + calibration/pending_review.md
+ Generating content (advanced)? → skills/conscience/SKILL.md [background, only if structured red lines exist]
+ Org context?      → org/overlays/{org}/brand_voice.md + org/overlays/{org}/behaviour_bands.yaml
                      (brand voice overrides identity/voice.md for org-facing content)
+ Domain-specific? → check domain_index.yaml → load {domain}/frameworks.md + {domain}/landscape.md
                      (alongside, not instead of, knowledge/frameworks.md)

Never with public writing:
  network/contacts.jsonl
  network/interactions.jsonl

Never speculatively:
  memory/failures.jsonl
  memory/experiences.jsonl
  calibration/divergence.jsonl
  signals/observations.jsonl
```

---

## Onboarding Stage Reference

After completing all three onboarding stages, a full AMAI profile includes:

| Stage | Files Populated |
|-------|----------------|
| **Stage 1** (Quickstart) | `identity/values.yaml`, `identity/heuristics.yaml`, `goals/current_focus.yaml` |
| **Stage 2** (Foundation) | `identity/voice.md`, `goals/north_star.md`, `goals/goals.yaml`, `identity/beliefs.yaml`, `knowledge/frameworks.md`, `knowledge/domain_landscape.md` |
| **Stage 3** (Full Core) | `identity/story.md`, `identity/principles.md`, `operations/rituals.md`, `operations/workflows.md`, `network/circles.yaml`, `memory/decisions.jsonl` (seed), `memory/experiences.jsonl` (seed) |

**Optional additions (beyond Stage 3):** org overlays (`org/overlays/{org}/`), knowledge domains (`knowledge/domains/{id}/`), contacts and interactions (`network/contacts.jsonl`, `network/interactions.jsonl`).

After Stage 3, the full module trigger table above applies. The default minimal set handles every session; load additional modules as task type dictates.
