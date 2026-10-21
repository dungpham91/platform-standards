#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     tests/workflow_sanity.sh
# Purpose:    Lint GitHub Actions workflows (actionlint or minimal structure grep).
# Version:    1.0.0
# Requires:   bash 4+; optional actionlint
# Usage:      bash tests/workflow_sanity.sh
# Exit codes: 0 pass, 1 invalid workflow
# Related:    scripts/lint-shell.sh, .github/workflows/
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WF_DIR="$ROOT/.github/workflows"

if command -v actionlint >/dev/null 2>&1; then
  actionlint "$WF_DIR"/*.yml
  echo "workflow_sanity (actionlint): OK"
  exit 0
fi

for f in "$WF_DIR"/*.yml; do
  grep -q "^name:" "$f"
  grep -q "^on:" "$f"
  grep -q "jobs:" "$f"
done

echo "workflow_sanity (basic grep): OK — install actionlint for stricter checks"
