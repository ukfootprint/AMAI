#!/usr/bin/env bash
# scripts/eval_quality.sh — AMAI Quality Evaluation Generator
# Generates a 5-task evaluation prompt from live AMAI data for pre/post pruning comparison.
# Usage: bash scripts/eval_quality.sh [--output PATH] [--tasks 1,2,3,4,5] [--format prompt|json]

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

OUTPUT=""; TASKS="1,2,3,4,5"; FORMAT="prompt"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) OUTPUT="${2:-}"; shift 2 ;;
    --tasks)  TASKS="${2:-1,2,3,4,5}"; shift 2 ;;
    --format) FORMAT="${2:-prompt}"; shift 2 ;;
    *) echo "Usage: bash scripts/eval_quality.sh [--output PATH] [--tasks 1,2,3,4,5] [--format prompt|json]" >&2; exit 2 ;;
  esac
done

python3 - "$REPO_ROOT" "$OUTPUT" "$TASKS" "$FORMAT" << 'PYEOF'
import sys, json, datetime, re
from pathlib import Path

ROOT, OUT_ARG, T_ARG, FMT = Path(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4]
today = datetime.date.today().isoformat()
task_nums = [int(x) for x in T_ARG.split(",") if x.strip().isdigit()]

def rd(p):
    try: return (ROOT / p).read_text()
    except: return ""

def yval(txt, key, default="[not set]"):
    m = re.search(rf'^{key}:\s*(.+)$', txt, re.MULTILINE)
    return m.group(1).strip().strip('"\'') if m else default

vy = rd("identity/values.yaml"); hy = rd("identity/heuristics.yaml")
fy = rd("goals/current_focus.yaml"); dl = rd("knowledge/domain_landscape.md")
bl = rd("identity/beliefs.yaml")

one_thing = yval(fy, "the_one_thing"); week_of = yval(fy, "week_of", "not set")

heur = "integrity_test: would I be comfortable if this decision were public?"
for m in re.finditer(r'rule:\s*[">]?\s*(.*?)(?:\n|")', hy):
    rv = m.group(1).strip().rstrip('">')
    if rv and not rv.startswith("[") and len(rv) > 20: heur = rv[:80]; break

val_id = "integrity"
for m in re.finditer(r'^\s+- id:\s+(\w+)', vy, re.MULTILINE): val_id = m.group(1); break

domain = "your core domain"
for ln in dl.split("\n"):
    ln = ln.strip().lstrip("#").strip()
    if len(ln) > 15 and not ln.startswith(("_", "<!--", "*")): domain = ln[:70]; break

belief_ctx = "a high-stakes strategy that may conflict with a strongly-held belief"
for m in re.finditer(r'statement:\s*(.+)', bl):
    s = m.group(1).strip().strip('"')
    if s and not s.startswith("["): belief_ctx = f'whether: "{s[:60]}"'; break

RT = "Self-rating — confidence this reflects the user's values and style: HIGH / MEDIUM / LOW. One sentence why."

TASK_DEF = {
  1: ("Client Capabilities Response", "values, red lines, voice",
      f'Draft a one-paragraph response to a new client asking:\n"Tell me about your approach and what I can expect from working with you."\n\nContext loaded: identity/values.yaml (top value: {val_id}), identity/voice.md\n\n{RT}'),
  2: ("Weekly Priorities", "current_focus accuracy",
      f'What are your top 3 priorities this week and why?\n\nContext loaded: goals/current_focus.yaml (week_of: {week_of})\nThe one thing: {one_thing}\n\nNote: If priorities show placeholder text, rate LOW and say so.\n{RT}'),
  3: ("Heuristics Under Pressure", "heuristics, values under pressure",
      f'A colleague says: "Cut corners on quality to meet this deadline — the client won\'t notice."\n\nHow do you respond?\n\nContext loaded: identity/heuristics.yaml, identity/values.yaml\nKey heuristic to apply: {heur}\n\n{RT}'),
  4: ("Domain Knowledge Summary", "knowledge loading, domain accuracy",
      f'Summarise your approach to and understanding of: {domain}\n\nContext loaded: knowledge/domain_landscape.md, knowledge/frameworks.md\n\n{RT}'),
  5: ("Decision Framework", "heuristics, beliefs, decision-making style",
      f'You are deciding {belief_ctx}.\n\nWalk through your decision-making process step by step.\n\nContext loaded: identity/heuristics.yaml, identity/beliefs.yaml\n\n{RT}')
}

if FMT == "json":
    print(json.dumps({"generated": today, "tasks": [
        {"task": n, "title": TASK_DEF[n][0], "tests": TASK_DEF[n][1], "prompt": TASK_DEF[n][2]}
        for n in task_nums if n in TASK_DEF]}, indent=2))
    sys.exit(0)

lines = [
    "# AMAI Quality Evaluation",
    f"**Generated:** {today}  |  **Tasks:** {T_ARG}",
    "",
    "**Instructions:** Load your AMAI context, paste each task into your AI, record confidence ratings.",
    "Run before and after pruning. If 2+ tasks drop a confidence level, pruning removed critical context.",
    "",
    "---",
    ""]

for n in task_nums:
    if n not in TASK_DEF: continue
    ti, ts, pr = TASK_DEF[n]
    lines += [
        f"## Task {n}: {ti}",
        f"*Tests: {ts}*",
        "",
        "```",
        pr,
        "```",
        "",
        "**Before pruning:** ___ (HIGH / MEDIUM / LOW)",
        "**After pruning:**  ___ (HIGH / MEDIUM / LOW)",
        "**Notes:**",
        "",
        "---",
        ""]

content = "\n".join(lines)
if OUT_ARG: p = Path(OUT_ARG)
else: d = ROOT / "reports"; d.mkdir(exist_ok=True); p = d / f"quality_eval_{today}.md"
p.parent.mkdir(parents=True, exist_ok=True)
p.write_text(content)
print(f"Quality evaluation written to: {p}")
print(f"Tasks: {T_ARG} — paste each into your AI with AMAI context loaded.")
PYEOF
