#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     terraform-validate-all-modules.sh
# Purpose:    terraform init -backend=false, validate, and test every P1 module.
# Version:    1.0.0
# Requires:   bash 4+, terraform CLI (1.16+ recommended)
# Usage:      bash scripts/terraform-validate-all-modules.sh
# Exit codes: 0 all modules pass, 1 any validate/test failure
# Related:    tests/terraform_validate.sh, .github/workflows/pr-quality-gate.yml
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$ROOT/scripts/lib/common.sh"

require_cmd terraform

MODULES_ROOT="$ROOT/src/problem1/terraform/modules"
failed=0

while IFS= read -r -d '' dir; do
  mod_dir="$(dirname "$dir")"
  log "terraform validate: $mod_dir"
  (
    cd "$mod_dir"
    retry 3 terraform init -backend=false -input=false
    terraform validate
    if compgen -G "tests/*.tftest.hcl" >/dev/null; then
      log "terraform test: $mod_dir"
      terraform test
    fi
  ) || failed=1
done < <(find "$MODULES_ROOT" -name main.tf -print0 | sort -z)

if [[ "$failed" -ne 0 ]]; then
  die "One or more modules failed terraform validate/test"
fi

log "terraform-validate-all-modules: OK"
