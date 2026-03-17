---
description: Run AMAI structural validation and report results inline
allowed-tools: Bash, Read
---

**Path convention:** All user data files are in `${AMAI_USER_ROOT}` — the user's personal AMAI directory, resolved at session start from `~/.amai/config.yaml`. If not resolved, fall back to `${CLAUDE_PLUGIN_ROOT}`.

Run the AMAI validation script and report results.

Execute:
```bash
bash "${AMAI_USER_ROOT}/scripts/validate.sh"
```

Capture the full output. Then:

1. Parse the results — identify any errors, warnings, and passed checks.

2. Present the results in a clear format:

---
**AMAI Validation Results**

✅ Passed: [count]
⚠️ Warnings: [count]
❌ Errors: [count]

**Errors** (must fix):
[list each error with the affected file and description]

**Warnings** (should review):
[list each warning with context]

**Passed checks:**
[brief list]
---

3. If there are errors, explain what each one means in plain language and suggest how to fix it.

4. If validation passed cleanly, confirm: "AMAI structure is valid. No issues found."

Do not just dump the raw script output — parse it and present it readably.
If the script fails to run (e.g., not executable), attempt: `chmod +x "${AMAI_USER_ROOT}/scripts/validate.sh"` and retry.
