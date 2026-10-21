# Repository map

| Area | Path | Notes |
| --- | --- | --- |
| Problem 1 — architecture + IaC | [src/problem1](../src/problem1) | [SOLUTION.md](../src/problem1/SOLUTION.md), [terraform](../src/problem1/terraform) |
| Problem 2 — troubleshooting | [src/problem2](../src/problem2) | Scripts + [SOLUTION.md](../src/problem2/SOLUTION.md) |
| Problem 3 — container stack | [src/problem3](../src/problem3) | Docker Compose |
| Problem 4 — delivery | [src/problem4](../src/problem4) | Apps + [.github/workflows](../.github/workflows) |
| P4 backend deploy (CodeDeploy) | [apps/backend/deploy/README.md](../src/problem4/apps/backend/deploy/README.md) | Revision zip, `IMAGE_URI` hook, EC2/IAM; pairs with [GITHUB-ACTIONS-SECRETS.md](GITHUB-ACTIONS-SECRETS.md) |
| Problem 5 — security | [src/problem5](../src/problem5) | Extends Problem 1 |
| Apply runbook | [APPLY-AND-VERIFY.md](APPLY-AND-VERIFY.md) | Post-local mock |
| Security scans (CI policy) | [SECURITY-SCANNING.md](SECURITY-SCANNING.md) | SARIF, severities, branch protection |
| Scan tooling | [SCANNING-TOOLS.md](SCANNING-TOOLS.md) | Trivy vs Checkov |
| Local scans | [LOCAL-SCAN.md](LOCAL-SCAN.md) | Gitleaks, Trivy, Checkov on workstation |
| P4 app security | [FRONTEND-BACKEND-SECURITY.md](FRONTEND-BACKEND-SECURITY.md) | CORS, headers, delivery |
| Guardrails | [REPO-GUARDRAILS.md](REPO-GUARDRAILS.md) | Hooks + required PR checks |
| GHA secrets pattern | [GITHUB-ACTIONS-SECRETS.md](GITHUB-ACTIONS-SECRETS.md) | Environments + `secrets.*` / `vars.*` |
| Mock tests | [tests](../tests) | `run_mock_tests.sh` (includes `iac_scan_paths_smoke.sh`) |
| Naming | [NAMING.md](NAMING.md) | Paths, workflows, Terraform modules |
| IaC scan paths | [scripts/iac-scan-paths.sh](../scripts/iac-scan-paths.sh) | Single list for Trivy/Checkov |
