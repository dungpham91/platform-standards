#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     checkov-iac-gate.sh
# Purpose:    Fail CI/local gate on Checkov findings (Terraform + docker-compose).
# Version:    1.0.2
# Requires:   bash 4+, checkov on PATH
# Usage:      bash scripts/checkov-iac-gate.sh
# Exit codes: 0 pass, 1 Checkov findings or missing checkov
# Related:    scripts/checkov-iac-sarif.sh, .github/workflows/pr-quality-gate.yml
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$ROOT/scripts/lib/common.sh"

require_cmd checkov

mapfile -t TF_DIRS < <(bash "$ROOT/scripts/iac-scan-paths.sh" --terraform)
P3_DIR="$(bash "$ROOT/scripts/iac-scan-paths.sh" --compose | head -n1)"

tf_args=()
for d in "${TF_DIRS[@]}"; do
  tf_args+=(-d "$d")
done

log "checkov terraform: ${TF_DIRS[*]}"
checkov "${tf_args[@]}" --framework terraform \
  --hard-fail-on CRITICAL,HIGH,MEDIUM,LOW \
  --compact

log "checkov docker_compose: $P3_DIR"
checkov -d "$P3_DIR" --framework docker_compose \
  --hard-fail-on CRITICAL,HIGH,MEDIUM,LOW \
  --compact

log "checkov-iac-gate: OK"
