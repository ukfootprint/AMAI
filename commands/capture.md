---
description: Log an observation, decision, experience, or learning to AMAI memory
allowed-tools: Read, Write, Edit, Bash
---

Capture a signal or observation to AMAI memory. This command invokes the signal-capture skill.

$ARGUMENTS may contain a pre-stated observation (e.g., `/amai:capture I decided to X because Y`).
If provided, use it as the starting point for the capture. If empty, ask the user what they want to log.

Follow the signal-capture skill workflow:

1. Determine the signal type (observation, decision, experience, failure, learning, org tension).
   - If $ARGUMENTS contains a clear description, infer the type from it.
   - If ambiguous, ask: "What type of signal is this — a decision, experience, learning, or general observation?"

2. Read the SCHEMA.md for the target file:
   - General observations: `${CLAUDE_PLUGIN_ROOT}/signals/SCHEMA.md`
   - Decisions/experiences/failures: `${CLAUDE_PLUGIN_ROOT}/memory/SCHEMA.md`
   - Learning: `${CLAUDE_PLUGIN_ROOT}/knowledge/SCHEMA.md`

3. Read one or two recent entries from the target JSONL file to confirm the schema in use.

4. Gather any missing required fields from the user. Keep it brief — derive what you can from context.

5. Construct the JSON entry. Show it to the user and ask for confirmation before writing.

6. Append the entry as a new line to the target JSONL file. Never overwrite existing entries.

7. Confirm: "Logged to [filename]."

Use the current timestamp in ISO 8601 format.
