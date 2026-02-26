# SECURITY.md
*Read this before committing AMAI files to any repository or syncing them to any cloud service.*

AMAI centralises sensitive personal information — values, relationships, failures, decisions, ethical red lines — into a single readable folder. That is the point. It also means the risk surface is meaningful. This file gives you a framework for protecting it.

---

## Sensitivity Tiering

Not all AMAI files carry the same risk. Use this tiering to decide what to protect most carefully.

### Tier 1 — Highest sensitivity. Protect by default.

| File | Why it's sensitive |
|------|--------------------|
| `identity/values.yaml → ethical_red_lines` | Defines your absolute constraints. Exposure reveals what you won't do — useful information for anyone trying to manipulate or pressure you. |
| `memory/failures.jsonl` | Candid record of your worst decisions and what went wrong. Deeply personal; professionally damaging if exposed. |
| `memory/experiences.jsonl` | Key personal and professional moments with emotional weight. |
| `network/contacts.jsonl` | Individual relationship records. Contains your assessments of people, which they haven't consented to. Third-party privacy risk. |
| `network/interactions.jsonl` | Interaction history including candid notes about conversations. |

**Default rule:** Tier 1 files should never leave your local machine without deliberate intent. Never commit to a public repo. Never paste into a browser-based AI session without considering who can see the output.

---

### Tier 2 — Significant sensitivity. Handle with care.

| File | Why it's sensitive |
|------|--------------------|
| `memory/decisions.jsonl` | Important decisions and reasoning. May reference third parties or confidential context. |
| `goals/goals.yaml` | Your strategic priorities. Useful intelligence for competitors or counterparties. |
| `signals/observations.jsonl` | Raw session observations. May contain candid assessments. |
| `calibration/divergence.jsonl` | Classified divergences between declared and observed behaviour. Personal and unresolved. |
| `network/organisations.jsonl` | Organisation records including your assessments. |

**Default rule:** Tier 2 files are fine in a private repo. Review before sharing with collaborators. Never in a public repo.

---

### Tier 3 — Lower sensitivity. Shareable with intent.

| File | Why it's lower risk |
|------|---------------------|
| `identity/voice.md` | Describes communication style. Low sensitivity; useful to share with collaborators. |
| `identity/story.md` | Background narrative. Public-facing version of who you are. |
| `identity/principles.md` | Reasoning behind decisions. Can be shared intentionally. |
| `knowledge/frameworks.md` | Mental models. Generally not sensitive. |
| `knowledge/domain_landscape.md` | Sector context. Likely not sensitive. |
| `goals/north_star.md` | Long-term vision. Shareable if you choose. |
| `operations/workflows.md`, `rituals.md` | How you work. Low sensitivity. |

**Default rule:** Tier 3 files can be committed to a public repo if you are open-sourcing your AMAI setup. Review each one before doing so — the template versions are generic; your personalised versions may contain more.

---

## .gitignore Guidance

The included `.gitignore` excludes all Tier 1 and Tier 2 JSONL files by default. **Do not remove these exclusions for a public repo.**

### Safe to commit publicly (template values only)
```
BRAIN.md
MODULE_SELECTION.md
README.md
SECURITY.md
LICENSE
identity/values.yaml       ← safe IF red_lines are still placeholder
identity/heuristics.yaml   ← safe IF domain heuristics are still placeholder
identity/voice.md
identity/story.md
identity/principles.md
goals/goals.yaml            ← safe IF goals are still placeholder
goals/current_focus.yaml    ← safe IF priorities are still placeholder
goals/north_star.md
goals/deferred_with_reason.md
knowledge/frameworks.md
knowledge/domain_landscape.md
knowledge/reading_list.md
knowledge/learning.jsonl    ← example schema entry only, no real content
network/circles.yaml
network/rhythms.yaml
operations/workflows.md
operations/rituals.md
operations/tools.md
memory/                     ← example schema entries only
signals/                    ← example schema entries only
calibration/                ← MODULE.md and protocol.md only; not divergence.jsonl
```

### Never commit to a public repo
```
network/contacts.jsonl
network/organisations.jsonl
network/interactions.jsonl
memory/experiences.jsonl
memory/decisions.jsonl
memory/failures.jsonl
signals/observations.jsonl
calibration/divergence.jsonl
```

### Safe for a private repo (not public)
Everything above, plus the Tier 2 JSONL files — provided the repo is genuinely private and you trust anyone with access.

---

## Storage Guidance

### Local-only (recommended for Tier 1 and Tier 2)
Keep your AMAI folder on local disk only. No cloud sync. This is the most secure option. The tradeoff is no cross-device access.

### Private cloud sync (acceptable)
Syncing via iCloud, Dropbox, or similar to your own devices is a reasonable tradeoff for convenience. Ensure:
- The service uses end-to-end encryption, or you accept the provider's access policies
- Sharing is explicitly disabled for the AMAI folder
- You understand that the provider's employees may technically have access depending on your settings

### Git remote (private repo)
A private GitHub/GitLab repo is acceptable for version control and backup, provided:
- The repo is set to **private** and you regularly verify this
- You have not accidentally committed Tier 1 or Tier 2 JSONL files (check with `git log --all -- network/contacts.jsonl`)
- You trust the platform with the content of your AMAI config

### Browser-based AI sessions
When you paste AMAI context into a browser-based session (Claude Projects, ChatGPT, Gemini):

> **The content leaves your device.** It is transmitted to and processed on the AI provider's servers, subject to their data handling policies.

Practical implications:
- Avoid pasting Tier 1 JSONL content into browser sessions. Summaries or anonymised versions are safer.
- `identity/values.yaml` (without red lines populated) is generally safe to upload.
- `network/contacts.jsonl` with real names and relationship notes should never be uploaded to a browser session.
- Review each provider's data retention and training policies before uploading sensitive content.

---

## Redaction Patterns

When you want AI context that references relationships or decisions without exposing identifying details about third parties:

**For network context**, describe roles rather than names:
```yaml
# Instead of:
name: "Alice Chen"
company: "Acme Corp"
notes: "Pushed back hard on pricing in Q3 meeting"

# Use in session context:
"A senior buyer at a target account pushed back on pricing in a recent meeting"
```

**For decision context**, strip identifying details:
```yaml
# Instead of pasting the full decisions.jsonl entry:
"In [year], I decided to [action] in a situation involving [role/relationship type],
reasoning that [the reasoning]. The outcome was [outcome]."
```

**For failures**, use the lesson not the incident:
```yaml
# Instead of the raw failure entry, extract the pattern:
"I have a documented tendency to [pattern] in [context type]. I correct for this by [method]."
```

This preserves the utility of the context for the AI while protecting third-party privacy and limiting your own exposure.

---

## Multi-Device and Collaboration Notes

**Multiple devices:** If you use AMAI across devices, treat the git repo (private) as the sync mechanism rather than cloud folder sync. Commit and pull regularly. Avoid editing the same file on two devices without syncing — JSONL append conflicts are difficult to resolve.

**Collaborators:** AMAI is designed for personal use. If you share access with a collaborator (e.g. an EA or business partner):
- Do not give access to Tier 1 files without explicit consideration
- Create a separate, filtered context set for collaboration rather than sharing the full AMAI folder
- Be aware that any file you share with another person is no longer private by any reasonable definition

---

*This document does not constitute legal or security advice. Threat models vary by context. If you operate in a regulated industry or hold sensitive professional obligations, consult appropriate guidance for your situation.*
