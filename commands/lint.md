---
description: Lint an org overlay for schema compliance and structural issues
allowed-tools: Bash, Read
argument-hint: [org-name]
---

Run the AMAI lint script against the specified org overlay.

The org name is: $ARGUMENTS

If no org name was provided, read `${CLAUDE_PLUGIN_ROOT}/org/org_index.yaml` and list the available overlays, then ask the user which one to lint.

Once the org name is confirmed, execute:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/amai_lint.sh" "$ARGUMENTS"
```

Capture the full output. Then:

1. Parse the results — identify schema violations, missing required fields, structural issues.

2. Present results in a clear format:

---
**AMAI Lint: [org name]**

✅ Passed: [count]
⚠️ Warnings: [count]
❌ Errors: [count]

**Errors:**
[list each with affected file and field]

**Warnings:**
[list each with context]
---

3. For each error, explain what the schema requires and what was found.

4. Offer to fix simple issues (missing optional fields with sensible defaults) if the user confirms.

If the script fails to run, attempt: `chmod +x "${CLAUDE_PLUGIN_ROOT}/scripts/amai_lint.sh"` and retry.
