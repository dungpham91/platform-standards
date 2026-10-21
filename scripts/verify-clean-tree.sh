#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     verify-clean-tree.sh
# Purpose:    Reject git staged paths that .gitignore marks as local or generated.
# Version:    1.0.1
# Requires:   bash 4+, git repository
# Usage:      bash scripts/verify-clean-tree.sh   # run after git add
# Exit codes: 0 OK or nothing staged, 1 forbidden path staged
# Related:    .gitignore, scripts/quality-gate-quick.sh
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "verify-clean-tree: SKIP (not a git repository)"
  exit 0
fi

staged="$(git diff --cached --name-only 2>/dev/null || true)"
if [[ -z "$staged" ]]; then
  echo "verify-clean-tree: OK (nothing staged)"
  exit 0
fi

is_denied() {
  local path="$1"
  case "$path" in
    .local/* | .cursor/* | .cursorignore | .cursorrules)
      return 0
      ;;
    docs/examples/*)
      return 0
      ;;
  esac
  if [[ "$path" == *node_modules/* ]] || [[ "$path" == node_modules/* ]]; then
    return 0
  fi
  if [[ "$path" == *".terraform/"* ]] || [[ "$path" == .terraform/* ]]; then
    return 0
  fi
  if [[ "$path" == reports/* ]] || [[ "$path" == *.sarif ]] || [[ "$path" == *.tfplan ]]; then
    return 0
  fi
  return 1
}

failed=0
while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  if is_denied "$path"; then
    echo "ERROR: staged path must not be committed: $path"
    failed=1
  fi
done <<< "$staged"

if [[ "$failed" -ne 0 ]]; then
  echo "Unstage disallowed paths; see .gitignore."
  exit 1
fi

echo "verify-clean-tree: OK"
