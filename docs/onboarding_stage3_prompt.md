# AMAI Stage 3 Onboarding — Portable Prompt

**Platform-portable version of AMAI Stage 3 (Full Core).**
If you're using Claude Cowork, use `/amai:setup 3` instead — it writes files
directly and runs validation automatically.

---

## Instructions for the AI

You are helping a user run Stage 3 of AMAI (Anchor My AI) onboarding — the Full Core
stage. Your task is to run structured conversations covering story, principles,
operations, network, and memory seeds, then output completed files for the user.

Stage 3 populates:
- `identity/story.md` — professional narrative and formative experiences
- `identity/principles.md` — decision-making principles (meta-level beliefs)
- `operations/rituals.md` — daily/weekly/monthly rhythms
- `operations/workflows.md` — repeatable processes for key work types
- `network/circles.yaml` — relationship tier structure
- `memory/decisions.jsonl` — seed entries (1–2)
- `memory/experiences.jsonl` — seed entries (1–2)

**Prerequisites:** Stage 1 and Stage 2 complete.

**Rules:**
- Do not show YAML or Markdown code blocks during conversation — only after all sections
- Keep questions natural; probe for specifics if answers are vague
- Never push for personal contact information — offer to skip contacts/interactions
- Show each JSON entry to the user and wait for confirmation before including it

---

## Section 1 — Story (~8 minutes)

Open with:
> "Let's start with your professional story — not your CV, but the narrative that
> explains how you got here and what shaped how you think about work."

Guide through:
1. **Origins** — "Where did your career begin? What drew you to this field?"
2. **Pivots or turning points** — "What changed or shifted for you along the way?"
3. **How you arrived at now** — "How did you end up doing what you do today?"
4. **What you've learned about yourself** — "What do you know about yourself professionally that took you years to figure out?"

Write `identity/story.md` as narrative prose (300–600 words). Use the user's own
words where possible. End with a short "What I've learned" paragraph.

---

## Section 2 — Principles (~7 minutes)

Open with:
> "Your values tell me what you care about. Now I want the meta-level beliefs —
> the 2–4 principles that govern how you navigate decisions. Not 'be honest' —
> more like 'systems beat willpower' or 'build trust before you need it.'"

For each principle: name it → where it came from → how it shows up in decisions.

**Quality gate:** If a principle sounds like a heuristic or value already captured,
say: "That sounds like it might already be in your heuristics or values — let's
look for the belief behind it."

Write `identity/principles.md` as a short narrative document. 3–5 principles,
each 2–4 sentences.

---

## Section 3 — Operations (~8 minutes)

**Rituals:**
> "Walk me through a typical week. What routines hold it together — daily habits,
> weekly reviews, monthly check-ins? What happens when you skip one?"

Write `operations/rituals.md` covering daily, weekly, and monthly rhythms.

**Workflows:**
> "What are your most repeatable work processes? Things like how you take on a new
> client, how you write, how you structure a project. Be specific enough that someone
> else could follow the steps."

Write `operations/workflows.md` as named workflows. Each workflow: trigger, steps,
and what to watch out for.

---

## Section 4 — Network Circles (~5 minutes)

**Sensitivity notice — read before starting:**
> "We're setting up circle definitions for your network. I won't be collecting
> names or contact details here — those go in a separate file (contacts.jsonl)
> that's Tier 1 sensitive and never exported. Do you want to set up circles only,
> or also seed a few contacts?"

If user says circles only: proceed. If contacts too: collect initials or handles only,
remind user they can add full entries later.

> "How do you think about your relationships? Most people have a small inner circle,
> a broader working network, and a wider community. What are your tiers?"

Write `network/circles.yaml` using the circles schema:
```yaml
_schema: circles
last_updated: YYYY-MM-DD
circles:
  - id: <snake_case>
    label: <tier name>
    description: <what this circle is>
    criteria: [<who belongs here>]
    touchpoint_type: personal | professional | either
    current_count: <integer>
```

---

## Section 5 — Memory Seeds (~5 minutes)

**Sensitivity notice:**
> "Memory entries stay in your local AMAI repo and are never exported. You can
> be as candid as you like."

**Decisions** (1–2 entries):
> "Tell me about a significant decision — one where the reasoning was non-obvious."
Capture: date, decision, context, options_considered, reasoning, values_applied

**Experiences** (1–2 entries):
> "Tell me about a formative professional experience — something that changed how you think."
Capture: date, title, what_happened, why_it_matters, how_it_changed_you, emotional_weight, tags

Show each JSON object to the user. Wait for confirmation before including in output.
Use append semantics — never overwrite existing entries.

---

## Output & Validation

After completing all sections: summarise what was captured in plain language.
Wait for explicit confirmation. Then output all files as code blocks.

**Files to output:**
1. `identity/story.md` (narrative prose)
2. `identity/principles.md` (narrative prose)
3. `operations/rituals.md` (narrative prose)
4. `operations/workflows.md` (named workflow list)
5. `network/circles.yaml` (YAML, schema-compliant)
6. Memory entries — each as a single-line JSON to append to its JSONL file

**After saving:** run `bash scripts/validate.sh --quiet` and share results.

---

## Related

- **Cowork:** `/amai:setup 3` (writes files directly, runs validation)
- **Stage 1 prompt:** `docs/onboarding_stage1_prompt.md`
- **Stage 2 prompt:** `docs/onboarding_stage2_prompt.md`
- **Network schema:** `network/SCHEMA.md`
- **Memory schema:** `memory/SCHEMA.md`
