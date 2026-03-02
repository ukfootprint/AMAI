#!/usr/bin/env bash
# scripts/changelog.sh — AMAI Git-Derived Change Summary
#
# Generate a human-readable change summary from git history, filtered to
# AMAI-relevant files only. This is a convenience layer over git log that
# summarises what changed in AMAI terms (which modules, what kind of change).
#
# Usage:
#   bash scripts/changelog.sh [--since <date|tag|commit>] \
#                             [--until <date|tag|commit>] \
#                             [--output <file>] \
#                             [--format markdown|json]
#
# Options:
#   --since   Start point. Default: last git tag, or "30 days ago" if no tags.
#             Accepts: ISO date (2026-02-15), relative date (30 days ago),
#             tag name (v2.0), or commit hash.
#   --until   End point. Default: HEAD.
#   --output  Write to file instead of stdout.
#   --format  Output format: markdown (default) or json.
#
# Dependencies: bash + git only. No python3 required.
# Portable: macOS and Linux. Uses git's own date parsing to avoid
#           GNU vs BSD date command differences.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AMAI_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Defaults ──────────────────────────────────────────────────────────────────
SINCE_ARG=""
UNTIL_ARG="HEAD"
OUTPUT_FILE=""
FORMAT="markdown"
LAST_TAG=""   # may be populated below; used in footer

# ── Parse arguments ───────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --since)
            [[ -z "${2:-}" ]] && { echo "Error: --since requires a value" >&2; exit 1; }
            SINCE_ARG="$2"; shift 2 ;;
        --until)
            [[ -z "${2:-}" ]] && { echo "Error: --until requires a value" >&2; exit 1; }
            UNTIL_ARG="$2"; shift 2 ;;
        --output)
            [[ -z "${2:-}" ]] && { echo "Error: --output requires a value" >&2; exit 1; }
            OUTPUT_FILE="$2"; shift 2 ;;
        --format)
            [[ -z "${2:-}" ]] && { echo "Error: --format must be 'markdown' or 'json'" >&2; exit 1; }
            FORMAT="$2"; shift 2 ;;
        --since=*)  SINCE_ARG="${1#--since=}";  shift ;;
        --until=*)  UNTIL_ARG="${1#--until=}";  shift ;;
        --output=*) OUTPUT_FILE="${1#--output=}"; shift ;;
        --format=*) FORMAT="${1#--format=}";    shift ;;
        *)
            printf "Unknown argument: %s\n" "$1" >&2
            printf "Usage: bash scripts/changelog.sh [--since <date|tag|commit>] [--until <date|tag|commit>] [--output <file>] [--format markdown|json]\n" >&2
            exit 1 ;;
    esac
done

# ── Validate format ───────────────────────────────────────────────────────────
if [[ "$FORMAT" != "markdown" && "$FORMAT" != "json" ]]; then
    printf "Error: --format must be 'markdown' or 'json'. Got: %s\n" "$FORMAT" >&2
    exit 1
fi

# ── Check git ─────────────────────────────────────────────────────────────────
if ! git -C "$AMAI_ROOT" rev-parse --git-dir &>/dev/null 2>&1; then
    echo "Not a git repository. changelog.sh requires git." >&2
    exit 1
fi

# ── Determine --since default ─────────────────────────────────────────────────
if [[ -z "$SINCE_ARG" ]]; then
    LAST_TAG=$(git -C "$AMAI_ROOT" describe --tags --abbrev=0 2>/dev/null || true)
    if [[ -n "$LAST_TAG" ]]; then
        SINCE_ARG="$LAST_TAG"
        SINCE_LABEL="$LAST_TAG"
    else
        SINCE_ARG="30 days ago"
        SINCE_LABEL="30 days ago"
    fi
else
    SINCE_LABEL="$SINCE_ARG"
fi

# ── AMAI-relevant paths (filter commits to these only) ────────────────────────
AMAI_PATHS=(
    "identity/" "goals/" "knowledge/" "memory/" "network/"
    "operations/" "signals/" "calibration/" "org/"
    "scripts/" "schemas/" "hooks/" "commands/" "skills/"
    "BRAIN.md" "MODULE_SELECTION.md" "SECURITY.md"
)

# ── Module classification from file path ──────────────────────────────────────
classify_module() {
    local filepath="$1"
    case "$filepath" in
        identity/*)     echo "Identity" ;;
        goals/*)        echo "Goals" ;;
        knowledge/*)    echo "Knowledge" ;;
        memory/*)       echo "Memory" ;;
        network/*)      echo "Network" ;;
        operations/*)   echo "Operations" ;;
        signals/*)      echo "Signals" ;;
        calibration/*)  echo "Calibration" ;;
        org/*)          echo "Org Overlays" ;;
        scripts/*|schemas/*|hooks/*|commands/*|skills/*)
                        echo "Infrastructure" ;;
        *.md|*.yaml|*.json|*.txt)
                        echo "Documentation" ;;
        *)              echo "" ;;  # Not AMAI-relevant; skip
    esac
}

# ── Change type from commit message prefix (conventional commits) ─────────────
classify_type() {
    local msg="$1"
    local lower
    lower=$(printf '%s' "$msg" | tr '[:upper:]' '[:lower:]')

    if   [[ "$lower" == feat:* ]];     then echo "Added"
    elif [[ "$lower" == fix:* ]];      then echo "Fixed"
    elif [[ "$lower" == refactor:* ]]; then echo "Changed"
    elif [[ "$lower" == docs:* ]];     then echo "Documentation"
    elif [[ "$lower" == chore:* ]];    then echo "Maintenance"
    elif [[ "$lower" == *prune* || "$lower" == *archive* ]]; then echo "Pruned"
    elif [[ "$lower" == *calibrat* ]]; then echo "Calibrated"
    else                                    echo "Updated"
    fi
}

# ── Escape a string for embedding in JSON ─────────────────────────────────────
json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"   # backslash → \\
    s="${s//\"/\\\"}"   # double-quote → \"
    s="${s//$'\t'/\\t}" # tab → \t
    s="${s//$'\r'/\\r}" # CR → \r
    printf '%s' "$s"
}

# ── Build git log range arguments ─────────────────────────────────────────────
# Distinguish date expressions from tag/commit refs so we use the right syntax.
# Date expressions: contain spaces ("30 days ago") or match YYYY-MM-DD.
# Everything else is treated as a git ref (tag, branch, commit hash).
GIT_LOG_PRE=()
if [[ "$SINCE_ARG" == *" "* ]] || [[ "$SINCE_ARG" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    GIT_LOG_PRE+=("--since=$SINCE_ARG")
    [[ "$UNTIL_ARG" != "HEAD" ]] && GIT_LOG_PRE+=("--until=$UNTIL_ARG")
else
    # Range syntax: <ref>..<ref>  (e.g. v2.0..HEAD)
    GIT_LOG_PRE+=("${SINCE_ARG}..${UNTIL_ARG}")
fi

# ── Temp directory for per-module entry files ─────────────────────────────────
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

# ── Module list — display order and labels ────────────────────────────────────
# MODULES: keys used for temp filenames (no spaces)
# MODULE_LABELS: human-readable labels for output
MODULES=(
    "Identity" "Goals" "Knowledge" "Memory" "Network"
    "Operations" "Signals" "Calibration" "Org_Overlays"
    "Infrastructure" "Documentation"
)
MODULE_LABELS=(
    "Identity" "Goals" "Knowledge" "Memory" "Network"
    "Operations" "Signals" "Calibration" "Org Overlays"
    "Infrastructure" "Documentation"
)

# ── Collect and categorise commits ────────────────────────────────────────────
COMMIT_COUNT=0
FIRST_COMMIT_DATE=""
LAST_COMMIT_DATE=""

# git log format: HASH<TAB>SHORT<TAB>DATETIME<TAB>SUBJECT
# Using TAB as primary delimiter; subject may contain | but not TAB
# Note: outer loop uses fd 3 to avoid stdin conflict with inner diff-tree loops
while IFS=$'\t' read -r full_hash short_hash commit_datetime commit_msg <&3; do
    [[ -z "$full_hash" ]] && continue

    # Extract date only (YYYY-MM-DD)
    entry_date="${commit_datetime%% *}"

    # Track date range
    [[ -z "$LAST_COMMIT_DATE" ]] && LAST_COMMIT_DATE="$entry_date"
    FIRST_COMMIT_DATE="$entry_date"

    # Get files changed by this commit
    touched_keys=""
    while IFS= read -r filepath; do
        [[ -z "$filepath" ]] && continue
        module=$(classify_module "$filepath")
        [[ -z "$module" ]] && continue
        module_key="${module// /_}"
        # Deduplicate: only add if not already in touched_keys
        [[ "$touched_keys" == *"::${module_key}::"* ]] && continue
        touched_keys+="::${module_key}::"
    done < <(git -C "$AMAI_ROOT" diff-tree --no-commit-id --name-only -r "$full_hash" 2>/dev/null)

    # Skip commits that touch no AMAI-relevant files
    [[ -z "$touched_keys" ]] && continue

    COMMIT_COUNT=$((COMMIT_COUNT + 1))

    # Classify change type
    change_type=$(classify_type "$commit_msg")

    # Sanitise message for tab-delimited temp file (replace tabs with spaces)
    safe_msg="${commit_msg//$'\t'/ }"

    # Write entry to each touched module's temp file
    for module_key in "${MODULES[@]}"; do
        if [[ "$touched_keys" == *"::${module_key}::"* ]]; then
            printf "%s\t%s\t%s\t%s\n" \
                "$change_type" "$short_hash" "$entry_date" "$safe_msg" \
                >> "$WORK_DIR/$module_key"
        fi
    done

done 3< <(git -C "$AMAI_ROOT" log \
    "${GIT_LOG_PRE[@]}" \
    --pretty=tformat:"%H%x09%h%x09%ci%x09%s" \
    -- "${AMAI_PATHS[@]}" 2>/dev/null)

# ── Resolve display date range ─────────────────────────────────────────────────
TODAY=$(date +%Y-%m-%d 2>/dev/null || echo "today")
PERIOD_SINCE="${FIRST_COMMIT_DATE:-$SINCE_LABEL}"
PERIOD_UNTIL="${LAST_COMMIT_DATE:-$TODAY}"
# If no commits, use the configured bounds for display
if [[ $COMMIT_COUNT -eq 0 ]]; then
    PERIOD_SINCE="$SINCE_LABEL"
    PERIOD_UNTIL="$TODAY"
fi

# ── Generated timestamp ────────────────────────────────────────────────────────
GENERATED=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")

# ── Footer range description ──────────────────────────────────────────────────
if [[ -n "$LAST_TAG" ]]; then
    RANGE_DESC="${LAST_TAG}..${UNTIL_ARG}"
else
    RANGE_DESC="${SINCE_LABEL} to ${UNTIL_ARG}"
fi

# ── Generate markdown output ──────────────────────────────────────────────────
generate_markdown() {
    printf '# AMAI Changelog\n'
    printf '**Period:** %s to %s\n' "$PERIOD_SINCE" "$PERIOD_UNTIL"
    printf '**Commits:** %d\n\n' "$COMMIT_COUNT"

    if [[ $COMMIT_COUNT -eq 0 ]]; then
        printf 'No AMAI changes in this period.\n\n'
    else
        for i in "${!MODULES[@]}"; do
            module_key="${MODULES[$i]}"
            module_label="${MODULE_LABELS[$i]}"
            module_file="$WORK_DIR/$module_key"
            [[ ! -f "$module_file" ]] && continue

            printf '## %s\n' "$module_label"
            while IFS=$'\t' read -r type hash date msg; do
                printf -- '- **%s:** %s (%s, %s)\n' "$type" "$msg" "$hash" "$date"
            done < "$module_file"
            printf '\n'
        done
    fi

    printf -- '---\n'
    printf 'Generated: %s\n' "$GENERATED"
    printf 'Range: %s\n' "$RANGE_DESC"
}

# ── Generate JSON output ───────────────────────────────────────────────────────
generate_json() {
    # Collect active modules (those with at least one entry)
    local active_idxs=()
    for i in "${!MODULES[@]}"; do
        [[ -f "$WORK_DIR/${MODULES[$i]}" ]] && active_idxs+=("$i")
    done
    local total_modules=${#active_idxs[@]}

    printf '{\n'
    printf '  "period": {"since": "%s", "until": "%s"},\n' \
        "$(json_escape "$PERIOD_SINCE")" "$(json_escape "$PERIOD_UNTIL")"
    printf '  "commit_count": %d,\n' "$COMMIT_COUNT"
    printf '  "categories": {'

    if [[ $total_modules -eq 0 ]]; then
        printf '}\n'
    else
        printf '\n'
        local module_num=0
        for i in "${active_idxs[@]}"; do
            module_num=$((module_num + 1))
            module_key="${MODULES[$i]}"
            module_label="${MODULE_LABELS[$i]}"
            module_file="$WORK_DIR/$module_key"

            # Collect entries for this module into an array
            local entries=()
            while IFS=$'\t' read -r type hash date msg; do
                entries+=("{\"type\": \"$(json_escape "$type")\", \"message\": \"$(json_escape "$msg")\", \"hash\": \"$(json_escape "$hash")\", \"date\": \"$(json_escape "$date")\"}")
            done < "$module_file"

            printf '    "%s": [' "$(json_escape "$module_label")"
            local total_entries=${#entries[@]}
            local entry_num=0
            for entry in "${entries[@]}"; do
                entry_num=$((entry_num + 1))
                if [[ $entry_num -lt $total_entries ]]; then
                    printf '%s, ' "$entry"
                else
                    printf '%s' "$entry"
                fi
            done
            printf ']'

            # Comma after each module except the last
            if [[ $module_num -lt $total_modules ]]; then
                printf ',\n'
            else
                printf '\n'
            fi
        done
        printf '  },\n'
    fi

    printf '  "generated": "%s"\n' "$(json_escape "$GENERATED")"
    printf '}\n'
}

# ── Produce output ─────────────────────────────────────────────────────────────
if [[ -n "$OUTPUT_FILE" ]]; then
    if [[ "$FORMAT" == "json" ]]; then
        generate_json > "$OUTPUT_FILE"
    else
        generate_markdown > "$OUTPUT_FILE"
    fi
    printf 'Changelog written to: %s\n' "$OUTPUT_FILE"
else
    if [[ "$FORMAT" == "json" ]]; then
        generate_json
    else
        generate_markdown
    fi
fi
