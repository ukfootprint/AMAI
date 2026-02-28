# AMAI Cowork Plugin

The AMAI Cowork plugin turns your AMAI directory into an intelligent Claude session layer.
Instead of manually loading context at the start of every session, the plugin handles it
automatically — and adds commands and skills for the workflows you run repeatedly.

## What it does

**On session start (automatic):** Claude loads your BRAIN.md, values, heuristics, current
focus, and module trigger table. You start every session already oriented, with no prompt ceremony.

**During the session (on-demand):** The context-loader skill reads your MODULE_SELECTION.md
trigger table and loads additional modules when your task calls for them — memory, network,
knowledge, org overlay, and more.

**At session end (automatic):** If the session contained a signal-worthy moment (a significant
decision, learning, or interpersonal interaction), Claude offers to capture it.

## Commands

| Command | What it does |
|---------|-------------|
| `/amai:status` | Show system health, calibration date, stale modules, active overlays |
| `/amai:calibrate` | Walk through the calibration protocol interactively |
| `/amai:validate` | Run `scripts/validate.sh` and report results inline |
| `/amai:lint [org]` | Run `scripts/amai_lint.sh` against a specified org overlay |
| `/amai:export` | Run `scripts/amai_export.sh` and generate a browser-safe bundle |
| `/amai:capture [text]` | Log an observation, decision, experience, or learning to memory |

## Skills

| Skill | Triggers on |
|-------|------------|
| `context-loader` | Any task where additional AMAI modules should be loaded |
| `org-overlay` | Org context activation, session states, behaviour bands, tension logging |
| `signal-capture` | Logging observations, decisions, experiences, failures, or learnings |
| `identity-voice` | Writing in your voice, applying values, checking heuristics |

## Setup

No additional configuration required. The plugin lives in the AMAI directory itself —
when the AMAI folder is your Cowork workspace, `${CLAUDE_PLUGIN_ROOT}` resolves to the
root of your AMAI repo and all file references work automatically.

### Installing the plugin

1. Open Cowork and select your AMAI folder as the workspace
2. Install the `amai.plugin` file
3. The SessionStart hook will fire on your next session

## Architecture

This plugin implements **Option 1: plugin alongside AMAI files, single branch.** The plugin
infrastructure (`.claude-plugin/`, `commands/`, `skills/`, `hooks/`) lives in the same git
repo and branch as your AMAI data files. This keeps everything in one place and makes
the plugin configuration part of your AMAI version history.

The plugin does not contain any personal data — it only contains instructions for how
Claude should read and use your AMAI files. Your personal data (values, voice, memory,
network, org overlays) remains in the AMAI data directories unchanged.

## What this doesn't cover

- **Browser sessions** (Claude.ai): Use `scripts/amai_export.sh` + SYNC_STRATEGY.md for browser contexts
- **Other AI platforms**: Plugin is Claude Cowork-specific; raw AMAI files remain usable with any platform
- **Multi-device sync**: Still managed via git, not the plugin
