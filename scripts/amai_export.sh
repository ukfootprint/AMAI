#!/bin/bash
# amai_export.sh
# Generates a browser-safe or public-safe export bundle for a given org context.
# Strips Tier 1 and Tier 2 personal data and prohibited org modules.
# Output goes to EXPORT/ folder in repo root (gitignored by default).
# Usage: bash scripts/amai_export.sh --context=<context_type> --org=<org_id>
# Example: bash scripts/amai_export.sh --context=client_facing --org=acme-corp

set -e

CONTEXT=""
ORG_ID=""

for arg in "$@"; do
  case $arg in
    --context=*) CONTEXT="${arg#*=}" ;;
    --org=*) ORG_ID="${arg#*=}" ;;
  esac
done

if [ -z "$CONTEXT" ] || [ -z "$ORG_ID" ]; then
  echo "Usage: bash scripts/amai_export.sh --context=<context_type> --org=<org_id>"
  echo "Valid contexts: internal, client_facing, thought_leadership, executive_comms"
  exit 1
fi

EXPORT_DIR="EXPORT/${ORG_ID}_${CONTEXT}_$(date +%Y%m%d)"
mkdir -p "$EXPORT_DIR"

MANIFEST="$EXPORT_DIR/MANIFEST.md"
echo "# Export Manifest" > "$MANIFEST"
echo "Generated: $(date)" >> "$MANIFEST"
echo "Org: $ORG_ID" >> "$MANIFEST"
echo "Context: $CONTEXT" >> "$MANIFEST"
echo "" >> "$MANIFEST"
echo "## Included files" >> "$MANIFEST"

copy_if_exists() {
  local src="$1"
  local label="$2"
  if [ -f "$src" ]; then
    cp "$src" "$EXPORT_DIR/$(basename $src)"
    echo "- $src ($label)" >> "$MANIFEST"
  fi
}

echo ""
echo "=== AMAI Export: $ORG_ID / $CONTEXT ==="
echo "Output: $EXPORT_DIR"
echo ""

# Always include: minimal safe personal set
echo "-- Including safe personal context --"
copy_if_exists "BRAIN.md" "personal: always included"
copy_if_exists "MODULE_SELECTION.md" "personal: always included"
copy_if_exists "HOW_THIS_WORKS.md" "personal: always included"
copy_if_exists "identity/voice.md" "personal: Tier 3"
copy_if_exists "identity/heuristics.yaml" "personal: Tier 3"
copy_if_exists "knowledge/frameworks.md" "personal: Tier 3"

# Always include: org overlay files
echo "-- Including org overlay --"
copy_if_exists "org/org_index.yaml" "org: always included"
copy_if_exists "org/MODULE.md" "org: always included"
copy_if_exists "org/overlays/$ORG_ID/overlay.yaml" "org: overlay config"
copy_if_exists "org/overlays/$ORG_ID/behaviour_bands.yaml" "org: bands"
copy_if_exists "org/overlays/$ORG_ID/SESSION_STATES.md" "org: session states"
copy_if_exists "org/overlays/$ORG_ID/policy/data_classes.yaml" "org: policy"
copy_if_exists "org/overlays/$ORG_ID/policy/disclosure_rules.yaml" "org: policy"

# Context-conditional: include goals only for internal/exec contexts
if [ "$CONTEXT" = "internal" ] || [ "$CONTEXT" = "executive_comms" ]; then
  echo "-- Including context-appropriate personal goals --"
  copy_if_exists "goals/current_focus.yaml" "personal: Tier 2 — internal/exec only"
fi

# Explicitly excluded — log to manifest
echo "" >> "$MANIFEST"
echo "## Excluded files (by policy)" >> "$MANIFEST"
echo "- identity/values.yaml (Tier 1: red lines — never included in org export)" >> "$MANIFEST"
echo "- memory/failures.jsonl (Tier 1: personal memory)" >> "$MANIFEST"
echo "- memory/decisions.jsonl (Tier 2: excluded from client/public contexts)" >> "$MANIFEST"
echo "- network/contacts.jsonl (Tier 1: personal network — always excluded)" >> "$MANIFEST"
echo "- network/interactions.jsonl (Tier 1: personal network — always excluded)" >> "$MANIFEST"
echo "- signals/observations.jsonl (personal signals — always excluded from org export)" >> "$MANIFEST"
echo "- org/overlays/$ORG_ID/tension_log.jsonl (personal tension data — always excluded)" >> "$MANIFEST"

echo ""
echo "=== Export complete ==="
echo "Files written to: $EXPORT_DIR"
echo "Review MANIFEST.md before uploading to any AI session."
echo ""
echo "REMINDER: This bundle is safe for $CONTEXT context."
echo "Before uploading to a browser AI session, read SECURITY.md — browser"
echo "sessions transmit content to AI provider servers."
