#!/usr/bin/env bash
# scripts/prune_report.sh
#
# Deterministic pruning candidate analysis for AMAI.
# Identifies archive candidates, size warnings, and freshness review items.
# Human-in-the-loop: this script recommends; the user decides.
#
# Usage:
#   bash scripts/prune_report.sh [--mode review|patch] [--output <dir>] [--json]
#
# Flags:
#   --mode review   (default) Human-readable markdown report of pruning candidates
#   --mode patch    Generate a reviewable shell script that archives candidates
#   --output <dir>  Output directory (default: reports/)
#   --json          JSON output instead of markdown
#
# Exit codes:
#   0 — report generated successfully
#   1 — error (can't read files, git not available, etc.)
#   2 — usage error

set -euo pipefail

# ── Locate repo root ──────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# ── Parse arguments ───────────────────────────────────────────────────────────
MODE="review"
OUTPUT_DIR="reports"
JSON_MODE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --mode requires a value (review|patch)" >&2
        exit 2
      fi
      MODE="$2"
      if [[ "$MODE" != "review" && "$MODE" != "patch" ]]; then
        echo "Error: --mode must be 'review' or 'patch'" >&2
        exit 2
      fi
      shift 2
      ;;
    --output)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --output requires a directory path" >&2
        exit 2
      fi
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --json)
      JSON_MODE=true
      shift
      ;;
    -h|--help)
      sed -n '/^# Usage/,/^# Exit codes/p' "$0" | sed 's/^# //'
      exit 0
      ;;
    *)
      echo "Error: Unknown option: $1" >&2
      exit 2
      ;;
  esac
done

# ── Run analysis via Python3 ──────────────────────────────────────────────────
python3 - "$REPO_ROOT" "$MODE" "$OUTPUT_DIR" "$JSON_MODE" << 'PYEOF'

import sys
import os
import json
import re
import subprocess
import datetime
from pathlib import Path

REPO_ROOT = Path(sys.argv[1])
MODE      = sys.argv[2]
OUTPUT_DIR = Path(sys.argv[3])
JSON_MODE = sys.argv[4].lower() == "true"

TODAY = datetime.date.today()
TODAY_STR = TODAY.isoformat()

# ── Helpers ───────────────────────────────────────────────────────────────────

PLACEHOLDER_PATTERNS = [
    r'\bEXAMPLE\b', r'\bPLACEHOLDER\b', r'\bREPLACE\b',
    r'\bTODO\b', r'\bTBD\b', r'\bYOUR_', r'_PLACEHOLDER\b',
    r'YYYY-MM-DD',
]

def is_placeholder(text):
    for p in PLACEHOLDER_PATTERNS:
        if re.search(p, str(text), re.IGNORECASE):
            return True
    return False

def git_last_modified(path):
    """Return days since last git modification, or None if unknown."""
    try:
        result = subprocess.run(
            ['git', 'log', '-1', '--format=%ci', '--', str(path)],
            capture_output=True, text=True, cwd=REPO_ROOT
        )
        date_str = result.stdout.strip()
        if not date_str:
            return None
        d = datetime.datetime.fromisoformat(date_str[:10]).date()
        return (TODAY - d).days
    except Exception:
        return None

def file_size_kb(path):
    try:
        return round(os.path.getsize(REPO_ROOT / path) / 1024, 1)
    except Exception:
        return 0

def count_jsonl_entries(path, exclude_example=True):
    """Count non-example JSONL entries."""
    full = REPO_ROOT / path
    if not full.exists():
        return 0
    count = 0
    try:
        with open(full) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                    if exclude_example and obj.get('_example'):
                        continue
                    count += 1
                except json.JSONDecodeError:
                    pass
    except Exception:
        pass
    return count

def read_jsonl(path):
    """Return list of parsed JSONL objects (non-example)."""
    full = REPO_ROOT / path
    if not full.exists():
        return []
    entries = []
    try:
        with open(full) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                    if obj.get('_example'):
                        continue
                    entries.append(obj)
                except json.JSONDecodeError:
                    pass
    except Exception:
        pass
    return entries

def try_load_yaml(path):
    """Load YAML file, returning None on failure."""
    full = REPO_ROOT / path
    if not full.exists():
        return None
    try:
        import yaml
        with open(full) as f:
            return yaml.safe_load(f)
    except ImportError:
        # Fallback: minimal YAML parsing for simple cases
        return None
    except Exception:
        return None

# ── Protected modules ─────────────────────────────────────────────────────────

PROTECTED = {
    'identity/values.yaml':     'core identity (simplification only, never deletion)',
    'identity/heuristics.yaml': 'decision rules (simplification only)',
    'goals/current_focus.yaml': 'weekly priorities (always current)',
    'memory/failures.jsonl':    'lessons learned (append-only, never prune)',
}

# ── Analysis structures ───────────────────────────────────────────────────────

archive_candidates = []   # {file, item, reason, type}
consolidation_candidates = []
size_warnings = []
freshness_reviews = []

# ── Load calibration/metrics.yaml for module_load_frequency ──────────────────

metrics = try_load_yaml('calibration/metrics.yaml')
module_freq = {}
if metrics and isinstance(metrics, dict):
    freq = metrics.get('module_load_frequency', {})
    if isinstance(freq, dict):
        module_freq = freq

# ── 1. YAML FILES — per-entry analysis ───────────────────────────────────────

# goals/goals.yaml — completed or abandoned goals
goals_data = try_load_yaml('goals/goals.yaml')
if goals_data and isinstance(goals_data, dict):
    for goal in goals_data.get('goals', []):
        status = goal.get('status', '')
        gid    = goal.get('id', 'unknown')
        label  = goal.get('label', gid)
        if status in ('completed', 'abandoned'):
            horizon = goal.get('horizon', '')
            archive_candidates.append({
                'file': 'goals/goals.yaml',
                'item': f'`{gid}` — "{label}"',
                'reason': f'status: {status}' + (f' (horizon: {horizon})' if horizon else ''),
                'type': 'goal',
            })
        if is_placeholder(label) or is_placeholder(goal.get('why', '')):
            archive_candidates.append({
                'file': 'goals/goals.yaml',
                'item': f'`{gid}`',
                'reason': 'contains placeholder text — not yet populated',
                'type': 'placeholder',
            })

# identity/values.yaml — placeholder values or red lines
values_data = try_load_yaml('identity/values.yaml')
if values_data and isinstance(values_data, dict):
    for val in values_data.get('core_values', []):
        vid  = val.get('id', 'unknown') if isinstance(val, dict) else 'entry'
        desc = val.get('description', '') if isinstance(val, dict) else str(val)
        if is_placeholder(desc):
            consolidation_candidates.append({
                'file': 'identity/values.yaml',
                'item': f'core_value `{vid}`',
                'reason': 'contains placeholder text — populate or remove',
            })
    for i, rl in enumerate(values_data.get('ethical_red_lines', [])):
        if isinstance(rl, str) and is_placeholder(rl):
            consolidation_candidates.append({
                'file': 'identity/values.yaml',
                'item': f'ethical_red_lines[{i}]',
                'reason': 'contains placeholder text — populate or remove',
            })

# identity/heuristics.yaml — placeholder heuristics
heuristics_data = try_load_yaml('identity/heuristics.yaml')
if heuristics_data and isinstance(heuristics_data, dict):
    for category in ('universal', 'domain', 'commercial', 'people'):
        for h in heuristics_data.get(category, []):
            rule = h.get('rule', '') if isinstance(h, dict) else str(h)
            if is_placeholder(rule):
                consolidation_candidates.append({
                    'file': 'identity/heuristics.yaml',
                    'item': f'{category} heuristic',
                    'reason': 'contains placeholder text — populate or remove',
                })

# network/circles.yaml — placeholder circles
circles_data = try_load_yaml('network/circles.yaml')
if circles_data and isinstance(circles_data, dict):
    for cname, circle in circles_data.items():
        if isinstance(circle, dict) and is_placeholder(str(circle)):
            consolidation_candidates.append({
                'file': 'network/circles.yaml',
                'item': f'circle `{cname}`',
                'reason': 'contains placeholder text — populate or remove',
            })

# ── 2. JSONL FILES — growth and content analysis ──────────────────────────────

JSONL_FILES = [
    'knowledge/learning.jsonl',
    'memory/decisions.jsonl',
    'memory/experiences.jsonl',
    'memory/failures.jsonl',
    'signals/observations.jsonl',
    'calibration/divergence.jsonl',
]

for jpath in JSONL_FILES:
    full = REPO_ROOT / jpath
    if not full.exists():
        continue
    count = count_jsonl_entries(jpath)
    size  = file_size_kb(jpath)
    if count == 0:
        continue  # empty — nothing to prune

    if size > 50:
        msg = f'{count} entries, {size}KB — approaching unwieldy size for context loading.'
        if jpath == 'signals/observations.jsonl':
            entries = read_jsonl(jpath)
            unreviewed = sum(1 for e in entries if e.get('reviewed') is None)
            if unreviewed > 0:
                msg += f' {unreviewed} entries not yet reviewed.'
                msg += ' → Run /amai:calibrate to process pending signals.'
        size_warnings.append({'file': jpath, 'detail': msg})

    if jpath == 'signals/observations.jsonl':
        entries = read_jsonl(jpath)
        unreviewed = sum(1 for e in entries if e.get('reviewed') is None)
        if unreviewed > 100:
            size_warnings.append({
                'file': jpath,
                'detail': f'{unreviewed} unreviewed entries (> 100 threshold). Run /amai:calibrate.'
            })

    if jpath == 'calibration/divergence.jsonl':
        entries = read_jsonl(jpath)
        stale_defers = []
        for e in entries:
            if e.get('disposition') == 'DEFER':
                date_str = e.get('date', '')
                try:
                    d = datetime.date.fromisoformat(date_str)
                    age = (TODAY - d).days
                    if age > 90:
                        stale_defers.append((date_str, age, e.get('tension', '')[:60]))
                except Exception:
                    pass
        if stale_defers:
            detail = f'{len(stale_defers)} DEFER entries older than 90 days — stale deferrals should be resolved.'
            for ds, age, tension in stale_defers[:3]:
                detail += f'\n  - {ds} ({age}d): {tension}'
            if len(stale_defers) > 3:
                detail += f'\n  - ... and {len(stale_defers) - 3} more'
            archive_candidates.append({
                'file': 'calibration/divergence.jsonl',
                'item': f'{len(stale_defers)} stale DEFER entries',
                'reason': detail,
                'type': 'stale_defer',
            })

# ── 3. MARKDOWN FILES — freshness analysis ────────────────────────────────────

NARRATIVE_FILES = [
    ('identity/voice.md',            180),
    ('identity/story.md',            180),
    ('identity/principles.md',       180),
    ('goals/north_star.md',          180),
    ('knowledge/frameworks.md',      180),
    ('knowledge/domain_landscape.md',180),
    ('operations/workflows.md',      180),
    ('operations/rituals.md',        180),
]

SIZE_SIMPLIFY_KB = 10  # files > 10KB flagged as potential simplification candidates

for fpath, threshold_days in NARRATIVE_FILES:
    full = REPO_ROOT / fpath
    if not full.exists():
        continue
    size = file_size_kb(fpath)
    days = git_last_modified(fpath)
    notes = []
    if days is not None and days > threshold_days:
        notes.append(f'Last modified {days} days ago (>{threshold_days} day threshold)')
    if size > SIZE_SIMPLIFY_KB:
        notes.append(f'{size}KB — potential simplification candidate')
    if notes:
        freshness_reviews.append({
            'file': fpath,
            'detail': f'{"; ".join(notes)}.',
        })

# ── 4. MODULE LOAD FREQUENCY ──────────────────────────────────────────────────

freq_warnings = []
if module_freq:
    for module, freq in module_freq.items():
        if isinstance(freq, int) and freq == 0:
            freq_warnings.append({
                'module': module,
                'detail': 'Never loaded — candidate for archival or review',
            })

# ── Assemble results ──────────────────────────────────────────────────────────

total_archive       = len(archive_candidates)
total_consolidation = len(consolidation_candidates)
total_size          = len(size_warnings)
total_freshness     = len(freshness_reviews)
total_freq          = len(freq_warnings)
is_first_run        = not (REPO_ROOT / OUTPUT_DIR).exists()

if JSON_MODE:
    output = {
        'generated': TODAY_STR,
        'first_run': is_first_run,
        'summary': {
            'archive_candidates':       total_archive,
            'consolidation_candidates': total_consolidation,
            'size_warnings':            total_size,
            'freshness_reviews':        total_freshness,
            'frequency_warnings':       total_freq,
            'protected_modules':        len(PROTECTED),
        },
        'archive_candidates':       archive_candidates,
        'consolidation_candidates': consolidation_candidates,
        'size_warnings':            size_warnings,
        'freshness_reviews':        freshness_reviews,
        'frequency_warnings':       freq_warnings,
        'protected': list(PROTECTED.keys()),
    }
    print(json.dumps(output, indent=2))
    sys.exit(0)

# ── Markdown report ───────────────────────────────────────────────────────────

lines = []
lines.append("# AMAI Pruning Report")
lines.append(f"**Generated:** {TODAY_STR}")
if is_first_run:
    lines.append("**Note:** First prune report. Baseline established.")
lines.append("")

total_items = total_archive + total_consolidation + total_size + total_freshness

if total_items == 0 and not freq_warnings:
    lines.append("✅ **System is lean. No pruning candidates found.**")
    lines.append("")
else:
    # Archive Candidates
    if archive_candidates:
        lines.append("## 🗄️ Archive Candidates")
        lines.append("Items recommended for moving to `_archive/` (not deleted — restorable)")
        lines.append("")
        by_file = {}
        for c in archive_candidates:
            by_file.setdefault(c['file'], []).append(c)
        for fpath, items in by_file.items():
            lines.append(f"### {fpath}")
            for c in items:
                lines.append(f"- {c['item']} — {c['reason']}")
            lines.append("")

    # Consolidation Candidates
    if consolidation_candidates:
        lines.append("## ✂️ Consolidation Candidates")
        lines.append("Items that may be redundant, overlapping, or incomplete")
        lines.append("")
        by_file = {}
        for c in consolidation_candidates:
            by_file.setdefault(c['file'], []).append(c)
        for fpath, items in by_file.items():
            lines.append(f"### {fpath}")
            for c in items:
                lines.append(f"- {c['item']} — {c['reason']}")
            lines.append("")

    # Size Warnings
    if size_warnings:
        lines.append("## 📏 Size Warnings")
        lines.append("Files approaching unwieldy size for context loading")
        lines.append("")
        for w in size_warnings:
            lines.append(f"### {w['file']}")
            lines.append(f"- {w['detail']}")
            lines.append("")

    # Freshness Reviews
    if freshness_reviews:
        lines.append("## 📝 Freshness Review")
        lines.append("Narrative files not updated recently")
        lines.append("")
        for r in freshness_reviews:
            lines.append(f"### {r['file']}")
            lines.append(f"- {r['detail']}")
            lines.append("")

    # Frequency Warnings
    if freq_warnings:
        lines.append("## 📊 Module Load Frequency")
        lines.append("")
        for w in freq_warnings:
            lines.append(f"- **{w['module']}** — {w['detail']}")
        lines.append("")

# Protected Modules (always shown)
lines.append("## 🛡️ Protected Modules (never pruned)")
for fpath, reason in PROTECTED.items():
    lines.append(f"- `{fpath}` — {reason}")
lines.append("")

# Summary table
lines.append("## 📋 Summary")
lines.append("")
lines.append("| Category | Items |")
lines.append("|---|---|")
lines.append(f"| Archive candidates       | {total_archive} |")
lines.append(f"| Consolidation candidates | {total_consolidation} |")
lines.append(f"| Size warnings            | {total_size} |")
lines.append(f"| Freshness reviews        | {total_freshness} |")
lines.append(f"| Frequency warnings       | {total_freq} |")
lines.append(f"| Protected (no action)    | {len(PROTECTED)} |")
lines.append("")

# Next steps
lines.append("## Next Steps")
steps = []
if archive_candidates:
    steps.append("Review archive candidates above and decide: move to `_archive/` or keep?")
if consolidation_candidates:
    steps.append("Address placeholder entries — populate or remove them.")
unrev_count = 0
for w in size_warnings:
    if '/observations.jsonl' in w['file']:
        m = re.search(r'(\d+) entries not yet reviewed', w['detail'])
        if m:
            unrev_count = int(m.group(1))
if unrev_count > 0:
    steps.append(f"Run `/amai:calibrate` to process {unrev_count} unreviewed signals.")
if freshness_reviews:
    steps.append(f"Review {total_freshness} narrative file(s) for continued accuracy.")
if not steps:
    steps.append("System is healthy. Next scheduled review: 3 months from now.")
for i, s in enumerate(steps, 1):
    lines.append(f"{i}. {s}")
lines.append("")
lines.append("---")
lines.append("*To generate a patch file for archive actions: `bash scripts/prune_report.sh --mode patch`*")

report_text = "\n".join(lines)
print(report_text)

# ── Write to file ─────────────────────────────────────────────────────────────
output_path = REPO_ROOT / OUTPUT_DIR
output_path.mkdir(parents=True, exist_ok=True)
report_file = output_path / f"prune_{TODAY_STR}.md"
with open(report_file, 'w') as f:
    f.write(report_text + "\n")
print(f"\n→ Report saved to {OUTPUT_DIR}/prune_{TODAY_STR}.md", file=sys.stderr)

# ── Patch mode ────────────────────────────────────────────────────────────────
if MODE == 'patch':
    patch_lines = [
        "#!/usr/bin/env bash",
        f"# AMAI Prune Patch — Generated {TODAY_STR}",
        "# Review each action below. Run this script to apply.",
        "# To undo: check git history or _archive/ directory.",
        "# Protected modules are never modified by this script.",
        "",
        'set -euo pipefail',
        'REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"',
        'cd "$REPO_ROOT/.."',
        "",
        "mkdir -p _archive",
        "",
    ]

    # Archive completed/abandoned goals
    if goals_data and isinstance(goals_data, dict):
        for goal in goals_data.get('goals', []):
            if goal.get('status') in ('completed', 'abandoned'):
                gid = goal.get('id', 'unknown')
                entry = json.dumps({
                    'archived_from': 'goals/goals.yaml',
                    'archive_date': TODAY_STR,
                    'id': gid,
                    'label': goal.get('label', ''),
                    'status': goal.get('status', ''),
                })
                patch_lines.append(f"# Archive {goal.get('status', '')} goal: {gid}")
                patch_lines.append(f"echo '{entry}' >> _archive/goals_archived.jsonl")
                patch_lines.append(f"# TODO: Remove {gid} from goals/goals.yaml manually")
                patch_lines.append("")

    # Archive stale DEFER divergences
    div_entries = read_jsonl('calibration/divergence.jsonl')
    stale_defers = []
    for e in div_entries:
        if e.get('disposition') == 'DEFER':
            date_str = e.get('date', '')
            try:
                d = datetime.date.fromisoformat(date_str)
                if (TODAY - d).days > 90:
                    stale_defers.append(e)
            except Exception:
                pass
    if stale_defers:
        patch_lines.append(f"# Archive {len(stale_defers)} stale DEFER divergences")
        for e in stale_defers:
            entry = json.dumps({**e, 'archived_date': TODAY_STR})
            patch_lines.append(f"echo '{entry}' >> _archive/divergence_archived.jsonl")
        patch_lines.append("# NOTE: Remove archived entries from calibration/divergence.jsonl manually")
        patch_lines.append("")

    if len(patch_lines) <= 12:
        patch_lines.append("echo 'No archive actions needed — system is clean.'")
    else:
        patch_lines.append("echo 'Patch applied. Review _archive/ to confirm.'")

    patch_text = "\n".join(patch_lines)
    patch_file = output_path / f"prune_{TODAY_STR}.patch.sh"
    with open(patch_file, 'w') as f:
        f.write(patch_text + "\n")
    os.chmod(patch_file, 0o755)
    print(f"→ Patch script saved to {OUTPUT_DIR}/prune_{TODAY_STR}.patch.sh", file=sys.stderr)
    print("  Review and run it manually to apply archive actions.", file=sys.stderr)

PYEOF
