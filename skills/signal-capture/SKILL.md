---
name: signal-capture
description: >
  This skill should be used when the user wants to log an observation, signal,
  or experience to their AMAI memory. Trigger phrases include: "log this",
  "capture that", "add to observations", "record this decision", "note this experience",
  "I want to remember this", "log a failure", "capture this learning", or when
  the user responds positively to the `/amai:capture` prompt. Also trigger when
  the user says "what signals have I logged", "show recent observations", or
  "review my signals".
version: 0.1.0
---

The signal-capture skill guides structured observation logging to AMAI's memory
modules. It ensures entries follow the correct schema and are appended without
corrupting existing data.

**Path convention:** All user data file paths (identity/, signals/, calibration/, etc.) resolve to `${AMAI_USER_ROOT}` — the user's personal AMAI directory, set in `~/.amai/config.yaml`. If not configured, fall back to `${CLAUDE_PLUGIN_ROOT}`.

## Step 1: Determine the signal type

Ask the user what they want to capture if not already clear. Signal types map to files:

| Signal type | Target file | When to use |
|-------------|------------|-------------|
| General observation | `signals/observations.jsonl` | Anything notable that doesn't fit a specific category |
| Decision | `memory/decisions.jsonl` | A decision that was made, with reasoning |
| Experience | `memory/experiences.jsonl` | A meaningful event or situation that resolved |
| Failure | `memory/failures.jsonl` | Something that went wrong, with root cause and lessons |
| Learning | `knowledge/learning.jsonl` | A new insight, concept, or understanding |
| Org tension | `org/overlays/{org}/tension_log.jsonl` | Conflict between personal values and org context |

## Step 2: Read the schema

Before logging, read the SCHEMA.md file in the relevant directory:
- `${AMAI_USER_ROOT}/signals/SCHEMA.md` for observations
- `${AMAI_USER_ROOT}/memory/SCHEMA.md` for decisions, experiences, failures
- `${AMAI_USER_ROOT}/knowledge/SCHEMA.md` for learning

Parse one or two recent entries from the target JSONL file to confirm the exact schema in use.

## Step 3: Gather the observation

Ask for any missing fields required by the schema. Do not ask for more than necessary —
derive what you can from the conversation context.

Common fields across signal types:
- `timestamp`: ISO 8601 (generate current time)
- `type`: signal category
- `content` or `description`: the core observation
- `context`: what led to this
- `tags`: relevant keywords for future retrieval
- `significance`: low / medium / high

## Step 4: Construct and confirm

Show the user the JSON object you're about to log. Ask for confirmation before writing.

Example confirmation:
> About to log this observation:
> ```json
> { "timestamp": "...", "type": "decision", "content": "...", "tags": [...] }
> ```
> Confirm?

## Step 5: Append to the file

Use the Edit tool to append the new JSON line to the end of the target JSONL file.
Never overwrite existing entries. Each entry is a single JSON object on its own line.

Confirm success: "Logged to [filename]. Total entries: [count]."

## Viewing recent signals

When the user asks to review signals or observations:
1. Read the relevant JSONL file
2. Parse and display the most recent entries (last 10 unless a different count is requested)
3. Format readably — not raw JSON
4. Offer to filter by tag or type if the file is large

---

## Audit Logging

After appending an entry to any JSONL file, log the change to the audit trail:

```bash
bash "${AMAI_USER_ROOT}/scripts/audit_log.sh" \
  --actor ai \
  --actor-id signal-capture \
  --module "MODULE_AREA" \
  --category update \
  --description "Logged TYPE signal: BRIEF_SUMMARY" \
  --files "TARGET_FILE"
```

Example: `--module "signals/observations" --description "Logged override signal: rewrote AI's formal tone to conversational" --files "signals/observations.jsonl"`

If the script isn't found, skip silently — never block signal capture over audit logging.
