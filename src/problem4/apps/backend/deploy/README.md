# Backend CodeDeploy revision (Problem 4)

GitHub Actions uploads a **revision zip** (this AppSpec + scripts + generated `image_uri`) to S3, then starts a CodeDeploy deployment. See [problem4-backend-ci.yml](../../../../../.github/workflows/problem4-backend-ci.yml) job `deploy-ec2`.

## Revision contents

| Path in zip | Role |
| --- | --- |
| `appspec.yml` | Copied from [appspec.yaml](appspec.yaml) at deploy time |
| `scripts/start-api.sh` | `ApplicationStart` hook — reads [scripts/image_uri](scripts/image_uri) (written in CI, gitignored) |
| `scripts/image_uri` | Full ECR image URI for the release (`account.dkr.ecr.region.amazonaws.com/repo:tag`) |

## EC2 target (deployment group)

Each instance in the CodeDeploy deployment group should have:

- **Docker** installed and running.
- **AWS CLI** (for `aws ecr get-login-password` in the hook).
- **CodeDeploy agent** installed and healthy.
- **IAM instance profile** allowing at least:
  - `ecr:GetAuthorizationToken` (resource `*`)
  - `ecr:BatchGetImage`, `ecr:GetDownloadUrlForLayer` on the API repository
  - Read access to the revision object in `CODEDEPLOY_REVISION_BUCKET` (via CodeDeploy service role or instance profile per your design)

Optional environment on the instance: `AWS_REGION`, `CONTAINER_NAME`, `HOST_PORT` (defaults in [start-api.sh](scripts/start-api.sh)).

## GitHub OIDC role (workflow)

The `AWS_ROLE_ARN` used in Actions should allow at least:

- ECR push for `build-push-ecr` (`ecr:*` scoped to the API repository, plus `ecr:GetAuthorizationToken`)
- `s3:PutObject` on `s3://<CODEDEPLOY_REVISION_BUCKET>/codedeploy/*` for revision upload
- `codedeploy:CreateDeployment` (and typically `codedeploy:GetApplication`, `codedeploy:GetDeploymentGroup`)

Variables and secrets: [GITHUB-ACTIONS-SECRETS.md](../../../../../docs/GITHUB-ACTIONS-SECRETS.md).

## CI job split (no double Docker build)

On push to `main`/`master` with `DEPLOY_ENABLED=true`, job `build` is **skipped**; `build-push-ecr` performs the only image build and ECR push. Job `deploy-ec2` only packages CodeDeploy artifacts and calls AWS APIs.
