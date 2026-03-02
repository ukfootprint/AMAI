#!/usr/bin/env bash
# scripts/setup-hooks.sh
# One-time setup: wire .githooks/ as the active Git hooks directory.
#
# Run from the repo root:
#   bash scripts/setup-hooks.sh

set -euo pipefail

REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"

echo "🔧  AMAI — setting up Git hooks"
echo "    Repo: $REPO_ROOT"
echo ""

# Point Git at our managed hooks directory.
git -C "$REPO_ROOT" config core.hooksPath .githooks
echo "    ✅  core.hooksPath = .githooks"

# Ensure the pre-commit hook is executable (might lose bits after a fresh clone).
HOOK="$REPO_ROOT/.githooks/pre-commit"
if [[ -f "$HOOK" ]]; then
  chmod +x "$HOOK"
  echo "    ✅  .githooks/pre-commit — executable"
else
  echo "    ⚠️   .githooks/pre-commit not found — skipping chmod"
fi

# Ensure validate.sh is executable too.
VALIDATE="$REPO_ROOT/scripts/validate.sh"
if [[ -f "$VALIDATE" ]]; then
  chmod +x "$VALIDATE"
  echo "    ✅  scripts/validate.sh — executable"
else
  echo "    ⚠️   scripts/validate.sh not found — skipping chmod"
fi

echo ""
echo "✅  Done. Every 'git commit' will now run AMAI validation."
echo "    To skip for a one-off commit: git commit --no-verify"
echo ""
