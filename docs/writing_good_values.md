# Writing Good AMAI Entries

This document helps you write entries that AMAI can actually use — specific enough
to load meaningful context, not so vague they add noise. It's referenced by
`validate.sh` WARN messages and by the onboarding skill when validation flags issues.

---

## 1. Core Values (`identity/values.yaml`)

A value entry has three working parts: `description`, `in_practice`, and `test`.
All three do different jobs. A weak entry fails at all three.

### The description

**Weak — triggers `WARN:VAGUE_VALUE`:**
```yaml
description: "Be honest"
```
Too short, too abstract. Says nothing about when honesty is hard, or what it
costs you. Every person claiming this value would describe it differently.

**Strong:**
```yaml
description: >
  Default to transparency in all professional communications. When in doubt,
  share more context rather than less. Accept short-term discomfort — a
  difficult conversation now, a lost contract — in exchange for long-term
  trust. Omission counts as dishonesty when the other party would clearly
  want to know.
```
Specific. States the trade-off (short-term discomfort). Defines where the
boundary is (omission). An AI loading this knows what to do when transparency
conflicts with politeness.

### The in_practice examples

**Weak — triggers `WARN:MISSING_EXAMPLES`:**
```yaml
in_practice:
  - "Be truthful in conversations"
```
One entry. And it just restates the label. Not an example — an aspiration.

**Strong:**
```yaml
in_practice:
  - "Told a client the timeline was unrealistic even though it risked losing
     the contract. They stayed. The project shipped on time."
  - "Shared revenue figures with the team including the months we
     underperformed — not just the wins."
```
Concrete past moments. "I did X in situation Y." Not "I try to X." The AI
can use these as reference points: if a situation resembles one of these,
apply the value the same way.

### The test

**Weak:**
```yaml
test: "Am I being honest?"
```
Just a restatement. Useless — it doesn't help you decide anything new.

**Strong:**
```yaml
test: "If this conversation were published verbatim, would I be comfortable
       with what I withheld?"
```
Situational. Forces a specific mental move. An AI can apply this as a
literal check when reviewing a draft message.

---

## 2. Ethical Red Lines (`ethical_red_lines` in `identity/values.yaml`)

Red lines are not values — they are constraints. They define what you will not
do regardless of context, pressure, or apparent benefit.

### Recommended format: When/Do/Never/Except (structured)

The structured format is the recommended approach. It makes red lines
machine-checkable and forces the edge-case thinking that vague strings skip:

```yaml
ethical_red_lines:
  - id: client_capability_claims
    when: "Client communications, proposals, capability claims, sales materials"
    do: "State only capabilities that have been delivered or are in active development with named evidence"
    never: "Claim capability that doesn't exist, hasn't been tested, or cite reference clients without their consent"
    except: "Clearly labelled roadmap items with explicit caveats ('planned for Q3, not yet in production')"
    examples:
      - "We delivered X for Client Y in Q3 — here are the results"
      - "X is on our roadmap for Q2. It's not yet in production and I can't guarantee the timeline"
    severity: absolute
```

- **`when`** — the scope: which situations, roles, or relationships this applies to
- **`do`** — the positive obligation: what you actively do in this context
- **`never`** — the hard constraint: specific enough for a third party to evaluate
- **`except`** — carve-outs, or "none" (more than 1–2 exceptions = not a red line)
- **`examples`** — concrete anchors the AI uses as reference scenarios
- **`severity`** — `absolute` (default) or `strong` (near-absolute, acknowledged edge cases)

See `docs/red_line_migration.md` for step-by-step migration instructions.

### Legacy format: plain strings (deprecated — triggers `WARN:DEPRECATED_RED_LINE_FORMAT`)

Plain strings still validate but are deprecated. Migrate when you run `/amai:setup-advanced`.

**Weak legacy string:**
```
"Don't lie"
```
Under 10 words. Too vague. Gives an AI nothing to evaluate against.

**Strong legacy string (still deprecated, but better):**
```
"Never claim a capability, qualification, or track record that hasn't been
demonstrated in a real engagement — not in proposals, pitches, or casual
conversation."
```
Specific. Testable. Named contexts. Still better migrated to the structured format.

### The thinking tool

If you're not sure whether something is a red line, run it through:

- **When:** In what contexts does this apply?
- **Do:** What should I actively do instead?
- **Never:** What exactly is prohibited?
- **Except:** Are there any legitimate exceptions?

If you find yourself writing "Except in cases where…" with more than one or
two narrow carve-outs, it's probably not a red line — it's a strong preference.
Move it to values or heuristics.

---

## 3. Heuristics (`identity/heuristics.yaml`)

A heuristic is a decision shortcut — something you apply fast, without full
deliberation, because you've already done the deliberation and bottled the result.
The test: could you apply it mechanically, without needing to think?

### What makes a heuristic weak — triggers `WARN:VAGUE_HEURISTIC`

**Weak:**
```yaml
rule: "Think carefully"
use_when: "Always"
```
"Think carefully" is not a heuristic — it's a reminder. It provides no actual
guidance. "Always" as a use_when means it's not a heuristic either, it's a
principle. Move it to values.

**Weak:**
```yaml
rule: "Be transparent with clients"
use_when: "Client conversations"
```
Still too general. What does transparent mean in practice? This overlaps with
the values layer and adds no decision guidance.

**Strong:**
```yaml
rule: >
  Never discount a growth-stage consulting engagement below 80% of listed
  price. The margin is the capacity to deliver well — cut it and you cut
  your ability to do the job properly.
use_when: "Commercial negotiation on consulting engagements under £50K annual value"
confidence: high
```
Could apply it mechanically: if a negotiation starts, don't go below 80%.
Specific context: consulting, under £50K. Includes the reasoning (capacity
to deliver), which helps when the rule is challenged.

### Confidence levels — use them accurately

- **high** — you've tested this across many situations, it almost always holds,
  you'd need strong evidence to override it
- **medium** — strong default, but you've seen legitimate exceptions; you'd
  override it consciously, not casually
- **low** — more of a reminder or hypothesis; you're still gathering evidence

Don't mark everything `high` because it sounds more authoritative. A `medium`
heuristic that's honestly calibrated is more useful than an overstated `high`.

### Categories matter

Place heuristics in the right category — AMAI loads them selectively by context:

- `universal` — applies to how you operate generally (relationships, communication,
  time management)
- `domain` — specific to your professional sector or function
- `commercial` — pricing, negotiation, revenue, proposals
- `people` — managing relationships, teams, clients, difficult conversations

A heuristic that "applies everywhere" is probably a value, not a heuristic.
If you're unsure, ask: would you apply this rule in a personal relationship?
A negotiation? A team decision? If all three, it's universal. If only one, it
belongs in that category.

---

## 4. Current Focus (`goals/current_focus.yaml`)

The current focus file is loaded every session. It tells AMAI what's urgent
right now. Vague entries mean AMAI gives generic advice when it should give
specific, contextual help.

### The one thing

**Weak:**
```yaml
the_one_thing: "Make progress"
```
On what? Progress towards what? This tells AMAI nothing.

**Weak:**
```yaml
the_one_thing: "Client work"
```
Which client? Which piece of work? What does done look like?

**Strong:**
```yaml
the_one_thing: "Ship the revised proposal to ClientX by Thursday — this
                determines Q2 pipeline"
```
Names the deliverable (revised proposal). Names the recipient (ClientX).
Names the deadline (Thursday). States why it matters (Q2 pipeline). An AI
loading this knows to prioritise anything that unblocks this outcome.

### Priorities

**Weak:**
```yaml
priorities:
  - rank: 1
    item: "Work stuff"
    goal_ref: null
```
Useless. What work stuff?

**Strong:**
```yaml
priorities:
  - rank: 1
    item: "Finalise ClientX proposal — updated pricing model and case study section"
    goal_ref: "goal_grow_consulting_revenue"
  - rank: 2
    item: "Review and respond to pending Loom from the ops team re: onboarding process"
    goal_ref: null
  - rank: 3
    item: "Prep agenda for Thursday board call — 3 discussion points max"
    goal_ref: "goal_governance"
```
Each item is a specific action with a clear output. Two are tied to goals,
one isn't (that's fine — not everything maps to a strategic goal). An AI
can now help you with any of these in context.

### Not this week

Don't leave `not_this_week` empty. It is as important as the priority list —
it's where you park things that are demanding attention so you can consciously
ignore them.

**Weak:**
```yaml
not_this_week: []
```

**Strong:**
```yaml
not_this_week:
  - "Website redesign — in backlog, not urgent"
  - "Catching up on unread newsletters"
  - "Initial scoping call with potential partner X — too early in the week,
     defer to next week when proposal is done"
```

---

## 5. General Principles for All AMAI Entries

**Specificity over aspiration.** Describe what you actually do, not what you
wish you did. "I always sleep on large financial decisions" is more useful than
"I try to be thoughtful about money." The first is a behaviour an AI can reference;
the second is noise.

**Past examples over future intentions.** "I declined a contract because the
client's procurement process required us to misrepresent our team size" is more
useful than "I would decline contracts that require dishonesty." Past examples
prove the value is real. Intentions don't.

**Include the trade-off.** Every value implies a cost. If transparency costs
you nothing, it's not a value — it's a preference. "I prioritise long-term
relationships over short-term revenue" becomes real when you can say "even when
that means turning down a £30K project from a client I don't trust."

**Name the context.** "When negotiating deals under £50K" is dramatically more
useful than "in business." The more specific the context, the more precisely
AMAI can apply the heuristic.

**Revisit and sharpen.** A vague entry that gets sharpened in month 2 is better
than no entry at all. The onboarding flow is a starting point, not a permanent
record. When `validate.sh` flags `WARN:VAGUE_VALUE` or `WARN:VAGUE_HEURISTIC`,
treat it as an invitation to improve the entry — not a system failure.
