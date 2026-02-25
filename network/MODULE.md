# Network Module
*Load for: outreach, partnership decisions, meeting preparation, relationship management*

---

## What This Module Is For

This module holds who you know — structured as relationship tiers with associated touchpoint rhythms and interaction history. Load it when the AI needs context on a person or organisation, or when you're planning outreach and relationship maintenance.

---

## Files In This Module

| File | Format | Load When |
|------|--------|-----------|
| `circles.yaml` | YAML | Classifying a contact; checking relationship tier |
| `rhythms.yaml` | YAML | Planning outreach; checking when to next contact someone |
| `contacts.jsonl` | JSONL | Preparing for a meeting; researching a person; outreach |
| `organisations.jsonl` | JSONL | Researching an organisation; understanding account context |
| `interactions.jsonl` | JSONL | Reviewing relationship history; updating after a conversation |

---

## AI Instructions

1. **Circles define care model.** `circles.yaml` defines what each tier requires — use it to understand how much attention a relationship should get, not just what tier someone is in.
2. **Rhythms are guidelines, not rules.** `rhythms.yaml` defines target touchpoint frequency. Use these as defaults, but context always overrides schedule.
3. **Check interactions before outreach.** Always read recent entries in `interactions.jsonl` for a contact before drafting an outreach message. Context matters.
4. **Contacts and organisations are private.** These files contain personal relationship data. Do not include contact details in any output unless explicitly asked.
