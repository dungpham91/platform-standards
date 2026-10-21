#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     lint-shell.sh
# Purpose:    shellcheck all *.sh and shfmt check; validate workflow YAML structure.
# Version:    1.0.0
# Requires:   bash 4+, shellcheck, shfmt
# Usage:      bash scripts/lint-shell.sh
# Exit codes: 0 pass, 1 lint violation
# Related:    .github/workflows/pr-quality-gate.yml (shell-and-repo-lint job)
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$ROOT/scripts/lib/common.sh"

log "lint-shell — root $ROOT"

require_cmd shellcheck
find "$ROOT" -name '*.sh' -not -path '*/node_modules/*' -print0 |
  xargs -0 shellcheck -x -S style

require_cmd shfmt
find "$ROOT" -name '*.sh' -not -path '*/node_modules/*' -print0 |
  xargs -0 shfmt -d -i 2 -ci -bn

if command -v actionlint >/dev/null 2>&1; then
  actionlint "$ROOT/.github/workflows/"*.yml
else
  bash "$ROOT/tests/workflow_sanity.sh"
fi

log "lint-shell: OK"
