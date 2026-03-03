# Knowledge Module
*Load for: research, writing, analysis, domain questions*

---

## What This Module Is For

This module holds what you know and are learning — your mental models, domain context, and ongoing learning log. Load it when the AI needs background on your field, or when you want to apply frameworks to a problem.

The knowledge module has two tiers:

- **General files** (`knowledge/*.md`, `knowledge/*.jsonl`) — apply to all tasks regardless of domain
- **Domain-specific files** (`knowledge/domains/{domain}/`) — load additionally when the task relates to a specific domain

---

## General Files

| File | Format | Load When |
|------|--------|-----------|
| `frameworks.md` | Markdown | Applying mental models; working through a decision or problem |
| `domain_landscape.md` | Markdown | Research, analysis, strategy; anything requiring sector context |
| `learning.jsonl` | JSONL | Extracting patterns from past learning; avoiding known mistakes |
| `reading_list.md` | Markdown | Finding relevant resources; tracking what to read next |

---

## Domain System

`knowledge/domains/` contains a registry and subdirectory for each knowledge domain.

| File | Purpose |
|------|---------|
| `knowledge/domains/domain_index.yaml` | Registry of all domains — IDs, paths, active status, tags |
| `knowledge/domains/{id}/frameworks.md` | Domain-specific mental models |
| `knowledge/domains/{id}/landscape.md` | Domain-specific market and sector context |
| `knowledge/domains/{id}/terminology.md` | Domain vocabulary and shorthand |
| `knowledge/domains/{id}/resources.md` | Domain-specific references and reading |

**How domain files relate to general files:**
Domain-specific files supplement, not replace, the general files. When a task relates
to a specific domain, load both the general `knowledge/frameworks.md` AND the domain's
`frameworks.md`. The general files provide cross-domain mental models; domain files
provide depth.

---

## AI Instructions

1. **Frameworks are tools, not rules.** Apply frameworks from `frameworks.md` when they're genuinely useful — don't force them onto every situation.

2. **Domain landscape is context, not gospel.** `domain_landscape.md` reflects your understanding of the landscape at the time of writing. Acknowledge when it may be out of date.

3. **Learning log patterns.** When reading `learning.jsonl`, look for recurring themes across entries, not just individual insights.

4. **Domain detection.** If a task clearly relates to a specific domain (e.g. EdTech, AI infrastructure), check `knowledge/domains/domain_index.yaml` for a matching entry. If found and active, load the domain-specific files alongside the general files.

5. **Don't over-load domains.** Only load a domain's files if the task genuinely requires that domain's context. Loading all domains for a general task adds noise without signal.
