---
name: context-loader
description: >
  This skill should be used when the user begins a task that may require additional
  AMAI modules beyond the default set already loaded. Trigger phrases include:
  "help me write", "draft a", "make a decision about", "I need to decide",
  "research", "plan", "review this", "help me think through", or any task where
  the nature of the work (writing, decision-making, research, network/relationship,
  learning, operations, memory recall) suggests specific AMAI modules should be loaded.
  Also trigger when the user says "load my context", "check what modules are loaded",
  or "what context do you have".
version: 0.1.0
---

The context-loader skill implements AMAI's progressive disclosure model. The default
session context (values, heuristics, current_focus, MODULE_SELECTION) is already loaded
via the SessionStart hook. This skill handles on-demand loading of additional modules.

## How to use this skill

1. Read `${CLAUDE_PLUGIN_ROOT}/MODULE_SELECTION.md` if not already fully parsed — specifically the trigger table that maps task types to module files.

2. Identify the task type from the user's request. Common categories: writing/communication, decision-making, research/learning, network/relationship, org/work, operations, memory recall, calibration.

3. Consult the trigger table in MODULE_SELECTION.md to determine which module files apply to this task type.

4. Read the relevant module files (using the Read tool). Each module directory contains a MODULE.md describing what it provides, plus the data files themselves.

5. Confirm what was loaded to the user: "Loaded [module names] for this task."

## Module locations

All module directories are at `${CLAUDE_PLUGIN_ROOT}/`:

| Module area | Directory | Key files |
|-------------|-----------|-----------|
| Identity & voice | `identity/` | voice.md, values.yaml, heuristics.yaml, principles.md |
| Goals | `goals/` | goals.yaml, current_focus.yaml, north_star.md |
| Memory | `memory/` | experiences.jsonl, decisions.jsonl, failures.jsonl |
| Network | `network/` | contacts.jsonl, circles.yaml, interactions.jsonl, rhythms.yaml |
| Knowledge | `knowledge/` | frameworks.md, domain_landscape.md, learning.jsonl |
| Calibration | `calibration/` | metrics.yaml, protocol.md, pending_review.md |
| Org overlay | `org/` | org_index.yaml, overlays/{name}/ |
| Signals | `signals/` | observations.jsonl |
| Operations | `operations/` | workflows.md, rituals.md, tools.md |

## Loading rules

- **Default set** (always loaded via SessionStart hook): `identity/values.yaml`, `identity/heuristics.yaml`, `goals/current_focus.yaml`, MODULE_SELECTION.md
- **Load additional modules** only when the task type calls for them
- **Read MODULE.md first** in any module directory before loading data files — it explains what the module contains and how to interpret it
- **JSONL files**: read the most recent N entries relevant to the task; avoid loading entire large files
- **Confirm** what you loaded so the user knows what context is active

## After loading

Apply the loaded context actively — don't just acknowledge it. If voice.md is loaded, write in that voice. If decisions.jsonl is loaded, reference relevant past decisions. If network/contacts.jsonl is loaded, use relationship context when relevant.

See `references/module-loading-guide.md` for detailed guidance on interpreting each module type.
