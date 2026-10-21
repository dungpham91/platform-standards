#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     tests/run_mock_tests.sh
# Purpose:    Orchestrate local mock checks (terraform, workflows, optional P3 Docker).
# Version:    1.0.1
# Requires:   bash 4+; optional terraform, docker
# Usage:      bash tests/run_mock_tests.sh
# Exit codes: 0 pass (skips OK), 1 sub-suite failed
# Related:    README.md, .github/workflows/pr-quality-gate.yml
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "== Mock test suite =="
echo "Note: skipped checks are OK locally; CI pr-quality-gate is authoritative."

bash "$ROOT/tests/terraform_validate.sh"

bash "$ROOT/tests/iac_scan_paths_smoke.sh"

bash "$ROOT/tests/workflow_sanity.sh"

if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  bash "$ROOT/tests/problem3_smoke.sh"
else
  echo "SKIP problem3_smoke (docker not available)"
fi

echo "== All mock checks passed =="
