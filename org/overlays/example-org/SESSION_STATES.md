# Session States for [Organisation Name] Overlay

## Overview

Every org-context session moves through defined states. The AI must track
which state is active and follow the rules for that state.
State transitions always require explicit user confirmation.

---

## States

### S0 — No overlay active
Personal AMAI context only. Org files not loaded. Default state.

### S1 — Overlay suggested
The AI has detected org context in the user's message and is proposing to
activate the overlay. Waiting for user confirmation. Org files not yet loaded.

### S2 — Overlay active
Overlay confirmed by user. Org modules loaded. Session banner displayed.
Behaviour bands and disclosure rules in effect.

### S3 — Overlay change requested
User has indicated a context type change mid-session (e.g. from internal
to client_facing). Transition in progress. Requires re-confirmation.

### S4 — Overlay locked
Client-facing or public context is active. Strictest disclosure rules apply.
Personal Tier 1 and Tier 2 data completely excluded.
Returning to S2 (internal context) requires explicit user instruction.

---

## Transition Rules

**S0 → S1**
Trigger: user message contains org context cues (org name, client reference,
"internal memo", "board update", "for the client", "proposal for").
Action: AI outputs — "This looks like a [org_name] / [context_type] session.
Should I activate the [org_id] overlay?"
Do not load any org files until user confirms.

**S1 → S2**
Trigger: user confirms overlay activation and names context type.
Action: load overlay.yaml, behaviour_bands.yaml, policy files for named context.
Output session banner as defined in overlay.yaml.

**S1 → S0**
Trigger: user declines overlay activation.
Action: continue in personal mode. Do not suggest again in this session
unless the user explicitly requests it.

**S2 → S3**
Trigger: user changes task type mid-session in a way that crosses a context
boundary (e.g. from internal memo to client-facing proposal).
Action: AI flags the shift — "This looks like a context change from [current]
to [new]. The disclosure rules and behaviour band levels would change. Confirm?"
Do not load new modules or change active bands until confirmed.

**S3 → S2**
Trigger: user confirms new context type.
Action: reload policy files and behaviour band defaults for new context.
Re-output session banner with updated context type.

**S2 → S4**
Trigger: context type is client_facing or context type changes to public.
Action: apply strictest disclosure rules. Remove from context any Tier 1 or
Tier 2 personal data that was previously loaded. Confirm this with user.
Banner updates to reflect S4.

**S4 → S2**
Trigger: explicit user instruction to switch back to internal context.
Action: return to S2 rules for internal context. Personal Tier 2 data
may be reloaded on request.

**Any state → S0**
Trigger: user says "personal mode" or equivalent.
Action: deactivate overlay. Clear org modules from active context.
Confirm deactivation. Continue in personal mode.

---

## What the AI must never do

- Activate an overlay without user confirmation
- Load prohibited modules for the active state and context
- Silently change context type without flagging
- Resolve a precedence conflict without the conflict protocol output
