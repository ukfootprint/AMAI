#!/usr/bin/env bash
# scripts/usage_report.sh — AMAI Module Usage Report
# Reads calibration/metrics.yaml → module_load_frequency and summarises usage.
# Usage: bash scripts/usage_report.sh [--json] [--threshold N]

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

JSON_MODE=false; THRESHOLD=5
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON_MODE=true; shift ;;
    --threshold) THRESHOLD="${2:-5}"; shift 2 ;;
    *) echo "Usage: bash scripts/usage_report.sh [--json] [--threshold N]" >&2; exit 2 ;;
  esac
done

python3 - "$REPO_ROOT" "$JSON_MODE" "$THRESHOLD" << 'PYEOF'
import sys, json, datetime
from pathlib import Path

REPO_ROOT = Path(sys.argv[1])
JSON_MODE = sys.argv[2].lower() == "true"
THRESHOLD = int(sys.argv[3])

def load_yaml(path):
    try:
        import yaml
        with open(path) as f: return yaml.safe_load(f)
    except Exception: return None

data = load_yaml(REPO_ROOT / "calibration/metrics.yaml") or {}
freq = {k: v for k, v in data.get("module_load_frequency", {}).items() if isinstance(v, int)}
dates = [str(r["date"]) for r in data.get("review_history", [])
         if isinstance(r, dict) and r.get("date") and r["date"] != "null"]

today = datetime.date.today().isoformat()
period = dates[0] if dates else "no reviews yet"

def status(n):
    if n == 0:        return "Unused",   True
    if n < THRESHOLD: return "Low",      False
    if n < 20:        return "Moderate", False
    return "Active", False

if JSON_MODE:
    rows = [{"module": m, "loads": c, "status": status(c)[0]} for m, c in sorted(freq.items())]
    print(json.dumps({"generated": today, "period_start": period,
                      "threshold_low": THRESHOLD, "modules": rows,
                      "unused": [r["module"] for r in rows if r["status"] == "Unused"]}, indent=2))
    sys.exit(0)

print(f"AMAI Module Usage Report\nGenerated: {today}\nPeriod start: {period}\nLow threshold: < {THRESHOLD} loads\n")

if not freq:
    print("No data in calibration/metrics.yaml → module_load_frequency.")
    print("Data is collected when modules are loaded via the context-loader skill.")
    sys.exit(0)

w = max(len(k) for k in freq) + 2
print(f"{'Module':<{w}} {'Loads':>6}    Status"); print("─" * (w + 22))

unused = []
for m, c in sorted(freq.items()):
    label, flag = status(c)
    print(f"{m:<{w}} {c:>6}    {label}{' ⚠️' if flag else ''}")
    if flag: unused.append(m)

print()
if unused:
    print(f"⚠️  {len(unused)} unused module(s): {', '.join(unused)}")
    print("   Candidates for pruning review — run /amai:prune to investigate.")
else:
    print("✓  All modules have been loaded at least once.")
PYEOF
