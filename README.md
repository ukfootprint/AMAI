# AMAI — Anchor My AI

> *A values-first, file-based personal AI infrastructure.*

Give any AI assistant structured context about who you are, what you're building, and how you think — so it operates in alignment with your values from session one, without you re-explaining yourself each time.

No database. No app. No API keys. No platform lock-in. Plain files that both humans and AI read natively, versioned in git, working with any AI model.

---

## How it works

Every session starts with one instruction:

> *"Read my BRAIN.md and load the relevant modules for this task."*

The AI reads `BRAIN.md`, loads only the modules relevant to the task, and operates within your values, voice, and context.

---

## AI Compatibility

AMAI works with any AI model. How well it works depends on how much file access your AI environment has.

### Best experience — desktop apps and code assistants

AMAI is specifically designed for AI environments that can read files directly from your local system. These include:

- **AI desktop apps** (e.g. Claude desktop with Cowork, local AI tools)
- **AI code assistants** (e.g. Claude Code, Cursor, Copilot with workspace access)

In these environments the instruction *"Read my BRAIN.md"* works literally — the AI reads the file from disk and loads modules as needed. The full system works as designed.

### Browser sessions — workarounds required

Browser-based AI sessions at claude.ai, chatgpt.com, or gemini.google.com cannot access your local file system. You need to bring your context to the AI rather than letting the AI read it. The three approaches below are ordered from best to most manual.

---

#### Claude — claude.ai

**Using Projects (recommended)**

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

Files in Project Knowledge are available to every conversation automatically — no re-uploading needed.

**Using Custom Instructions (lighter alternative)**

Go to **Settings → Custom Instructions** and paste the contents of `BRAIN.md`. This works for all conversations, not just a project, but has a character limit so you may need to condense it.

---

#### ChatGPT — chatgpt.com

**Using Projects (recommended, Plus/Pro)**

ChatGPT Projects function similarly to Claude Projects.

1. In the sidebar, click **New Project**
2. Name it *AMAI*
3. Upload your core AMAI files using the attachment button
4. ChatGPT will reference these files across all conversations in the project

**Using Custom Instructions (available to all users)**

Go to **Settings → Personalization → Custom Instructions** and paste a condensed version of `BRAIN.md` in the *"What would you like ChatGPT to know about you?"* field. This applies globally to all conversations.

**Using Custom GPTs (Plus/Pro)**

You can create a personal GPT pre-loaded with your AMAI context:

1. Go to **Explore GPTs → Create**
2. Paste `BRAIN.md` content into the system instructions
3. Upload your module files under **Knowledge**
4. Save as a private GPT for personal use

**Per-session upload (any plan)**

Upload your files as attachments at the start of each conversation, then give the instruction. Less convenient but always available.

---

#### Gemini — gemini.google.com

**Using Gems (recommended, Gemini Advanced)**

Gems are Gemini's persistent custom AI configurations.

1. Go to [gemini.google.com](https://gemini.google.com) and click **Gems → New Gem**
2. Paste `BRAIN.md` content into the instructions field
3. Upload your core module files
4. Save the Gem and use it for all AMAI sessions

**Using Google Drive integration**

Gemini can read directly from your Google Drive — which makes it uniquely suited to a file-based system like AMAI.

1. Save your AMAI files (or a curated subset) to a folder in Google Drive
2. In a Gemini conversation, click the Google Drive icon to connect
3. Reference the files directly: *"Read my BRAIN.md from Drive and load the relevant modules"*

This approach means your AMAI files stay on Drive, sync across devices, and are always current without re-uploading.

**Per-session upload (any plan)**

Upload files as attachments at the start of each conversation, then give the instruction.

---

### Recommended file set for browser sessions

You don't need to upload every file. A practical minimum that covers most sessions:

| File | Why |
|------|-----|
| `BRAIN.md` | The AI's onboarding document and operating instructions |
| `identity/values.yaml` | Ethical red lines — needed for any decision |
| `identity/voice.md` | Needed for any writing task |
| `identity/heuristics.yaml` | Fast decision rules |
| `goals/current_focus.yaml` | What matters this week |

Load additional module files when the task calls for them — network files for relationship tasks, memory files for reflection, and so on.

---

## Getting Started

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
└── memory/                         ← What you have lived and learned
    ├── experiences.jsonl           ← Key moments and their weight
    ├── decisions.jsonl             ← Important decisions and reasoning
    └── failures.jsonl              ← Failures and what they taught you
```

---

## Design principles

**Format follows function** — YAML for data AI needs to query; JSONL for logs that grow over time; Markdown for narrative context AI needs to read. Every file's format reflects how it will be used.

**Comments separate from data** — In YAML files, comments (`#`) carry the 'why'. The fields themselves carry clean, queryable data. AI can extract structured values without reading prose; humans can understand structure without losing context.

**Module isolation** — Each module has a `MODULE.md` with its own AI instructions. The AI loads only what's needed. Network data never bleeds into content tasks; content templates never load during meeting prep.

**Append-only memory** — JSONL files store judgment, not just facts. Every logged decision, failure, and learning makes the system smarter about how you actually think — not how you wish you'd thought. History is never deleted.

**Values-first AI** — `BRAIN.md` contains standing instructions across all sessions. `identity/values.yaml` defines ethical red lines. `identity/heuristics.yaml` gives AI fast, domain-specific rules before recommending anything.

**Model agnostic** — AMAI works with any AI assistant. The system is plain files and plain instructions. No platform dependency, no API keys, no configuration beyond filling in your own context.

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

## Credits & Inspiration

**[Muratcan Koylan](https://x.com/koylanai)** — the context engineering approach that underpins AMAI. His insight: *the file system is the new database* — and an AI that knows your context is worth ten that don't.

**[Daniel Miessler](https://danielmiessler.com)** — whose [Personal AI Infrastructure (PAI)](https://github.com/danielmiessler/Personal_AI_Infrastructure) project explored the agentic end of the same problem space, and directly inspired the signals/calibration layer.

**[Joel Hans](https://ngrok.com/blog/bmo-self-improving-coding-agent)** — whose write-up of BMO, a self-improving coding agent built at Ngrok, provided the empirical grounding for six specific improvements to AMAI: explicit trigger cues for signal capture, quantitative telemetry in the calibration layer, the deferred_with_reason anti-pattern fix, typed learning logs, hyper-specific heuristics, and the meta-learner prompt.

---

## Licence

MIT — see `LICENSE`.
