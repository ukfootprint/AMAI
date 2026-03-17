---
name: conscience
description: >
  Real-time ethical red-line and heuristic monitoring. Phase 1: checks session content
  against the user's structured ethical red lines (When/Do/Never/Except format).
  Phase 2: also checks against high-confidence heuristics. Runs silently in the
  background during any content-generation session — surfaces an advisory alert only
  when a potential violation is detected. Never blocking. Always advisory.
  Trigger phrases include: "check this against my red lines", "conscience check",
  "ethical check", "red line check", "does this cross a line", "is this okay ethically",
  "check my values on this", "run conscience", "check heuristics".
version: 0.2.0
triggers:
  - "check this against my red lines"
  - "conscience check"
  - "ethical check"
  - "red line check"
  - "does this cross a line"
  - "is this okay ethically"
  - "check my values on this"
  - "run conscience"
  - "check heuristics"
tools:
  - Read
  - Bash
---

The conscience skill monitors session content against the user's declared ethical red
lines and high-confidence heuristics. It operates in two modes — background scan
(automatic, silent unless flagged) and on-demand check (invoked explicitly via
`/amai:conscience` or the trigger phrases above).

This skill does not replace judgment. It raises concerns for the user to consider.
The user is always the final authority.

**Path convention:** All user data file paths (identity/, signals/, calibration/, etc.) resolve to `${AMAI_USER_ROOT}` — the user's personal AMAI directory, set in `~/.amai/config.yaml`. If not configured, fall back to `${CLAUDE_PLUGIN_ROOT}`.

**Phase 2 default behaviour:** Both red-line checking (Phase 1) and heuristic checking
(Phase 2) are active by default. Use `--red-lines-only` to revert to Phase 1 behaviour.

---

## Phase Configuration

| Phase | Scope | Status |
|-------|-------|--------|
| Phase 1 | `ethical_red_lines` in `identity/values.yaml` | Active |
| Phase 2 | Phase 1 + high-confidence entries in `identity/heuristics.yaml` | Active (default) |
| Phase 3 | Broader values-trajectory monitoring with calibration data | Future |

**Mode flags (passed via command arguments or session context):**
- `--include-heuristics` (default) — Phase 1 + Phase 2
- `--red-lines-only` — Phase 1 only
- `--heuristics-only` — Phase 2 only (no red-line checking)

**Known limitations:**
- The skill evaluates generated text, not intent — false positives are expected
- String-format red lines get best-effort keyword matching only (encourage upgrade)
- Heuristic alerts have a higher expected false-positive rate than red-line alerts
- Background scan can only flag content after it has been generated; it cannot pre-empt
- This skill does not block, modify, or delay any output

---

## Mode A: Background Scan

Background scan runs silently throughout any session where content is being generated
(writing, advice, recommendations, plans, proposals, communications).

**When to activate background scan:**
- `identity/values.yaml` is loaded (standard for every session)
- `ethical_red_lines` contains at least one structured entry (not all placeholders)
- The session involves generating content, not just reading or research

**When NOT to activate:**
- `ethical_red_lines` is empty, all placeholder strings, or all unstructured strings
- The session is pure research, analysis, or question-answering with no content generation

**Background scan process (per generated response):**

**Phase 1 — Red line check:**
1. Load `identity/values.yaml → ethical_red_lines` if not already in session context
2. For each response generated during the session, mentally scan the content against each red line:
   - Does the content touch the "when" context for this red line?
   - If yes: does the content violate or approach the "never" constraint?
   - Does the "except" clause apply?
3. If no violation detected: do nothing. Do not mention the scan.
4. If a potential violation is detected: surface a CONSCIENCE:ALERT or CONSCIENCE:CHECK immediately after the response (see Alert Format below)
5. Log the alert to `signals/observations.jsonl` as type `"conscience_alert"` (see Logging section below)

**Phase 2 — Heuristic check (if mode includes heuristics):**
6. Load `identity/heuristics.yaml` if not already in session context
7. Filter for entries where `confidence: high` only (skip medium, low, or unset)
8. For each high-confidence heuristic whose `use_when` or domain matches the current session:
   - Does the generated content contradict the heuristic's `rule` or `action`?
   - If yes: surface a CONSCIENCE:HEURISTIC notice (softer than ALERT — see Alert Format)
   - Log to `signals/observations.jsonl` as type `"conscience_heuristic"`
9. If no heuristic conflict detected: do nothing.

**Silence is the normal state.** The user should rarely see conscience output during
a session. If alerts are firing frequently, either the rules are misspecified or
the session topic is genuinely close to a boundary — either is worth noting.

---

## Mode B: On-Demand Check

On-demand check is triggered by `/amai:conscience` or the trigger phrases listed in
the frontmatter. It evaluates the current work product or a specified piece of content
against all structured red lines.

**Process:**

1. Load `identity/values.yaml → ethical_red_lines`
2. Check for structured entries:
   - If none exist (all strings or all placeholders): output the upgrade prompt (see below)
   - If some exist but some are strings: process structured entries, flag strings as legacy
3. For each structured red line, evaluate the current context:
   - State the red line's `id` and `when` scope
   - Assess: does the current content/context fall within this `when` scope?
   - If yes: does it violate the `never` constraint?
   - Check the `except` clause
   - Report compliance status for each red line in scope
4. If no red lines are in scope for this content: confirm clearly

**Output format for on-demand check:**

```
Conscience check — [brief description of what's being checked]

Red lines in scope for this context:
─────────────────────────────────────
[id]: [label from when field]
  Status: ✓ Compliant / ⚠️ POTENTIAL VIOLATION / ✗ VIOLATION
  [If flagged: brief explanation and suggested action]

Red lines not in scope:
  [list ids — why they don't apply to this content]

No red lines structured yet:
  [If applicable — upgrade prompt]
```

---

## Red Line Matching Logic

Apply this logic consistently across both modes:

### Step 1: Identify red line format

```
For each entry in ethical_red_lines:
  IF it is a string (quoted text, not a YAML object):
    → Legacy format. Do a best-effort keyword scan of the string.
    → If the current content plausibly relates to the string's theme: flag as
      CONSCIENCE:CHECK with note "Legacy red line — consider upgrading to structured format"
    → Reference docs/red_line_migration.md for the user

  IF it is a structured object (has id, when, never fields):
    → Apply structured matching logic (Step 2)
```

### Step 2: Context matching (structured red lines)

```
1. Read the "when" field: what contexts, roles, or relationships does this rule cover?
2. Does the current session content involve this context?
   - Yes clearly → proceed to Step 3
   - Possibly → proceed to Step 3 with lower confidence (use CONSCIENCE:CHECK not ALERT)
   - No → skip this red line for this content
```

### Step 3: Constraint evaluation

```
1. Read the "never" field: what specific behaviour is prohibited?
2. Does the generated content or proposed action violate this constraint?
3. Read the "except" field: does any stated exception apply?
   - If an exception applies and is clearly relevant → no flag
   - If an exception might apply but is ambiguous → flag with note about the exception
4. Use the "examples" field as reference anchors:
   - Are the examples showing compliant behaviour? Does current content resemble them?
   - Are the examples showing violations? Does current content resemble those instead?
```

### Step 4: Severity routing

```
IF severity == "absolute" AND violation detected:
  → CONSCIENCE:ALERT

IF severity == "strong" AND violation detected:
  → CONSCIENCE:CHECK (softer — asks user to verify rather than stating a violation)

IF no violation:
  → No output in background mode
  → "✓ Compliant" in on-demand mode
```

---

## Alert Format

### CONSCIENCE:ALERT (absolute severity, clear violation)

```
⚠️ CONSCIENCE:ALERT — [red_line_id]
Red line: [never field verbatim]
Context match: [when field — the context that triggered this]
Concern: [specific explanation of what in the current output may violate this constraint]
Suggested action: [concrete: reword X, add caveat Y, remove claim Z, or confirm this is an exception]
Exceptions: [except field, or "none declared"]
```

### CONSCIENCE:CHECK (strong severity, or lower-confidence match)

```
💭 CONSCIENCE:CHECK — [red_line_id]
Red line: [never field verbatim]
Context: [when field]
Note: [what in the current output may be relevant to this constraint — stated tentatively]
Question for you: [one specific question to help the user decide if this is a concern]
```

### CONSCIENCE:HEURISTIC (Phase 2 — high-confidence heuristic conflict)

```
💡 CONSCIENCE:HEURISTIC — [heuristic_id]
Rule: [rule field from heuristics.yaml]
Domain: [domain or use_when field]
Concern: [what in the current output may contradict this heuristic]
Note: This is a heuristic, not a red line. The user may have good reasons to deviate.
```

Heuristic alerts are softer than red-line alerts — they are advisory observations,
not warnings. They should appear less frequently than red-line checks and are logged
separately as `"conscience_heuristic"` rather than `"conscience_alert"`.

### Legacy red line flag

```
📋 CONSCIENCE:LEGACY — [first few words of string]
This red line is in string format and can't be checked precisely.
Best-effort match: [explanation of what seemed relevant]
To enable precise checking: run /amai:setup-advanced → red line upgrade, or
edit identity/values.yaml directly using docs/red_line_migration.md
```

---

## Logging

Every alert (CONSCIENCE:ALERT or CONSCIENCE:CHECK) — regardless of whether the user
acts on it — is logged to `signals/observations.jsonl` as a conscience-subtype entry.

**Log format — red line alerts (type: conscience_alert):**

```jsonl
{
  "date": "YYYY-MM-DD",
  "type": "conscience_alert",
  "context": "Conscience alert during [session context]",
  "signals": [
    "Conscience:ALERT — [red_line_id]: [one-line concern]",
    "User response: acknowledged / adjusted / dismissed"
  ],
  "possible_divergence": "Type 1 (Values) — ethical_red_lines → [red_line_id]",
  "config_ref": "identity/values.yaml → ethical_red_lines → [red_line_id]"
}
```

**Log format — heuristic notices (type: conscience_heuristic):**

```jsonl
{
  "date": "YYYY-MM-DD",
  "type": "conscience_heuristic",
  "context": "Heuristic notice during [session context]",
  "signals": [
    "Conscience:HEURISTIC — [heuristic_id]: [one-line concern]",
    "User response: acknowledged / adjusted / dismissed / no_response"
  ],
  "possible_divergence": "Type 3 (Operational) — heuristics → [heuristic_id]",
  "config_ref": "identity/heuristics.yaml → [section] → [heuristic_id]"
}
```

**User response tracking:**
After surfacing an alert, note the user's response in the same session:
- `acknowledged` — user noted the concern but continued as-is
- `adjusted` — user modified their content or approach in response
- `dismissed` — user explicitly rejected the concern
- `no_response` — user did not respond to the alert (note this in the log entry)

Log entries for conscience are written at session end alongside any other signal
entries, not immediately on alert (to avoid interrupting workflow). If the session
ends without an opportunity to append, the alert is noted in the Stop hook output.

---

## Entry Reference Logging

In addition to the `signals/observations.jsonl` log above, conscience alerts also append
to `calibration/entry_references.jsonl` for per-entry frequency tracking. This enables
the pruning system to answer "how often does this red line actually fire?" without any
LLM introspection.

**When a red line alert fires, append to `calibration/entry_references.jsonl`:**

```jsonl
{"date": "YYYY-MM-DD", "entry_id": "RED_LINE_ID", "entry_type": "red_line", "source_file": "identity/values.yaml", "event": "conscience_alert", "context": "BRIEF_SESSION_CONTEXT", "outcome": "fired"}
```

**When a heuristic notice fires, append to `calibration/entry_references.jsonl`:**

```jsonl
{"date": "YYYY-MM-DD", "entry_id": "HEURISTIC_ID", "entry_type": "heuristic", "source_file": "identity/heuristics.yaml", "event": "conscience_heuristic", "context": "BRIEF_SESSION_CONTEXT", "outcome": "fired"}
```

**After the user responds, update the outcome in the same entry if possible, or append a follow-up entry:**
- User adjusted their work → `"outcome": "applied"` (the constraint was applied)
- User explicitly dismissed → `"outcome": "dismissed"`
- User acknowledged but continued → `"outcome": "confirmed"` (they confirmed their approach is fine)

**Rules:**
- The `entry_id` must exactly match the `id` field from the red line or heuristic entry in the YAML file. Never paraphrase or abbreviate.
- Append entry reference logs at the same time as the `signals/observations.jsonl` entry (session end), not immediately on alert.
- If `calibration/entry_references.jsonl` does not exist, skip silently — never block conscience monitoring.
- This log is separate from `signals/observations.jsonl`. Do not duplicate data between them. The `signals/` file captures qualitative observations; `entry_references.jsonl` tracks entry-level event counts.

**Belief challenge tracking:**

When the conscience skill (or any session) encounters evidence that clearly and articulably
contradicts a stated belief from `identity/beliefs.yaml`, log to `calibration/entry_references.jsonl`:

```jsonl
{"date": "YYYY-MM-DD", "entry_id": "BELIEF_ID", "entry_type": "belief", "source_file": "identity/beliefs.yaml", "event": "belief_challenged", "context": "Evidence: BRIEF_DESCRIPTION_OF_CONTRADICTING_EVIDENCE", "outcome": "challenged"}
```

Rules for belief challenges:
- Only log when there is a clear, articulable contradiction between observed evidence and a stated belief.
- Do not log vague "this might not be true" intuitions.
- The `entry_id` must exactly match the `id` field in `identity/beliefs.yaml`.
- Log to `entry_references.jsonl` only — NOT to `signals/observations.jsonl` (beliefs are not operational signals).
- The calibration review process picks up these entries and asks the user whether to revise the belief's confidence level.
- If `calibration/entry_references.jsonl` does not exist, skip silently.

---

## No-Red-Lines Handling

If `ethical_red_lines` is empty, contains only placeholder strings (containing
"[Replace" or "[Example"), or contains only legacy string-format entries:

Do not activate background scan mode.

For on-demand checks, output:

```
No structured red lines found in identity/values.yaml.

Your ethical_red_lines section currently contains:
  [summary: X entries, all string format / all placeholders / empty]

To enable conscience checking:
1. Run /amai:setup-advanced to upgrade red lines conversationally, or
2. Edit identity/values.yaml directly following docs/red_line_migration.md
3. Then run: bash scripts/validate.sh

Conscience checking will activate automatically once structured entries are present.
```

---

## Worked Examples

### Example 1: Background scan — clear violation caught

*Session:* Drafting a client proposal. The user has a red line:
```yaml
- id: no_capability_overstatement
  when: "Client proposals, sales materials, capability claims"
  never: "Claim a capability that doesn't exist or hasn't been tested in production"
  severity: absolute
```

*Generated content includes:* "Our platform handles 10,000 concurrent users seamlessly."

*Conscience output (immediately after the response):*
```
⚠️ CONSCIENCE:ALERT — no_capability_overstatement
Red line: Claim a capability that doesn't exist or hasn't been tested in production
Context match: Client proposals, sales materials, capability claims
Concern: "10,000 concurrent users seamlessly" is a specific performance claim. Has this
been tested and verified? If not, this is a capability statement without evidence.
Suggested action: Replace with actual tested figures, or add: "in our testing environment
at [specific load]" — or remove the claim if no test data exists.
Exceptions: none declared
```

---

### Example 2: On-demand check — compliant

*User runs:* `/amai:conscience` while drafting a data policy document.

*Red lines in values.yaml:*
- `no_capability_overstatement` — context: client proposals (not in scope for a data policy)
- `no_client_data_misuse` — context: customer data handling (in scope)

*Output:*
```
Conscience check — data policy document

Red lines in scope:
─────────────────────────────────────
no_client_data_misuse: Customer data handling
  Status: ✓ Compliant
  The document explicitly states consent requirements and data class restrictions
  consistent with your declared constraint.

Red lines not in scope:
  no_capability_overstatement — this red line applies to sales materials,
  not data policy documents.

No concerns detected.
```

---

### Example 3: Legacy red line

*User's values.yaml contains:*
```yaml
ethical_red_lines:
  - "Never mislead a client about readiness"
```

*Session:* Drafting client update email.

*Background scan output:*
```
📋 CONSCIENCE:LEGACY — "Never mislead a client..."
This red line is in string format and can't be checked precisely.
Best-effort match: This session involves a client communication — your red line about
misleading clients may be relevant. Review manually.
To enable precise checking: run /amai:setup-advanced or follow docs/red_line_migration.md
```

---

## Relationship to Other Skills

**signal-capture:** Conscience alerts are a specific subtype of signal. They are logged
via the same `signals/observations.jsonl` mechanism but have their own `Conscience:`
prefix and structured log format. You do not need to invoke signal-capture separately
to log a conscience alert — the conscience skill handles its own logging.

**context-loader:** The conscience skill is loaded as part of the default session context
whenever `identity/values.yaml` is loaded and contains structured red lines. It does not
require explicit invocation for background scan mode.

**calibration:** Conscience alerts that are acknowledged or that the user acts on become
Type 1 (Values) divergence candidates during the next calibration review. Include
conscience-prefixed signals when reviewing `signals/observations.jsonl` during calibration.

---

## Audit Logging

The conscience skill logs alerts to `signals/observations.jsonl` — those log entries are the primary record. Additionally, when a conscience alert results in the user *modifying* their work (i.e., the alert was actionable), log that to the audit trail:

```bash
bash "${AMAI_USER_ROOT}/scripts/audit_log.sh" \
  --actor ai \
  --actor-id conscience \
  --module "signals/observations" \
  --category update \
  --description "Conscience alert: RED_LINE_ID — user acknowledged/adjusted" \
  --files "signals/observations.jsonl"
```

Only log when an alert fires and the user responds. Silent background scans with no violations do not generate audit entries.

If the script isn't found, skip silently — never block conscience monitoring over audit logging.
