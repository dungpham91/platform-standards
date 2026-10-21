#!/usr/bin/env bash
# Reference EC2 deploy hook (SSM / manual). Production in this repo uses CodeDeploy — see apps/backend/deploy/.
# Install on host as /opt/backend/bin/deploy.sh
set -euo pipefail

IMAGE_DIGEST="${1:?ECR image digest (sha256:...)}"
ECR_REGISTRY="${ECR_REGISTRY:?}"
ECR_REPOSITORY="${ECR_REPOSITORY:?platform-trading-api}"
IMAGE="${ECR_REGISTRY}/${ECR_REPOSITORY}@${IMAGE_DIGEST}"
STATE_DIR="/opt/backend/state"
ACTIVE_FILE="${STATE_DIR}/active_port"
BLUE_PORT="${BLUE_PORT:-8081}"
GREEN_PORT="${GREEN_PORT:-8082}"
HEALTH_PATH="${HEALTH_PATH:-/health}"

mkdir -p "$STATE_DIR"
CURRENT="$(cat "$ACTIVE_FILE" 2>/dev/null || echo "$BLUE_PORT")"
if [[ "$CURRENT" == "$BLUE_PORT" ]]; then
  NEXT="$GREEN_PORT"
else
  NEXT="$BLUE_PORT"
fi

aws ecr get-login-password --region "${AWS_REGION:?}" \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"

docker pull "$IMAGE"
docker rm -f "backend-${NEXT}" 2>/dev/null || true
docker run -d --name "backend-${NEXT}" -p "127.0.0.1:${NEXT}:3000" \
  --env-file /opt/backend/backend.env "$IMAGE"

for _ in $(seq 1 30); do
  if curl -sf "http://127.0.0.1:${NEXT}${HEALTH_PATH}" >/dev/null; then
    echo "$NEXT" >"$ACTIVE_FILE"
    echo "Healthy on port ${NEXT}; switch nginx upstream to backend_${NEXT}."
    exit 0
  fi
  sleep 2
done

docker rm -f "backend-${NEXT}" 2>/dev/null || true
echo "Health check failed for ${IMAGE}" >&2
exit 1
