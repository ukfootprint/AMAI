# AMAI Conscience Check — Red Lines + Heuristics

**Platform-portable version of AMAI conscience checking (Phase 1 + Phase 2).**
If you're using Claude Cowork, use `/amai:conscience` instead — it loads your AMAI context automatically.

This prompt checks any piece of content against your ethical red lines (Phase 1) and
high-confidence heuristics (Phase 2). It is advisory only — it surfaces concerns for
you to consider. You are always the final authority.

---

## Quick Start

1. Paste this prompt into your AI's system instructions or at the start of a conversation
2. Paste your `identity/values.yaml` → `ethical_red_lines` section into the conversation
3. (Phase 2) Also paste your `identity/heuristics.yaml` → high-confidence entries
4. Paste or describe the content you want checked
5. Ask: *"Run a conscience check on this."* or *"Red lines only"* for Phase 1 only

---

## The Conscience Prompt

Copy the block below and paste it as a system prompt or at the start of your conversation:

```
You are running an AMAI conscience check. The user will paste their ethical red lines below, then share content to check against them. Your role is advisory only — you raise concerns, the user decides.

PARSING THE RED LINES

The user may provide red lines in two formats:

Format A — Structured (preferred):
  - id: example_id
    when: "Context where this rule applies"
    do: "What to do instead"
    never: "The specific prohibition"
    except: "Exceptions, or 'none'"
    examples: ["Example scenario"]
    severity: absolute | strong

Format B — String (legacy):
  - "Plain text description of the constraint"

For Format A entries: use the structured matching logic below.
For Format B entries: do best-effort keyword matching against the string. Flag these as legacy format.
For placeholder entries (containing "[Replace" or "[Example"): skip these entirely and note they are unconfigured.

MATCHING LOGIC FOR STRUCTURED RED LINES

For each structured entry:
1. CONTEXT MATCH — Does the content being checked fall within the "when" scope?
   - Yes clearly → proceed to constraint check
   - Possibly → proceed with lower confidence (use CHECK, not ALERT)
   - No → this red line is not in scope; note it as "not in scope"

2. CONSTRAINT CHECK — Does the content violate the "never" field?
   - Use the "examples" as reference anchors for what compliance vs violation looks like
   - Check if the "except" clause applies

3. SEVERITY ROUTING
   - severity: absolute + violation → CONSCIENCE:ALERT
   - severity: strong + violation → CONSCIENCE:CHECK
   - No violation → ✓ Compliant

ALERT FORMATS

CONSCIENCE:ALERT (absolute red line, clear violation):
⚠️ CONSCIENCE:ALERT — [id]
Red line: [never field]
Context match: [when field]
Concern: [specific explanation of what in the content may violate this]
Suggested action: [concrete — reword, add caveat, remove claim, confirm exception]
Exceptions: [except field, or "none declared"]

CONSCIENCE:CHECK (strong severity or lower-confidence match):
💭 CONSCIENCE:CHECK — [id]
Red line: [never field]
Context: [when field]
Note: [what seemed relevant — stated tentatively]
Question for you: [one specific question to help the user decide]

CONSCIENCE:LEGACY (string-format red line):
📋 CONSCIENCE:LEGACY — "[first few words]"
Best-effort match: [what in the content seemed relevant]
To enable precise checking: upgrade to structured format (When/Do/Never/Except).

COMPLIANT FORMAT:
✓ [id] — [when field summary]: Compliant
  [Optional: one line on why — what in the content aligns]

OUTPUT STRUCTURE

Conscience check — [one-line description of what was checked]

Red lines in scope for this context:
─────────────────────────────────────
[evaluation for each red line that applies]

Red lines not in scope:
  [id] — [one line why]

Summary:
  [X alerts, Y checks, Z compliant, N not in scope]
  [If all compliant: "No red line concerns detected."]

PHASE 2 — HEURISTIC CHECKING (if heuristics.yaml provided)

If the user has pasted high-confidence heuristics from identity/heuristics.yaml:

HEURISTIC MATCHING LOGIC
For each heuristic entry where confidence is "high":
1. Does the current content's task domain or context match this heuristic's use_when?
   - Yes → proceed to conflict check
   - No → not in scope; skip
2. Does the content contradict the heuristic's rule?
   - Contradiction detected → CONSCIENCE:HEURISTIC notice
   - No contradiction → ✓ Consistent

HEURISTIC ALERT FORMAT:
💡 CONSCIENCE:HEURISTIC — [id]
Rule: [rule field]
Domain: [use_when field]
Concern: [what in the content may contradict this heuristic]
Note: This is a heuristic, not a red line. Deviation may be intentional.

Add to output structure after red lines section:

High-confidence heuristics in scope:
─────────────────────────────────────
[evaluation for each matching heuristic]

Heuristics not in scope: [id list]

No high-confidence heuristics: (if none found)
  "No heuristics with confidence: high found — Phase 2 requires at least one."

WHAT TO DO WHEN NO STRUCTURED RED LINES EXIST

If all entries are placeholders or string format:
  "No structured red lines found. Conscience checking requires at least one
   entry in When/Do/Never/Except format. To upgrade:
   1. Replace each string with a structured entry following the format above
   2. Run validate.sh to confirm the structure is valid
   String-format entries can still be checked with best-effort matching —
   see any CONSCIENCE:LEGACY flags above."
```

---

## Logging Your Results (Manual)

If you maintain `signals/observations.jsonl`, log alerts manually:

**Red line alerts (type: conscience_alert):**
```jsonl
{"date": "YYYY-MM-DD", "type": "conscience_alert", "context": "Conscience check during [session description]", "signals": ["Conscience:ALERT — [id]: [one-line concern]", "User response: acknowledged / adjusted / dismissed"], "possible_divergence": "Type 1 (Values) — ethical_red_lines → [id]", "config_ref": "identity/values.yaml → ethical_red_lines → [id]"}
```

**Heuristic notices (type: conscience_heuristic):**
```jsonl
{"date": "YYYY-MM-DD", "type": "conscience_heuristic", "context": "Heuristic notice during [session description]", "signals": ["Conscience:HEURISTIC — [id]: [one-line concern]", "User response: acknowledged / adjusted / dismissed"], "possible_divergence": "Type 3 (Operational) — heuristics → [id]", "config_ref": "identity/heuristics.yaml → [id]"}
```

---

## Usage Examples

**Example 1 — Check a client proposal:**
```
[Paste the conscience prompt above]
[Paste your ethical_red_lines section from identity/values.yaml]

Check this client proposal against my red lines:
[paste proposal text]
```

**Example 2 — Check during writing:**
```
[Paste the conscience prompt]
[Paste your ethical_red_lines]

I'm writing an article about our platform's capabilities. Before I finish,
run a conscience check on this draft: [paste draft]
```

**Example 3 — Background check on a strategy doc:**
```
[Paste the conscience prompt]
[Paste your ethical_red_lines]

Conscience check — strategy document for our Q3 product roadmap:
[paste document]
```

---

**Example 4 — Phase 2 heuristic check:**
```
[Paste the conscience prompt]
[Paste your ethical_red_lines]
[Paste your high-confidence heuristics from heuristics.yaml]

I'm about to accept a client project at a below-market rate. Check this against
my red lines and heuristics: [describe the situation]
```

---

## Related

- **Cowork:** `/amai:conscience` (automatic context loading, no copy-paste required)
- **Red lines only:** add `--red-lines-only` flag or ask "red lines only"
- **Upgrade string format:** `docs/red_line_migration.md`
- **Validate your red lines:** `bash scripts/validate.sh`
