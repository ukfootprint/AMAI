# AMAI Cowork Plugin

The AMAI Cowork plugin turns your AMAI directory into an intelligent Claude session layer.
Instead of manually loading context at the start of every session, the plugin handles it
automatically — and adds commands and skills for the workflows you run repeatedly.

## What it does

**On session start (automatic):** Claude loads your BRAIN.md, values, heuristics, current
focus, and module trigger table. Conscience monitoring begins immediately — ethical red lines
and high-confidence heuristics are checked silently throughout the session.

**During the session (on-demand):** The context-loader skill reads your MODULE_SELECTION.md
trigger table and loads additional modules when your task calls for them — memory, network,
knowledge, org overlay, domain files, and more. Domain-specific knowledge loads automatically
when session vocabulary matches a registered domain's trigger tags.

**At session end (automatic):** If the session contained a signal-worthy moment (a significant
decision, learning, or interpersonal interaction), Claude offers to capture it.

## Commands

| Command | What it does |
|---------|-------------|
| `/amai:status` | Show system health, calibration date, stale modules, active overlays |
| `/amai:setup [1\|2\|3]` | Run progressive onboarding — Stage 1 (30 min), Stage 2 (45 min), Stage 3 (30 min) |
| `/amai:calibrate` | Walk through the calibration protocol interactively |
| `/amai:validate` | Run `scripts/validate.sh` and report results inline |
| `/amai:lint [org]` | Run `scripts/amai_lint.sh` against a specified org overlay |
| `/amai:export` | Run `scripts/amai_export.sh` and generate a browser-safe bundle |
| `/amai:capture [text]` | Log an observation, decision, experience, or learning to memory |
| `/amai:prune` | Generate a pruning report — archive candidates, consolidation, domain analysis |
| `/amai:conscience [--red-lines-only\|--heuristics-only]` | On-demand ethical check against red lines and/or heuristics |
| `/amai:brand-voice [--list\|--activate\|--new]` | Set up or activate an organisational brand voice overlay |

## Skills

| Skill | Triggers on |
|-------|------------|
| `context-loader` | Any task where additional AMAI modules should be loaded; also loads domain-specific knowledge when task vocabulary matches registered domain tags |
| `conscience` | Background monitoring of red lines (Phase 1) and high-confidence heuristics (Phase 2) every session; on-demand via `/amai:conscience` |
| `org-overlay` | Org context activation, session states, behaviour bands, tension logging |
| `signal-capture` | Logging observations, decisions, experiences, failures, or learnings |
| `identity-voice` | Writing in your voice, applying values, checking heuristics |
| `onboarding` | Guided conversational setup — Stages 1, 2, and 3 |
| `pruning` | Interactive review of archive candidates and pruning recommendations |

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
