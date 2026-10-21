#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     security-scan.sh
# Purpose:    Local Trivy IaC/image, Checkov gate, Gitleaks; write reports/*.sarif.
# Version:    1.0.1
# Requires:   bash 4+, trivy; optional checkov, gitleaks, docker
# Usage:      bash scripts/security-scan.sh
# Exit codes: 0 pass, 1 scanner findings or hard failure
# Related:    docs/LOCAL-SCAN.md, scripts/checkov-iac-gate.sh
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$ROOT/scripts/lib/common.sh"

REPORTS="$ROOT/reports"
SEV="CRITICAL,HIGH,MEDIUM,LOW"
mapfile -t IAC_DIRS < <(bash "$ROOT/scripts/iac-scan-paths.sh")

mkdir -p "$REPORTS"

install_trivy() {
  if command -v trivy >/dev/null 2>&1; then
    return
  fi
  retry 3 curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.76.0
}

install_trivy

echo "== Trivy IaC (all severities) =="
trivy config --format sarif --output "$REPORTS/trivy-terraform.sarif" \
  --severity "$SEV" "${IAC_DIRS[@]}"
trivy config --format table --severity "$SEV" "${IAC_DIRS[@]}"
trivy config --exit-code 1 --severity "$SEV" "${IAC_DIRS[@]}"

if command -v checkov >/dev/null 2>&1; then
  log "== Checkov IaC (terraform modules + live, Problem 3 compose) =="
  bash "$ROOT/scripts/checkov-iac-gate.sh"
else
  log "SKIP checkov (pip install checkov for local parity with CI)"
fi

if command -v gitleaks >/dev/null 2>&1; then
  echo "== Gitleaks (SARIF) =="
  gitleaks detect --source "$ROOT" --no-banner --config "$ROOT/.gitleaks.toml" \
    --report-format sarif --report-path "$REPORTS/gitleaks.sarif" \
    --exit-code 1
fi

if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  for ctx in \
    "$ROOT/src/problem4/apps/backend:devopslite-trading-api:scan" \
    "$ROOT/src/problem3/api:devopslite-problem3-api:scan"; do
    IFS=: read -r context tag <<<"$ctx"
    docker build -q -t "$tag" "$context"
    echo "== Trivy image $tag =="
    trivy image --format sarif --output "$REPORTS/trivy-image-${tag//:/-}.sarif" \
      --severity "$SEV" "$tag"
    trivy image --exit-code 1 --severity "$SEV" "$tag"
  done
fi

echo "SARIF written to $REPORTS/ (upload in CI via upload-sarif)"
