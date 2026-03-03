#!/usr/bin/env bash
# AMAI Validation Script — Schema-backed, severity levels
# Usage: bash scripts/validate.sh [--allow-warn] [--json] [--quiet]
#
# Exit codes:
#   0 — clean or WARN-only
#   1 — one or more ERRORs present
#   2 — usage error
#
# Requires: bash, python3
# Optional: jq (for downstream pipe of --json output)
# No pip packages — uses Python stdlib; PyYAML used if available, otherwise falls back.

AMAI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEMA_DIR="$AMAI_ROOT/schemas"

# ── Parse flags ────────────────────────────────────────────────────────────────
ALLOW_WARN=0
JSON_OUTPUT=0
QUIET=0

for arg in "$@"; do
  case "$arg" in
    --allow-warn) ALLOW_WARN=1 ;;
    --json)       JSON_OUTPUT=1 ;;
    --quiet)      QUIET=1 ;;
    *)
      printf "Unknown flag: %s\nUsage: bash scripts/validate.sh [--allow-warn] [--json] [--quiet]\n" "$arg" >&2
      exit 2
      ;;
  esac
done

# ── Check python3 ──────────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
  echo "ERROR: python3 is required but not found." >&2
  exit 1
fi

# ── Check jq (optional, note only if --json used) ─────────────────────────────
if [[ "$JSON_OUTPUT" == "1" ]] && ! command -v jq &>/dev/null; then
  printf "Note: jq not found — --json output is unformatted JSON.\n" >&2
fi

# ── Temp file for exit-code summary ───────────────────────────────────────────
SUMMARY_FILE="$(mktemp)"
trap 'rm -f "$SUMMARY_FILE"' EXIT

# ── Main validation (Python) ───────────────────────────────────────────────────
AMAI_ROOT="$AMAI_ROOT" \
SCHEMA_DIR="$SCHEMA_DIR" \
JSON_OUTPUT="$JSON_OUTPUT" \
QUIET="$QUIET" \
SUMMARY_FILE="$SUMMARY_FILE" \
python3 << 'PYEOF'
import os, sys, json, re
from datetime import date, timedelta

ROOT       = os.environ['AMAI_ROOT']
SCHEMA_DIR = os.environ['SCHEMA_DIR']
JSON_OUT   = os.environ.get('JSON_OUTPUT', '0') == '1'
QUIET      = os.environ.get('QUIET', '0') == '1'
SUMFILE    = os.environ.get('SUMMARY_FILE', '')
TODAY      = date.today()

PLACEHOLDER_PATTERNS = [
    'Example:', 'TODO', 'Replace this', 'Your ', '[your', 'PLACEHOLDER',
    '[Replace', 'YYYY-MM-DD',
]

# ── YAML Loading ───────────────────────────────────────────────────────────────

try:
    import yaml as _pyyaml
    def load_yaml(path):
        try:
            with open(path) as f:
                return _pyyaml.safe_load(f), None
        except Exception as e:
            return None, str(e)
except ImportError:
    _pyyaml = None

    def load_yaml(path):
        try:
            with open(path) as f:
                text = f.read()
            return _yaml_fallback(text), None
        except Exception as e:
            return None, str(e)

    def _strip_inline_comment(s):
        in_q = False; qc = None
        for i, c in enumerate(s):
            if c in ('"', "'"):
                if not in_q: in_q, qc = True, c
                elif c == qc: in_q = False
            elif c == '#' and not in_q:
                return s[:i].rstrip()
        return s

    def _parse_scalar(s):
        s = s.strip()
        if not s or s.lower() in ('null', '~'): return None
        if s.lower() == 'true': return True
        if s.lower() == 'false': return False
        try: return int(s)
        except ValueError: pass
        try: return float(s)
        except ValueError: pass
        if len(s) >= 2 and s[0] == s[-1] and s[0] in ('"', "'"):
            return s[1:-1]
        return s

    def _parse_array(lines, base_indent):
        items = []; current = []; i = 0
        while i < len(lines):
            ln = lines[i]; st = ln.strip()
            if not st or st.startswith('#'): i += 1; continue
            indent = len(ln) - len(ln.lstrip())
            if indent == base_indent and st.startswith('- '):
                if current: items.append(_array_item(current, base_indent + 2))
                rest = st[2:].strip()
                if rest.startswith('#'): rest = ''
                current = [(' ' * (base_indent + 2)) + rest] if rest else []
            elif indent == base_indent and st == '-':
                if current: items.append(_array_item(current, base_indent + 2))
                current = []
            else:
                current.append(ln)
            i += 1
        if current: items.append(_array_item(current, base_indent + 2))
        return items

    def _array_item(lines, base_indent):
        non_empty = [l for l in lines if l.strip() and not l.strip().startswith('#')]
        if not non_empty: return None
        first = non_empty[0].strip()
        # Block scalar indicator at the start of an array item (e.g. "- >\n  text...")
        if first in ('>', '|', '>-', '|-', '>+', '|+'):
            rest = [l.strip() for l in non_empty[1:] if l.strip()]
            return ' '.join(rest)
        if ':' in first and not first.startswith(('"', "'")):
            return _parse_obj(lines, base_indent)
        return _parse_scalar(first)

    def _parse_obj(lines, base_indent):
        obj = {}; i = 0
        while i < len(lines):
            ln = lines[i]; st = ln.strip()
            if not st or st.startswith('#'): i += 1; continue
            indent = len(ln) - len(ln.lstrip())
            if indent != base_indent: i += 1; continue
            if ':' not in st: i += 1; continue
            cp = st.index(':'); key = st[:cp].strip()
            val_raw = _strip_inline_comment(st[cp+1:].strip())
            if val_raw in ('>', '|', '>-', '|-', '>+', '|+'):
                i += 1; parts = []
                while i < len(lines):
                    bln = lines[i]; bst = bln.strip()
                    if not bst or bst.startswith('#'): i += 1; continue
                    if len(bln) - len(bln.lstrip()) <= base_indent: break
                    parts.append(bst); i += 1
                obj[key] = ' '.join(parts)
            elif not val_raw:
                i += 1; nested = []; nb = None
                while i < len(lines):
                    bln = lines[i]; bst = bln.strip()
                    if not bst or bst.startswith('#'): i += 1; continue
                    bi = len(bln) - len(bln.lstrip())
                    if nb is None: nb = bi
                    if bi < nb: break
                    nested.append(bln); i += 1
                if nested:
                    f0 = nested[0].strip()
                    obj[key] = _parse_array(nested, nb) if f0.startswith('- ') or f0 == '-' else _parse_obj(nested, nb)
                else:
                    obj[key] = None
            else:
                obj[key] = _parse_scalar(val_raw); i += 1
        return obj

    def _yaml_fallback(text):
        lines = text.split('\n'); result = {}; i = 0
        while i < len(lines):
            ln = lines[i]; st = ln.strip()
            if not st or st.startswith('#'): i += 1; continue
            if ln[0:1].isspace(): i += 1; continue
            if ':' not in st: i += 1; continue
            cp = st.index(':'); key = st[:cp].strip()
            if key.startswith('#'): i += 1; continue
            val_raw = _strip_inline_comment(st[cp+1:].strip())
            if val_raw in ('>', '|', '>-', '|-', '>+', '|+'):
                i += 1; parts = []
                while i < len(lines):
                    bln = lines[i]; bst = bln.strip()
                    if not bst or bst.startswith('#'): i += 1; continue
                    if not lines[i][0:1].isspace(): break
                    parts.append(bst); i += 1
                result[key] = ' '.join(parts)
            elif not val_raw:
                i += 1; nested = []; nb = None
                while i < len(lines):
                    bln = lines[i]; bst = bln.strip()
                    if not bst or bst.startswith('#'): i += 1; continue
                    bi = len(bln) - len(bln.lstrip())
                    if bi == 0: break
                    if nb is None: nb = bi
                    nested.append(bln); i += 1
                if nested:
                    f0 = nested[0].strip()
                    result[key] = _parse_array(nested, nb) if f0.startswith('- ') or f0 == '-' else _parse_obj(nested, nb)
                else:
                    result[key] = None
            else:
                result[key] = _parse_scalar(val_raw); i += 1
        return result

# ── Results Accumulator ────────────────────────────────────────────────────────

class Results:
    def __init__(self):
        self.files = []
        self.cur = None

    def begin(self, rel_path):
        self.cur = {'path': rel_path, 'issues': []}
        self.files.append(self.cur)

    def add(self, sev, code, msg):
        self.cur['issues'].append({'severity': sev, 'code': code, 'message': msg})

    def error(self, code, msg): self.add('ERROR', code, msg)
    def warn(self, code, msg):  self.add('WARN',  code, msg)
    def info(self, code, msg):  self.add('INFO',  code, msg)

    def summary(self):
        e = w = n = 0
        for f in self.files:
            for i in f['issues']:
                s = i['severity']
                if s == 'ERROR': e += 1
                elif s == 'WARN': w += 1
                else: n += 1
        return {'errors': e, 'warns': w, 'infos': n}

R = Results()

# ── Helpers ────────────────────────────────────────────────────────────────────

def p(rel): return os.path.join(ROOT, rel)

def is_stale(val, days):
    if val is None: return True
    try:
        d = date.fromisoformat(str(val))
        return (TODAY - d).days > days
    except Exception:
        return True

def has_placeholder(val):
    if not isinstance(val, str): return False
    for pat in PLACEHOLDER_PATTERNS:
        if pat in val: return True  # case-sensitive — 'Your ' won't match 'your way'
    return False

def check_placeholders(data, path_prefix=''):
    hits = []
    if isinstance(data, dict):
        for k, v in data.items():
            kp = f'{path_prefix}.{k}' if path_prefix else k
            if k.startswith('_'): continue   # skip metadata fields
            hits += check_placeholders(v, kp)
    elif isinstance(data, list):
        for i, v in enumerate(data):
            hits += check_placeholders(v, f'{path_prefix}[{i}]')
    elif isinstance(data, str) and has_placeholder(data):
        hits.append((path_prefix, data[:80]))
    return hits

# ── identity/values.yaml ───────────────────────────────────────────────────────

def validate_values():
    path = p('identity/values.yaml')
    R.begin('identity/values.yaml')
    if not os.path.exists(path):
        R.error('MISSING_FILE', 'identity/values.yaml not found'); return

    data, err = load_yaml(path)
    if err or data is None:
        R.error('PARSE_ERROR', f'Could not parse YAML: {err}'); return

    # Schema checks
    if data.get('_schema') != 'values':
        R.error('SCHEMA_MISMATCH', f'_schema should be "values", got "{data.get("_schema")}"')
    if data.get('_version') != '1.0':
        R.error('VERSION_MISMATCH', f'_version should be "1.0", got "{data.get("_version")}"')
    R.info('SCHEMA_VERSION', f'_schema=values _version={data.get("_version")}')

    # core_values
    core_values = data.get('core_values')
    if not isinstance(core_values, list) or len(core_values) == 0:
        R.error('MISSING_FIELD', 'core_values must be a non-empty array')
    else:
        for idx, cv in enumerate(core_values):
            if not isinstance(cv, dict):
                R.error('SCHEMA_ERROR', f'core_values[{idx}] is not an object'); continue
            for req in ['id', 'label', 'priority', 'description', 'in_practice', 'test']:
                if req not in cv or cv[req] is None:
                    R.error('MISSING_FIELD', f'core_values[{idx}].{req} is required but missing')
            desc = cv.get('description', '')
            if isinstance(desc, str) and 0 < len(desc) < 20:
                R.warn('VAGUE_VALUE',
                       f'core_values[{idx}] ({cv.get("id","?")}).description is only {len(desc)} chars — aim for 20+')
            ip = cv.get('in_practice')
            if isinstance(ip, list) and len(ip) < 2:
                R.warn('MISSING_EXAMPLES',
                       f'core_values[{idx}] ({cv.get("id","?")}) has only {len(ip)} in_practice example(s) — add at least 2')

    # ethical_red_lines
    red_lines = data.get('ethical_red_lines')
    if red_lines is None:
        R.error('MISSING_FIELD', 'ethical_red_lines is required')
    elif isinstance(red_lines, list):
        if len(red_lines) == 0:
            R.warn('EMPTY_RED_LINES', 'ethical_red_lines array is empty — add at least 2 non-negotiable constraints')
        else:
            for idx, rl in enumerate(red_lines):
                if isinstance(rl, str):
                    # Legacy string format
                    if len(rl) < 10:
                        R.warn('SHORT_RED_LINE',
                               f'ethical_red_lines[{idx}] is only {len(rl)} chars — be more specific')
                    R.warn('DEPRECATED_RED_LINE_FORMAT',
                           f'ethical_red_lines[{idx}] is a plain string — migrate to When/Do/Never/Except format (see docs/red_line_migration.md)')
                elif isinstance(rl, dict):
                    # Structured format — check recommended fields
                    if not rl.get('do'):
                        R.warn('REDLINE_MISSING_DO',
                               f'ethical_red_lines[{idx}] ({rl.get("id","?")}) has no "do" field — add the required positive behaviour')
                    examples = rl.get('examples')
                    if not isinstance(examples, list) or len(examples) < 1:
                        R.warn('REDLINE_MISSING_EXAMPLES',
                               f'ethical_red_lines[{idx}] ({rl.get("id","?")}) has no examples — add at least 1 concrete example')

    # Placeholder scan
    for fp, snippet in check_placeholders(data):
        R.warn('PLACEHOLDER_DATA', f'{fp} contains placeholder text: "{snippet[:60]}"')

    # Staleness
    lu = data.get('last_updated')
    if is_stale(lu, 60):
        R.warn('STALE_MODULE', f'last_updated is {"null" if lu is None else lu} — threshold: 60 days')

# ── identity/heuristics.yaml ──────────────────────────────────────────────────

def validate_heuristics():
    path = p('identity/heuristics.yaml')
    R.begin('identity/heuristics.yaml')
    if not os.path.exists(path):
        R.error('MISSING_FILE', 'identity/heuristics.yaml not found'); return

    data, err = load_yaml(path)
    if err or data is None:
        R.error('PARSE_ERROR', f'Could not parse YAML: {err}'); return

    if data.get('_schema') != 'heuristics':
        R.error('SCHEMA_MISMATCH', f'_schema should be "heuristics"')
    if data.get('_version') != '1.0':
        R.error('VERSION_MISMATCH', f'_version should be "1.0"')
    R.info('SCHEMA_VERSION', f'_schema=heuristics _version={data.get("_version")}')

    CONF = {'high', 'medium', 'low'}

    universal = data.get('universal')
    if not isinstance(universal, list) or len(universal) == 0:
        R.error('MISSING_FIELD', 'universal must be a non-empty array')
    else:
        for idx, h in enumerate(universal):
            if not isinstance(h, dict): continue
            for req in ['id', 'rule', 'use_when', 'confidence']:
                if req not in h or h[req] is None:
                    R.error('MISSING_FIELD', f'universal[{idx}].{req} is required but missing')
            rule = h.get('rule', '')
            if isinstance(rule, str) and 0 < len(rule) < 15:
                R.warn('VAGUE_HEURISTIC',
                       f'universal[{idx}] ({h.get("id","?")}).rule is only {len(rule)} chars — aim for 15+')
            conf = h.get('confidence')
            if conf is not None and conf not in CONF:
                R.error('INVALID_ENUM', f'universal[{idx}].confidence "{conf}" must be high|medium|low')

    for section in ('domain', 'commercial', 'people'):
        items = data.get(section)
        if not isinstance(items, list): continue
        for idx, h in enumerate(items):
            if not isinstance(h, dict): continue
            for req in ['id', 'rule', 'confidence']:
                if req not in h or h[req] is None:
                    R.error('MISSING_FIELD', f'{section}[{idx}].{req} is required but missing')
            rule = h.get('rule', '')
            if isinstance(rule, str) and 0 < len(rule) < 15:
                R.warn('VAGUE_HEURISTIC',
                       f'{section}[{idx}] ({h.get("id","?")}).rule is only {len(rule)} chars')
            conf = h.get('confidence')
            if conf is not None and conf not in CONF:
                R.error('INVALID_ENUM', f'{section}[{idx}].confidence "{conf}" must be high|medium|low')

    for fp, snippet in check_placeholders(data):
        R.warn('PLACEHOLDER_DATA', f'{fp} contains placeholder text: "{snippet[:60]}"')

    lu = data.get('last_updated')
    if is_stale(lu, 60):
        R.warn('STALE_MODULE', f'last_updated is {"null" if lu is None else lu} — threshold: 60 days')

# ── goals/goals.yaml ──────────────────────────────────────────────────────────

def validate_goals():
    path = p('goals/goals.yaml')
    R.begin('goals/goals.yaml')
    if not os.path.exists(path):
        R.error('MISSING_FILE', 'goals/goals.yaml not found'); return

    data, err = load_yaml(path)
    if err or data is None:
        R.error('PARSE_ERROR', f'Could not parse YAML: {err}'); return

    if data.get('_schema') != 'goals':
        R.error('SCHEMA_MISMATCH', f'_schema should be "goals"')
    if data.get('_version') != '1.0':
        R.error('VERSION_MISMATCH', f'_version should be "1.0"')
    R.info('SCHEMA_VERSION', f'_schema=goals _version={data.get("_version")}')

    STATUS_ENUM = {'active', 'on_hold', 'completed', 'abandoned'}
    goals = data.get('goals')
    if not isinstance(goals, list):
        R.error('SCHEMA_ERROR', 'goals must be an array')
    else:
        for idx, g in enumerate(goals):
            if not isinstance(g, dict): continue
            for req in ['id', 'label', 'status', 'horizon', 'why', 'key_results']:
                if req not in g or g[req] is None:
                    R.error('MISSING_FIELD', f'goals[{idx}].{req} is required but missing')
            st = g.get('status')
            if st is not None and st not in STATUS_ENUM:
                R.error('INVALID_ENUM', f'goals[{idx}].status "{st}" must be active|on_hold|completed|abandoned')
            krs = g.get('key_results')
            if isinstance(krs, list) and len(krs) < 1:
                R.error('ARRAY_TOO_SHORT', f'goals[{idx}].key_results must have at least 1 item')

    for fp, snippet in check_placeholders(data):
        R.warn('PLACEHOLDER_DATA', f'{fp} contains placeholder text: "{snippet[:60]}"')

    lu = data.get('last_updated')
    if is_stale(lu, 60):
        R.warn('STALE_MODULE', f'last_updated is {"null" if lu is None else lu} — threshold: 60 days')

# ── goals/current_focus.yaml ──────────────────────────────────────────────────

def validate_current_focus():
    path = p('goals/current_focus.yaml')
    R.begin('goals/current_focus.yaml')
    if not os.path.exists(path):
        R.error('MISSING_FILE', 'goals/current_focus.yaml not found'); return

    data, err = load_yaml(path)
    if err or data is None:
        R.error('PARSE_ERROR', f'Could not parse YAML: {err}'); return

    R.info('SCHEMA_VERSION', f'_schema=current_focus _version={data.get("_version", "n/a")}')

    for req in ['priorities', 'not_this_week', 'the_one_thing']:
        if req not in data or data[req] is None:
            R.error('MISSING_FIELD', f'Required field "{req}" is missing or null')

    the_one = data.get('the_one_thing', '')
    if isinstance(the_one, str) and len(the_one) < 5:
        R.error('FIELD_TOO_SHORT', f'the_one_thing must be at least 5 chars (got "{the_one[:30]}")')

    priorities = data.get('priorities')
    if not isinstance(priorities, list) or len(priorities) < 1:
        R.error('ARRAY_TOO_SHORT', 'priorities must have at least 1 item')
    elif isinstance(priorities, list):
        for idx, pr in enumerate(priorities):
            if not isinstance(pr, dict): continue
            for req in ['rank', 'item', 'goal_ref']:
                if req not in pr:
                    R.error('MISSING_FIELD', f'priorities[{idx}].{req} is required but missing')
            item = pr.get('item', '')
            if isinstance(item, str) and len(item) < 5:
                R.error('FIELD_TOO_SHORT', f'priorities[{idx}].item must be at least 5 chars')

    for fp, snippet in check_placeholders(data):
        R.warn('PLACEHOLDER_DATA', f'{fp} contains placeholder text: "{snippet[:60]}"')

    lu = data.get('last_updated')
    if is_stale(lu, 14):
        R.warn('STALE_FOCUS', f'last_updated is {"null" if lu is None else lu} — threshold: 14 days')

# ── calibration/metrics.yaml ──────────────────────────────────────────────────

def validate_metrics():
    path = p('calibration/metrics.yaml')
    R.begin('calibration/metrics.yaml')
    if not os.path.exists(path):
        R.info('SKIPPED', 'calibration/metrics.yaml not found — skipping'); return

    data, err = load_yaml(path)
    if err or data is None:
        R.error('PARSE_ERROR', f'Could not parse YAML: {err}'); return

    for req in ['signal_volume', 'divergence_volume', 'module_load_frequency', 'learning_log']:
        if req not in data or data[req] is None:
            R.error('MISSING_FIELD', f'Required field "{req}" is missing')

    R.info('SCHEMA_VERSION', 'calibration/metrics.yaml present')

    lu = data.get('last_updated')
    if is_stale(lu, 60):
        R.warn('STALE_MODULE', f'last_updated is {"null" if lu is None else lu} — threshold: 60 days')

# ── network/circles.yaml ──────────────────────────────────────────────────────

def validate_circles():
    path = p('network/circles.yaml')
    R.begin('network/circles.yaml')
    if not os.path.exists(path):
        R.error('MISSING_FILE', 'network/circles.yaml not found'); return

    data, err = load_yaml(path)
    if err or data is None:
        R.error('PARSE_ERROR', f'Could not parse YAML: {err}'); return

    if data.get('_schema') != 'circles':
        R.error('SCHEMA_MISMATCH', f'_schema should be "circles"')
    R.info('SCHEMA_VERSION', f'_schema=circles _version={data.get("_version")}')

    TOUCH = {'personal', 'professional', 'either'}
    circles = data.get('circles')
    if not isinstance(circles, list):
        R.error('SCHEMA_ERROR', 'circles must be an array')
    else:
        for idx, c in enumerate(circles):
            if not isinstance(c, dict): continue
            for req in ['id', 'label', 'description', 'criteria', 'touchpoint_type', 'current_count']:
                if req not in c or c[req] is None:
                    R.error('MISSING_FIELD', f'circles[{idx}].{req} is required but missing')
            tt = c.get('touchpoint_type')
            if tt is not None and tt not in TOUCH:
                R.error('INVALID_ENUM', f'circles[{idx}].touchpoint_type "{tt}" must be personal|professional|either')
            crit = c.get('criteria')
            if isinstance(crit, list) and len(crit) < 1:
                R.error('ARRAY_TOO_SHORT', f'circles[{idx}].criteria must have at least 1 item')

    lu = data.get('last_updated')
    if is_stale(lu, 60):
        R.warn('STALE_MODULE', f'last_updated is {"null" if lu is None else lu} — threshold: 60 days')

# ── network/rhythms.yaml ──────────────────────────────────────────────────────

def validate_rhythms():
    path = p('network/rhythms.yaml')
    R.begin('network/rhythms.yaml')
    if not os.path.exists(path):
        R.error('MISSING_FILE', 'network/rhythms.yaml not found'); return

    data, err = load_yaml(path)
    if err or data is None:
        R.error('PARSE_ERROR', f'Could not parse YAML: {err}'); return

    if data.get('_schema') != 'rhythms':
        R.error('SCHEMA_MISMATCH', f'_schema should be "rhythms"')
    R.info('SCHEMA_VERSION', f'_schema=rhythms _version={data.get("_version")}')

    rhythms = data.get('rhythms')
    if not isinstance(rhythms, list):
        R.error('SCHEMA_ERROR', 'rhythms must be an array')
    else:
        for idx, r in enumerate(rhythms):
            if not isinstance(r, dict): continue
            for req in ['circle', 'label', 'target_frequency', 'max_gap', 'touchpoint_types']:
                if req not in r:
                    R.error('MISSING_FIELD', f'rhythms[{idx}].{req} is required but missing')
            tps = r.get('touchpoint_types')
            if isinstance(tps, list) and len(tps) < 1:
                R.error('ARRAY_TOO_SHORT', f'rhythms[{idx}].touchpoint_types must have at least 1 item')

    lu = data.get('last_updated')
    if is_stale(lu, 60):
        R.warn('STALE_MODULE', f'last_updated is {"null" if lu is None else lu} — threshold: 60 days')

# ── JSONL validation ──────────────────────────────────────────────────────────

JSONL_SPECS = {
    'knowledge/learning.jsonl': {
        'required': ['date', 'type', 'source', 'insight', 'context', 'confidence'],
        'enums': {
            'type':       ['correction', 'preference', 'pattern', 'insight'],
            'source':     ['experience', 'conversation', 'reading', 'observation'],
            'confidence': ['high', 'medium', 'low'],
        },
        'minLength': {'insight': 10},
        'arrays':    {},
    },
    'memory/decisions.jsonl': {
        'required': ['date', 'decision', 'context', 'options_considered', 'reasoning'],
        'enums':    {},
        'minLength': {'decision': 10, 'reasoning': 10},
        'arrays':    {'options_considered': 1},
    },
    'memory/failures.jsonl': {
        'required': ['date', 'what_failed', 'context', 'what_i_did', 'what_went_wrong',
                     'warning_signs_missed', 'what_id_do_differently', 'emotional_weight', 'lesson'],
        'enums':    {'emotional_weight': ['high', 'medium', 'low']},
        'minLength': {},
        'arrays':    {},
    },
    'memory/experiences.jsonl': {
        'required': ['date', 'title', 'what_happened', 'why_it_matters',
                     'how_it_changed_you', 'emotional_weight'],
        'enums':    {'emotional_weight': ['high', 'medium', 'low']},
        'minLength': {},
        'arrays':    {},
    },
    'signals/observations.jsonl': {
        'required': ['date', 'context', 'signals'],
        'enums':    {},
        'minLength': {},
        'arrays':    {'signals': 1},
    },
    'calibration/divergence.jsonl': {
        'required': ['date', 'type', 'source', 'signal', 'brained_ref', 'tension', 'disposition'],
        'enums': {
            'type':        ['values', 'identity', 'operational', 'relational'],
            'source':      ['signals_override', 'signals_friction', 'signals_pattern',
                            'signals_inference', 'other'],
            'disposition': ['CONFIRM', 'CANDIDATE', 'WARNING', 'DEFER', 'INCORPORATED', 'REJECTED'],
        },
        'minLength': {},
        'arrays':    {},
    },
}

def validate_jsonl(rel_path):
    path = p(rel_path)
    R.begin(rel_path)
    if not os.path.exists(path):
        R.info('SKIPPED', f'{rel_path} not found — skipping'); return

    spec = JSONL_SPECS.get(rel_path, {})
    required   = spec.get('required', [])
    enums      = spec.get('enums', {})
    min_len    = spec.get('minLength', {})
    min_arr    = spec.get('arrays', {})

    # File size
    size = os.path.getsize(path)
    if size > 50 * 1024:
        R.info('FILE_SIZE', f'{size // 1024}KB — approaching unwieldy (threshold: 50KB)')

    entries = []; parse_errors = []
    with open(path) as f:
        for ln_num, raw in enumerate(f, 1):
            raw = raw.strip()
            if not raw: continue
            try:
                entries.append((ln_num, json.loads(raw)))
            except json.JSONDecodeError as e:
                parse_errors.append((ln_num, str(e)))

    for ln_num, err in parse_errors:
        R.error('PARSE_ERROR', f'line {ln_num}: invalid JSON — {err}')

    real = [(ln, e) for ln, e in entries if not e.get('_example')]
    example_count = len(entries) - len(real)
    R.info('ENTRY_COUNT', f'{len(real)} entr{"y" if len(real)==1 else "ies"}'
                          f'{f" ({example_count} example/template lines skipped)" if example_count else ""}')

    for ln_num, entry in real:
        for req in required:
            if req not in entry or entry[req] is None:
                R.error('MISSING_FIELD', f'line {ln_num}: required field "{req}" is missing or null')
        for field, allowed in enums.items():
            val = entry.get(field)
            if val is not None and val not in allowed:
                R.error('INVALID_ENUM', f'line {ln_num}: {field}="{val}" must be one of {allowed}')
        for field, ml in min_len.items():
            val = entry.get(field)
            if isinstance(val, str) and len(val) < ml:
                R.error('FIELD_TOO_SHORT', f'line {ln_num}: {field} must be at least {ml} chars')
        for field, mc in min_arr.items():
            val = entry.get(field)
            if val is not None and (not isinstance(val, list) or len(val) < mc):
                R.error('ARRAY_TOO_SHORT', f'line {ln_num}: {field} must have at least {mc} item(s)')
        for fp, snippet in check_placeholders(entry):
            R.warn('PLACEHOLDER_DATA', f'line {ln_num}: {fp} contains placeholder text: "{snippet[:60]}"')

# ── BRAIN.md ──────────────────────────────────────────────────────────────────

def validate_brain():
    path = p('BRAIN.md')
    R.begin('BRAIN.md')
    if not os.path.exists(path):
        R.error('MISSING_FILE', 'BRAIN.md not found'); return

    with open(path) as f:
        content = f.read()

    m = re.search(r'STATUS:\s*(\S+)', content)
    if not m:
        R.error('MISSING_FIELD', 'BRAIN.md has no "STATUS:" line')
    else:
        status = m.group(1).rstrip('#').strip()
        VALID = {'CURRENT', 'PARTIAL', 'STALE'}
        if status not in VALID:
            R.error('INVALID_ENUM', f'STATUS: "{status}" must be CURRENT|PARTIAL|STALE')
        else:
            R.info('STATUS', f'BRAIN.md STATUS: {status}')

# ── Run all ────────────────────────────────────────────────────────────────────

validate_values()
validate_heuristics()
validate_goals()
validate_current_focus()
validate_metrics()
validate_circles()
validate_rhythms()
for rel in JSONL_SPECS:
    validate_jsonl(rel)
validate_brain()

# ── Output ─────────────────────────────────────────────────────────────────────

summary = R.summary()

e, w, n = summary['errors'], summary['warns'], summary['infos']

if JSON_OUT:
    print(json.dumps({'date': str(TODAY), 'files': R.files, 'summary': summary}, indent=2))
elif QUIET and e == 0 and w == 0:
    pass  # Clean run in quiet mode — print nothing (lets pre-commit hook detect clean state)
else:
    EC = '\033[0;31m'; WC = '\033[0;33m'; GC = '\033[0;32m'; BC = '\033[0;34m'; NC = '\033[0m'

    if not QUIET:
        print(f'\n{"═"*38}')
        print(f'  AMAI Validation Report')
        print(f'  Date: {TODAY}')
        print(f'{"═"*38}')

    for fdata in R.files:
        issues   = fdata['issues']
        ferrors  = [i for i in issues if i['severity'] == 'ERROR']
        fwarns   = [i for i in issues if i['severity'] == 'WARN']
        finfos   = [i for i in issues if i['severity'] == 'INFO']

        # In quiet mode, skip files with no ERROR/WARN
        if QUIET and not ferrors and not fwarns:
            continue

        # Skip silently-skipped files in quiet mode
        if QUIET and len(issues) == 1 and issues[0].get('code') == 'SKIPPED':
            continue

        print(f'\n{fdata["path"]}')

        if len(issues) == 1 and issues[0].get('code') == 'SKIPPED':
            if not QUIET:
                print(f'  {BC}ℹ️  Not found — skipping{NC}')
            continue

        if not ferrors:
            print(f'  {GC}✅ Schema: valid{NC}')
            if not fwarns and not QUIET:
                print(f'  {GC}✅ All fields populated{NC}')

        for i in ferrors:
            print(f'  {EC}❌ ERROR:{i["code"]}{NC} — {i["message"]}')
        for i in fwarns:
            print(f'  {WC}⚠️  WARN:{i["code"]}{NC} — {i["message"]}')
        if not QUIET:
            for i in finfos:
                if i.get('code') != 'SKIPPED':
                    print(f'  {BC}ℹ️  INFO:{i["code"]}{NC} — {i["message"]}')

    print(f'\n{"─"*38}')
    if e == 0 and w == 0:
        if not QUIET:
            print(f'{GC}✅ Summary: 0 ERROR, 0 WARN, {n} INFO — all clean{NC}')
    elif e == 0:
        print(f'{WC}⚠️  Summary: 0 ERROR, {w} WARN, {n} INFO{NC}')
    else:
        print(f'{EC}❌ Summary: {e} ERROR, {w} WARN, {n} INFO{NC}')
    print(f'{"─"*38}\n')

# Write summary for bash exit code
if SUMFILE:
    with open(SUMFILE, 'w') as f:
        json.dump(summary, f)
PYEOF

# ── Exit code ──────────────────────────────────────────────────────────────────
if [[ -f "$SUMMARY_FILE" ]]; then
  ERRORS=$(python3 -c "import json; d=json.load(open('$SUMMARY_FILE')); print(d['errors'])" 2>/dev/null || echo "0")
else
  ERRORS=0
fi

if [[ "$ERRORS" -gt 0 ]]; then
  exit 1
fi
exit 0
