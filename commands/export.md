---
description: Generate a browser-safe AMAI bundle for use in web AI sessions
allowed-tools: Bash, Read
---

Generate a browser-safe AMAI export bundle using the export script.

Execute:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/amai_export.sh"
```

Capture the full output, including the location of the generated bundle.

Then:

1. Confirm where the export was written (the script output will indicate this).

2. Summarise what was included in the export:
   - Which modules were exported
   - Any modules excluded (e.g., sensitive data excluded by default)
   - File size and format

3. Explain how to use the bundle: "To use this with Claude.ai or another browser-based AI, upload the exported file at the start of your session and include this prompt: [show the standard AMAI session-start prompt from SYNC_STRATEGY.md]"

4. Read `${CLAUDE_PLUGIN_ROOT}/SYNC_STRATEGY.md` to provide the correct usage instructions for the exported bundle.

If the script fails to run, attempt: `chmod +x "${CLAUDE_PLUGIN_ROOT}/scripts/amai_export.sh"` and retry.
If the script produces errors, parse and explain them in plain language.
