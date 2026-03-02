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
`knowledge/frameworks.md`, `knowledge/domain_landscape.md` through structured
conversation.

Read `schemas/goals.schema.json` before writing `goals/goals.yaml`.

**Files to check before starting:** Read `identity/voice.md`, `goals/north_star.md`,
`goals/goals.yaml`, `knowledge/frameworks.md`, and `knowledge/domain_landscape.md`.
If any contain non-placeholder data (no `[Replace`, `[Fill`, `[Add` markers), say:
"It looks like [file] already has some content. Want to replace it, or add to it?"
Wait for confirmation before overwriting.

---

### Voice (~10 minutes)

Open with:

> "Now let's capture how you communicate. This isn't about grammar rules — I want
> to understand your natural tone, the way you phrase things, what makes writing
> sound like you vs. generic."

Draw out the following dimensions through natural conversation — **do not turn this
into a form or checklist**. Let the answers flow and probe for specifics:

1. **Formality range** — "How does your writing change depending on who you're
   writing to — say, a client versus a colleague versus a friend?"

2. **Sentence length tendency** — "Do you tend to write in short, punchy sentences,
   or longer flowing ones? What feels more natural to you when you're not editing
   yourself?"

3. **Jargon comfort** — "In your field, do you use insider vocabulary freely, or do
   you prefer to translate everything into plain terms? Does it depend on the
   audience?"

4. **Expressing uncertainty** — "When you're not sure of something in writing, how
   do you typically flag that? Like 'I think', 'possibly', 'my read is', 'the data
   suggests' — what's your instinct?"

5. **Openings** — "How do you tend to start messages, emails, or documents? Do you
   get straight to the point, or set context first?"

6. **Closings and sign-offs** — "How do you close out a piece of writing? Do you
   typically end with a call to action, a summary, something warmer?"

7. **Delivering bad news or pushing back** — "When you have to tell someone
   something they won't want to hear — a missed deadline, a changed position — what
   does that look like in writing?"

8. **Use of humour** — "Is humour ever part of your written voice? If so, how would
   you describe it — dry, self-deprecating, situational, rare?"

**Derive from answers:** Write a narrative `identity/voice.md` that captures these
dimensions with concrete examples drawn from the conversation. This is **not** a
bullet list — it should read as a document an AI can use to produce writing that
sounds like the user. Use the user's own phrases and examples where possible.

**Quality check:** After drafting (but before confirming), read back 2 short
sentences written in the captured voice and ask:

> "Does this sound like you — or is it off? Too formal, too casual, or about right?"

Adjust based on the answer before writing the file.

**Document structure:**
```
# Voice & Communication Style

## Formality
[Narrative paragraph — default register, how it shifts by audience, with examples]

## Structure and Length
[How they organise writing, sentence length tendency, approach to brevity vs detail]

## Domain Language
[Philosophy on jargon — when to use insider vocabulary vs. translate for outsiders]

## Tone
[Directness, how they handle uncertainty, approach to conflict and bad news,
use of humour if any — with characteristic phrases where possible]

## Signature Patterns
[2–3 habits that make their writing distinctly theirs — openings, closings,
framing moves — described so an AI can replicate them]

## Voice Test
[A personalised version: "Would I say this to [a specific person they named]?"]
```

---

### North Star (~5 minutes)

Open with:

> "Where are you heading in the next 3–10 years? Not a business plan — more like,
> what does life and work look like if things go well?"

Draw out **four distinct sections** through the conversation:

1. **The Vision** — "Paint the picture: if things go well over the next decade, what
   have you built, what have you changed, what are you known for?" Aim for 2–3
   paragraphs. If the first answer is vague, probe: "What specifically would be true
   that isn't true now?"

2. **What Success Looks Like** — "Give me 3–5 observable markers — concrete states
   of the world that would tell you you've succeeded. Not metrics, but things you'd
   recognise. Try starting each one: 'I'd know I've succeeded when...'"

3. **What This Is Not** — "What are you explicitly not trying to build or become?
   Naming the non-goals is as useful as the goals — it stops scope creep and
   misaligned advice. Try: 'I'm not trying to...'"

4. **The 3-Year Waypoint** — "If the full vision is the 10-year destination, where
   do you need to be in 3 years for it to still be reachable? What's the nearest
   milestone that proves the direction is right?"

**Write** `goals/north_star.md` with all four sections plus a `Last updated:` footer.

**Document structure:**
```markdown
# North Star

## The Vision
[2–3 paragraphs — specific enough to orient decisions, not so specific it becomes a plan]

## What Success Looks Like
- I'd know I've succeeded when [observable marker 1]
- I'd know I've succeeded when [observable marker 2]
[3–5 total]

## What This Is Not
- I'm not trying to [non-goal 1]
- I'm not trying to [non-goal 2]
[2–3 total]

## The 3-Year Waypoint
[Bridge paragraph — where the user needs to be in 3 years for the vision to remain viable]

---
*Last updated: YYYY-MM-DD*
```

---

### Goals (~10 minutes)

Open with:

> "What are you actively working toward right now? Think outcomes, not activities.
> What would you be measuring if you had a dashboard?"

Draw out **3–6 goals**. For each goal, collect all fields before moving on:

1. **Label** — "One line: what is this goal?"

2. **Status** — "Is this active and in progress, or on hold?" (At initial setup,
   use only `active` or `on_hold` — do not ask about completed or abandoned.)

3. **Horizon** — "When do you expect meaningful progress by? A month, a quarter,
   a year?"

4. **Why** — "Why does this goal matter to you right now? What does achieving it
   unlock — for you, your business, or the people you're trying to help?" Listen
   for links back to values or the north star and make them explicit in the `why`
   field.

5. **Key results** — "How will you know it's working? Give me 1–3 measurable
   outcomes — not tasks or activities, but observable results you could point at."

6. **Constraints** (optional) — "Are there any guardrails on how this goal should
   be pursued? Things that are off-limits even if they'd technically move the
   needle?"

**Cross-reference with current_focus.yaml:** After writing goals.yaml, if any goal
maps to a priority already captured in `goals/current_focus.yaml` (from Stage 1),
note the connection and offer:

> "The goal IDs I've just written are: [list]. Your current_focus.yaml has
> `goal_ref` fields — would you like me to update those to reference these IDs now?"

**Write** `goals/goals.yaml` using the schema from `schemas/goals.schema.json`:

```yaml
_schema: goals
_version: "1.0"
last_updated: YYYY-MM-DD
goals:
  - id: <snake_case — e.g. grow_consulting_revenue>
    label: "<One-line goal description>"
    status: active | on_hold
    horizon: "<Timeframe — e.g. Q2 2026 or 12 months>"
    why: >
      <Why this goal matters. At least 20 words. State what it unlocks.>
    key_results:
      - "<Observable outcome 1>"
      - "<Observable outcome 2>"
    constraints:
      - "<Constraint if any — omit or use [] if none>"
    notes: ""
```

---

### Knowledge (~5 minutes)

**Frameworks:**

Open with:

> "What mental models or frameworks do you find yourself reaching for repeatedly?
> The lenses you use to analyse situations — ones you've actually used recently,
> not just ones you've read about."

Capture **3–5 frameworks**. For each: what it is, when this person uses it, why it
works for their context, and any limitations they've noticed or worked around. Write
`knowledge/frameworks.md` as a narrative document — not a list of definitions. An
AI reading it should understand when and how to apply these lenses in the user's
specific work.

**Domain landscape:**

Open with:

> "Paint me a picture of the landscape you operate in. Who are the players? What
> are the forces? Where are the opportunities and threats?"

Ask follow-up questions to get past surface description: "Who specifically do you
watch closely — competitors, adjacent players?" "What's shifting in your market
right now?" "What do you believe about this space that most people in it don't see
yet?" "What could blow up your assumptions?"

Write `knowledge/domain_landscape.md` as narrative — cover sector context,
competitive dynamics, regulatory or structural forces, and technology or behavioural
trends relevant to the user's goals.

Both files should read as opinionated, first-person perspectives, not Wikipedia
summaries. Use the user's language.

---

### Post-Write Steps

After completing all five conversations:

1. **Summarise in plain language** — NOT raw YAML or Markdown. Use this format:

   > "Here's what I've captured:
   >
   > **Voice:** [2-sentence summary of the key voice characteristics]
   > **North Star:** [one-line vision + 3-year waypoint in a phrase]
   > **Goals ([N] active):** [comma-separated list of goal labels]
   > **Frameworks ([N]):** [comma-separated list of framework names]
   > **Domain:** [one-line characterisation of the sector description]
   >
   > Does this feel right, or should we adjust anything before I write the files?"

2. **Wait for explicit confirmation** before writing any files.

3. **Write all five files** using the Write tool:
   - `identity/voice.md`
   - `goals/north_star.md`
   - `goals/goals.yaml`
   - `knowledge/frameworks.md`
   - `knowledge/domain_landscape.md`

4. **Set `last_updated`** to today's date (YYYY-MM-DD) in `goals/goals.yaml`.
   Add a `Last updated: YYYY-MM-DD` footer to the three Markdown files.

5. **Run validation:**
   ```bash
   bash scripts/validate.sh --quiet
   ```

6. **Report results.** Only `goals/goals.yaml` is schema-validated; the Markdown
   files are checked for presence. Surface WARNs plainly:

   > "Validation flagged a few things: [list]. Want to sharpen these now, or
   > leave them for the next review?"

   If the user wants to address WARNs, make surgical edits to the specific fields —
   do **not** re-run the full Stage 2 conversation.

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
