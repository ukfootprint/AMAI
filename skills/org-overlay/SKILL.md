---
name: org-overlay
description: >
  This skill should be used when the user needs to work in an organisational context —
  activating an org overlay, switching between personal and org modes, handling
  session state transitions (S0/S1/S2), applying behaviour bands, navigating
  disclosure rules, or logging org tensions. Trigger phrases include:
  "activate [org name] overlay", "switch to work mode", "org context",
  "check disclosure rules", "log a tension", "what behaviour band am I in",
  "session state", or any task where the user is operating in a professional
  or organisational setting that requires contextual separation from personal identity.
version: 0.1.0
---

The org-overlay skill manages the separation between personal identity (AMAI core)
and organisational context. It handles overlay activation, session state transitions,
behaviour band selection, disclosure rules, and tension logging.

## Concepts

**Session states** control how much of the AMAI core is active alongside an org overlay:
- **S0** — Personal mode. Only AMAI core loaded. No org context active.
- **S1** — Dual mode. AMAI core + org overlay both active. Full awareness.
- **S2** — Org mode. Org overlay takes precedence. Personal context suppressed except where explicitly permitted.

**Behaviour bands** (defined per overlay) specify how to behave within org context — tone, formality, disclosure limits, decision authority.

**Disclosure rules** specify what personal information can be referenced or shared when in org mode.

## Activation workflow

1. Read `${CLAUDE_PLUGIN_ROOT}/org/org_index.yaml` to list available overlays.

2. Ask the user which overlay to activate (or use the one they named).

3. Read the overlay files:
   - `${CLAUDE_PLUGIN_ROOT}/org/overlays/{org-name}/overlay.yaml` — core overlay config
   - `${CLAUDE_PLUGIN_ROOT}/org/overlays/{org-name}/behaviour_bands.yaml` — behaviour specifications
   - `${CLAUDE_PLUGIN_ROOT}/org/overlays/{org-name}/SESSION_STATES.md` — state transition rules
   - `${CLAUDE_PLUGIN_ROOT}/org/overlays/{org-name}/policy/disclosure_rules.yaml` — what can be shared

4. Confirm activation explicitly: "Activating [org name] overlay in S[n] mode. Behaviour band: [band name]. [Brief description of what this means for this session.]"

5. Never activate an overlay silently — always confirm with the user first.

## Tension logging

When the user experiences a conflict between personal values and org requirements, log it:

1. Read `${CLAUDE_PLUGIN_ROOT}/org/overlays/{org-name}/tension_log.jsonl` to see existing log format.
2. Read `${CLAUDE_PLUGIN_ROOT}/signals/SCHEMA.md` for field definitions.
3. Construct the tension entry with the user's input.
4. Append to `tension_log.jsonl` (using the Write/Edit tool with append semantics).
5. Confirm the entry was logged.

## Session state transitions

Transitions require explicit user confirmation:
- **S0 → S1**: User activates an overlay but wants to keep personal context visible
- **S0 → S2**: User enters a fully org-bounded session
- **S1 → S2**: User wants to suppress personal context for the current task
- **S2 → S0/S1**: User exits org mode

Always state the transition explicitly and what it means for the session.

## Precedence rules

When in S1 or S2 mode, read `${CLAUDE_PLUGIN_ROOT}/org/overlays/{org-name}/policy/` files to understand:
- What data classes exist and how they're classified
- Which personal context elements can surface in org mode
- What decision authorities apply

See `references/overlay-guide.md` for detailed interpretation guidance.
