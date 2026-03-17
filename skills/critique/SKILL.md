---
name: critique
description: >
  Multi-level AMAI-aware critique — from supportive reviewer to hostile critic.
  Uses the user's own values, frameworks, and domain context as critique lenses.
  Trigger phrases include: "critique this", "review this critically",
  "find holes in this", "what's wrong with this", "devil's advocate",
  "tear this apart", "give me honest feedback", "stress test this",
  "critical friend", "hostile critic", "level 1 review", "level 5 critique",
  "find every hole", "give me gentle feedback", "supportive review".
version: 0.1.0
triggers:
  - "critique this"
  - "review this critically"
  - "find holes in this"
  - "what's wrong with this"
  - "devil's advocate"
  - "tear this apart"
  - "give me honest feedback"
  - "stress test this"
  - "critical friend"
  - "hostile critic"
  - "level 1 review"
  - "level 5 critique"
tools:
  - Read
  - Bash
---

The critique skill delivers AMAI-aware critique at five levels of intensity. It is not
a generic "find problems" prompt — it uses the user's own declared values, heuristics,
frameworks, and domain context as the evaluation criteria. The result is critique that
reflects this person's judgment, not a generic standard.

**Path convention:** All user data file paths (identity/, signals/, calibration/, etc.) resolve to `${AMAI_USER_ROOT}` — the user's personal AMAI directory, set in `~/.amai/config.yaml`. If not configured, fall back to `${CLAUDE_PLUGIN_ROOT}`.

---

## Critique Levels

### Level 1 — Supportive Reviewer

**Tone:** Encouraging, constructive. Lead with what's working.

**Structure:**
- Open with what is genuinely strong (specific, not generic: name why it works)
- Offer 2–3 suggestions framed positively: "You could strengthen X by..."
- Close with the most important single improvement

**AMAI context used:**
- `identity/voice.md` — is the writing consistent with the user's voice?
- `identity/values.yaml` — does the content align with stated values?

**Output format:** Prose paragraphs. No numbered lists of failures. Warm register.

**When to use:** Early drafts, creative work, when the user needs confidence alongside improvement.

---

### Level 2 — Critical Friend

**Tone:** Direct but kind. Balanced — strengths and weaknesses given equal weight.

**Structure:**
1. What's strong and why (specific, not generic praise)
2. What needs work and why (specific issues, not vague "could be better")
3. Concrete suggestions (rewritten sentences, alternative framings, missing elements)

**AMAI context used:**
- `identity/values.yaml` — apply as evaluation criteria: does this work reflect stated values?
- `identity/heuristics.yaml` — apply user's own decision rules as critique lenses
- `knowledge/frameworks.md` — apply user's mental models to evaluate the argument

**Output format:** Structured prose with clear sections.

**When to use:** Work in progress that needs honest feedback before sharing.

---

### Level 3 — Devil's Advocate

**Tone:** Deliberately argumentative. Takes the opposing position regardless of the AI's actual assessment. No hedging.

**Structure:**
1. State the strongest counter-argument to the user's position
2. Identify the weakest assumptions: what must be true for this to work?
3. Name the audience or stakeholder who would most disagree — articulate their objection in their voice
4. Surface what's been left unsaid or assumed

**AMAI context used:**
- `knowledge/frameworks.md` — use the user's own frameworks against their argument
- `knowledge/domain_landscape.md` — ground objections in real market and domain context
- `identity/values.yaml` — flag if the position conflicts with stated values, or if it doesn't but arguably should

**Output format:** Written as if from an informed sceptic. No softening language.

**When to use:** Testing a proposal, preparing for tough questions, pressure-testing strategy.

---

### Level 4 — Rigorous Examiner

**Tone:** Academic, precise, dispassionate. Not hostile, but unsparing.

**Structure:**
1. **Evidence audit** — for each substantive claim: what's the evidence? Is it sufficient? What would falsify this?
2. **Logic check** — identify logical gaps, unsupported leaps, or circular reasoning
3. **Completeness check** — what has been omitted? What alternatives were not considered?
4. **Assumptions register** — list every assumption, stated and unstated; grade each: safe / questionable / unsupported
5. **Verdict** — overall assessment: sound, partially sound, or unsound — with specific reasons

**AMAI context used:**
- `knowledge/frameworks.md` — apply relevant frameworks as evaluation criteria
- `memory/decisions.jsonl` — reference past decisions on similar topics (if file has entries)
- `identity/heuristics.yaml` — flag any heuristic violations

**Output format:** Numbered findings with severity (minor, significant, critical). Summary verdict at end.

**When to use:** Final review before publishing, investment decisions, policy documents.

---

### Level 5 — Hostile Critic

**Tone:** Precise, not polite. Assumes the work must justify itself. No credit for effort or intention.

**Structure:**
1. **Failures** — what is factually wrong, logically broken, or unsupported? List each with evidence.
2. **Unproven assumptions** — what is assumed without justification? For each: what would need to be true, and is there any reason to believe it?
3. **Missing counter-arguments** — what objections exist that have not been addressed? Articulate each as the strongest opponent would.
4. **Structural weaknesses** — where does the argument rely on weakest evidence? Where would a single changed fact collapse the conclusion?
5. **The question you haven't answered** — what is the one question, asked in a boardroom or under cross-examination, that would expose the biggest gap?

**AMAI context used:**
- All context from Levels 1–4, plus:
- `goals/north_star.md` — does this work actually advance the user's long-term direction, or is it a distraction?
- `identity/values.yaml → ethical_red_lines` — does anything here approach a declared red line?

**Output format:** Numbered items under each heading. No softening language. Final line: the single most important thing to fix.

**When to use:** High-stakes deliverables, board papers, public commitments, anything where being wrong has real consequences.

---

## Level Detection

Parse the user's invocation to determine the requested level:

| User says | Level |
|-----------|-------|
| A number: "level 3", "L3", "critique level 3" | Use that level (1–5) |
| "devil's advocate" | Level 3 |
| "hostile critic" | Level 5 |
| "critical friend" | Level 2 |
| "supportive review" or "gentle feedback" | Level 1 |
| "rigorous examiner" or "evidence audit" | Level 4 |
| "tear this apart" or "find every hole" | Level 5 |
| "critique this" or "review this" with no level | **Level 2 (default)** |

**Default behaviour:** If no level is specified, default to Level 2 and inform the user:
> "Running at Level 2 (Critical Friend). Say 'level 5' if you want the hostile version."

---

## Context Loading

Before running critique at any level, load the following AMAI modules:

| Level | Modules to load |
|-------|-----------------|
| All   | `identity/values.yaml`, `identity/heuristics.yaml` |
| 2+    | Also load `knowledge/frameworks.md` |
| 3+    | Also load `knowledge/domain_landscape.md` |
| 4+    | Also load `memory/decisions.jsonl` if it has entries |
| 5     | Also load `goals/north_star.md` |

**Staleness note:** If any loaded module has `last_updated` > 60 days ago (or null), mention it:
> "Note: [module] hasn't been updated in [N] days — critique may not fully reflect your current position."

Do not refuse to proceed if modules are stale or placeholder — critique still has value, just note the caveat.

---

## What to Critique

The skill works on whatever the user provides:
- Text pasted into the conversation
- A document (ask user to share or reference it)
- A plan or strategy described in conversation
- A draft email, proposal, or presentation
- An idea articulated verbally
- An AMAI file (e.g., `/amai:critique level 4 — review my MODULE_SELECTION.md`)

If the user says "critique this" but hasn't provided content, ask:
> "What would you like me to critique? Paste text, describe your idea, or tell me which file to review."

---

## Applying AMAI Context in Critique

This is what distinguishes `/amai:critique` from a generic review prompt. Always ground
critique observations in the user's own declared context — never critique generically.

**Values as criteria:**
> "Your stated value of [X] suggests this section should emphasise [Y], but it currently prioritises [Z]."

**Heuristics as tests:**
> "Your heuristic '[rule]' (confidence: high) applies here. The current approach appears to violate it because [reason]."

**Frameworks as lenses:**
> "Applying your [framework name] framework to this: [analysis]."

**Domain context as grounding:**
> "In the context of [domain landscape point], the assumption that [X] may not hold because [Y]."

**North star alignment (Level 5 only):**
> "Your north star describes [vision]. This proposal moves toward/away from that because [reason]."

If a relevant module is missing or placeholder, proceed but note it:
> "I don't have your frameworks loaded yet — running this critique against general standards rather than your personal mental models. Run /amai:setup 2 to populate this."

---

## Entry Reference Logging

After completing a critique, append entries to `calibration/entry_references.jsonl` for each
AMAI entry that was **explicitly referenced** in the critique output — i.e., cited by name
using the language patterns above (e.g., "Applying your [framework name] framework...",
"Your heuristic '[rule]' applies here...", "Your stated value of [X]...").

**For frameworks used as lenses** (slugify the section heading: lowercase, spaces → underscores):

```jsonl
{"date": "YYYY-MM-DD", "entry_id": "FRAMEWORK_SLUG", "entry_type": "framework", "source_file": "knowledge/frameworks.md", "event": "critique_applied", "context": "Level N critique of [TOPIC]", "outcome": "applied"}
```

**For values used as criteria:**

```jsonl
{"date": "YYYY-MM-DD", "entry_id": "VALUE_ID", "entry_type": "value", "source_file": "identity/values.yaml", "event": "critique_applied", "context": "Level N critique of [TOPIC]", "outcome": "applied"}
```

**For heuristics used as tests:**

```jsonl
{"date": "YYYY-MM-DD", "entry_id": "HEURISTIC_ID", "entry_type": "heuristic", "source_file": "identity/heuristics.yaml", "event": "critique_applied", "context": "Level N critique of [TOPIC]", "outcome": "applied"}
```

**Rules:**
- Only log entries that were **explicitly referenced** in the critique output — not every entry loaded into context.
- Do not log entries that were loaded but not cited.
- For framework slugs: take the section heading, lowercase, replace spaces with underscores (e.g., "First Principles Thinking" → `first_principles_thinking`).
- Batch all reference entries and append them **after** the critique is complete, not during.
- `entry_id` must match the `id` field in the source file, or (for frameworks) the slugified section heading.
- If `calibration/entry_references.jsonl` does not exist, skip silently — never block critique output.
