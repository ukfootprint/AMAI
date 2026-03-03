# _archive/

This directory contains items archived during AMAI pruning reviews.

**Archive, never delete** — items are moved here, not removed. They are
fully restorable.

---

## Directory Structure

Files mirror their original location in the AMAI repo:

```
_archive/
  goals_archived.jsonl          — archived goals from goals/goals.yaml
  signals_archived.jsonl        — archived entries from signals/observations.jsonl
  divergence_archived.jsonl     — archived entries from calibration/divergence.jsonl
  [module]_archived.jsonl       — archived entries from other JSONL files
```

---

## Restoring an Item

**File-based restore:**
```bash
mv _archive/[path] [original-path]
```

**JSONL entry restore:**
Copy the specific line from `_archive/[module]_archived.jsonl` back into the
original file at the correct location.

**Git restore** (if the file was committed before archiving):
```bash
git checkout HEAD -- [file]
```

---

## Archive Decision Log

All pruning decisions are logged in `memory/decisions.jsonl` with
`"type": "pruning_decision"`. Check that file to see what was archived,
when, and why.

---

## Git Status

This directory is **git-ignored by default** (see `.gitignore`). If you want
to track archive history in a private repository, remove the `_archive/` line
from `.gitignore` and commit this directory explicitly.

---

*Created by AMAI pruning skill. Use `/amai:prune` or `docs/pruning_prompt.md`
to run future pruning reviews.*
