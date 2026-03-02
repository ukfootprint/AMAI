#!/bin/bash
# scripts/amai_export.sh
# AMAI Export Script — profile-driven, deterministic export with character budgets.
#
# Reads export/profiles.yaml and generates context bundles for AI platforms.
# Enforces character budgets, truncates at section boundaries, checks staleness,
# and excludes Tier 1/2 sensitive files as defined per profile.
#
# Usage:
#   bash scripts/amai_export.sh --target <profile> [--output <dir>] [--dry-run]
#
# Profiles (defined in export/profiles.yaml):
#   claude_project    — Claude Projects; 90K chars; single .md file
#   chatgpt_project   — ChatGPT Projects; 60K chars; single .md file
#   gemini_drive      — Gemini via Drive; 120K chars; multi-file folder
#   generic           — Any platform; 15K chars; single .md file
#
# Backward compatibility (deprecated):
#   bash scripts/amai_export.sh --context=<type> --org=<id>
#
# Part of: AMAI Build Weeks 3-4, Session 8
# Depends: python3, PyYAML (pip install pyyaml)

# ── Resolve AMAI root ──────────────────────────────────────────────────────────
# Script lives in scripts/; AMAI root is one directory up.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AMAI_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Check python3 ─────────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
  echo "Error: python3 is required but not found." >&2
  echo "Install python3 and PyYAML (pip install pyyaml) to use amai_export.sh." >&2
  exit 1
fi

# ── Argument parsing ──────────────────────────────────────────────────────────
TARGET=""
OUTPUT_DIR=""
DRY_RUN="false"
LEGACY_CONTEXT=""
LEGACY_ORG=""

i=0
args=("$@")
while [ $i -lt ${#args[@]} ]; do
  arg="${args[$i]}"
  case "$arg" in
    --target)
      i=$((i+1)); TARGET="${args[$i]}" ;;
    --target=*)
      TARGET="${arg#*=}" ;;
    --output)
      i=$((i+1)); OUTPUT_DIR="${args[$i]}" ;;
    --output=*)
      OUTPUT_DIR="${arg#*=}" ;;
    --dry-run)
      DRY_RUN="true" ;;
    --context=*)
      LEGACY_CONTEXT="${arg#*=}" ;;
    --org=*)
      LEGACY_ORG="${arg#*=}" ;;
  esac
  i=$((i+1))
done

# ── Backward compatibility: legacy --context/--org mode ───────────────────────
if [ -n "$LEGACY_CONTEXT" ] && [ -z "$TARGET" ]; then
  echo "WARNING: --context is deprecated. Use --target for profile-based export." >&2
  echo "   Falling back to legacy org-overlay export behaviour." >&2
  echo ""

  if [ -z "$LEGACY_ORG" ]; then
    echo "Usage: bash scripts/amai_export.sh --context=<type> --org=<org_id>" >&2
    echo "Valid contexts: internal, client_facing, thought_leadership, executive_comms" >&2
    exit 1
  fi

  EXPORT_DIR="${AMAI_ROOT}/EXPORT/${LEGACY_ORG}_${LEGACY_CONTEXT}_$(date +%Y%m%d)"
  mkdir -p "$EXPORT_DIR"
  MANIFEST="$EXPORT_DIR/MANIFEST.md"
  echo "# Export Manifest (Legacy)" > "$MANIFEST"
  echo "Generated: $(date)" >> "$MANIFEST"
  echo "Org: $LEGACY_ORG" >> "$MANIFEST"
  echo "Context: $LEGACY_CONTEXT" >> "$MANIFEST"
  echo "WARNING: This export was generated using the deprecated --context/--org flags." >> "$MANIFEST"
  echo "   Use --target for profile-based export in future." >> "$MANIFEST"

  legacy_copy() {
    local src="$AMAI_ROOT/$1"; local label="$2"
    if [ -f "$src" ]; then
      cp "$src" "$EXPORT_DIR/$(basename $src)"
      echo "- $1 ($label)" >> "$MANIFEST"
    fi
  }

  legacy_copy "BRAIN.md" "personal: always included"
  legacy_copy "MODULE_SELECTION.md" "personal: always included"
  legacy_copy "HOW_THIS_WORKS.md" "personal: always included"
  legacy_copy "identity/voice.md" "personal: Tier 3"
  legacy_copy "identity/heuristics.yaml" "personal: Tier 3"
  legacy_copy "knowledge/frameworks.md" "personal: Tier 3"

  if [ "$LEGACY_CONTEXT" = "internal" ] || [ "$LEGACY_CONTEXT" = "executive_comms" ]; then
    legacy_copy "goals/current_focus.yaml" "personal: Tier 2 -- internal/exec only"
  fi

  echo "" >> "$MANIFEST"
  echo "## Excluded files (by policy)" >> "$MANIFEST"
  for f in "network/contacts.jsonl" "network/interactions.jsonl" \
           "memory/failures.jsonl" "memory/decisions.jsonl" "signals/observations.jsonl"; do
    echo "- $f (excluded)" >> "$MANIFEST"
  done

  echo ""
  echo "=== Legacy Export: $LEGACY_ORG / $LEGACY_CONTEXT ==="
  echo "Output: $EXPORT_DIR"
  exit 0
fi

# ── Validate profiles file exists ─────────────────────────────────────────────
PROFILES_FILE="$AMAI_ROOT/export/profiles.yaml"

if [ ! -f "$PROFILES_FILE" ]; then
  echo "Error: export/profiles.yaml not found. Run setup first." >&2
  exit 1
fi

# ── Validate target is provided ───────────────────────────────────────────────
if [ -z "$TARGET" ]; then
  echo "Error: --target is required." >&2
  echo ""
  echo "Usage: bash scripts/amai_export.sh --target <profile> [--output <dir>] [--dry-run]"
  echo ""
  echo "Available profiles:"
  python3 -c "
import yaml, sys
try:
    data = yaml.safe_load(open('$PROFILES_FILE'))
    for p in data['profiles']:
        print(f'  {p[\"target\"]:<22} -- {p[\"description\"]}')
except Exception as e:
    print(f'  (could not read profiles.yaml: {e})', file=sys.stderr)
"
  exit 1
fi

# ── Write the Python export engine to a temp file ─────────────────────────────
PYTHON_SCRIPT=$(mktemp /tmp/amai_export_XXXXXX.py)
trap "rm -f $PYTHON_SCRIPT" EXIT

cat > "$PYTHON_SCRIPT" << 'PYEOF'
#!/usr/bin/env python3
"""
AMAI Export Engine -- called by amai_export.sh.
Implements: profile loading, budget enforcement, section-boundary truncation,
staleness checking, single_file_markdown and multi_file_folder output assembly.
Determinism guarantee: same source files + same profile + same commit = same output
(only generated_on timestamp varies).
"""

import sys
import os
import re
import datetime
import subprocess

try:
    import yaml
except ImportError:
    print("Error: PyYAML is required. Install with: pip install pyyaml", file=sys.stderr)
    sys.exit(1)

# ── Arguments passed from bash ────────────────────────────────────────────────
TARGET     = sys.argv[1]
OUTPUT_DIR = sys.argv[2]   # empty string means auto-generate
DRY_RUN    = sys.argv[3] == "true"
AMAI_ROOT  = sys.argv[4]

PROFILES_PATH = os.path.join(AMAI_ROOT, "export", "profiles.yaml")


# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

def load_profiles():
    with open(PROFILES_PATH, encoding="utf-8") as f:
        return yaml.safe_load(f)


def find_profile(data, target):
    for p in data["profiles"]:
        if p["target"] == target:
            return p
    available = ", ".join(p["target"] for p in data["profiles"])
    print(f"Error: Unknown profile: {target}. Available: {available}", file=sys.stderr)
    sys.exit(1)


def get_source_commit(root):
    try:
        r = subprocess.run(
            ["git", "rev-parse", "--short", "HEAD"],
            capture_output=True, text=True, cwd=root, timeout=5
        )
        return r.stdout.strip() if r.returncode == 0 else "no-git"
    except Exception:
        return "no-git"


def get_amai_version(root):
    """Extract version from BRAIN.md STATUS line, or CHANGELOG.md."""
    brain = os.path.join(root, "BRAIN.md")
    if os.path.exists(brain):
        with open(brain, encoding="utf-8", errors="replace") as f:
            for line in f:
                if re.search(r'(STATUS|Version|version)\s*[:\|]', line):
                    m = re.search(r'v?(\d+\.\d+[\.\d]*)', line)
                    if m:
                        return "v" + m.group(1)
    changelog = os.path.join(root, "CHANGELOG.md")
    if os.path.exists(changelog):
        with open(changelog, encoding="utf-8", errors="replace") as f:
            for line in f:
                m = re.search(r'##\s*\[?(v?[\d]+\.[\d]+[^\]\s]*)', line)
                if m:
                    v = m.group(1)
                    return v if v.startswith("v") else "v" + v
    return "unknown"


def truncate_markdown(content, max_chars, truncation_marker):
    """
    Truncate Markdown content at the last ## header or --- divider
    that falls before max_chars. Never cuts mid-paragraph.
    Returns (content, was_truncated).
    """
    if len(content) <= max_chars:
        return content, False

    # Section boundaries: any line starting with one or more # chars,
    # or a line that is exactly "---"
    boundaries = []
    for m in re.finditer(r'^(?:#{1,6}\s|---\s*$)', content, re.MULTILINE):
        if m.start() > 0:
            boundaries.append(m.start())

    cut_pos = 0
    for pos in boundaries:
        if pos <= max_chars:
            cut_pos = pos
        else:
            break

    if cut_pos == 0:
        # No section boundary found; fall back to last newline before limit
        cut_pos = content.rfind('\n', 0, max_chars)
        if cut_pos <= 0:
            cut_pos = max_chars

    return content[:cut_pos].rstrip() + truncation_marker, True


def truncate_yaml(content, max_chars, truncation_marker):
    """
    Truncate YAML content at the last top-level key boundary before max_chars.
    Top-level keys are lines at column 0 matching /^[a-zA-Z_][a-zA-Z0-9_]*\s*:/.
    Returns (content, was_truncated).
    """
    if len(content) <= max_chars:
        return content, False

    boundaries = []
    for m in re.finditer(r'^[a-zA-Z_][a-zA-Z0-9_]*\s*:', content, re.MULTILINE):
        if m.start() > 0:
            boundaries.append(m.start())

    cut_pos = 0
    for pos in boundaries:
        if pos <= max_chars:
            cut_pos = pos
        else:
            break

    if cut_pos == 0:
        cut_pos = content.rfind('\n', 0, max_chars)
        if cut_pos <= 0:
            cut_pos = max_chars

    return content[:cut_pos].rstrip() + truncation_marker, True


def smart_truncate(filepath_rel, content, max_chars, truncation_marker):
    """Route to appropriate truncation function by file extension."""
    if filepath_rel.endswith(('.yaml', '.yml')):
        return truncate_yaml(content, max_chars, truncation_marker)
    return truncate_markdown(content, max_chars, truncation_marker)


def get_last_updated(filepath_rel, content):
    """
    Extract last_updated date from file content.
    YAML: top-level last_updated field.
    Markdown: 'Last updated: YYYY-MM-DD' line.
    Returns a datetime object or None.
    """
    if filepath_rel.endswith(('.yaml', '.yml')):
        try:
            data = yaml.safe_load(content)
            if isinstance(data, dict):
                val = data.get("last_updated")
                if val:
                    return datetime.datetime.strptime(str(val), "%Y-%m-%d")
        except Exception:
            pass

    m = re.search(r'[Ll]ast [Uu]pdated\s*:\s*(\d{4}-\d{2}-\d{2})', content)
    if m:
        try:
            return datetime.datetime.strptime(m.group(1), "%Y-%m-%d")
        except Exception:
            pass
    return None


def check_staleness(filepath_rel, content, full_path, thresholds):
    """
    Returns a warning string if the file is overdue for updating, else None.
    Uses last_updated from content if available; falls back to file mtime.
    """
    is_current_focus = "current_focus" in filepath_rel
    threshold = (thresholds["current_focus_days"] if is_current_focus
                 else thresholds["general_module_days"])

    last_updated = get_last_updated(filepath_rel, content)

    if last_updated is None:
        try:
            mtime = os.path.getmtime(full_path)
            last_updated = datetime.datetime.fromtimestamp(mtime)
        except Exception:
            return f"{filepath_rel}: cannot determine last updated date"

    age = (datetime.datetime.now() - last_updated).days
    if age > threshold:
        return f"{filepath_rel}: last updated {age} days ago (threshold: {threshold} days)"
    return None


# ==============================================================================
# MAIN EXPORT LOGIC
# ==============================================================================

def run():
    data       = load_profiles()
    profile    = find_profile(data, TARGET)
    global_cfg = data["global"]

    truncation_marker = global_cfg["truncation_marker"]
    omission_marker   = global_cfg["omission_marker"]
    staleness_thresh  = global_cfg["staleness_thresholds"]
    budget            = profile["budget_chars"]
    fmt               = profile["format"]
    profile_name      = profile["target"]

    # Fast-lookup set of excluded files
    exclude_map   = {e["file"]: e["reason"] for e in profile.get("exclude", [])}
    include_files = {e["file"] for e in profile.get("include", [])}

    # Accumulators
    included           = []   # (filepath_rel, processed_content, was_truncated)
    excluded_inc       = []   # files in include list but also in exclude list (safety net)
    budget_skipped     = []   # (filepath_rel, chars_that_would_have_been_added)
    not_found          = []   # filepath_rel
    staleness_warnings = []
    running_total      = 0

    # Dry-run table rows (kept regardless of mode for code-path unity)
    table_rows = []

    # ── Process include list in priority order ─────────────────────────────────
    for entry in profile["include"]:
        fp           = entry["file"]
        priority     = entry["priority"]
        max_chars    = entry["max_chars"]
        full_path    = os.path.join(AMAI_ROOT, fp)

        # Safety net: included file is also in exclude list
        if fp in exclude_map:
            excluded_inc.append((fp, f"exclude list: {exclude_map[fp]}"))
            table_rows.append({"file": fp, "priority": str(priority),
                                "size": "-", "cum": f"{running_total:,}",
                                "status": f"🔒 excluded (safety net)"})
            continue

        # File not found
        if not os.path.exists(full_path):
            not_found.append(fp)
            print(f"INFO: {fp} not found -- skipping")
            table_rows.append({"file": fp, "priority": str(priority),
                                "size": "-", "cum": f"{running_total:,}",
                                "status": "⚠️  not found"})
            continue

        # Read and truncate to per-file max_chars
        with open(full_path, encoding="utf-8", errors="replace") as f:
            raw_content = f.read()

        content, was_truncated = smart_truncate(fp, raw_content, max_chars, truncation_marker)
        file_chars = len(content)

        # Budget enforcement
        if running_total + file_chars > budget:
            budget_skipped.append((fp, file_chars))
            table_rows.append({"file": fp, "priority": str(priority),
                                "size": f"{file_chars:,}", "cum": f"{running_total:,}",
                                "status": "⛔ budget exceeded"})
            continue

        # Staleness check
        warning = check_staleness(fp, content, full_path, staleness_thresh)
        if warning:
            staleness_warnings.append(warning)

        running_total += file_chars
        trunc_flag = " (truncated)" if was_truncated else ""
        included.append((fp, content, was_truncated))
        table_rows.append({"file": fp, "priority": str(priority),
                            "size": f"{file_chars:,}", "cum": f"{running_total:,}",
                            "status": f"✅ included{trunc_flag}"})

    # ── Append explicitly-excluded files (not in include list) to table ────────
    for excl in profile.get("exclude", []):
        if excl["file"] not in include_files:
            reason_short = excl["reason"][:40]
            table_rows.append({"file": excl["file"], "priority": "-",
                                "size": "-", "cum": "-",
                                "status": f"🔒 {reason_short}"})

    # ── Metadata ───────────────────────────────────────────────────────────────
    generated_on  = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    source_commit = get_source_commit(AMAI_ROOT)
    amai_version  = get_amai_version(AMAI_ROOT)
    pct           = (running_total / budget * 100) if budget > 0 else 0.0

    n_included  = len(included)
    # Count distinct excluded files across all categories
    n_excl_explicit = len([e for e in profile.get("exclude", [])
                           if e["file"] not in include_files])
    n_excl_safety   = len(excluded_inc)
    n_excluded      = n_excl_explicit + n_excl_safety
    n_budget_skip   = len(budget_skipped)
    n_not_found     = len(not_found)

    staleness_summary = (f"{len(staleness_warnings)} warning(s)"
                         if staleness_warnings else "all modules current")

    # ── DRY-RUN ────────────────────────────────────────────────────────────────
    if DRY_RUN:
        print()
        print(f"AMAI Export Dry-Run  --  {profile_name}")
        print(f"{'─' * 80}")
        header = f"{'File':<44} {'Pri':>3}  {'File sz':>8}  {'Running':>10}  Status"
        print(header)
        print(f"{'─' * 44} {'─' * 3}  {'─' * 8}  {'─' * 10}  {'─' * 25}")
        for row in table_rows:
            print(f"{row['file']:<44} {row['priority']:>3}  {row['size']:>8}  {row['cum']:>10}  {row['status']}")
        print()
        print(f"{'─' * 80}")
        print(f"Profile:    {profile_name}  --  {profile['description']}")
        print(f"Budget:     {running_total:,} / {budget:,} chars ({pct:.1f}% used)")
        print(f"Files:      {n_included} included, {n_excluded} excluded, "
              f"{n_budget_skip} skipped (budget), {n_not_found} not found")
        print(f"Staleness:  {staleness_summary}")
        print(f"Commit:     {source_commit}")
        print(f"Version:    {amai_version}")
        print(f"Format:     {fmt}")
        print()
        return

    # ── Determine output directory ─────────────────────────────────────────────
    date_str = datetime.datetime.utcnow().strftime("%Y%m%d")
    if OUTPUT_DIR:
        out_dir = OUTPUT_DIR
    else:
        out_dir = os.path.join(AMAI_ROOT, "export", f"{profile_name}_{date_str}")

    os.makedirs(out_dir, exist_ok=True)

    # ── Build omissions list for footer ───────────────────────────────────────
    all_omitted = []
    for fp, reason in excluded_inc:
        all_omitted.append((fp, reason))
    for fp, chars in budget_skipped:
        all_omitted.append((fp, f"budget exhausted ({running_total:,}/{budget:,} chars used)"))
    for fp in not_found:
        all_omitted.append((fp, "file not found in AMAI repo"))
    for excl in profile.get("exclude", []):
        if excl["file"] not in include_files:
            all_omitted.append((excl["file"], excl["reason"]))

    # ── Build reusable text blocks ─────────────────────────────────────────────
    meta_comment = (
        f"<!-- AMAI Export: {profile_name} -->\n"
        f"<!-- Generated: {generated_on} | Commit: {source_commit} | "
        f"Profile: {profile_name} | Version: {amai_version} -->\n"
    )

    staleness_lines = ["## Staleness Summary", ""]
    if staleness_warnings:
        for w in staleness_warnings:
            staleness_lines.append(f"- WARNING: {w}")
    else:
        staleness_lines.append("All modules current.")
    staleness_block = "\n".join(staleness_lines)

    omitted_lines = ["## Omitted Files", ""]
    if all_omitted:
        for fp, reason in all_omitted:
            omitted_lines.append(f"- `{fp}` -- {reason}")
    else:
        omitted_lines.append("*(none)*")
    omitted_block = "\n".join(omitted_lines)

    # ── single_file_markdown ───────────────────────────────────────────────────
    if fmt == "single_file_markdown":
        parts = [
            meta_comment,
            "# AMAI Context Bundle\n",
            staleness_block,
        ]
        for fp, content, _ in included:
            parts.append(f"\n---\n## {fp}\n")
            parts.append(content)

        parts.append("\n\n---\n")
        parts.append(omitted_block)

        output_text = "\n".join(parts)
        out_file = os.path.join(out_dir, "amai_export.md")
        with open(out_file, "w", encoding="utf-8") as f:
            f.write(output_text)

        print()
        print("AMAI Export Complete")
        print(f"{'─' * 44}")
        print(f"Profile:    {profile_name}")
        print(f"Output:     {out_file}")
        print(f"Files:      {n_included} included, {n_excluded} excluded, "
              f"{n_budget_skip} skipped (budget)")
        print(f"Size:       {running_total:,} / {budget:,} chars ({pct:.1f}%)")
        print(f"Staleness:  {staleness_summary}")
        print(f"Commit:     {source_commit}")
        print()

    # ── multi_file_folder ──────────────────────────────────────────────────────
    elif fmt == "multi_file_folder":
        written = []
        for fp, content, _ in included:
            dest = os.path.join(out_dir, fp)
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            with open(dest, "w", encoding="utf-8") as f:
                f.write(content)
            written.append(fp)

        manifest_lines = [
            meta_comment,
            "# AMAI Export Manifest\n",
            staleness_block,
            "",
            "## Included Files",
            "",
        ]
        for fp in written:
            manifest_lines.append(f"- `{fp}`")
        manifest_lines.append("")
        manifest_lines.append(omitted_block)

        with open(os.path.join(out_dir, "MANIFEST.md"), "w", encoding="utf-8") as f:
            f.write("\n".join(manifest_lines))

        print()
        print("AMAI Export Complete")
        print(f"{'─' * 44}")
        print(f"Profile:    {profile_name}")
        print(f"Output:     {out_dir}/")
        print(f"Files:      {n_included} included, {n_excluded} excluded, "
              f"{n_budget_skip} skipped (budget)")
        print(f"Size:       {running_total:,} / {budget:,} chars ({pct:.1f}%)")
        print(f"Staleness:  {staleness_summary}")
        print(f"Commit:     {source_commit}")
        print()

    else:
        print(f"Error: Unknown format '{fmt}' in profile '{profile_name}'.",
              file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    run()

PYEOF

# ── Invoke the Python engine ───────────────────────────────────────────────────
python3 "$PYTHON_SCRIPT" "$TARGET" "$OUTPUT_DIR" "$DRY_RUN" "$AMAI_ROOT"
