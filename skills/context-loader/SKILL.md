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

**Path convention:** All user data file paths (identity/, signals/, calibration/, etc.) resolve to `${AMAI_USER_ROOT}` — the user's personal AMAI directory, set in `~/.amai/config.yaml`. If not configured, fall back to `${CLAUDE_PLUGIN_ROOT}`.

## How to use this skill

1. Read `${AMAI_USER_ROOT}/MODULE_SELECTION.md` if not already fully parsed — specifically the trigger table that maps task types to module files.

2. Identify the task type from the user's request. Common categories: writing/communication, decision-making, research/learning, network/relationship, org/work, operations, memory recall, calibration.

3. Consult the trigger table in MODULE_SELECTION.md to determine which module files apply to this task type.

4. Read the relevant module files (using the Read tool). Each module directory contains a MODULE.md describing what it provides, plus the data files themselves.

5. Confirm what was loaded to the user: "Loaded [module names] for this task."

## Module locations

All module directories are at `${AMAI_USER_ROOT}/`:

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

## Domain Loading

After identifying task type and loading general knowledge modules, check whether the task
relates to a specific knowledge domain.

**Step 1 — Check domain_index:**

```
Read: ${AMAI_USER_ROOT}/knowledge/domains/domain_index.yaml
```

Filter for domains where `active: true`. For each active domain, check whether the task
vocabulary, user mention, or task context matches the domain's `tags` or `description`.

**Step 2 — Load matching domain files (if match found):**

```
Read: ${AMAI_USER_ROOT}/knowledge/domains/{id}/frameworks.md  (if exists)
Read: ${AMAI_USER_ROOT}/knowledge/domains/{id}/landscape.md   (if exists)
```

Load these **alongside** (not instead of) `knowledge/frameworks.md`.

**Step 3 — Confirm to user:**

If a domain was loaded, say: *"Loaded [domain label] knowledge overlay alongside general frameworks."*

**Step 4 — Increment domain load counter:**

After loading a domain, increment a domain-specific counter in `calibration/metrics.yaml`
under a `domain_load_frequency` key. If the key doesn't exist, skip silently.

```python
module = 'knowledge'   # increment the general knowledge counter as normal
domain_id = 'DOMAIN_ID'  # the domain that was loaded
# The instrumentation command can be extended to track domain_id separately
# if calibration/metrics.yaml has a domain_load_frequency map
```

**Multiple domains:**
If multiple domains match, load the most specific. If genuinely ambiguous, ask the user.

**No match:**
If no domain matches, do not load any domain files. Load only general knowledge files.

---

## Module Load Instrumentation

After loading any module, silently increment the corresponding counter in
`calibration/metrics.yaml → module_load_frequency`. This data is used by the
pruning skill to identify which modules are actively used vs. neglected.

**Module area mapping:**

| File prefix | Area key in metrics.yaml |
|-------------|--------------------------|
| `identity/` | `identity` |
| `goals/` | `goals` |
| `knowledge/` | `knowledge` |
| `network/` | `network` |
| `operations/` | `operations` |
| `memory/` | `memory` |
| `signals/` | `signals` |
| `calibration/` | `calibration` |

**Instrumentation command** (run after loading from a given module area):

```bash
python3 -c "
import re, os, subprocess
_ur = subprocess.run(['sed', '-n', 's/^user_root:[[:space:]]*//p', os.path.expanduser('~/.amai/config.yaml')], capture_output=True, text=True).stdout.strip().replace(\"'\",\"\").replace('\"','')
if _ur and _ur.startswith('~'): _ur = os.path.expanduser(_ur)
if not _ur: _ur = os.environ.get('CLAUDE_PLUGIN_ROOT', '.')
path = os.path.join(_ur, 'calibration/metrics.yaml')
module = 'REPLACE_WITH_AREA'
try:
    with open(path, 'r') as f: content = f.read()
    new = re.sub(
        r'(^\s+' + module + r':\s+)(\d+)',
        lambda m: m.group(1) + str(int(m.group(2)) + 1),
        content, flags=re.MULTILINE
    )
    with open(path, 'w') as f: f.write(new)
except Exception: pass
" 2>/dev/null || true
```

Replace `REPLACE_WITH_AREA` with the module area key (e.g. `identity`, `goals`).

**Rules:**
- If multiple files from the same area are loaded in one session, increment once (not per file).
- If a module area isn't in the `module_load_frequency` map, skip silently.
- If `calibration/metrics.yaml` doesn't exist or fails to parse, skip silently — never break a session over instrumentation.
- The default set (identity, goals) is incremented by the SessionStart hook automatically.
- This skill only needs to instrument **additional** modules loaded on demand.
