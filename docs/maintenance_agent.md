# AMAI Maintenance Agent

The maintenance agent is a scheduled weekly task that checks your AMAI system health
and surfaces what needs attention. It runs every Monday at 9:00 AM.

---

## What It Does

Each run, the agent:

1. **Runs health checks** — validates your AMAI files, checks staleness across all modules, reviews signal capture cadence, and notes any unused modules
2. **Reviews current_focus.yaml** — checks if your weekly priorities are stale (> 14 days old) and pre-drafts a suggested update if so
3. **Produces a weekly report** saved to `reports/weekly_maintenance_[date].md`
4. **Presents a summary** in the Cowork chat with key issues and recommendations

The agent NEVER modifies AMAI files automatically. All recommendations require your review and approval.

---

## Weekly Report Structure

Each report includes:
- **Health status:** HEALTHY / NEEDS_ATTENTION / ACTION_REQUIRED
- **System checks table:** validation, staleness, signal capture, usage
- **Recommendations list:** specific actions flagged
- **Focus review:** current_focus.yaml status + draft update if stale

---

## Configuration

**Change the schedule:** Edit the task in Cowork's Scheduled section (sidebar) and update the cron expression. Default: `0 9 * * 1` (Mondays at 9am).

**Disable:** Toggle the task off in the Scheduled section. Your reports are preserved.

**Re-enable:** Toggle it back on. The next scheduled run will proceed normally.

---

## Acting on Recommendations

Common recommendations and what to do:

| Issue | Action |
|-------|--------|
| Validation errors | Run `bash scripts/validate.sh` and fix the flagged fields |
| Stale current_focus | Review the draft update in the report; update manually if it's right |
| No recent signals | After your next AMAI session, log observations to `signals/observations.jsonl` |
| Unused modules | Consider pruning with `/amai:prune` or leave if recently set up |

---

*The agent's task file is at: Scheduled/amai-weekly-maintenance/SKILL.md*
