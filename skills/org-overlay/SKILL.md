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

**Path convention:** All user data file paths (identity/, signals/, calibration/, etc.) resolve to `${AMAI_USER_ROOT}` — the user's personal AMAI directory, set in `~/.amai/config.yaml`. If not configured, fall back to `${CLAUDE_PLUGIN_ROOT}`.

## Concepts

**Session states** control how much of the AMAI core is active alongside an org overlay:
- **S0** — Personal mode. Only AMAI core loaded. No org context active.
- **S1** — Dual mode. AMAI core + org overlay both active. Full awareness.
- **S2** — Org mode. Org overlay takes precedence. Personal context suppressed except where explicitly permitted.

**Behaviour bands** (defined per overlay in `behaviour_bands.yaml`) narrow how personal values and heuristics apply in org context — they never expand beyond personal values or red lines. If a band would require violating a personal value, the personal value wins. Template: `org/templates/behaviour_bands.yaml`.

**Brand voice** (defined per overlay in `brand_voice.md`) specifies the org's tone, vocabulary, channel rules, and examples. When loaded:
- Apply it to ALL content produced for this org
- Brand voice takes priority over personal voice for org-facing content
- Personal voice applies to everything outside this org
- If brand voice would conflict with personal values (not just style), flag it to the user
Template: `org/templates/brand_voice.md`

**Disclosure rules** specify what personal information can be referenced or shared when in org mode.

## Activation workflow

1. Read `${AMAI_USER_ROOT}/org/org_index.yaml` to list available overlays.

2. Ask the user which overlay to activate (or use the one they named).

3. Read the overlay files:
   - `${AMAI_USER_ROOT}/org/overlays/{org-name}/overlay.yaml` — core overlay config
   - `${AMAI_USER_ROOT}/org/overlays/{org-name}/behaviour_bands.yaml` — behaviour bands (how personal defaults flex)
   - `${AMAI_USER_ROOT}/org/overlays/{org-name}/brand_voice.md` — org voice and channel rules (if present)
   - `${AMAI_USER_ROOT}/org/overlays/{org-name}/SESSION_STATES.md` — state transition rules
   - `${AMAI_USER_ROOT}/org/overlays/{org-name}/policy/disclosure_rules.yaml` — what can be shared

4. Confirm activation explicitly: "Activating [org name] overlay in S[n] mode. Behaviour band: [band name]. [Brief description of what this means for this session.]"

5. Never activate an overlay silently — always confirm with the user first.

## Tension logging

When the user experiences a conflict between personal values and org requirements, log it:

1. Read `${AMAI_USER_ROOT}/org/overlays/{org-name}/tension_log.jsonl` to see existing log format.
2. Read `${AMAI_USER_ROOT}/signals/SCHEMA.md` for field definitions.
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

When in S1 or S2 mode, read `${AMAI_USER_ROOT}/org/overlays/{org-name}/policy/` files to understand:
- What data classes exist and how they're classified
- Which personal context elements can surface in org mode
- What decision authorities apply

See `references/overlay-guide.md` for detailed interpretation guidance.

## Setting Up a New Org Overlay

If the user asks to set up a new org:

1. Create the overlay directory: `org/overlays/[org-name]/`
2. Copy the templates:
   ```bash
   cp org/templates/brand_voice.md org/overlays/[org-name]/brand_voice.md
   cp org/templates/behaviour_bands.yaml org/overlays/[org-name]/behaviour_bands.yaml
   ```
3. Walk the user through populating `brand_voice.md` — see `docs/brand_voice_prompt.md` for guided questions
4. Walk the user through setting `behaviour_bands.yaml` band org_range values
5. Run `bash "${AMAI_USER_ROOT}/scripts/validate.sh"` to confirm no errors

For a guided setup, use `/amai:brand-voice` (see `commands/brand-voice.md`).
