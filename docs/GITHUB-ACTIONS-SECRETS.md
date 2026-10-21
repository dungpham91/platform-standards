# GitHub Actions — secrets, variables, and environments

Assessment repo: deploy and Slack notify jobs are **gated** until you configure GitHub. Workflows use standard patterns (`secrets.*`, `vars.*`, protected environments) — no credentials in YAML.

## Repository variables (Settings → Secrets and variables → Actions → Variables)

| Variable | Example | Used when |
| --- | --- | --- |
| `DEPLOY_ENABLED` | `true` | Push deploy jobs on `production` (`problem4-*-ci.yml`) |
| `SLACK_ALERTS_ENABLED` | `true` | [slack-ci-alerts.yml](../.github/workflows/slack-ci-alerts.yml) |
| `AWS_REGION` | `ap-southeast-1` | P4 deploy (optional; workflows default to `ap-southeast-1` if unset) |
| `FRONTEND_S3_BUCKET` | `devopslite-trading-web` | Frontend S3 sync |
| `ECR_REPOSITORY` | `devopslite-trading-api` | Backend ECR repository name (local tag + push) |
| `CODEDEPLOY_APPLICATION` | `devopslite-trading-api` | CodeDeploy application (backend deploy) |
| `CODEDEPLOY_DEPLOYMENT_GROUP` | `devopslite-trading-api-prod` | CodeDeploy deployment group (backend deploy) |
| `CODEDEPLOY_REVISION_BUCKET` | `devopslite-codedeploy-revisions-YOUR_SUFFIX` | S3 bucket for CodeDeploy revision bundles (AppSpec + `scripts/image_uri`) |

Non-sensitive names only — never put passwords or webhooks in **Variables**.

When `DEPLOY_ENABLED=true`, backend deploy also requires `CODEDEPLOY_*` variables; frontend deploy requires `CLOUDFRONT_DISTRIBUTION_ID` on environment `production`. Backend **build-push-ecr** runs once per release; **deploy-ec2** only uploads the revision zip and calls CodeDeploy (no second Docker build).

## Environment secrets (Settings → Environments)

### `production`

Used by deploy jobs (`environment: production`). Configure **OIDC trust** for `AWS_ROLE_ARN` in IAM before enabling `DEPLOY_ENABLED`.

| Secret | Purpose |
| --- | --- |
| `AWS_ROLE_ARN` | IAM role for `aws-actions/configure-aws-credentials` (OIDC) |
| `CLOUDFRONT_DISTRIBUTION_ID` | CloudFront invalidation after S3 sync (frontend) |

### `ci-alerts`

| Secret | Purpose |
| --- | --- |
| `SLACK_WEBHOOK_URL` | Incoming webhook for CI failure posts |

## Not stored in GitHub Actions

Terragrunt / Terraform sensitive inputs stay **out of CI** in this repo (plan/apply from workstation or a future dedicated apply workflow):

- `TF_VAR_db_password`
- `TF_VAR_redis_auth_token`
- `TF_VAR_slack_webhook_url` (runtime Slack via Terraform observability module)

See [APPLY-AND-VERIFY.md](APPLY-AND-VERIFY.md).

## Enable checklist

1. Create environments `production` and `ci-alerts` (optional reviewers on `production`).
2. Add environment secrets above.
3. Set repository variables (`DEPLOY_ENABLED`, `SLACK_ALERTS_ENABLED`, and when deploying backend: `CODEDEPLOY_*`, `CODEDEPLOY_REVISION_BUCKET`, `ECR_REPOSITORY`) before setting gates to `true`.
4. Configure AWS OIDC identity provider + IAM role trust for this repository.
5. **IAM (OIDC role):** ECR push/pull permissions for the API repo; `s3:PutObject` on `s3://<CODEDEPLOY_REVISION_BUCKET>/codedeploy/*`; CodeDeploy `CreateDeployment` (see [backend deploy README](../src/problem4/apps/backend/deploy/README.md)).
6. **EC2 / CodeDeploy:** Docker + agent on targets; instance profile for ECR pull at hook time; bucket policy so CodeDeploy can read revision objects.

PR validation ([pr-quality-gate.yml](../.github/workflows/pr-quality-gate.yml)) does **not** require these secrets.
