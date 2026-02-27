# Pending Calibration Reviews
*Generated from `divergence.jsonl` — items with disposition CANDIDATE or WARNING not yet resolved*

---

## Promotion Rubric — Before You Incorporate Anything

A CANDIDATE should only move to INCORPORATED after meeting **all three** of the following conditions:

| Condition | Why it matters |
|-----------|---------------|
| **1. Three independent sessions** — the pattern was observed in at least 3 separate AI sessions, not 3 signals in one session | Prevents premature crystallisation of a one-off. Single sessions can be mood, context, or task-type artefacts. Three independent observations is the minimum for a pattern. |
| **2. Not a values conflict** — the candidate does not soften, qualify, or create exceptions to an existing ethical red line | Config evolution is legitimate. Values erosion is not. If in doubt, classify as WARNING and do not incorporate. |
| **3. Deliberate human decision** — you have read the candidate, considered the implication, and made an active choice — not just accepted a suggestion | The AI proposes. You decide. "INCORPORATE" requires a conscious act, not passive agreement. |

**If a CANDIDATE does not meet all three conditions:** Keep it as CANDIDATE or move to DEFER. Do not incorporate.

**For WARNING items:** The rubric does not apply. WARNINGs are never candidates for incorporation. The question is not "should I update config?" but "what caused this drift and how do I correct it?"

---

## How to Use This File

Each item represents a detected divergence between session-observed signals and your declared AMAI configuration.

For each CANDIDATE, decide:
- **INCORPORATE** → All three rubric conditions met. Update the relevant config file, mark `INCORPORATED` in `divergence.jsonl`, log the decision in `memory/decisions.jsonl` with reasoning.
- **REJECT** → Config stays as-is. Note why the behaviour represents drift, not evolution. Mark `REJECTED` in `divergence.jsonl`.
- **DEFER** → More data needed, or conditions not yet met. Leave in place. Revisit next review. Note what you are waiting for.

For each WARNING, decide:
- **CORRECT** → Identify what caused the drift and how to address it. The config does not change.
- **DEFER** → More information needed before diagnosing cause.

---

## ⚠️ Active Warnings
*Behaviours diverging from values — requires course-correction, not config update*

*None currently logged.*

---

## 🔵 Active Candidates
*Potential config improvements — must meet all three promotion rubric conditions before incorporating*

*None currently logged.*

---

## ⏳ Deferred Items
*Watching for pattern — note what you are waiting for when deferring*

*None currently logged.*

---

*Last reviewed: —*
*Next scheduled review: —*

---

## Org Tension Review

Complete this section at monthly calibration if you are using an org overlay.

### Step 1: Review tension_log.jsonl

Read org/overlays/<org_id>/tension_log.jsonl for the past month.
Count entries by severity and tension_type.

Questions to answer:
- Are there any HIGH severity tension entries? What pattern do they point to?
- Is the frequency of tension entries increasing, stable, or decreasing?
- Which tension_type appears most often? What does that tell you about the
  fit between your personal values and this org context?

### Step 2: Review band calibration

Look at your behaviour_bands.yaml context_type_defaults (in overlay.yaml).
For each context type you used this month, ask:
- Did the band levels feel right, or were you consistently overriding them?
- If you were overriding, should the defaults change, or was the override
  situational?

Update overlay.yaml context_type_defaults if a systematic mismatch is evident.
Log the change in CHANGELOG.md.

### Step 3: Extreme band check

Review overlay.yaml context_type_defaults for any dimension set to L1 or L5.
Extremes should be deliberate. Ask:
- Is this extreme still warranted, or has the org context changed?
- Is an extreme setting suppressing something that should be expressed?

### Step 4: Structural misalignment flag

If HIGH severity tension entries are increasing month on month, or if the
same tension_type appears more than three times in a single month, flag this
explicitly in pending_review.md:

STRUCTURAL_TENSION_FLAG: [date] — [description]

A structural tension flag is not an action item — it is a signal that the
relationship between your personal values and this org context may warrant
a deliberate conversation, a role adjustment, or a values reconsideration.
It should not be resolved by updating config files.
