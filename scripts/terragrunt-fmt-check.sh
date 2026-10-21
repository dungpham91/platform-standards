#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     terragrunt-fmt-check.sh
# Purpose:    Check Terragrunt HCL format and syntax under live/ (no AWS creds).
# Version:    1.0.0
# Requires:   bash 4+, terragrunt (TERRAGRUNT_BIN override optional)
# Usage:      bash scripts/terragrunt-fmt-check.sh
# Exit codes: 0 pass, 1 fmt or hcl validate failure
# Related:    src/problem1/terraform/live/, docs/VERSION-PINS.md
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$ROOT/scripts/lib/common.sh"

LIVE="$ROOT/src/problem1/terraform/live"
TG="${TERRAGRUNT_BIN:-terragrunt}"

if ! command -v "$TG" >/dev/null 2>&1; then
  die "Missing terragrunt — install or set TERRAGRUNT_BIN"
fi

for f in "$LIVE/root.hcl" "$LIVE/dev/terragrunt.hcl" "$LIVE/prod/terragrunt.hcl"; do
  log "terragrunt hcl fmt --check --file $f"
  "$TG" hcl fmt --check --file "$f"
done

log "terragrunt hcl validate (live tree)"
( cd "$LIVE" && "$TG" hcl validate )

log "terragrunt-fmt-check: OK"
