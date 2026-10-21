#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     quality-gate-quick.sh
# Purpose:    Fast pre-commit/pre-push checks (verify tree, workflows, fmt, npm tests).
# Version:    1.0.2
# Requires:   bash 4+, git; optional terraform, npm (per-app node_modules)
# Usage:      bash scripts/quality-gate-quick.sh
# Exit codes: 0 pass, 1 sub-check failed
# Related:    scripts/install-git-hooks.sh, .pre-commit-config.yaml
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

bash "$ROOT/scripts/verify-clean-tree.sh"
bash "$ROOT/tests/iac_scan_paths_smoke.sh"
bash "$ROOT/tests/workflow_sanity.sh"

if command -v terraform >/dev/null 2>&1; then
  terraform fmt -check -recursive "$ROOT/src/problem1/terraform" >/dev/null
fi

bash "$ROOT/scripts/terraform-io-sort.sh" --check

for app in \
  src/problem4/apps/backend \
  src/problem4/apps/frontend \
  src/problem3/api; do
  if [[ -d "$ROOT/$app/node_modules" ]]; then
    (cd "$ROOT/$app" && npm test)
  fi
done

echo "quality-gate-quick: OK"
