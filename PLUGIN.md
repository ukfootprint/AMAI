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

### 1. Configure your personal AMAI data path

The plugin code (skills, commands, hooks) is read-only when installed as a Cowork plugin. Your personal AMAI data lives in a separate folder — your own AMAI instance (e.g., `AMAI-simon`). Tell the plugin where to find it:

Create `~/.amai/config.yaml`:

```yaml
# AMAI user configuration
# Points the Cowork plugin to your personal AMAI data directory.
user_root: ~/code/AMAI-simon
```

Replace the path with your actual AMAI data folder. This is the directory that contains your `identity/`, `goals/`, `signals/`, `memory/`, and other personal data directories.

If `~/.amai/config.yaml` is not present, the plugin falls back to `${CLAUDE_PLUGIN_ROOT}` (the plugin's own directory) — which works when the plugin and data live in the same folder, but will fail with write errors when the plugin is installed as a read-only Cowork plugin.

### 2. Install the plugin

1. Open Cowork (your AMAI data folder does not need to be the workspace)
2. Install the `amai.plugin` file
3. The SessionStart hook will fire on your next session, resolve your data path from `~/.amai/config.yaml`, and load your context

### How path resolution works

The plugin uses two path variables:

| Variable | Points to | Used for |
|----------|-----------|----------|
| `${CLAUDE_PLUGIN_ROOT}` | The plugin's installed location (read-only) | Skill definitions, command definitions, hook definitions |
| `${AMAI_USER_ROOT}` | Your personal AMAI data directory (read-write) | All user data: identity, goals, memory, signals, calibration, scripts, schemas |

The SessionStart hook resolves `${AMAI_USER_ROOT}` from `~/.amai/config.yaml` at the start of every session and prints it in the session context. All commands and skills use this path for reading and writing your data.

## Architecture

The plugin separates **plugin code** (read-only, distributable) from **user data** (read-write, personal). The plugin infrastructure (`.claude-plugin/`, `commands/`, `skills/`, `hooks/`) is versioned in this repository and installed as a Cowork plugin. Your personal data (values, voice, memory, network, org overlays, scripts, schemas) lives in your own AMAI instance directory, pointed to by `~/.amai/config.yaml`.

This separation means you can install plugin updates without affecting your personal data, and your data folder remains a standalone AMAI instance that works with any AI platform.

## What this doesn't cover

- **Browser sessions** (Claude.ai): Use `scripts/amai_export.sh` + SYNC_STRATEGY.md for browser contexts
- **Other AI platforms**: Plugin is Claude Cowork-specific; raw AMAI files remain usable with any platform
- **Multi-device sync**: Still managed via git, not the plugin
