#!/usr/bin/env bash
# Pull and run the API container image for this deployment revision.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_URI="$(tr -d '[:space:]' < "${SCRIPT_DIR}/image_uri")"

if [[ -z "${IMAGE_URI}" ]]; then
  echo "start-api.sh: image_uri file is empty" >&2
  exit 1
fi

AWS_REGION="${AWS_REGION:-ap-southeast-1}"
CONTAINER_NAME="${CONTAINER_NAME:-platform-api}"
HOST_PORT="${HOST_PORT:-3000}"

command -v docker >/dev/null 2>&1 || {
  echo "start-api.sh: docker is not installed on this instance" >&2
  exit 1
}

aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${IMAGE_URI%%/*}"

docker pull "${IMAGE_URI}"
docker stop "${CONTAINER_NAME}" 2>/dev/null || true
docker rm "${CONTAINER_NAME}" 2>/dev/null || true
docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  -p "${HOST_PORT}:3000" \
  "${IMAGE_URI}"
