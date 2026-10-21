#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     scripts/lib/common.sh
# Purpose:    Shared logging, die, require_cmd, retry for repo shell scripts.
# Version:    1.0.0
# Requires:   bash 4+ (source only — do not execute directly)
# Usage:      source "$ROOT/scripts/lib/common.sh"
# Exit codes: N/A (library)
# Related:    All scripts under scripts/ that source common.sh
# ------------------------------------------------------------------------------
set -euo pipefail

log() {
  printf '[%s] %s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$*"
}

die() {
  log "ERROR: $*"
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || {
    cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd
  }
}

retry() {
  local attempts=$1
  shift
  local n=1
  until "$@"; do
    if (( n >= attempts )); then
      return 1
    fi
    log "Retry $n/$attempts failed; sleeping 3s..."
    sleep 3
    n=$((n + 1))
  done
}
