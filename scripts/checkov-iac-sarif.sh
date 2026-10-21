#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     checkov-iac-sarif.sh
# Purpose:    Export Checkov results to SARIF for GitHub code scanning uploads.
# Version:    1.0.2
# Requires:   bash 4+, checkov on PATH
# Usage:      bash scripts/checkov-iac-sarif.sh [reports_dir]
# Exit codes: 0 SARIF written (soft-fail scan), non-zero on checkov crash
# Related:    scripts/checkov-iac-gate.sh, docs/SECURITY-SCANNING.md
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORTS="${1:-$ROOT/reports}"

mkdir -p "$REPORTS"

mapfile -t TF_DIRS < <(bash "$ROOT/scripts/iac-scan-paths.sh" --terraform)
P3_DIR="$(bash "$ROOT/scripts/iac-scan-paths.sh" --compose | head -n1)"

tf_args=()
for d in "${TF_DIRS[@]}"; do
  tf_args+=(-d "$d")
done

checkov "${tf_args[@]}" --framework terraform \
  --hard-fail-on CRITICAL,HIGH,MEDIUM,LOW \
  --output sarif --output-file-path "$REPORTS/checkov-terraform.sarif" \
  --soft-fail

checkov -d "$P3_DIR" --framework docker_compose \
  --hard-fail-on CRITICAL,HIGH,MEDIUM,LOW \
  --output sarif --output-file-path "$REPORTS/checkov-docker-compose.sarif" \
  --soft-fail
