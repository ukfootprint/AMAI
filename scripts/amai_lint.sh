#!/bin/bash
# amai_lint.sh
# Validates org overlay files for schema completeness and internal consistency.
# Run before activating a new overlay or after making changes to overlay files.
# Usage: bash scripts/amai_lint.sh <org_id>
# Example: bash scripts/amai_lint.sh acme-corp

set -e

ORG_ID="${1:-}"
if [ -z "$ORG_ID" ]; then
  echo "ERROR: org_id required. Usage: bash scripts/amai_lint.sh <org_id>"
  exit 1
fi

OVERLAY_DIR="org/overlays/$ORG_ID"
ERRORS=0

check_file_exists() {
  if [ ! -f "$1" ]; then
    echo "MISSING: $1"
    ERRORS=$((ERRORS + 1))
  fi
}

check_field_present() {
  local file="$1"
  local field="$2"
  if ! grep -q "^${field}:" "$file" 2>/dev/null; then
    echo "MISSING FIELD: '$field' not found in $file"
    ERRORS=$((ERRORS + 1))
  fi
}

check_bands_have_examples() {
  local file="$OVERLAY_DIR/behaviour_bands.yaml"
  if [ ! -f "$file" ]; then return; fi
  for level in L1 L2 L3 L4 L5; do
    if ! grep -q "positive_example" "$file"; then
      echo "MISSING EXAMPLES: behaviour_bands.yaml must include positive_example for each level"
      ERRORS=$((ERRORS + 1))
      break
    fi
    if ! grep -q "negative_example" "$file"; then
      echo "MISSING EXAMPLES: behaviour_bands.yaml must include negative_example for each level"
      ERRORS=$((ERRORS + 1))
      break
    fi
  done
}

echo "=== AMAI Overlay Lint: $ORG_ID ==="
echo ""

# Check required files exist
echo "-- Checking required files --"
check_file_exists "org/org_index.yaml"
check_file_exists "org/MODULE.md"
check_file_exists "$OVERLAY_DIR/overlay.yaml"
check_file_exists "$OVERLAY_DIR/behaviour_bands.yaml"
check_file_exists "$OVERLAY_DIR/SESSION_STATES.md"
check_file_exists "$OVERLAY_DIR/policy/data_classes.yaml"
check_file_exists "$OVERLAY_DIR/policy/disclosure_rules.yaml"

# Check required fields in overlay.yaml
echo ""
echo "-- Checking overlay.yaml fields --"
check_field_present "$OVERLAY_DIR/overlay.yaml" "schema_version"
check_field_present "$OVERLAY_DIR/overlay.yaml" "org_id"
check_field_present "$OVERLAY_DIR/overlay.yaml" "requires_explicit_activation"
check_field_present "$OVERLAY_DIR/overlay.yaml" "session_disclosure_banner"
check_field_present "$OVERLAY_DIR/overlay.yaml" "prohibited_modules"
check_field_present "$OVERLAY_DIR/overlay.yaml" "precedence"
check_field_present "$OVERLAY_DIR/overlay.yaml" "conflict_protocol"
check_field_present "$OVERLAY_DIR/overlay.yaml" "context_type_defaults"

# Check required fields in org_index.yaml
echo ""
echo "-- Checking org_index.yaml --"
check_field_present "org/org_index.yaml" "schema_version"
if ! grep -q "$ORG_ID" "org/org_index.yaml" 2>/dev/null; then
  echo "WARNING: org_id '$ORG_ID' not found in org/org_index.yaml"
  ERRORS=$((ERRORS + 1))
fi

# Check behaviour bands have examples
echo ""
echo "-- Checking behaviour_bands.yaml --"
check_bands_have_examples

# Check data_classes maps to personal tiers
echo ""
echo "-- Checking data_classes.yaml --"
check_field_present "$OVERLAY_DIR/policy/data_classes.yaml" "schema_version"
if ! grep -q "maps_to_personal_tier" "$OVERLAY_DIR/policy/data_classes.yaml" 2>/dev/null; then
  echo "MISSING: data_classes.yaml must map classes to personal sensitivity tiers"
  ERRORS=$((ERRORS + 1))
fi

# Check disclosure_rules reference allowed_classes_by_context
echo ""
echo "-- Checking disclosure_rules.yaml --"
check_field_present "$OVERLAY_DIR/policy/disclosure_rules.yaml" "allowed_classes_by_context"
check_field_present "$OVERLAY_DIR/policy/disclosure_rules.yaml" "never_include"

# Result
echo ""
echo "=== Lint complete ==="
if [ "$ERRORS" -eq 0 ]; then
  echo "PASSED: No issues found for overlay '$ORG_ID'."
else
  echo "FAILED: $ERRORS issue(s) found. Fix before activating overlay."
  exit 1
fi
