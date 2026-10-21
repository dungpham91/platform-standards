#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     issue1-disk-triage.sh
# Purpose:    Problem 2 — triage disk-full on NGINX load-balancer VM (Issue 1).
# Version:    1.0.0
# Requires:   bash 4+, coreutils; run on LB VM (sudo recommended)
# Usage:      sudo bash scripts/issue1-disk-triage.sh
# Exit codes: 0 completed triage output, non-zero on set -e command failure
# Related:    src/problem2/SOLUTION.md
# ------------------------------------------------------------------------------
set -euo pipefail

echo "=== Step 1: block vs inode usage ==="
df -h /
df -i /

echo ""
echo "=== Step 2: top directories (may take ~30s) ==="
du -xh /var /usr /opt /home 2>/dev/null | sort -h | tail -15

echo ""
echo "=== Step 3: NGINX log sizes ==="
if [[ -d /var/log/nginx ]]; then
  ls -lh /var/log/nginx/
  du -sh /var/log/nginx/
else
  echo "(no /var/log/nginx on this host — expected in lab VM only)"
fi

echo ""
echo "=== Step 4: journald disk ==="
if command -v journalctl >/dev/null; then
  journalctl --disk-usage || true
fi

echo ""
echo "=== Step 5: largest files under /var/log ==="
find /var/log -type f -size +50M 2>/dev/null | head -20 || true

echo ""
echo "Done. Compare output to expected patterns in SOLUTION.md"
