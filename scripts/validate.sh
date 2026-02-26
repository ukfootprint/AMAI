#!/usr/bin/env bash
# AMAI Validation Script
# Run from your AMAI root folder: bash scripts/validate.sh
# Checks: required fields in YAML files, date format validity, JSONL parse integrity
# No dependencies beyond bash, grep, python3 (standard on macOS/Linux)

set -euo pipefail

AMAI_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0
WARNINGS=0

red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
info()   { printf '  %s\n' "$*"; }

fail()  { red "  ✗ $*"; ((ERRORS++)) || true; }
warn()  { yellow "  ⚠ $*"; ((WARNINGS++)) || true; }
pass()  { green "  ✓ $*"; }

echo ""
echo "AMAI Validation — $(date '+%Y-%m-%d')"
echo "Root: $AMAI_ROOT"
echo "────────────────────────────────────────"

# ── 1. YAML REQUIRED FIELDS ──────────────────────────────────────────────────

echo ""
echo "1. YAML required fields"

check_yaml_field() {
  local file="$1" field="$2"
  if grep -q "^${field}:" "$file" 2>/dev/null; then
    pass "$field present in $(basename "$file")"
  else
    fail "$field missing from $(basename "$(dirname "$file")")/$(basename "$file")"
  fi
}

check_yaml_not_null() {
  local file="$1" field="$2" threshold_days="${3:-60}"
  local value
  value=$(grep "^${field}:" "$file" 2>/dev/null | sed 's/.*: *//' | sed 's/ *#.*//' | tr -d '"' | tr -d "'" || true)
  if [[ -z "$value" || "$value" == "null" ]]; then
    warn "$field is null in $(basename "$(dirname "$file")")/$(basename "$file") — may be stale"
  else
    # Check if date is older than threshold
    if python3 -c "
from datetime import date, timedelta
import sys
try:
    d = date.fromisoformat('${value}')
    threshold = date.today() - timedelta(days=${threshold_days})
    sys.exit(0 if d >= threshold else 1)
except Exception:
    sys.exit(0)
" 2>/dev/null; then
      pass "$field up to date in $(basename "$(dirname "$file")")/$(basename "$file")"
    else
      warn "$field is older than ${threshold_days} days in $(basename "$(dirname "$file")")/$(basename "$file") ($value)"
    fi
  fi
}

# identity/values.yaml
F="$AMAI_ROOT/identity/values.yaml"
if [[ -f "$F" ]]; then
  check_yaml_field "$F" "_schema"
  check_yaml_field "$F" "_version"
  check_yaml_field "$F" "core_values"
  check_yaml_field "$F" "ethical_red_lines"
  check_yaml_field "$F" "last_updated"
  check_yaml_not_null "$F" "last_updated" 60
else fail "identity/values.yaml not found"; fi

# identity/heuristics.yaml
F="$AMAI_ROOT/identity/heuristics.yaml"
if [[ -f "$F" ]]; then
  check_yaml_field "$F" "_schema"
  check_yaml_field "$F" "_version"
  check_yaml_field "$F" "universal"
  check_yaml_field "$F" "last_updated"
  check_yaml_not_null "$F" "last_updated" 60
else fail "identity/heuristics.yaml not found"; fi

# goals/goals.yaml
F="$AMAI_ROOT/goals/goals.yaml"
if [[ -f "$F" ]]; then
  check_yaml_field "$F" "_schema"
  check_yaml_field "$F" "goals"
  check_yaml_field "$F" "last_updated"
  check_yaml_not_null "$F" "last_updated" 60
else fail "goals/goals.yaml not found"; fi

# goals/current_focus.yaml
F="$AMAI_ROOT/goals/current_focus.yaml"
if [[ -f "$F" ]]; then
  check_yaml_field "$F" "week_of"
  check_yaml_field "$F" "last_updated"
  check_yaml_field "$F" "the_one_thing"
  check_yaml_not_null "$F" "last_updated" 7
else fail "goals/current_focus.yaml not found"; fi

# network/circles.yaml
F="$AMAI_ROOT/network/circles.yaml"
if [[ -f "$F" ]]; then
  check_yaml_field "$F" "_schema"
  check_yaml_field "$F" "circles"
  check_yaml_field "$F" "last_updated"
else fail "network/circles.yaml not found"; fi

# network/rhythms.yaml
F="$AMAI_ROOT/network/rhythms.yaml"
if [[ -f "$F" ]]; then
  check_yaml_field "$F" "_schema"
  check_yaml_field "$F" "rhythms"
  check_yaml_field "$F" "last_updated"
else fail "network/rhythms.yaml not found"; fi

# BRAIN.md STATUS field
F="$AMAI_ROOT/BRAIN.md"
if [[ -f "$F" ]]; then
  if grep -q "STATUS:" "$F"; then
    pass "STATUS field present in BRAIN.md"
  else
    fail "STATUS field missing from BRAIN.md"
  fi
else fail "BRAIN.md not found"; fi

# ── 2. DATE FORMAT VALIDATION ─────────────────────────────────────────────────

echo ""
echo "2. Date format validation (YYYY-MM-DD)"

validate_dates_in_jsonl() {
  local file="$1"
  local bad_dates
  bad_dates=$(python3 -c "
import json, sys, re
bad = []
with open('$file') as f:
    for i, line in enumerate(f, 1):
        line = line.strip()
        if not line or line.startswith('//'):
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            continue
        # Skip example/template entries
        if obj.get('_example'):
            continue
        for k, v in obj.items():
            if 'date' in k.lower() and isinstance(v, str) and v not in ('null', ''):
                if not re.match(r'^\d{4}-\d{2}-\d{2}$', v):
                    bad.append(f'line {i}: {k}={v}')
print('\n'.join(bad))
" 2>/dev/null || true)
  if [[ -z "$bad_dates" ]]; then
    pass "$(basename "$file") — dates valid"
  else
    while IFS= read -r line; do
      fail "$(basename "$(dirname "$file")")/$(basename "$file"): bad date format — $line"
    done <<< "$bad_dates"
  fi
}

for jsonl_file in \
  "$AMAI_ROOT/network/contacts.jsonl" \
  "$AMAI_ROOT/network/interactions.jsonl" \
  "$AMAI_ROOT/memory/decisions.jsonl" \
  "$AMAI_ROOT/memory/failures.jsonl" \
  "$AMAI_ROOT/memory/experiences.jsonl" \
  "$AMAI_ROOT/knowledge/learning.jsonl" \
  "$AMAI_ROOT/signals/observations.jsonl" \
  "$AMAI_ROOT/calibration/divergence.jsonl"; do
  if [[ -f "$jsonl_file" ]]; then
    validate_dates_in_jsonl "$jsonl_file"
  else
    info "$(basename "$jsonl_file") not present — skipping"
  fi
done

# ── 3. JSONL PARSE INTEGRITY ──────────────────────────────────────────────────

echo ""
echo "3. JSONL parse integrity"

validate_jsonl() {
  local file="$1"
  local result
  result=$(python3 -c "
import json, sys
errors = []
with open('$file') as f:
    for i, line in enumerate(f, 1):
        line = line.strip()
        if not line:
            continue
        try:
            json.loads(line)
        except json.JSONDecodeError as e:
            errors.append(f'line {i}: {e}')
if errors:
    print('\n'.join(errors))
    sys.exit(1)
" 2>&1 || true)
  if [[ -z "$result" ]]; then
    pass "$(basename "$(dirname "$file")")/$(basename "$file") — valid JSON on all lines"
  else
    while IFS= read -r line; do
      fail "$(basename "$(dirname "$file")")/$(basename "$file"): $line"
    done <<< "$result"
  fi
}

for jsonl_file in \
  "$AMAI_ROOT/network/contacts.jsonl" \
  "$AMAI_ROOT/network/organisations.jsonl" \
  "$AMAI_ROOT/network/interactions.jsonl" \
  "$AMAI_ROOT/memory/decisions.jsonl" \
  "$AMAI_ROOT/memory/failures.jsonl" \
  "$AMAI_ROOT/memory/experiences.jsonl" \
  "$AMAI_ROOT/knowledge/learning.jsonl" \
  "$AMAI_ROOT/signals/observations.jsonl" \
  "$AMAI_ROOT/calibration/divergence.jsonl"; do
  if [[ -f "$jsonl_file" ]]; then
    validate_jsonl "$jsonl_file"
  else
    info "$(basename "$jsonl_file") not present — skipping"
  fi
done

# ── 4. SUMMARY ────────────────────────────────────────────────────────────────

echo ""
echo "────────────────────────────────────────"
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
  green "All checks passed."
elif [[ $ERRORS -eq 0 ]]; then
  yellow "Passed with $WARNINGS warning(s). Review warnings before your next calibration session."
else
  red "$ERRORS error(s), $WARNINGS warning(s). Fix errors before relying on AMAI context."
  exit 1
fi
echo ""
