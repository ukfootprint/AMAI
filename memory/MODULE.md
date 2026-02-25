# Memory Module
*Load for: reflection, strategic decisions, avoiding past mistakes*

---

## What This Module Is For

This module holds what you have lived and learned — not facts, but judgment. Every entry captures a decision, failure, or experience with the reasoning and emotional weight attached. The AI uses this to avoid repeating past mistakes and to understand the context behind your current positions.

---

## Files In This Module

| File | Format | Load When |
|------|--------|-----------|
| `decisions.jsonl` | JSONL | Reflecting on a decision; checking for precedent |
| `failures.jsonl` | JSONL | Planning something you've attempted before; avoiding known mistakes |
| `experiences.jsonl` | JSONL | Understanding formative context; writing your story |

---

## The Distinction from signals/

`memory/` stores *conclusions* — things you have processed, reflected on, and decided are worth keeping permanently. It is curated, low-frequency, and high-deliberation.

`signals/observations.jsonl` *(advanced layer)* stores *raw observations* from AI sessions — low-deliberation captures that may or may not become conclusions. See `signals/MODULE.md`.

Do not conflate the two. Memory entries are permanent and intentional. Signal entries are temporary and unprocessed.

---

## AI Instructions

1. **Check memory before recommending.** Before suggesting a course of action, check `decisions.jsonl` and `failures.jsonl` for relevant past experience. Flag if the suggestion risks repeating a known mistake.
2. **Failures are the most valuable file.** Entries in `failures.jsonl` represent hard-won learning. Weight them heavily when they're relevant.
3. **Do not sanitise entries.** When logging memory entries, preserve the emotional weight and honest assessment — the rawness is what makes them useful.
4. **Never delete entries.** Memory is append-only. Entries can be annotated (add a `follow_up` field) but not removed.
