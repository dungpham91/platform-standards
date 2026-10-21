#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     lint-all.sh
# Purpose:    Broad local lint: shell, Terraform fmt/I/O order, P4 npm tests.
# Version:    1.1.0
# Requires:   bash 4+, shellcheck, shfmt; optional terraform, npm
# Usage:      bash scripts/lint-all.sh
# Exit codes: 0 pass, 1 any check failed
# Related:    scripts/lint-shell.sh, scripts/quality-gate-quick.sh, docs/LOCAL-SCAN.md
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$ROOT/scripts/lib/common.sh"

log "Lint all — root $ROOT"

bash "$ROOT/scripts/lint-shell.sh"
bash "$ROOT/scripts/terraform-io-sort.sh" --check

if command -v terraform >/dev/null 2>&1; then
  terraform fmt -check -recursive "$ROOT/src/problem1/terraform"
else
  log "SKIP terraform fmt (terraform CLI not installed)"
fi

if [[ -d "$ROOT/src/problem4/apps/backend/node_modules" ]]; then
  (cd "$ROOT/src/problem4/apps/backend" && npm run lint && npm run build && npm test)
else
  (cd "$ROOT/src/problem4/apps/backend" && npm ci && npm run lint && npm run build && npm test)
fi

if [[ -d "$ROOT/src/problem4/apps/frontend/node_modules" ]]; then
  (cd "$ROOT/src/problem4/apps/frontend" && npm test)
else
  (cd "$ROOT/src/problem4/apps/frontend" && npm ci && npm test)
fi

log "lint-all: OK (run verify-clean-tree after git add before commit)"
