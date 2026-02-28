# Org Overlay Guide

Reference for interpreting overlay files and managing the personal/org boundary.

## overlay.yaml structure

The core overlay config. Typical fields:
- `org_name`: Display name of the organisation
- `role`: User's role within the org
- `default_session_state`: Which state to default to on activation (S0/S1/S2)
- `default_behaviour_band`: Which band to apply by default
- `active`: Whether this overlay is currently enabled

## behaviour_bands.yaml structure

Defines different behavioural modes within the org context. Each band typically specifies:
- `tone`: Communication style (formal, collegial, executive, etc.)
- `formality`: Formality level
- `decision_authority`: What decisions the user can make at this band
- `visibility`: Who the user is interacting with (internal, external, board, etc.)
- `special_rules`: Any band-specific constraints

When a band is active, apply its tone and formality to all outputs. Do not default to generic
professional tone — use the specific band definition.

## SESSION_STATES.md structure

Describes what is permitted in each state for this specific org. Read this before any
state transition. It overrides the general S0/S1/S2 descriptions with org-specific rules.

## policy/disclosure_rules.yaml

Defines what personal context can be referenced in org mode:
- Data classification levels (e.g., private, internal, shareable)
- Which AMAI modules are accessible in each session state
- What the user can reveal about their personal identity/values in professional contexts

Always consult this before referencing personal AMAI data in an org-mode session.

## policy/data_classes.yaml

Categorises types of information by sensitivity:
- What counts as personal vs. professional data
- Retention and handling rules
- Cross-context contamination rules (what should not flow from org → personal or vice versa)

## tension_log.jsonl

Append-only log of tensions between personal values and org requirements. When logging:
1. Parse one existing entry to understand the exact JSON schema used
2. Construct a new entry following the same schema
3. Use the current ISO timestamp
4. Include: the tension description, the value in conflict, the org pressure, and the resolution or status
5. Append as a new line (do NOT overwrite existing entries)

## Activation checklist

Before confirming overlay activation, verify:
- [ ] `overlay.yaml` read and parsed
- [ ] `behaviour_bands.yaml` read — know which band applies
- [ ] `SESSION_STATES.md` read — know what S1/S2 means for this org
- [ ] `disclosure_rules.yaml` read — know what personal context can surface
- [ ] User confirmed the activation explicitly

## Deactivation

On deactivation (returning to S0):
1. State that org mode is deactivated
2. Confirm that personal AMAI context is fully restored
3. If tensions were logged during the session, offer a summary
