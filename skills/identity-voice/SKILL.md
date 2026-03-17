---
name: identity-voice
description: >
  This skill should be used when the user needs Claude to actively apply their
  personal identity, voice, values, or heuristics to output — not just read
  those files, but embody them in the response. Trigger phrases include:
  "write in my voice", "does this sound like me", "apply my values to this",
  "what would I say here", "make this sound like me", "check this against my
  heuristics", "is this on-brand for me", or when the user shares a draft and
  asks for it to be revised to match their style.
  Also trigger proactively when writing, editing, or composing any content that
  will be attributed to or sent by the user.
version: 0.1.0
---

The identity-voice skill actively applies this person's identity context to shape
output — tone, vocabulary, reasoning patterns, and values. This is not passive
reference reading. The goal is output that sounds like it came from this person.

**Path convention:** All user data file paths (identity/, signals/, calibration/, etc.) resolve to `${AMAI_USER_ROOT}` — the user's personal AMAI directory, set in `~/.amai/config.yaml`. If not configured, fall back to `${CLAUDE_PLUGIN_ROOT}`.

## What to load

Read the following files if not already in session context:

1. `${AMAI_USER_ROOT}/identity/voice.md` — primary voice reference
2. `${AMAI_USER_ROOT}/identity/heuristics.yaml` — decision and reasoning shortcuts
3. `${AMAI_USER_ROOT}/identity/values.yaml` — values to apply as constraints
4. `${AMAI_USER_ROOT}/identity/principles.md` — deeper reasoning behind values (load for complex or high-stakes content)

## Applying voice.md

The voice file describes how this person writes. When applying it:

- Extract the core stylistic signals: sentence length, vocabulary level, formality, directness, use of humour
- Identify signature patterns: how they open, how they close, how they handle uncertainty, how they signal emphasis
- Apply these actively to the output — rewrite or compose in that style
- Do not add stylistic elements that are not described (e.g., do not add warmth if the voice is described as direct and sparse)

## Applying heuristics.yaml

Heuristics are decision shortcuts — personal rules of thumb encoded from experience.

- Check whether any heuristic applies to the current situation
- If yes, apply it as a primary constraint, not a suggestion
- Reference the specific heuristic when it influences the output: "Applying your heuristic on X..."
- Do not override heuristics with generic best-practice advice unless explicitly asked

## Applying values.yaml

Values are decision criteria and identity anchors.

- When evaluating options or making recommendations, score against stated values
- Flag any option that conflicts with a core value — do not silently recommend it
- When writing persuasive or emotive content, ensure it aligns with stated values
- Values are ranked or weighted — consult that ranking when values are in tension

## Voice consistency checks

When the user shares a draft to review:

1. Read voice.md
2. Identify 3-5 specific places where the draft diverges from the described voice
3. Offer concrete rewrites, not general feedback
4. Distinguish between style deviations (fixable) and content deviations (may reflect intentional choice)

Format the review as:
> **Voice check:** [overall alignment — Strong / Partial / Off]
>
> Specific divergences:
> 1. [Quote from draft] → [Suggested rewrite] *(reason)*
> 2. ...

## Values alignment check

When the user asks whether something is aligned with their values:

1. Read values.yaml
2. Evaluate the thing against each relevant value
3. Report: aligned, neutral, or in tension — with reasoning
4. If in tension, offer options that resolve the tension

Do not hedge or soften this analysis. If something conflicts with a stated value, say so directly.
