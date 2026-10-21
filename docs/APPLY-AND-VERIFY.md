# Apply and verify

Use after mock tests pass locally.

## Mock (no cloud)

```bash
bash tests/run_mock_tests.sh
```

If Terraform or Docker is not installed locally, several checks **SKIP** with exit 0 — **CI on pull request is the authoritative gate** (`pr-quality-gate.yml`).

```bash
cd src/problem4/apps/backend && npm ci && npm test
docker build -t platform-trading-api:local src/problem4/apps/backend
curl -sf http://127.0.0.1:3000/health
```

## Problem 1 — Terragrunt (S3 remote state)

Create state bucket and lock table once (example names — use your suffix):

```bash
export TG_STATE_BUCKET=platform-terraform-state-YOUR_SUFFIX
export TG_LOCK_TABLE=platform-terraform-locks-YOUR_SUFFIX
export TF_VAR_db_password='strong-password-from-secret-manager'
# Optional when enable_slack_notifications = true:
# export TF_VAR_slack_webhook_url='https://hooks.slack.com/...'

cd src/problem1/terraform/live/dev
terragrunt init
terragrunt plan
```

Production: `cd ../prod`, same env vars, apply with change approval.

CI: fmt + validate all modules (includes `terraform test` per module) — [terraform-ci.yml](../.github/workflows/terraform-ci.yml). Full IaC/container scans — [pr-quality-gate.yml](../.github/workflows/pr-quality-gate.yml).

## Problem 3 — Docker

```bash
cd src/problem3 && docker compose up --build -d
curl -sf http://localhost:8080/api/users
```

## Problem 4 — GitHub Actions

- **Every PR and push to `main`/`master`:** [pr-quality-gate.yml](../.github/workflows/pr-quality-gate.yml) (Gitleaks, IaC, image scan, shell lint — no deploy secrets required; Dependency Review on PRs only).
- **Backend / frontend path changes:** [problem4-backend-ci.yml](../.github/workflows/problem4-backend-ci.yml), [problem4-frontend-ci.yml](../.github/workflows/problem4-frontend-ci.yml) (test, build; deploy gated by `DEPLOY_ENABLED`).

Deploy and Slack credentials: [GITHUB-ACTIONS-SECRETS.md](GITHUB-ACTIONS-SECRETS.md) (`production` / `ci-alerts` environment secrets, repository variables).

When enabling backend deploy, set repository variable `CODEDEPLOY_REVISION_BUCKET` (S3 for CodeDeploy revision zips) plus `CODEDEPLOY_APPLICATION` / `CODEDEPLOY_DEPLOYMENT_GROUP`. EC2 agent, Docker, and IAM expectations: [apps/backend/deploy/README.md](../src/problem4/apps/backend/deploy/README.md).

## Problem 2 and 5

Operational and architecture documentation — validate via peer review and tabletop exercises.
