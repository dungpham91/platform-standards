# Toolchain and dependency pins

Resolved from official registries on **2026-10-21**. Problem 3 API dependencies follow the problem spec; everything else tracks **current stable** at pin time.

| Component | Pin | Source |
| --- | --- | --- |
| Terraform (CI / local IaC) | 1.16.6 | [github.com/hashicorp/terraform/releases](https://github.com/hashicorp/terraform/releases) — match CI when running `terraform-validate-all-modules.sh` locally |
| Terragrunt (CI) | 1.1.6 | [github.com/gruntwork-io/terragrunt/releases](https://github.com/gruntwork-io/terragrunt/releases) |
| AWS provider | `>= 5.100.0, < 6.0.0` | Terraform Registry (latest 5.x: 5.100.0) |
| terraform-aws-modules/vpc/aws | 5.21.0 | Terraform Registry (latest 5.x line) |
| Node.js (CI / Docker) | 22 LTS | [nodejs.org](https://nodejs.org/) — current LTS line for apps |
| Trivy (CI / local script) | 0.76.0 | [github.com/aquasecurity/trivy/releases](https://github.com/aquasecurity/trivy/releases) |
| Checkov (CI) | 3.3.30 | [pypi.org/project/checkov](https://pypi.org/project/checkov/) |
| Gitleaks (CI) | 8.30.1 | [github.com/gitleaks/gitleaks/releases](https://github.com/gitleaks/gitleaks/releases) |
| Express (P4 API) | ^5.3.0 | npm |
| Helmet (P4 API) | ^8.3.0 | npm |
| nginx (P3 Compose) | 1.27.4-alpine | Docker Hub stable tag ([docker-compose.yml](../src/problem3/docker-compose.yml)) |
| PostgreSQL (P3 Compose) | 16-alpine | Docker Hub |
| Redis (P3 Compose) | 7.4-alpine | Docker Hub ([docker-compose.yml](../src/problem3/docker-compose.yml)) |

RDS / ElastiCache **engine versions** in Terragrunt (`postgres_engine_version`, `redis_engine_version`) are AWS account–specific; update after reviewing [RDS releases](https://docs.aws.amazon.com/AmazonRDS/latest/PostgreSQLReleaseNotes/) and ElastiCache docs.

Dependabot (`.github/dependabot.yml`) proposes weekly bumps for GitHub Actions, npm, and Dockerfiles.
