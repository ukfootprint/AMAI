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

---

## Privacy and Minimisation Principles for Network Data

### The core rule

network/contacts.jsonl and network/interactions.jsonl contain assessments of real people who have not consented to being in this system. Treat this data with proportionate care.

### What to log

Log only what is necessary for the AI to be useful in a specific interaction context. Ask: "Would I need this to prepare for a meeting or draft a message to this person?" If yes, log it. If it is a judgement, an observation, or a personal detail that would not affect how you interact with them, do not log it.

### What not to log

Do not log: health information, financial details, information shared in confidence, assessments of character that you would not say to the person's face, or anything that would be damaging if they read it.

### The minimisation test

Before adding an entry, ask: "Is there a less sensitive way to record what I need?" A contact's communication preference ("prefers async, hates calls") is useful. An assessment of their personality ("difficult, defensive") is a liability. Log the former, not the latter.

### Reviewing existing entries

At each monthly calibration, review the five most recently added contact entries. Apply the minimisation test retrospectively. Remove or redact anything that fails it.

### If someone asks about their entry

If a person you have logged asks whether you keep notes about them, you can truthfully say you keep a professional context file. You are not obligated to share it. If you choose to share or delete it, use the Public-Safe Export pattern in SECURITY.md as a guide for what is appropriate to disclose.
