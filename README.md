# AMAI — Anchor My AI

> *A values-first, file-based personal AI infrastructure.*

Give any AI assistant structured context about who you are, what you're building, and how you think — so it operates in alignment with your values from session one, without you re-explaining yourself each time.

No database. No app. No API keys. No platform lock-in. Plain files that both humans and AI read natively, versioned in git, working with any AI model.

---

## Native plugin for Claude Cowork

> **The best AMAI experience is zero-ceremony.** The `amai.plugin` for [Claude Cowork](https://claude.ai/download) eliminates the manual session-start prompt entirely.

Install `amai.plugin` with your AMAI folder as the Cowork workspace and every session starts already loaded — values, heuristics, current focus, and the full module trigger table injected automatically. Commands like `/amai:status`, `/amai:calibrate`, and `/amai:capture` are available from the first message. Signal-worthy moments are detected and offered for logging at session end without you having to remember.

The plugin is included in this repository alongside your AMAI files. See [PLUGIN.md](PLUGIN.md) for full details, and [Getting Started](#getting-started) for installation instructions.

---

## How it works

Every session starts with one instruction:

> *"Read my BRAIN.md and load the relevant modules for this task."*

The AI reads `BRAIN.md`, loads only the modules relevant to the task, and operates within your values, voice, and context.

With the Claude Cowork plugin installed, this instruction is issued automatically by the `SessionStart` hook — you don't type it.

---

## How it works — the honest version

Before using AMAI, read [HOW_THIS_WORKS.md](HOW_THIS_WORKS.md) for an honest account of what the system does and does not enforce.

---

## AI Environment Guide

AMAI works with any AI model. What you can rely on — and what requires your discipline — depends entirely on your environment. This section is honest about both.

---

### Desktop apps and code assistants — full reliability

AMAI is designed for AI environments that can read files directly from your local system:

- **Claude Cowork** (recommended — native plugin support)
- **AI code assistants** (e.g. Claude Code, Cursor, Copilot with workspace access)
- **Other AI desktop apps** with local file access

**What AMAI can guarantee here:** The instruction *"Read my BRAIN.md"* works literally. The AI reads the file from disk, loads modules on demand, and sees the current version of every file. The full system works as designed.

**What you still need to do:** Keep your files up to date. The AI reads what's there — if `current_focus.yaml` is three weeks old, the AI will work from three-week-old priorities.

#### Claude Cowork + amai.plugin

Using AMAI with Claude Cowork and the included plugin is the highest-fidelity experience available.

| Without plugin | With plugin |
|----------------|-------------|
| Manual prompt every session: *"Read my BRAIN.md…"* | `SessionStart` hook loads defaults automatically |
| User manages what modules to load | `context-loader` skill reads the trigger table and loads the right modules |
| Signal capture requires remembering | `Stop` hook detects signal-worthy moments and offers to log them |
| No slash commands | `/amai:status`, `/amai:calibrate`, `/amai:capture`, `/amai:validate`, `/amai:lint`, `/amai:export` |
| Org overlays require manual activation | `org-overlay` skill handles S0/S1/S2 transitions with confirmation |

**Setup:** Open Cowork, select your AMAI folder as the workspace, and install `amai.plugin`. That's it — the next session starts fully loaded.

---

### Browser sessions — environment-dependent

Browser-based sessions at claude.ai, chatgpt.com, or gemini.google.com cannot access your local file system. You bring context to the AI; the AI does not pull it. Each environment has different persistence models, and each comes with different tradeoffs.

For browser-based sessions, read [SYNC_STRATEGY.md](SYNC_STRATEGY.md) before your first session.

The approaches below are ordered from most reliable to least.

---

#### Claude — claude.ai

**Using Projects**

Claude Projects let you upload files that persist across every conversation in that project.

1. Go to [claude.ai](https://claude.ai) and click **Projects → New Project**
2. Name it *AMAI* (or your name)
3. Open **Project Knowledge** and upload:
   - `BRAIN.md`
   - `identity/values.yaml`
   - `identity/voice.md`
   - `identity/heuristics.yaml`
   - Any other modules you use regularly
4. Start every conversation in this project with the usual instruction

**What AMAI can guarantee here:** Files in Project Knowledge are present in every conversation — no re-uploading needed, and the AI can reference them reliably.

**What it cannot guarantee:** Project Knowledge files are not live-synced to your local repo. If you update `current_focus.yaml` locally, the Project copy is stale until you manually re-upload it. AMAI is only as current as your last upload. Check `last_updated` fields regularly and re-upload when modules are stale.

**Using Custom Instructions (lighter alternative)**

Go to **Settings → Custom Instructions** and paste the contents of `BRAIN.md`. Applies globally to all conversations but has a character limit — you may need to condense. Module files are not available unless uploaded per-session.

---

#### ChatGPT — chatgpt.com

**Using Projects (Plus/Pro)**

ChatGPT Projects function similarly to Claude Projects.

1. In the sidebar, click **New Project**
2. Name it *AMAI*
3. Upload your core AMAI files using the attachment button
4. ChatGPT will reference these files across all conversations in the project

**What AMAI can guarantee here:** Files are persistently available within the project. The core session-start instruction works as intended.

**What it cannot guarantee:** Same as Claude Projects — uploaded files are a snapshot, not a live sync. Your AMAI context is only as current as your last upload. Re-upload `current_focus.yaml` at minimum when priorities shift.

**Using Custom Instructions (all users)**

Go to **Settings → Personalization → Custom Instructions** and paste a condensed version of `BRAIN.md`. Applies globally but cannot hold full module files.

**Using Custom GPTs (Plus/Pro)**

Create a private GPT with `BRAIN.md` pasted into system instructions and module files under Knowledge. Persistent and reliable, but the same staleness caveat applies — Knowledge files are not live.

**Per-session upload (any plan)**

Upload files as attachments at the start of each conversation, then give the instruction.

**What AMAI can guarantee here:** Nothing across sessions. **What it cannot guarantee:** Anything. This is as reliable as your upload discipline, every single session.

---

#### Gemini — gemini.google.com

**Using Google Drive integration (most reliable for Gemini)**

Gemini can read directly from Google Drive — which makes it the most live-sync-capable browser environment for AMAI.

1. Save your AMAI files (or a curated subset) to a folder in Google Drive
2. Keep this folder in sync with your local repo (manual copy, or a sync tool)
3. In a Gemini conversation, click the Google Drive icon to connect
4. Reference the files directly: *"Read my BRAIN.md from Drive and load the relevant modules"*

**What AMAI can guarantee here:** If your Drive folder is current, Gemini reads current files. This is the closest browser environments get to the desktop experience.

**What it cannot guarantee:** Drive sync is your responsibility. If your local repo has diverged from your Drive folder, Gemini reads the Drive version — which may be stale.

**Using Gems (Gemini Advanced)**

Gems are persistent custom AI configurations. Paste `BRAIN.md` into the instructions field and upload core module files.

**What AMAI can guarantee:** Persistent instructions across sessions. **What it cannot guarantee:** Same staleness caveat as Claude/ChatGPT Projects — uploaded files are a snapshot.

**Per-session upload (any plan)**

Upload files as attachments at the start of each conversation. Same as above: reliable only as far as your upload discipline extends.

---

### What every browser session requires from you

Regardless of platform, browser-based AMAI has one dependency that desktop environments remove: **your maintenance discipline.**

| Maintenance task | Frequency | What breaks if you skip it |
|-----------------|-----------|---------------------------|
| Re-upload `current_focus.yaml` | When priorities shift | AI works from stale priorities |
| Re-upload `goals/goals.yaml` | When goals change status | Goal alignment prompts miss current state |
| Re-upload `identity/heuristics.yaml` | After calibration reviews | AI misses updated rules |
| Re-upload full module set | After major life/work changes | AI operates on outdated context |

The minimum upload set that covers most sessions:

| File | Why |
|------|-----|
| `BRAIN.md` | AI onboarding and operating instructions |
| `identity/values.yaml` | Ethical red lines — needed for any decision |
| `identity/voice.md` | Needed for any writing task |
| `identity/heuristics.yaml` | Fast decision rules |
| `goals/current_focus.yaml` | What matters this week |

Load additional module files when the task calls for them — network files for relationship tasks, memory files for reflection, and so on.

---

## Getting Started

**Recommended path: Claude Cowork + plugin**

If you're using Claude Cowork, install the plugin first — it makes every subsequent step better:

1. Open Cowork and select your AMAI folder as the workspace
2. Install `amai.plugin` (included in this repository)
3. Your next session will auto-load your context — then fill in the files below and they're immediately live

**Step 1 — Fill in your identity (30 minutes)**

Start with the `identity/` module. This is the foundation everything else draws from.

1. Open `identity/values.yaml` — define your core values and ethical red lines
2. Open `identity/voice.md` — describe how you communicate
3. Open `identity/heuristics.yaml` — add your fast decision rules
4. Open `identity/story.md` — write a short narrative of who you are and what you're building
5. Update the "Core Identity Summary" section in `BRAIN.md`

**Step 2 — Set your goals (20 minutes)**

1. Open `goals/north_star.md` — write your 3–10 year vision
2. Open `goals/goals.yaml` — set 3–5 current goals with status tracking
3. Open `goals/current_focus.yaml` — set this week's priority stack

**Step 3 — Add domain context (15 minutes)**

1. Open `knowledge/domain_landscape.md` — describe the sector or market you operate in
2. Open `knowledge/frameworks.md` — add the mental models you actually use

**Step 4 — Start using it**

Open a session with any AI assistant and say:

> "Read my BRAIN.md and load the relevant modules for this task."

Then describe what you want to work on. The AI has your context.

**Step 5 — Build out over time**

Add to `network/` as you log relationships. Add to `memory/` as you make significant decisions. The system gets more useful as it accumulates context.

**When you're ready — add the Advanced Layer**

Once the core modules feel natural, add `signals/` and `calibration/` to close the feedback loop between how you intend to behave and how you actually behave. See the Advanced Layer section below.

**If your work involves an organisation — add the Org Layer**

If you work within an organisation — as an employee, consultant, or portfolio worker — add `org/` to separate your personal identity from how you show up in an institutional context. See the Org Layer section below.

---

## File format design

| Format | Used for | How AI uses it |
|--------|----------|----------------|
| **YAML** | Structured config — values, goals, heuristics, circles, rhythms | Query fields directly: `status`, `priority`, `red_lines`, thresholds |
| **JSONL** | Append-only logs — contacts, interactions, decisions, signals | Read sequentially; patterns emerge across entries over time |
| **Markdown** | Narrative context — voice, story, principles, domain knowledge | Read as background; extract understanding from prose |

---

## Structure

```
AMAI/
├── BRAIN.md                        ← Master onboarding document. Start here.
├── MODULE_SELECTION.md             ← Which modules to load for which tasks
├── HOW_THIS_WORKS.md               ← Honest account of what the system enforces
├── SYNC_STRATEGY.md                ← Browser session staleness management
├── SECURITY.md                     ← Sensitivity tiering, encryption, safe export
├── PLUGIN.md                       ← Claude Cowork plugin documentation
├── amai.plugin                     ← Installable plugin for Claude Cowork
│
│   ── COWORK PLUGIN ──────────────────────────────────────────────────────────
│
├── .claude-plugin/
│   └── plugin.json                 ← Plugin manifest
├── hooks/
│   └── hooks.json                  ← SessionStart (auto-load) + Stop (signal capture)
├── commands/                       ← Slash commands: /amai:status, :calibrate,
│   │                                 :validate, :lint, :export, :capture
│   └── *.md
├── skills/                         ← On-demand intelligence layer
│   ├── context-loader/             ← Trigger table → auto-load right modules
│   ├── org-overlay/                ← Session states, behaviour bands, tension log
│   ├── signal-capture/             ← Guided JSONL observation logging
│   └── identity-voice/             ← Active voice + values + heuristics application
│
│   ── AMAI DATA ─────────────────────────────────────────────────────────────
│
├── identity/                       ← Who you are and what you stand for
│   ├── values.yaml                 ← Core values with priorities and ethical red lines
│   ├── heuristics.yaml             ← Fast decision rules by domain
│   ├── voice.md                    ← How you communicate
│   ├── story.md                    ← Background and journey
│   └── principles.md               ← Narrative reasoning behind decisions
│
├── goals/                          ← Where you are going
│   ├── goals.yaml                  ← OKR-style goals with status tracking
│   ├── current_focus.yaml          ← Live weekly priority stack
│   ├── north_star.md               ← Long-term narrative vision (3–10 years)
│   └── deferred_with_reason.md     ← Ideas deferred with explicit reasoning
│
├── knowledge/                      ← What you know and are learning
│   ├── learning.jsonl              ← Append-only insight and lesson log
│   ├── frameworks.md               ← Mental models you rely on
│   ├── domain_landscape.md         ← Your sector or domain context
│   └── reading_list.md             ← Books, articles, resources
│
├── network/                        ← Who you know
│   ├── circles.yaml                ← Relationship tier definitions and criteria
│   ├── rhythms.yaml                ← Touchpoint frequency per circle
│   ├── contacts.jsonl              ← Individual relationship records
│   ├── organisations.jsonl         ← Organisation records
│   └── interactions.jsonl          ← Interaction history
│
├── operations/                     ← How you work
│   ├── workflows.md                ← Standard operating procedures
│   ├── tools.md                    ← Tool stack
│   └── rituals.md                  ← Weekly, monthly, and quarterly rhythms
│
├── memory/                         ← What you have lived and learned
│   ├── experiences.jsonl           ← Key moments and their weight
│   ├── decisions.jsonl             ← Important decisions and reasoning
│   └── failures.jsonl              ← Failures and what they taught you
│
│   ── ADVANCED LAYER ─────────────────────────────────────────────────────────
│   Add these once your core modules are working. See sections below.
│
├── signals/                        ← Raw observations from AI sessions
│   └── observations.jsonl          ← Append-only log of overrides, friction, patterns
│
├── calibration/                    ← Where declared self meets observed self
│   ├── protocol.md                 ← Divergence taxonomy and incorporation rules
│   ├── metrics.yaml                ← Quantitative tracking across sessions
│   ├── divergence.jsonl            ← Append-only log of detected divergences
│   └── pending_review.md           ← Items awaiting deliberate human review
│
│   ── ORG LAYER ──────────────────────────────────────────────────────────────
│   Add this if your work involves an organisational context. See section below.
│
├── org/                            ← Organisation overlay
│   ├── MODULE.md                   ← When and how to load the org layer
│   ├── org_index.yaml              ← Registry of overlays in this instance
│   └── overlays/
│       └── <org-id>/               ← One folder per organisation
│           ├── overlay.yaml        ← Precedence, conflict protocol, session banner
│           ├── behaviour_bands.yaml← 5 dimensions × 5 levels with rules and examples
│           ├── SESSION_STATES.md   ← S0–S4 state machine for overlay transitions
│           ├── tension_log.jsonl   ← Append-only personal/org friction log
│           └── policy/
│               ├── data_classes.yaml      ← Org data classification
│               └── disclosure_rules.yaml  ← Allowed classes by context
│
└── scripts/                        ← Validation and export tooling
    ├── validate.sh                 ← Schema and date integrity checks
    ├── amai_lint.sh                ← Org overlay completeness validation
    └── amai_export.sh              ← Browser-safe bundle generator
```

---

## Design principles

**Format follows function** — YAML for data AI needs to query; JSONL for logs that grow over time; Markdown for narrative context AI needs to read. Every file's format reflects how it will be used.

**Comments separate from data** — In YAML files, comments (`#`) carry the 'why'. The fields themselves carry clean, queryable data. AI can extract structured values without reading prose; humans can understand structure without losing context.

**Module isolation** — Each module has a `MODULE.md` with its own AI instructions. The AI loads only what's needed. Network data never bleeds into content tasks; content templates never load during meeting prep.

**Append-only memory** — JSONL files store judgment, not just facts. Every logged decision, failure, and learning makes the system smarter about how you actually think — not how you wish you'd thought. History is never deleted.

**Values-first AI** — `BRAIN.md` contains standing instructions across all sessions. `identity/values.yaml` defines ethical red lines. `identity/heuristics.yaml` gives AI fast, domain-specific rules before recommending anything.

**Model agnostic** — AMAI works with any AI assistant. The system is plain files and plain instructions. No platform dependency, no API keys, no configuration beyond filling in your own context.

**Identity is the substrate, org is the overlay** — The org layer modifies how your identity is expressed in an institutional context; it does not replace it. Your personal ethical red lines sit above all org constraints in the precedence stack. Tension between personal and org context is logged and reviewed, not suppressed.

---

## Advanced Layer — Signals & Calibration

*Add this once your core modules are working. Estimated setup: 15 minutes.*

The advanced layer closes a feedback loop that the core modules leave open: the gap between who you intend to be (declared in your config) and how you actually behave (observed through AI sessions).

**`signals/`** captures raw observations from AI sessions — times you overrode a suggestion, felt friction, noticed a pattern, or spotted something surprisingly on-brand. Takes under 90 seconds per session. Your AI offers to log entries at session end.

**`calibration/`** compares those signals against your declared config monthly. Divergences are classified as confirmations, update candidates, or drift warnings — and presented for your deliberate review. Your config only changes when you decide it should.

```
AI session happens
        ↓
Notable override / friction / pattern observed
        ↓
AI drafts signal entry → you confirm → appended to signals/observations.jsonl
        ↓
Monthly calibration review: signals compared against config
        ↓
Divergences classified: CONFIRM / CANDIDATE / WARNING / DEFER
        ↓
You review pending_review.md → decide: INCORPORATE / REJECT / DEFER
        ↓
If INCORPORATE: config updated + logged in memory/decisions.jsonl
If REJECT: behaviour corrected, config unchanged
```

**The governing principle:** Observed behaviour never auto-updates declared values. You always decide.

---

## Org Layer — Organisation Overlay

*Add this if your work involves an organisational context. Estimated setup: 30 minutes.*

The org layer separates two contexts that often collide: who you are as a person (declared in `identity/`) and how you need to show up within a specific institution. It does not change your identity — it modifies how certain dimensions of it are expressed depending on the organisational context you're working in.

**`org/overlays/<org-id>/overlay.yaml`** defines the precedence stack when personal and org values conflict (8 levels from law to task instructions), the conflict protocol the AI must output visibly, and the session disclosure banner.

**`behaviour_bands.yaml`** replaces abstract tone settings with five concrete dimensions — formality, directness, risk language, personal disclosure, collective framing — each with five levels that have explicit rules and examples. The AI can verify it's applying the right level; so can you.

**`SESSION_STATES.md`** is a S0–S4 state machine. Every overlay transition requires your explicit confirmation. The AI never activates an overlay speculatively, never silently changes context type, and never resolves a precedence conflict without showing its work.

**`policy/`** maps org data classes to AMAI's personal sensitivity tiers and defines what can appear in each context type — internal, client-facing, thought leadership, executive comms.

**`tension_log.jsonl`** is an append-only log of moments where personal and org context pulled in different directions. It feeds into monthly calibration. Structural tension — recurring high-severity conflicts between your personal values and your org context — is flagged rather than resolved by config changes.

To set up the org layer:

1. Duplicate `org/overlays/example-org/` and rename it to your org slug (e.g. `acme-corp`)
2. Update `org/org_index.yaml` with your org_id and display name
3. Customise `overlay.yaml` context defaults and `behaviour_bands.yaml` examples for your org's culture
4. Run `bash scripts/amai_lint.sh <org-id>` to validate
5. For browser sessions with org context, run `bash scripts/amai_export.sh --org=<org-id> --context=<context_type>` to generate a safe upload bundle

---

## Development Setup

AMAI ships with a schema-backed validation script and a Git pre-commit hook that runs it automatically before every commit.

### First-time setup

```bash
bash scripts/setup-hooks.sh
```

This does two things: sets `core.hooksPath = .githooks` in your local Git config, and ensures the hook and validator are executable. Run it once after cloning.

### Running validation manually

```bash
# Full report — ERRORs, WARNs, and INFOs
bash scripts/validate.sh

# Suppress INFO, show WARNs and ERRORs only
bash scripts/validate.sh --quiet

# Treat WARNs as non-blocking (exit 0 even when WARNs are present)
bash scripts/validate.sh --allow-warn

# Machine-readable JSON output
bash scripts/validate.sh --json
```

### What gets validated

The validator checks every YAML and JSONL file in the AMAI core against its JSON Schema (`schemas/`), then runs a suite of data-quality rules:

| Severity | Code | Meaning |
|----------|------|---------|
| ERROR | `SCHEMA_INVALID` | File fails its JSON Schema — structural problem |
| WARN | `PLACEHOLDER_DATA` | File still contains template placeholder text |
| WARN | `STALE_MODULE` | `last_updated` is null or older than 60 days |
| WARN | `STALE_FOCUS` | `current_focus.yaml` is older than 14 days |
| WARN | `VAGUE_VALUE` | A value description is too short to be actionable |
| WARN | `MISSING_EXAMPLES` | A value has fewer than 2 `in_practice` entries |
| WARN | `VAGUE_HEURISTIC` | A heuristic rule is too short to be specific |
| WARN | `EMPTY_RED_LINES` | `ethical_red_lines` is empty |
| INFO | `ENTRY_COUNT` | How many entries are in each JSONL log |
| INFO | `SCHEMA_VERSION` | Schema version declared in each YAML file |

### Pre-commit hook behaviour

| Validation result | Hook action |
|---|---|
| 0 ERRORs, 0 WARNs | Silent pass — no output |
| 0 ERRORs, WARNs present | Prints warning summary, commit proceeds |
| Any ERRORs | Prints errors, **blocks the commit** |

To bypass the hook for a one-off commit (e.g. a WIP save):

```bash
git commit --no-verify -m "wip: your message"
```

---

## Credits & Inspiration

**[Muratcan Koylan](https://x.com/koylanai)** — the context engineering approach that underpins AMAI. His insight: *the file system is the new database* — and an AI that knows your context is worth ten that don't.

**[Daniel Miessler](https://danielmiessler.com)** — whose [Personal AI Infrastructure (PAI)](https://github.com/danielmiessler/Personal_AI_Infrastructure) project explored the agentic end of the same problem space, and directly inspired the signals/calibration layer.

**[Joel Hans](https://ngrok.com/blog/bmo-self-improving-coding-agent)** — whose write-up of BMO, a self-improving coding agent built at Ngrok, provided the empirical grounding for six specific improvements to AMAI: explicit trigger cues for signal capture, quantitative telemetry in the calibration layer, the deferred_with_reason anti-pattern fix, typed learning logs, hyper-specific heuristics, and the meta-learner prompt.

---

## Licence

MIT — see `LICENSE`.
