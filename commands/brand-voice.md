---
name: brand-voice
description: Set up or activate an organisational brand voice overlay
argument_hint: "[org-name | --list | --activate org-name | --new org-name]"
flags:
  --list: "List all configured org overlays"
  --activate: "Activate an existing overlay by name (e.g. --activate ukfootprint)"
  --new: "Set up a new overlay from scratch (guided)"
allowed_tools:
  - Read
  - Write
  - Edit
  - Bash
---

Invoke the org-overlay skill at `skills/org-overlay/SKILL.md` in brand voice setup or
activation mode.

**Mode detection:** Parse $ARGUMENTS before running:
- `--list` → list available org overlays from `org/org_index.yaml`
- `--activate [org-name]` → activate the named overlay (S1 mode by default)
- `--new [org-name]` → guided setup for a new overlay
- `[org-name]` with no flag → activate if it exists, offer to create if not
- No arguments → list available overlays and ask which to activate

**Step 1 — Read the skill:**

Read `${CLAUDE_PLUGIN_ROOT}/skills/org-overlay/SKILL.md` and follow its instructions
for the detected mode.

**Step 2 — For `--list`:**

Read `${CLAUDE_PLUGIN_ROOT}/org/org_index.yaml`. Output a summary table:

```
Configured org overlays:
  [org-id]  — [display_name]  ([status: active/inactive])
```

If no overlays are configured, say: "No org overlays configured yet. Use
`/amai:brand-voice --new [org-name]` to create one, or see `docs/brand_voice_prompt.md`
for a portable setup guide."

**Step 3 — For `--activate [org-name]` or `[org-name]`:**

Follow the org-overlay skill's Activation workflow exactly. Confirm the active context
to the user after loading.

**Step 4 — For `--new [org-name]`:**

Follow the org-overlay skill's "Setting Up a New Org Overlay" section. Walk the user
through all steps in `docs/brand_voice_prompt.md`. Create the overlay directory and
template files, then offer to activate immediately.

**Step 5 — Run validation:**

After any write operation (new or updated overlay), run:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh --quiet
```

Report any ERRORs. WARNs about placeholder data are expected for new overlays.
