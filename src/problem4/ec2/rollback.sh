#!/usr/bin/env bash
# Reference rollback: redeploy a known-good digest (SSM path). See deploy.sh and SOLUTION.md.
set -euo pipefail

IMAGE_DIGEST="${1:?previous ECR digest sha256:...}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "${SCRIPT_DIR}/deploy.sh" "$IMAGE_DIGEST"
