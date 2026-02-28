# Module Loading Guide

Reference for interpreting and applying each AMAI module type.

## Reading JSONL files

JSONL files (experiences.jsonl, decisions.jsonl, failures.jsonl, observations.jsonl,
interactions.jsonl, learning.jsonl, divergence.jsonl) are append-only logs. Each line
is a JSON object. When loading:

1. Read the SCHEMA.md in the same directory first to understand field meanings
2. Load the most recent entries (last 20-50 lines using `tail` or by reading the full file if small)
3. Filter to entries relevant to the current task
4. Never load the entire file into context if it is large — be selective

## Interpreting module types

### identity/voice.md
A description of how this person writes and communicates. When loaded:
- Adjust your writing style to match the described voice
- Apply tone, vocabulary preferences, and structural patterns described
- This is not background reading — actively shape output to this voice

### identity/values.yaml
Core values with descriptions. When loaded:
- Use values as decision criteria when evaluating options
- Reference relevant values explicitly when reasoning through decisions
- Flag if a proposed action conflicts with a stated value

### identity/heuristics.yaml
Decision-making shortcuts and personal rules of thumb. When loaded:
- Apply heuristics before offering analysis — they encode this person's judgment
- Reference specific heuristics when they apply to the situation
- Do not override heuristics with generic best-practice advice

### identity/principles.md
Deeper reasoning behind values — the "why." Load when: in-depth ethical reasoning is needed, or the situation involves values tension.

### goals/goals.yaml + north_star.md
Current goal stack and long-term direction. When loaded:
- Evaluate requests in terms of goal alignment
- Note if a task serves or conflicts with active goals
- north_star.md sets the orientation for long-horizon decisions

### goals/current_focus.yaml
The single most important near-term focus. Already in default load. Reference it to prioritize when multiple options exist.

### memory/experiences.jsonl
Past experiences and how they resolved. When loaded for a task:
- Check for similar past situations
- Reference relevant experiences in analysis
- Use outcomes to calibrate advice

### memory/decisions.jsonl
Record of past significant decisions. Load when: making a decision that may relate to prior commitments or patterns.

### memory/failures.jsonl
Documented failures with root causes and lessons. Load when: the current task has failure patterns worth learning from.

### network/contacts.jsonl + circles.yaml
People in this person's network, organized by relationship circles. Load when: the task involves people (outreach, collaboration, asking for help, gifts, difficult conversations).

### network/interactions.jsonl + rhythms.yaml
Interaction history and relationship maintenance rhythms. Load when: checking in on relationships, preparing for a specific meeting, or maintaining connections.

### knowledge/frameworks.md
Personal frameworks for thinking about problems. Load when: strategic or complex analytical work.

### knowledge/domain_landscape.md
How different fields and domains relate to each other in this person's mental model. Load when: cross-domain synthesis is needed.

### knowledge/learning.jsonl
Ongoing learning log. Load when: researching a topic to check what is already known, or when adding new learning.

### calibration/metrics.yaml + pending_review.md
AMAI health metrics and items awaiting review. Load when: the user asks about system health, or the session involves meta-reflection on the AMAI system.

### calibration/protocol.md
Instructions for running a calibration session. Used by `/amai:calibrate`.

### org/org_index.yaml
Index of available org overlays. Load when: org context is needed. Then load the specific overlay if one should be activated.

## Task-type quick reference

| Task type | Modules to load |
|-----------|----------------|
| Writing for work/external | `identity/voice.md` |
| Personal writing | `identity/voice.md`, `identity/principles.md` |
| Decision with options | `identity/values.yaml`, `identity/heuristics.yaml`, `memory/decisions.jsonl`, `goals/goals.yaml` |
| Learning / research | `knowledge/frameworks.md`, `knowledge/learning.jsonl` |
| People / relationship | `network/contacts.jsonl`, `network/circles.yaml` |
| Org context needed | `org/org_index.yaml`, then specific overlay |
| Memory recall | `memory/experiences.jsonl`, `memory/decisions.jsonl` |
| Planning / rituals | `operations/workflows.md`, `operations/rituals.md` |
| AMAI health check | `calibration/metrics.yaml`, `calibration/pending_review.md` |
