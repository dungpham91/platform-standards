#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     iac-scan-paths.sh
# Purpose:    Single source of truth for Trivy/Checkov IaC scan directories.
# Version:    1.2.1
# Requires:   bash 4+
# Usage:      bash scripts/iac-scan-paths.sh [--relative] [--terraform|--compose]
# Exit codes: 0 always (stdout is one path per line)
# Related:    scripts/security-scan.sh, scripts/checkov-iac-gate.sh, pr-quality-gate.yml
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELATIVE=0
SCOPE="all"
WANT_TERRAFORM=0
WANT_COMPOSE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --relative) RELATIVE=1; shift ;;
    --terraform) WANT_TERRAFORM=1; shift ;;
    --compose) WANT_COMPOSE=1; shift ;;
    -h | --help)
      echo "Usage: bash scripts/iac-scan-paths.sh [--relative] [--terraform|--compose]" >&2
      exit 0
      ;;
    *)
      echo "iac-scan-paths: unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ "$WANT_TERRAFORM" -eq 1 && "$WANT_COMPOSE" -eq 1 ]]; then
  echo "iac-scan-paths: use only one of --terraform or --compose" >&2
  exit 2
fi

if [[ "$WANT_TERRAFORM" -eq 1 ]]; then
  SCOPE="terraform"
elif [[ "$WANT_COMPOSE" -eq 1 ]]; then
  SCOPE="compose"
fi

REL_TERRAFORM=(
  src/problem1/terraform/modules
  src/problem1/terraform/live
)
REL_COMPOSE=(src/problem3)

emit() {
  local rel=$1
  if [[ "$RELATIVE" -eq 1 ]]; then
    printf '%s\n' "$rel"
  else
    printf '%s\n' "$ROOT/$rel"
  fi
}

case "$SCOPE" in
  all)
    for rel in "${REL_TERRAFORM[@]}" "${REL_COMPOSE[@]}"; do
      emit "$rel"
    done
    ;;
  terraform)
    for rel in "${REL_TERRAFORM[@]}"; do
      emit "$rel"
    done
    ;;
  compose)
    for rel in "${REL_COMPOSE[@]}"; do
      emit "$rel"
    done
    ;;
esac
