#!/usr/bin/env bash
# Example: GitHub Actions invokes SSM Run Command instead of CodeDeploy (reference only).
# Usage: bash ssm-backend-command.sh <ec2-instance-id> <image-digest>
set -euo pipefail

INSTANCE_ID="${1:?EC2 instance id}"
DIGEST="${2:?ECR image digest sha256:...}"
REMOTE_CMD="/opt/backend/bin/deploy.sh ${DIGEST}"

aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --instance-ids "$INSTANCE_ID" \
  --parameters "commands=[\"${REMOTE_CMD}\"]" \
  --output text \
  --query "Command.CommandId"
