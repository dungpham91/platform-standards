#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script:     tests/problem3_smoke.sh
# Purpose:    Build and smoke-test Problem 3 Compose stack (/ and /api/users).
# Version:    1.0.0
# Requires:   bash 4+, docker compose, curl
# Usage:      bash tests/problem3_smoke.sh
# Exit codes: 0 smoke pass, 1 curl/compose failure
# Related:    src/problem3/, pr-quality-gate problem3-compose-smoke job
# ------------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_DIR="$ROOT/src/problem3"

cd "$COMPOSE_DIR"
docker compose down -v --remove-orphans 2>/dev/null || true
docker compose up --build -d

cleanup() {
  cd "$COMPOSE_DIR"
  docker compose down -v --remove-orphans 2>/dev/null || true
}
trap cleanup EXIT

for i in $(seq 1 30); do
  if curl -sf "http://localhost:8080/" >/dev/null; then
    break
  fi
  sleep 2
done

curl -sf "http://localhost:8080/" | grep -q "Welcome"
curl -sf "http://localhost:8080/api/users" | grep -q '"ok":true'

echo "problem3_smoke: OK"
