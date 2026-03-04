#!/usr/bin/env bash
# scripts/usage_report.sh — AMAI Module Usage Report
# Reads calibration/metrics.yaml → module_load_frequency and summarises usage.
# Also reads calibration/entry_references.jsonl for per-entry reference counts.
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
import sys, json, datetime, collections
from pathlib import Path

REPO_ROOT = Path(sys.argv[1])
JSON_MODE = sys.argv[2].lower() == "true"
THRESHOLD = int(sys.argv[3])

def load_yaml(path):
    try:
        import yaml
        with open(path) as f: return yaml.safe_load(f)
    except Exception: return None

def read_jsonl(path):
    entries = []
    try:
        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line: continue
                try:
                    obj = json.loads(line)
                    if not obj.get('_example'):
                        entries.append(obj)
                except json.JSONDecodeError:
                    pass
    except FileNotFoundError:
        pass
    return entries

def get_all_declared_ids(repo_root):
    """Collect all declared entry ids from values, heuristics, and beliefs."""
    declared = {}  # id -> (entry_type, source_file)

    # identity/values.yaml — core_values and ethical_red_lines
    vdata = load_yaml(repo_root / "identity/values.yaml") or {}
    for cv in vdata.get("core_values", []):
        if isinstance(cv, dict) and cv.get("id"):
            declared[cv["id"]] = ("value", "identity/values.yaml")
    for rl in vdata.get("ethical_red_lines", []):
        if isinstance(rl, dict) and rl.get("id"):
            declared[rl["id"]] = ("red_line", "identity/values.yaml")

    # identity/heuristics.yaml
    hdata = load_yaml(repo_root / "identity/heuristics.yaml") or {}
    for section in ("universal", "domain", "commercial", "people"):
        for h in hdata.get(section, []):
            if isinstance(h, dict) and h.get("id"):
                declared[h["id"]] = ("heuristic", "identity/heuristics.yaml")

    # identity/beliefs.yaml
    bdata = load_yaml(repo_root / "identity/beliefs.yaml") or {}
    for b in bdata.get("beliefs", []):
        if isinstance(b, dict) and b.get("id"):
            declared[b["id"]] = ("belief", "identity/beliefs.yaml")

    return declared

# ── Module load frequency ──────────────────────────────────────────────────────
data = load_yaml(REPO_ROOT / "calibration/metrics.yaml") or {}
freq = {k: v for k, v in data.get("module_load_frequency", {}).items() if isinstance(v, int)}
dates = [str(r["date"]) for r in data.get("review_history", [])
         if isinstance(r, dict) and r.get("date") and r["date"] != "null"]

today = datetime.date.today().isoformat()
period = dates[0] if dates else "no reviews yet"

# ── Entry reference data ───────────────────────────────────────────────────────
ref_entries = read_jsonl(REPO_ROOT / "calibration/entry_references.jsonl")
ref_counts = collections.Counter(e["entry_id"] for e in ref_entries if e.get("entry_id"))
ref_last   = {}
for e in ref_entries:
    eid = e.get("entry_id")
    if eid and e.get("date"):
        if eid not in ref_last or e["date"] > ref_last[eid]:
            ref_last[eid] = e["date"]

all_ref_dates = sorted(e["date"] for e in ref_entries if e.get("date"))
ref_period_start = all_ref_dates[0] if all_ref_dates else None
declared_ids = get_all_declared_ids(REPO_ROOT)

def status(n):
    if n == 0:        return "Unused",   True
    if n < THRESHOLD: return "Low",      False
    if n < 20:        return "Moderate", False
    return "Active", False

if JSON_MODE:
    rows = [{"module": m, "loads": c, "status": status(c)[0]} for m, c in sorted(freq.items())]
    ref_rows = [
        {"entry_id": eid,
         "entry_type": declared_ids.get(eid, ("unknown",))[0],
         "references": ref_counts.get(eid, 0),
         "last_referenced": ref_last.get(eid)}
        for eid in sorted(set(list(ref_counts.keys()) + list(declared_ids.keys())))
    ]
    zero_ref = [eid for eid in sorted(declared_ids) if ref_counts.get(eid, 0) == 0]
    print(json.dumps({
        "generated": today,
        "period_start": period,
        "threshold_low": THRESHOLD,
        "modules": rows,
        "unused": [r["module"] for r in rows if r["status"] == "Unused"],
        "entry_references": {
            "period_start": ref_period_start,
            "total_events": len(ref_entries),
            "entries": ref_rows,
            "zero_references": zero_ref,
        }
    }, indent=2))
    sys.exit(0)

# ── Module load frequency table ────────────────────────────────────────────────
print(f"AMAI Module Usage Report\nGenerated: {today}\nPeriod start: {period}\nLow threshold: < {THRESHOLD} loads\n")

if not freq:
    print("No data in calibration/metrics.yaml → module_load_frequency.")
    print("Data is collected when modules are loaded via the context-loader skill.")
else:
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

# ── Entry Reference Summary ────────────────────────────────────────────────────
print()
print("Entry Reference Summary")
if ref_period_start:
    print(f"Period: {ref_period_start} to {today}")
else:
    print("Period: no entries yet")
print()

if not ref_entries:
    print("  No entry references recorded yet.")
    print("  References accumulate automatically as conscience alerts, critiques,")
    print("  calibrations, and goal updates run.")
else:
    all_referenced_ids = sorted(ref_counts.keys())
    w_id   = max((len(eid) for eid in all_referenced_ids), default=20) + 2
    w_type = 12
    print(f"  {'Entry ID':<{w_id}} {'Type':<{w_type}} {'References':>10}  {'Last Referenced'}")
    print("  " + "─" * (w_id + w_type + 28))

    for eid in all_referenced_ids:
        etype = declared_ids.get(eid, ("unknown",))[0]
        count = ref_counts[eid]
        last  = ref_last.get(eid, "—")
        print(f"  {eid:<{w_id}} {etype:<{w_type}} {count:>10}  {last}")

    print()
    print(f"  Total entries tracked: {len(ref_counts)}")

    # Zero-references from declared entries
    zero_ref = [eid for eid in sorted(declared_ids) if ref_counts.get(eid, 0) == 0]
    if zero_ref:
        print(f"  Entries with 0 references ({len(zero_ref)}): {', '.join(zero_ref)}")
    else:
        print("  All declared entries have been referenced at least once.")

PYEOF
