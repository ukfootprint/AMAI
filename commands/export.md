---
description: Export AMAI context bundle for a target AI platform
allowed-tools: Bash, Read
---

Export your AMAI context as a platform-specific bundle using profile-based export.

## Determine target

If the user invoked `/amai:export` with an argument (e.g. `/amai:export chatgpt_project`),
use that as the target. Otherwise, ask:

> Which platform are you exporting for?
> 1. **claude_project** — Claude Projects (custom instructions + knowledge files, ~90K chars)
> 2. **chatgpt_project** — ChatGPT Projects (project instructions + files, ~60K chars)
> 3. **gemini_drive** — Gemini via Google Drive (multi-file folder, ~120K chars)
> 4. **generic** — Any system instructions field (minimal bundle, ~15K chars)

Read `${CLAUDE_PLUGIN_ROOT}/export/profiles.yaml` to confirm available profiles and their
current budget settings before listing options.

## Run the export

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/amai_export.sh" --target <target>
```

Capture the full console output. It will show:
- Profile name and output path
- Files included, excluded, and skipped (budget)
- Character count vs budget (with percentage)
- Staleness warnings (if any modules are out of date)
- Source commit hash

## Report results

Show the user a plain-language summary:

1. **Where it was written** — the output path from the script
2. **Budget usage** — e.g. "43,305 / 90,000 chars (48%)"
3. **Staleness warnings** — list any modules flagged as stale, with a note that they
   should be updated via `/amai:setup` before the next export
4. **What was excluded** — mention the excluded tier 1/2 files briefly
   (e.g. "Contacts, interactions, failures, and decisions are never exported")

## Offer to show contents

After reporting the summary, ask:

> Want me to show you the export contents before you upload it?

If yes, read the generated file (for `single_file_markdown` profiles) or the MANIFEST.md
(for `multi_file_folder` profiles like gemini_drive) and display it.

## Usage instructions by target

After export, remind the user how to use the bundle:

- **claude_project / chatgpt_project**: Upload the `.md` file to your project's knowledge
  base, or paste it into the custom instructions field.
- **gemini_drive**: Upload the entire exported folder to a Google Drive folder, then
  reference it when starting a Gemini conversation.
- **generic**: Copy the `.md` contents into the system instructions or custom instructions
  field of any AI tool.

## Error handling

- If the script exits non-zero, parse the error output and explain it in plain language.
- If `export/profiles.yaml` is missing: "Run `bash scripts/amai_export.sh` to see setup
  instructions, or check that `export/profiles.yaml` exists."
- Make the script executable if needed: `chmod +x "${CLAUDE_PLUGIN_ROOT}/scripts/amai_export.sh"`
