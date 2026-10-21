#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     tests/iac_scan_paths_smoke.sh
# Purpose:    Assert iac-scan-paths.sh scopes match CI expectations.
# Version:    1.0.0
# Requires:   bash 4+
# Usage:      bash tests/iac_scan_paths_smoke.sh
# Exit codes: 0 pass, 1 unexpected path counts
# Related:    scripts/iac-scan-paths.sh, tests/run_mock_tests.sh
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

count_lines() {
  bash "$ROOT/scripts/iac-scan-paths.sh" "$@" | wc -l | tr -d ' '
}

all_count="$(count_lines --relative)"
tf_count="$(count_lines --relative --terraform)"
compose_count="$(count_lines --relative --compose)"

if [[ "$all_count" != "3" || "$tf_count" != "2" || "$compose_count" != "1" ]]; then
  echo "iac_scan_paths_smoke: FAIL (all=$all_count terraform=$tf_count compose=$compose_count)" >&2
  exit 1
fi

echo "iac_scan_paths_smoke: OK"
