# Platform standards

Enterprise-style **spot trading platform** reference: landing zone, multi-region design, Terraform modules, container stack, and CI/CD.

**Repository:** [github.com/dungpham91/platform-standards](https://github.com/dungpham91/platform-standards)

```bash
bash tests/run_mock_tests.sh
bash scripts/lint-shell.sh
bash scripts/verify-clean-tree.sh   # after git add — enforces .gitignore
```

Local mock tests **SKIP** Terraform/Docker when those tools are missing — pull request CI is authoritative.

| Document | Purpose |
| --- | --- |
| [docs/REPO-MAP.md](docs/REPO-MAP.md) | Where each problem lives |
| [docs/REPO-GUARDRAILS.md](docs/REPO-GUARDRAILS.md) | Block bad code **before** merge |
| [docs/GITHUB-REPO-SETUP.md](docs/GITHUB-REPO-SETUP.md) | Secret scanning, branch protection, environments |
| [docs/GITHUB-ACTIONS-SECRETS.md](docs/GITHUB-ACTIONS-SECRETS.md) | Actions secrets, variables, environments (P4 deploy, Slack) |
| [docs/SECURITY-SCANNING.md](docs/SECURITY-SCANNING.md) | Full severity scans + SARIF on GitHub |
| [docs/SCANNING-TOOLS.md](docs/SCANNING-TOOLS.md) | Why Trivy and Checkov both run in CI |
| [docs/FRONTEND-BACKEND-SECURITY.md](docs/FRONTEND-BACKEND-SECURITY.md) | Problem 4 app security notes |
| [docs/MONITORING-SLACK.md](docs/MONITORING-SLACK.md) | CI + platform alerts → Slack |
| [docs/APPLY-AND-VERIFY.md](docs/APPLY-AND-VERIFY.md) | Apply AWS/Docker after review |
| [docs/LOCAL-SCAN.md](docs/LOCAL-SCAN.md) | Gitleaks / Trivy / Checkov on your machine |
| [docs/VERSION-PINS.md](docs/VERSION-PINS.md) | Toolchain and dependency versions |
| [docs/NAMING.md](docs/NAMING.md) | File and folder naming conventions |

## Solutions

- [Problem 1 — Architecture & Terraform](src/problem1/SOLUTION.md)
- [Problem 2 — Operations troubleshooting](src/problem2/SOLUTION.md)
- [Problem 3 — Container platform debug](src/problem3/SOLUTION.md)
- [Problem 4 — CI/CD](src/problem4/SOLUTION.md)
- [Problem 5 — Security](src/problem5/SOLUTION.md)

Problem 4 uses a **monorepo** layout (backend + frontend + root workflows). Details: [src/problem4/SOLUTION.md](src/problem4/SOLUTION.md).

## CI in this repo

| Workflow | Role |
| --- | --- |
| [**pr-quality-gate.yml**](.github/workflows/pr-quality-gate.yml) | **Required** on PRs and push to `main`/`master` — Dependency Review (PR only), CodeQL, Gitleaks, Trivy, Checkov (TF + live + Compose), Terraform fmt + I/O A–Z + module tests, P3/P4 lint/build/test, P3 Compose smoke, image scans, shell lint |
| [terraform-ci.yml](.github/workflows/terraform-ci.yml) | Extra validate when only Terraform changes |
| [problem4-backend-ci.yml](.github/workflows/problem4-backend-ci.yml) | Backend lint/build/test, ECR, CodeDeploy |
| [problem4-frontend-ci.yml](.github/workflows/problem4-frontend-ci.yml) | Frontend lint/test/build, S3/CloudFront deploy |
| [slack-ci-alerts.yml](.github/workflows/slack-ci-alerts.yml) | Optional Slack on workflow failure |

Dependency updates: [.github/dependabot.yml](.github/dependabot.yml).
