---
name: prune
description: Interactive AMAI pruning review — walks through archive candidates, consolidation opportunities, size warnings, and staleness flags one category at a time
argument_hint: "[--conservative | --aggressive | --data-driven | --report-only | --category <name> | --compare <path>]"
allowed_tools:
  - Read
  - Write
  - Edit
  - Bash
---

Invoke the pruning skill at `skills/pruning/SKILL.md`.

**Step 1 — Parse arguments:**

Parse $ARGUMENTS:

| Argument | Behaviour |
|----------|-----------|
| *(empty)* | Full interactive review, balanced mode |
| `--conservative` | Full interactive review, conservative mode |
| `--aggressive` | Full interactive review, aggressive mode |
| `--report-only` | Run Phase 1 only — show report, no interactive review |
| `--category archive` | Review archive candidates only |
| `--category consolidation` | Review consolidation candidates only |
| `--category size` | Review size warnings only |
| `--category freshness` | Review freshness candidates only |
| `--category usage` | Review module usage warnings only |
| `--data-driven` | Data-driven mode — only flags items that are BOTH stale AND unused (requires 90+ days of usage data) |
| `--compare [path]` | Compare against a previous report — shows delta table of what's changed |

If an unrecognised argument is provided:
> "Unknown option: [arg]. Valid options: --conservative, --aggressive, --report-only,
> --category [archive | consolidation | size | freshness | usage]"

**Step 2 — Check prerequisites:**

Verify `scripts/prune_report.sh` exists:
```bash
test -f scripts/prune_report.sh && echo "ok" || echo "missing"
```

If missing:
> "prune_report.sh not found at scripts/prune_report.sh. This skill requires
> AMAI to be fully set up. Run `bash scripts/validate.sh` to diagnose."
> Stop.

**Step 3 — Run Phase 1:**

Follow Phase 1 from the skill exactly — run the report, parse it, present the summary.

If `--report-only` was specified: display the full report and stop.

If `--category [name]` was specified: skip to Phase 2 with only that category.

**Step 4 — Run Phase 2 (interactive review):**

Follow Phase 2 from the skill. Walk the user through candidates in the standard
category order (or the specified category if `--category` was used).

**Step 5 — Run Phase 3 (execute decisions):**

Follow Phase 3 from the skill — confirm, execute, log, validate, summarise.

**Step 6 — If anything was archived:**

Remind the user:
> "To restore any archived item, check `_archive/` or run `git checkout HEAD -- [file]`."
