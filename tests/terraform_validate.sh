#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     tests/terraform_validate.sh
# Purpose:    Entry for mock tests — terraform validate-all or SKIP if no CLI.
# Version:    1.0.0
# Requires:   bash 4+; optional terraform
# Usage:      bash tests/terraform_validate.sh
# Exit codes: 0 pass or SKIP, 1 validate failure
# Related:    scripts/terraform-validate-all-modules.sh
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v terraform >/dev/null 2>&1; then
  echo "SKIP terraform_validate (terraform CLI not installed)"
  exit 0
fi

bash "$ROOT/scripts/terraform-validate-all-modules.sh"

echo "terraform_validate: OK"
