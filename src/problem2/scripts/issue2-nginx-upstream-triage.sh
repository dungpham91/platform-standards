#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     issue2-nginx-upstream-triage.sh
# Purpose:    Problem 2 — triage upstream 502/504 on NGINX load-balancer VM.
# Version:    1.0.0
# Requires:   bash 4+, nginx on host; run on LB VM (sudo recommended)
# Usage:      sudo bash scripts/issue2-nginx-upstream-triage.sh
# Exit codes: 0 completed triage output, non-zero on set -e command failure
# Related:    src/problem2/SOLUTION.md
# ------------------------------------------------------------------------------
set -euo pipefail

echo "=== Step 1: NGINX config test ==="
nginx -t

echo ""
echo "=== Step 2: recent upstream errors ==="
grep -E "upstream|timed out|refused" /var/log/nginx/error.log 2>/dev/null | tail -20 || echo "(no error.log or no matches)"

echo ""
echo "=== Step 3: connection summary ==="
ss -s

echo ""
echo "=== Step 4: file descriptor limit ==="
ulimit -n
cat /proc/sys/fs/file-nr

echo ""
echo "=== Step 5: upstream health (edit paths for your env) ==="
echo "curl -sf http://127.0.0.1/upstream-health || true"

echo ""
echo "Done. See SOLUTION.md for interpretation table."
