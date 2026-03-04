---
description: Update the status of a goal and log the change to the entry reference and audit trail
allowed-tools: Read, Write, Edit, Bash
---

Update the status of a specific goal in `goals/goals.yaml`.

**Usage:** `/amai:goal-update [goal_id] [new_status]`

Valid statuses: `active` | `on_hold` | `completed` | `abandoned`

---

## Steps

1. Read `${CLAUDE_PLUGIN_ROOT}/goals/goals.yaml` to load current goals.

2. Find the goal with `id` matching the provided `goal_id`. If not found, list available goal ids and ask the user to confirm the correct one.

3. Check that `new_status` is one of: `active`, `on_hold`, `completed`, `abandoned`. If not, prompt the user to choose a valid status.

4. Note the current status as `old_status`.

5. Update the goal's `status` field in `goals/goals.yaml` and update `last_updated` to today's date.

6. Confirm the change with the user:
   > "Updated goal `[goal_id]` ("[label]") from `[old_status]` → `[new_status]`."

7. Append an entry to `calibration/entry_references.jsonl`:

```jsonl
{"date": "YYYY-MM-DD", "entry_id": "GOAL_ID", "entry_type": "goal", "source_file": "goals/goals.yaml", "event": "goal_status_change", "context": "Goal status changed from OLD_STATUS to NEW_STATUS", "outcome": "OUTCOME"}
```

Map `new_status` to `outcome`:
- `completed` → `outcome: "completed"`
- `abandoned` → `outcome: "deferred"` (treat as deferred from tracking perspective)
- `on_hold` → `outcome: "deferred"`
- `active` (reactivated from on_hold or abandoned) → `outcome: "confirmed"`

If `calibration/entry_references.jsonl` does not exist, skip silently.

8. Log to the audit trail:

```bash
bash scripts/audit_log.sh \
  --actor ai \
  --actor-id goal-update \
  --module "goals" \
  --category update \
  --description "Goal status update: [goal_id] changed from [old_status] to [new_status]" \
  --files "goals/goals.yaml,calibration/entry_references.jsonl"
```

If the script isn't found, skip silently.

---

## Notes

- This command only updates `status`. To update goal content (label, key_results, why), edit `goals/goals.yaml` directly.
- If a goal is marked `completed` or `abandoned`, the pruning system will flag it as an archive candidate at the next `/amai:prune` run.
- Goal history is preserved in the audit trail — goals are never deleted by this command.
