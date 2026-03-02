# AMAI Export System

This directory contains the export configuration and generated output bundles.

## Available Profiles

| Profile | Platform | Budget | Format |
|---|---|---|---|
| `claude_project` | Claude Projects | 90K chars | Single `.md` file |
| `chatgpt_project` | ChatGPT Projects | 60K chars | Single `.md` file |
| `gemini_drive` | Gemini via Google Drive | 120K chars | Multi-file folder |
| `generic` | Any system instructions field | 15K chars | Single `.md` file |

Profile details (per-file budgets, include/exclude lists) are in `profiles.yaml`.

## Running an Export

**From the command line:**
```bash
# Dry-run — see what would be included without writing files
bash scripts/amai_export.sh --target claude_project --dry-run

# Generate a real export
bash scripts/amai_export.sh --target claude_project

# Specify a custom output directory
bash scripts/amai_export.sh --target generic --output /tmp/amai_bundle/
```

**From Cowork:**
```
/amai:export
/amai:export claude_project
```

## Output Location

Generated exports land in `export/<profile>_<YYYYMMDD>/` and are excluded from git
(see `.gitignore`). Re-running on the same day overwrites the existing output.

## What Gets Excluded

Tier 1 and Tier 2 files are never included in any export. See `SECURITY.md` for the
full sensitivity tier table and the reasoning behind each exclusion.

## Adding a New Profile

Edit `profiles.yaml` and add a new entry under `profiles:` following the existing
structure. The export script reads profiles at runtime — no code changes needed.

Validate your new profile with a dry-run before committing:
```bash
bash scripts/amai_export.sh --target <new_profile> --dry-run
```
