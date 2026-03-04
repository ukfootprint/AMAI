#!/usr/bin/env bash
# AMAI Audit Log — append a structured entry to changelog_audit.jsonl
#
# Usage:
#   bash scripts/audit_log.sh \
#     --actor ai \
#     --actor-id onboarding \
#     --module "identity/values" \
#     --category create \
#     --description "Populated core values via Stage 1 onboarding" \
#     --files "identity/values.yaml"
#
# Multiple files: --files "identity/values.yaml,identity/heuristics.yaml"
#
# Actor types: human | ai | system
# Categories:  create | update | delete | prune | calibrate | onboard | export
#
# Requires: python3 (for UUID generation and JSON formatting)
# No pip packages.

AMAI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUDIT_FILE="$AMAI_ROOT/changelog_audit.jsonl"

# ── Parse arguments ──────────────────────────────────────────────────────────
ACTOR=""
ACTOR_ID=""
MODULE=""
CATEGORY=""
DESCRIPTION=""
FILES=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --actor)       ACTOR="$2";       shift 2 ;;
    --actor-id)    ACTOR_ID="$2";    shift 2 ;;
    --module)      MODULE="$2";      shift 2 ;;
    --category)    CATEGORY="$2";    shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --files)       FILES="$2";       shift 2 ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Usage: bash scripts/audit_log.sh --actor ai --actor-id NAME --module MOD --category CAT --description DESC --files FILE1,FILE2" >&2
      exit 2
      ;;
  esac
done

# ── Validate required fields ─────────────────────────────────────────────────
MISSING=""
[[ -z "$ACTOR" ]]       && MISSING="$MISSING --actor"
[[ -z "$ACTOR_ID" ]]    && MISSING="$MISSING --actor-id"
[[ -z "$MODULE" ]]      && MISSING="$MISSING --module"
[[ -z "$CATEGORY" ]]    && MISSING="$MISSING --category"
[[ -z "$DESCRIPTION" ]] && MISSING="$MISSING --description"
[[ -z "$FILES" ]]       && MISSING="$MISSING --files"

if [[ -n "$MISSING" ]]; then
  echo "Missing required arguments:$MISSING" >&2
  exit 2
fi

# ── Validate enums ───────────────────────────────────────────────────────────
case "$ACTOR" in
  human|ai|system) ;;
  *) echo "Invalid --actor: $ACTOR (must be human|ai|system)" >&2; exit 2 ;;
esac

case "$CATEGORY" in
  create|update|delete|prune|calibrate|onboard|export) ;;
  *) echo "Invalid --category: $CATEGORY (must be create|update|delete|prune|calibrate|onboard|export)" >&2; exit 2 ;;
esac

# ── Generate entry and append ────────────────────────────────────────────────
python3 -c "
import json, uuid
from datetime import datetime, timezone

files_str = '''$FILES'''
files_list = [f.strip() for f in files_str.split(',') if f.strip()]

entry = {
    'uid': str(uuid.uuid4()),
    'timestamp': datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ'),
    'actor': '$ACTOR',
    'actor_id': '$ACTOR_ID',
    'module': '$MODULE',
    'category': '$CATEGORY',
    'description': '''$DESCRIPTION'''.strip(),
    'files_changed': files_list
}

with open('$AUDIT_FILE', 'a') as f:
    f.write(json.dumps(entry, ensure_ascii=False) + '\n')

print(f'Logged: {entry[\"category\"]} → {entry[\"module\"]} ({entry[\"actor_id\"]})')
" 2>/dev/null

exit 0
