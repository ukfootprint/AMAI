---
name: onboarding
description: Progressive onboarding for AMAI — guides users through populating core modules in conversational stages
version: 0.1.0
triggers:
  - "set up AMAI"
  - "onboarding"
  - "get started"
  - "initialise AMAI"
  - "initialize AMAI"
  - "populate my AMAI"
  - "setup stage 1"
  - "setup stage 2"
  - "setup stage 3"
tools:
  - Read
  - Write
  - Edit
  - Bash
---

The onboarding skill populates AMAI's core modules through structured conversation.
It never shows the user raw YAML during the conversation phase. All output is written
only after the user confirms what was captured.

---

## Stage Detection

Before doing anything else, determine which stage to run:

- **Stage 1** — if the user says "stage 1", "quickstart", "get started", "set up AMAI",
  or "onboarding" without specifying a stage.
- **Stage 2** — if the user says "stage 2" or "foundation".
- **Stage 3** — if the user says "stage 3" or "full core".
- **Auto-detect** — if the user is unsure, read `identity/values.yaml`,
  `identity/heuristics.yaml`, and `goals/current_focus.yaml`. If any still contain
  placeholder text (look for `[Replace`, `[Example`, `TODO`), suggest Stage 1.
  If Stage 1 files are populated but Stage 2 files (`identity/voice.md`,
  `goals/north_star.md`, `goals/goals.yaml`) are missing or thin, suggest Stage 2.
  Otherwise suggest Stage 3.

Before starting any stage, read the relevant JSON Schemas so you know the exact
structural requirements:
- Stage 1: `schemas/values.schema.json`, `schemas/heuristics.schema.json`,
  `schemas/current_focus.schema.json`
- Stage 2: `schemas/goals.schema.json` (plus narrative files which have no schema)
- Stage 3: `schemas/circles.schema.json`, `schemas/decisions.schema.json`,
  `schemas/failures.schema.json`, `schemas/experiences.schema.json`

---

## Stage 1 — Quickstart (~10 minutes)

**Goal:** Populate `identity/values.yaml`, `identity/heuristics.yaml`, and
`goals/current_focus.yaml` with real data through conversation.

**Files to check before starting:** Read `identity/values.yaml`. If it contains
non-placeholder data, say: "It looks like values.yaml already has data. Want to
replace it, or add to it?" Wait for confirmation before proceeding.

---

### Step 1 — Values (~5 minutes)

Open with:

> "Let's set up AMAI with your core identity. I'll ask you some questions and
> translate your answers into the files that AMAI loads every session. This should
> take about 10 minutes."

Then:

> "First, your core values. I'm not looking for corporate mission statements — I want
> to know what actually drives your decisions. Think about the last time you made a
> hard call. What principle tipped the scale?"

Draw out **3–5 core values** through conversation, not a form. For each value:

1. **Get the description.** Ask follow-up questions until you have something specific
   and actionable (at least 20 words — if shorter, prompt for more: "Can you say a
   bit more about what that looks like in practice?").

2. **Get in_practice examples.** Ask: "Give me an example of when [value] actually
   changed what you did — a concrete moment, not a general principle." Aim for at
   least 2 examples per value.

3. **Get the test.** Ask: "If you had to test whether a decision aligns with [value],
   what question would you ask yourself? Make it specific — not just 'Am I being X?'"

4. **Assign priority.** Rank values as they emerge (1 = most important). If the user
   gives more than 5, ask them to pick the 3–5 that most often guide real decisions.

After values, ask:

> "Are there things you'd never do, regardless of context? Lines that aren't up for
> negotiation — not just 'try to avoid', but hard stops?"

Gather at least 2 ethical red lines. Each must be specific enough to be testable
(at least 10 words). If a red line is vague (e.g., "Don't lie"), probe: "Can you
say what that means in a specific situation? When would the line be crossed?"

**Do NOT show the user YAML during this conversation.**

---

### Step 2 — Heuristics (~3 minutes)

Transition:

> "Now some decision shortcuts. Think about rules of thumb you apply instinctively —
> things like 'never accept the first offer', 'always sleep on decisions over £10K',
> or 'if a client can't explain what they want in one sentence, they don't know yet.'"

Draw out **3–5 heuristics** through conversation. For each:

1. **Get the rule.** The rule should be specific enough that you could apply it
   mechanically. If it's vague, prompt: "Can you make that more concrete — name the
   exact situation and what you actually do?"

2. **Get use_when.** Ask: "When does this rule apply? Is it domain-specific, or
   more general?" Aim for a specific context (e.g., "in commercial negotiations
   under £50K", not "in business").

3. **Assign confidence.** Explain briefly: "How sure are you about this one? Is it
   a hard rule you'd almost never break (high), a strong default you'd sometimes
   override (medium), or more of a reminder to yourself (low)?"

Determine the heuristic category: universal (applies across all contexts), domain
(professional/sector-specific), commercial (pricing, negotiation, revenue), or
people (relationships, team, clients).

---

### Step 3 — Current Focus (~2 minutes)

Transition:

> "Last one. What are you focused on this week?"

1. **Get the_one_thing first.** Ask: "What's the one thing that, if it gets done,
   makes this week a success? Be specific — name the output, not the activity."

2. **Get 2–4 priorities.** Ask: "What else is on your plate this week that needs
   attention? Give them in rough order of importance." For each, ask if it ties to
   a specific goal (for goal_ref — can be null if not).

3. **Get not_this_week.** Ask: "What are you explicitly parking this week — things
   you're choosing not to touch so you can focus?"

4. Set `week_of` to the Monday of the current week (YYYY-MM-DD format).
   Set `last_updated` to today's date (YYYY-MM-DD format).

---

### Step 4 — Confirm and Write

After completing the conversation:

1. **Summarise in plain language** — NOT raw YAML. Example format:

   > "Here's what I've captured:
   >
   > **Values (4):** Transparency, Long-term thinking, Craft, Directness
   > **Red lines (2):** [brief description of each]
   > **Heuristics (4):** [brief description of each]
   > **This week's focus:** [the_one_thing]
   > **Priorities:** [list]
   > **Not this week:** [list]
   >
   > Does this feel right, or should we adjust anything?"

2. **Wait for confirmation** before writing any files.

3. **Construct valid YAML** for each file. Structural requirements:

   **identity/values.yaml:**
   ```
   _schema: values
   _version: "1.0"
   last_updated: YYYY-MM-DD
   core_values:
     - id: <snake_case label>
       label: <label>
       priority: <integer, 1 = highest>
       description: <at least 20 words>
       in_practice:
         - <concrete past example 1>
         - <concrete past example 2>
       test: <specific question to test alignment>
   secondary_values: []
   ethical_red_lines:
     - <specific, testable statement, at least 10 words>
   ```

   **identity/heuristics.yaml:**
   ```
   _schema: heuristics
   _version: "1.0"
   last_updated: YYYY-MM-DD
   universal:
     - id: <snake_case>
       rule: <specific rule>
       use_when: <specific context>
       confidence: high | medium | low
   domain: []
   commercial: []
   people: []
   ```
   (populate domain/commercial/people arrays if those heuristics were captured)

   **goals/current_focus.yaml:**
   ```
   _schema: current_focus
   _version: "1.0"
   week_of: YYYY-MM-DD   # Monday of current week
   last_updated: YYYY-MM-DD
   the_one_thing: <specific output, not activity>
   priorities:
     - rank: 1
       item: <specific task>
       goal_ref: <goal id or null>
   not_this_week:
     - <parked item>
   ```

4. **Write all three files** using the Write tool.

5. **Run validation:**
   ```bash
   bash scripts/validate.sh --quiet
   ```

6. **Report results.** If WARNs are present, surface them plainly:
   > "Validation flagged a few things: [list of WARN messages]. Want to sharpen
   > these now, or leave them for later?"

   If the user wants to fix them, guide targeted edits to the specific fields.

---

## Stage 2 — Foundation (~30 minutes)

**Goal:** Populate `identity/voice.md`, `goals/north_star.md`, `goals/goals.yaml`,
`knowledge/frameworks.md`, `knowledge/domain_landscape.md`.

Read `schemas/goals.schema.json` before writing `goals/goals.yaml`.

---

### Voice (~10 minutes)

> "Let's capture how you communicate. I'll ask you a few questions about your writing
> and speaking style, then write it up."

Ask:
- Formality level (very formal, professional, conversational, casual)
- Sentence length preference (concise and punchy, or detailed and explanatory)
- Use of jargon — do they embrace domain language or translate for non-experts?
- How they handle uncertainty in writing (hedge with qualifiers, or state clearly
  with acknowledged uncertainty)
- Tone: direct vs diplomatic, use of humour, how they push back on disagreement
- Ask for a writing sample or description of a recent important email or message

Write `identity/voice.md` as a narrative document (not YAML). Structure:

```
# Voice & Communication Style

## Formality
[Paragraph on default register and how it shifts by context]

## Structure and Length
[How they organise writing and default length]

## Domain Language
[Jargon usage philosophy]

## Tone
[Directness, humour, handling uncertainty, conflict]

## Sample register
[1–2 short examples of characteristic phrases or a paraphrased writing sample]
```

---

### North Star (~5 minutes)

> "Where are you heading in the next 3–10 years? Not a business plan — more like,
> what does success look like if everything goes well?"

Write `goals/north_star.md` with standard sections:

```markdown
# North Star

## The Vision
[3–5 sentences on the long-horizon outcome]

## What Success Looks Like
[3–5 specific, observable markers — not metrics, but recognisable states]

## What This Is Not
[2–3 explicit non-goals that clarify scope]

## The 3-Year Waypoint
[Where they need to be in 3 years for the longer vision to remain viable]
```

---

### Goals (~10 minutes)

> "What are your active goals right now? Think OKR-style: what you're trying to
> achieve and how you'll know you got there."

Draw out 3–6 goals. For each: status, horizon (weeks/months/years), why this goal,
and 2–4 key results (observable outcomes, not tasks).

Write `goals/goals.yaml`:
```yaml
_schema: goals
_version: "1.0"
last_updated: YYYY-MM-DD
goals:
  - id: <snake_case>
    label: <goal title>
    status: active | on_hold | completed | abandoned
    horizon: <timeframe>
    why: <reason this goal matters>
    key_results:
      - <observable outcome 1>
      - <observable outcome 2>
```

---

### Knowledge (~5 minutes)

> "What mental models do you rely on? Frameworks you use to think about problems?
> And what's your domain — the landscape you operate in?"

- Capture 3–5 frameworks in `knowledge/frameworks.md` (name, summary, when used)
- Capture domain context in `knowledge/domain_landscape.md` (sector, competitive
  landscape, key actors, current trends relevant to goals)

Run `bash scripts/validate.sh --quiet` after all writes.

---

## Stage 3 — Full Core (~30 minutes)

**Goal:** Complete `identity/story.md`, `identity/principles.md`,
`operations/rituals.md`, `operations/workflows.md`, `network/circles.yaml`,
and seed the first entries in `memory/` JSONL files.

Read `schemas/circles.schema.json`, `schemas/decisions.schema.json`,
`schemas/failures.schema.json`, `schemas/experiences.schema.json` before writing.

---

### Story & Principles (~10 minutes)

**Story:**
> "Tell me about your background — not your CV, but the formative experiences that
> made you who you are professionally. What shaped how you think about work?"

Write `identity/story.md` as a narrative document. Cover: background/origin,
turning points, how they arrived at their current work, what they've learned about
themselves. 300–600 words.

**Principles:**
> "Behind each of your values, there's a deeper 'why' — a belief about how the world
> works or what matters. What are the 2–3 core beliefs that underpin everything?"

Write `identity/principles.md` as a short document. Each principle: the belief,
where it came from, and how it shows up in decisions.

---

### Operations (~10 minutes)

**Rituals:**
> "Walk me through a typical week. What are the routines that hold it together —
> daily habits, weekly reviews, monthly check-ins?"

Write `operations/rituals.md` covering daily, weekly, and monthly rhythms. Include
what happens when a ritual is skipped (does it matter?).

**Workflows:**
> "What are your key workflows — repeatable processes you follow for common work?
> Things like how you take on a new client, how you structure a project, how you
> handle your inbox."

Write `operations/workflows.md` as a list of named workflows, each with:
trigger, steps, and notes on what to watch out for.

---

### Network (~5 minutes)

> "How do you think about your relationships? Most people have different tiers —
> a small inner circle, a broader set of professional contacts, a wider network.
> What does that look like for you?"

Write `network/circles.yaml` following `schemas/circles.schema.json`:
```yaml
_schema: circles
last_updated: YYYY-MM-DD
circles:
  - id: <snake_case>
    label: <circle name>
    description: <what this circle is>
    criteria:
      - <who belongs here>
    touchpoint_type: personal | professional | either
    current_count: <integer>
```

---

### Memory Seeds (~5 minutes)

Seed the JSONL files with 1–2 real entries each. Gather through conversation:

**Decisions (`memory/decisions.jsonl`):**
> "Tell me about a significant decision you've made — one where the reasoning was
> non-obvious or where you had to trade off competing priorities."
- Capture: date, decision, context, options_considered, reasoning, values_applied

**Failures (`memory/failures.jsonl`):**
> "Tell me about something that went wrong — not catastrophically, but a situation
> where you got it wrong and learned something real."
- Capture: date, what_failed, context, what_i_did, what_went_wrong,
  warning_signs_missed, what_id_do_differently, emotional_weight, lesson

**Experiences (`memory/experiences.jsonl`):**
> "Tell me about a formative experience — something that changed how you think
> or what you do."
- Capture: date, title, what_happened, why_it_matters, how_it_changed_you,
  emotional_weight, tags

**Append each entry as a single JSON line** to the target JSONL file. Never
overwrite existing lines. Show each JSON object to the user and confirm before
writing.

Run `bash scripts/validate.sh --quiet` after all writes. Report results.
