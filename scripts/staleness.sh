#!/usr/bin/env bash
# AMAI Staleness Report — focused purely on currency
# Usage: bash scripts/staleness.sh [--json] [--ci] [--threshold-focus <days>] [--threshold-general <days>]
#
# Exit codes:
#   0 — no critical staleness
#   1 — critical staleness found (only in --ci mode)
#   2 — usage error
#
# Requires: bash, python3 (stdlib only, no pip packages)

AMAI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Parse flags ────────────────────────────────────────────────────────────────
JSON_OUTPUT=0
CI_MODE=0
THRESHOLD_FOCUS=14
THRESHOLD_GENERAL=60

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)
      JSON_OUTPUT=1; shift ;;
    --ci)
      CI_MODE=1; shift ;;
    --threshold-focus)
      if [[ -z "$2" || "$2" == --* ]]; then
        printf "Error: --threshold-focus requires a <days> argument\n" >&2; exit 2
      fi
      THRESHOLD_FOCUS="$2"; shift 2 ;;
    --threshold-general)
      if [[ -z "$2" || "$2" == --* ]]; then
        printf "Error: --threshold-general requires a <days> argument\n" >&2; exit 2
      fi
      THRESHOLD_GENERAL="$2"; shift 2 ;;
    *)
      printf "Unknown flag: %s\nUsage: bash scripts/staleness.sh [--json] [--ci] [--threshold-focus <days>] [--threshold-general <days>]\n" "$1" >&2
      exit 2 ;;
  esac
done

# ── Check python3 ──────────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
  echo "ERROR: python3 is required but not found." >&2
  exit 1
fi

# ── Run main logic in Python ───────────────────────────────────────────────────
AMAI_ROOT="$AMAI_ROOT" \
JSON_OUTPUT="$JSON_OUTPUT" \
CI_MODE="$CI_MODE" \
THRESHOLD_FOCUS="$THRESHOLD_FOCUS" \
THRESHOLD_GENERAL="$THRESHOLD_GENERAL" \
python3 << 'PYEOF'
import os, sys, json, re
from datetime import date

ROOT              = os.environ['AMAI_ROOT']
JSON_OUT          = os.environ.get('JSON_OUTPUT', '0') == '1'
CI_MODE           = os.environ.get('CI_MODE', '0') == '1'
THRESHOLD_FOCUS   = int(os.environ.get('THRESHOLD_FOCUS', '14'))
THRESHOLD_GENERAL = int(os.environ.get('THRESHOLD_GENERAL', '60'))
TODAY             = date.today()

# ── YAML loader (stdlib fallback) ──────────────────────────────────────────────
try:
    import yaml as _pyyaml
    def load_yaml(path):
        try:
            with open(path) as f:
                return _pyyaml.safe_load(f), None
        except Exception as e:
            return None, str(e)
except ImportError:
    def load_yaml(path):
        """Minimal YAML loader for simple key: value files (stdlib fallback)."""
        try:
            data = {}
            with open(path) as f:
                for line in f:
                    line = line.rstrip()
                    if line.startswith('#') or ':' not in line:
                        continue
                    key, _, val = line.partition(':')
                    key = key.strip()
                    val = val.strip().strip('"').strip("'")
                    if val.lower() == 'null' or val == '~' or val == '':
                        data[key] = None
                    else:
                        data[key] = val
            return data, None
        except Exception as e:
            return None, str(e)

def p(rel):
    return os.path.join(ROOT, rel)

def days_ago(d):
    try:
        parsed = date.fromisoformat(str(d))
        return (TODAY - parsed).days
    except Exception:
        return None

def extract_last_updated_yaml(path):
    """Return (last_updated_str_or_None, source) from a YAML file."""
    if not os.path.exists(path):
        return None, 'missing'
    data, err = load_yaml(path)
    if err or data is None:
        return None, 'parse_error'
    lu = data.get('last_updated')
    return lu, 'yaml'

def extract_last_updated_md(path):
    """Return (last_updated_str_or_None, source) from a Markdown file."""
    if not os.path.exists(path):
        return None, 'missing'
    try:
        with open(path) as f:
            content = f.read()
        # Look for "Last updated: YYYY-MM-DD" anywhere in file
        m = re.search(r'[Ll]ast\s+updated[:\s]+(\d{4}-\d{2}-\d{2})', content)
        if m:
            return m.group(1), 'markdown'
        return None, 'no_date'
    except Exception:
        return None, 'read_error'

def file_mtime(path):
    """Return file modification date as ISO string."""
    try:
        import datetime
        ts = os.path.getmtime(path)
        return datetime.date.fromtimestamp(ts).isoformat()
    except Exception:
        return None

def check_brain_status():
    """Return BRAIN.md STATUS field value."""
    path = p('BRAIN.md')
    if not os.path.exists(path):
        return None
    try:
        with open(path) as f:
            for line in f:
                m = re.match(r'^STATUS:\s*(\S+)', line)
                if m:
                    return m.group(1).strip()
    except Exception:
        pass
    return None

def has_placeholder(path):
    """Return True if file looks like it still has placeholder content."""
    if not os.path.exists(path):
        return False
    placeholder_patterns = [
        r'\[.+\]',         # [bracketed text]
        r'TODO',
        r'PLACEHOLDER',
        r'Replace this',
        r'Your ',
        r'YYYY-MM-DD',
        r'_example:\s*true',
    ]
    try:
        with open(path) as f:
            content = f.read(4000)  # Sample first 4K
        for pat in placeholder_patterns:
            if re.search(pat, content):
                return True
    except Exception:
        pass
    return False

def count_jsonl_entries(path):
    """Count non-example entries in a JSONL file."""
    if not os.path.exists(path):
        return 0
    count = 0
    try:
        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                    if obj.get('_example') is True:
                        continue
                    count += 1
                except Exception:
                    pass
    except Exception:
        pass
    return count

# ── Build check results ────────────────────────────────────────────────────────

results = {
    'date': TODAY.isoformat(),
    'thresholds': {'focus_days': THRESHOLD_FOCUS, 'general_days': THRESHOLD_GENERAL},
    'critical': [],
    'warning': [],
    'current': [],
    'not_populated': [],
    'calibration': {},
    'summary': {},
    'recommendation': '',
}

def make_entry(rel_path, lu, threshold, action):
    ago = days_ago(lu) if lu else None
    return {
        'file': rel_path,
        'last_updated': lu if lu else None,
        'days_ago': ago,
        'threshold': threshold,
        'action': action,
    }

# ── CRITICAL checks ────────────────────────────────────────────────────────────

# 1. goals/current_focus.yaml
lu, src = extract_last_updated_yaml(p('goals/current_focus.yaml'))
ago = days_ago(lu) if lu else None
if lu is None or (ago is not None and ago > THRESHOLD_FOCUS):
    results['critical'].append(make_entry(
        'goals/current_focus.yaml', lu, THRESHOLD_FOCUS,
        'Run /amai:setup 1 or update manually'
    ))
else:
    results['current'].append(make_entry('goals/current_focus.yaml', lu, THRESHOLD_FOCUS, ''))

# 2. BRAIN.md STATUS == STALE
brain_status = check_brain_status()
if brain_status == 'STALE':
    results['critical'].append({
        'file': 'BRAIN.md',
        'last_updated': None,
        'days_ago': None,
        'threshold': None,
        'action': 'Update BRAIN.md STATUS and review stale modules',
    })

# ── WARNING checks ─────────────────────────────────────────────────────────────

warning_specs = [
    ('identity/values.yaml',         'yaml',     THRESHOLD_GENERAL, 'Run /amai:setup 1'),
    ('identity/heuristics.yaml',     'yaml',     THRESHOLD_GENERAL, 'Run /amai:setup 1'),
    ('identity/voice.md',            'markdown', 90,                'Review and refresh your voice profile'),
    ('goals/goals.yaml',             'yaml',     THRESHOLD_GENERAL, 'Review goals'),
    ('goals/north_star.md',          'markdown', 180,               'Review your long-horizon vision'),
    ('knowledge/frameworks.md',      'markdown', 90,                'Review and refresh'),
    ('knowledge/domain_landscape.md','markdown', 90,                'Review and refresh'),
    ('operations/rituals.md',        'markdown', 90,                'Review your rituals'),
    ('network/circles.yaml',         'yaml',     90,                'Review your network circles'),
]

for rel_path, fmt, threshold, action in warning_specs:
    full_path = p(rel_path)
    if not os.path.exists(full_path):
        results['not_populated'].append({
            'file': rel_path, 'reason': 'file missing',
            'note': '(Stage 3 — optional)' if rel_path in ('identity/story.md', 'identity/principles.md') else ''
        })
        continue

    if fmt == 'yaml':
        lu, src = extract_last_updated_yaml(full_path)
    else:
        lu, src = extract_last_updated_md(full_path)

    # Check if placeholder
    if lu is None and has_placeholder(full_path):
        results['not_populated'].append({
            'file': rel_path, 'reason': 'placeholder content', 'note': ''
        })
        continue

    ago = days_ago(lu) if lu else None
    if lu is None or (ago is not None and ago > threshold):
        results['warning'].append(make_entry(rel_path, lu, threshold, action))
    else:
        results['current'].append(make_entry(rel_path, lu, threshold, ''))

# ── INFO / NOT POPULATED checks ────────────────────────────────────────────────

stage3_optional = ['identity/story.md', 'identity/principles.md']
for rel_path in stage3_optional:
    if not os.path.exists(p(rel_path)):
        results['not_populated'].append({
            'file': rel_path, 'reason': 'not yet created',
            'note': '(Stage 3 — optional)'
        })

jsonl_checks = [
    'memory/decisions.jsonl',
    'memory/failures.jsonl',
    'signals/observations.jsonl',
]
for rel_path in jsonl_checks:
    full_path = p(rel_path)
    if not os.path.exists(full_path):
        results['not_populated'].append({'file': rel_path, 'reason': 'file missing', 'note': ''})
    else:
        count = count_jsonl_entries(full_path)
        if count == 0:
            results['not_populated'].append({'file': rel_path, 'reason': f'0 entries', 'note': ''})

# ── CALIBRATION check ──────────────────────────────────────────────────────────

cal_path = p('calibration/metrics.yaml')
cal_status = 'never_run'
cal_last = None

if os.path.exists(cal_path):
    data, err = load_yaml(cal_path)
    if data and not err:
        # Look for review_history — may be a list or a simple field
        rh = data.get('review_history')
        if isinstance(rh, list) and len(rh) > 0:
            # Expect entries with a 'date' key
            dates = []
            for entry in rh:
                if isinstance(entry, dict) and entry.get('date'):
                    d = entry.get('date')
                    if d:
                        dates.append(str(d))
            if dates:
                cal_last = sorted(dates)[-1]
        elif isinstance(rh, str) and rh:
            cal_last = rh

if cal_last:
    cal_ago = days_ago(cal_last)
    if cal_ago is not None and cal_ago > 30:
        cal_status = 'overdue'
    else:
        cal_status = 'current'

results['calibration'] = {
    'status': cal_status,
    'last_review': cal_last,
}

# ── Summary & recommendation ───────────────────────────────────────────────────

n_crit = len(results['critical'])
n_warn = len(results['warning'])
n_curr = len(results['current'])
n_pop  = len(results['not_populated'])

results['summary'] = {
    'critical': n_crit,
    'warning': n_warn,
    'current': n_curr,
    'not_populated': n_pop,
}

# Recommendation priority
if n_crit > 0:
    first_crit = results['critical'][0]
    results['recommendation'] = f"Update {first_crit['file']} now ({first_crit['action']})"
elif cal_status == 'overdue' and count_jsonl_entries(p('signals/observations.jsonl')) > 0:
    results['recommendation'] = "Run /amai:calibrate — overdue and signal data available"
elif n_warn > 1:
    first_warn = results['warning'][0]
    results['recommendation'] = f"Review {first_warn['file']} when you get 10 minutes"
else:
    results['recommendation'] = "System healthy. No action needed."

# ── Output ─────────────────────────────────────────────────────────────────────

def format_days(lu, ago):
    if lu is None:
        return "null (never set)"
    if ago is None:
        return f"{lu} (unknown age)"
    return f"{lu} ({ago} days ago)"

if JSON_OUT:
    print(json.dumps(results, indent=2))
else:
    # ANSI colours
    RED    = '\033[0;31m'
    YELLOW = '\033[0;33m'
    GREEN  = '\033[0;32m'
    CYAN   = '\033[0;36m'
    RESET  = '\033[0m'

    WIDTH = 42
    print(f"{'═' * WIDTH}")
    print(f"  AMAI Staleness Report")
    print(f"  Date: {TODAY.isoformat()}")
    print(f"  Thresholds: focus={THRESHOLD_FOCUS}d  general={THRESHOLD_GENERAL}d")
    print(f"{'═' * WIDTH}")

    if results['critical']:
        print(f"\n{RED}🔴 CRITICAL{RESET}")
        for item in results['critical']:
            print(f"  {item['file']:<40}  last updated: {format_days(item['last_updated'], item['days_ago'])}")
            print(f"  {'':40}  → {item['action']}")

    if results['warning']:
        print(f"\n{YELLOW}🟡 WARNING{RESET}")
        for item in results['warning']:
            print(f"  {item['file']:<40}  last updated: {format_days(item['last_updated'], item['days_ago'])}")
            print(f"  {'':40}  → {item['action']}")

    if results['current']:
        print(f"\n{GREEN}🟢 CURRENT{RESET}")
        for item in results['current']:
            print(f"  {item['file']:<40}  last updated: {format_days(item['last_updated'], item['days_ago'])}")

    if results['not_populated']:
        print(f"\n{CYAN}ℹ️  NOT YET POPULATED{RESET}")
        for item in results['not_populated']:
            note = f"  {item['note']}" if item.get('note') else f"  {item['reason']}"
            print(f"  {item['file']:<40}{note}")

    # Calibration
    print(f"\n📊 CALIBRATION")
    cal = results['calibration']
    if cal['status'] == 'never_run':
        print(f"  Status: Never run")
        print(f"  → Run /amai:calibrate when you have 2+ weeks of signal data")
    elif cal['status'] == 'overdue':
        ago = days_ago(cal['last_review'])
        print(f"  Status: Overdue (last: {cal['last_review']}, {ago} days ago)")
        print(f"  → Run /amai:calibrate")
    else:
        ago = days_ago(cal['last_review'])
        print(f"  Status: Current (last: {cal['last_review']}, {ago} days ago)")

    print(f"\n{'─' * WIDTH}")
    print(f"Summary: {n_crit} critical, {n_warn} warnings, {n_curr} current, {n_pop} not populated")
    print(f"Recommendation: {results['recommendation']}")
    print(f"{'─' * WIDTH}")

# ── Exit code ──────────────────────────────────────────────────────────────────
if CI_MODE and n_crit > 0:
    sys.exit(1)
sys.exit(0)

PYEOF
