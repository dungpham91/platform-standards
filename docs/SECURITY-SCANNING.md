# Security scanning and GitHub Advanced Security (SARIF)

## Severity policy

All scanners run with **`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`**. Pull requests fail if any finding remains in those levels (unless explicitly allowlisted with reason).

## Tools

| Tool | Target | SARIF category |
| --- | --- | --- |
| Dependency Review | New/changed dependencies on PR | GitHub Dependency graph (PR check) |
| CodeQL | JavaScript (Problem 3 API + Problem 4 apps) | Code scanning (category `problem3-problem4-javascript`) |
| Gitleaks | Secrets in git tree | `gitleaks` |
| Trivy config | Paths from [`scripts/iac-scan-paths.sh`](../scripts/iac-scan-paths.sh) | `trivy-terraform` |
| Trivy image | Problem 3 API + Problem 4 backend images (PR gate build) | `trivy-image` (per-job upload; same category label) |
| Checkov | Same path list (`--terraform` + `--compose` slices) | `checkov-terraform`, `checkov-docker-compose` |

Why Trivy and Checkov together: [SCANNING-TOOLS.md](SCANNING-TOOLS.md). Deploy/Slack **credentials** for Actions are documented in [GITHUB-ACTIONS-SECRETS.md](GITHUB-ACTIONS-SECRETS.md) (separate from IaC scan paths).

## Local

```bash
bash scripts/security-scan.sh
```

Reports: `reports/*.sarif` (gitignored). Fix findings before push; CI uploads the same formats to GitHub.

## GitHub — Code scanning alerts

1. Workflows use [github/codeql-action/upload-sarif](https://github.com/github/codeql-action/tree/main/upload-sarif) with **pinned commit SHA**.
2. Required permission: `security-events: write` on the job.
3. After a PR run, open **Security → Code scanning alerts** on the repository (requires GitHub Advanced Security or public repo default features per GitHub policy).
4. Each scan type uses a distinct **`category`** so results do not overwrite each other.

**Authoritative PR scan:** [pr-quality-gate.yml](../.github/workflows/pr-quality-gate.yml). Path-filtered backend/terraform workflows avoid duplicating Trivy gates.

## Allowlisting

- Trivy: [.trivyignore](../.trivyignore) in repo root (English comment per rule).
- Gitleaks: [.gitleaks.toml](../.gitleaks.toml) allowlist with justification in PR.
- Checkov: skip/check flags only via reviewed CI config or inline `# checkov:skip=` with ticket reference.
- Never allowlist without ticket/review for CRITICAL/HIGH.

## Review discipline

Do not downgrade scan severity in CI or add allowlist entries without PR review and a ticket reference for CRITICAL/HIGH findings.
