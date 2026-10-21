# Repository guardrails — block bad code before it lands

Defense in depth: **local hooks → PR CI (required) → branch protection**. Scanning only on `main` after merge is too late.

## Layer 1 — Local (developer machine)

| Tool | Install | What it blocks |
| --- | --- | --- |
| [pre-commit](https://pre-commit.com/) | `pip install pre-commit && pre-commit install` | Secrets, private keys, bad YAML, `terraform fmt`, module **variables/outputs A–Z**, actionlint, shellcheck, large files, direct commit to `main`, quick quality gate |
| Pre-push hook | `bash scripts/install-git-hooks.sh` | Quick tests + workflow sanity before `git push` |
| Staged-path check | `bash scripts/verify-clean-tree.sh` | Blocks staged paths that [.gitignore](../.gitignore) excludes |
| Full local lint | `bash scripts/lint-all.sh` | shellcheck/shfmt, module I/O A–Z, Terraform fmt, P4 npm tests |
| Full local scan | `bash scripts/security-scan.sh` | Trivy + Checkov + Gitleaks (+ image if Docker available) |

Config: [.pre-commit-config.yaml](../.pre-commit-config.yaml), [scripts/quality-gate-quick.sh](../scripts/quality-gate-quick.sh).

`git push --no-verify` bypasses local hooks — **Layer 2 is mandatory**.

## Layer 2 — Pull request CI (required checks)

Workflow [pr-quality-gate.yml](../.github/workflows/pr-quality-gate.yml) runs on **every** PR:

- Gitleaks (secrets) → SARIF category `gitleaks`
- Trivy IaC + container image — severities **CRITICAL through LOW** → SARIF `trivy-terraform`, `trivy-image`
- Checkov Terraform + live Terragrunt paths + Problem 3 Compose → SARIF `checkov-terraform`, `checkov-docker-compose`
- Terraform fmt + **module I/O A–Z** (`scripts/terraform-io-sort.sh --check`) + **validate all modules** (`scripts/terraform-validate-all-modules.sh`, includes `terraform test` per module)
- Backend, frontend, and Problem 3 API tests + container image scans (P3 + P4)
- actionlint + **shellcheck/shfmt** via `scripts/lint-shell.sh`

Path-filtered workflows ([terraform-ci.yml](../.github/workflows/terraform-ci.yml), [problem4-backend-ci.yml](../.github/workflows/problem4-backend-ci.yml)) add fast feedback on large trees; **they do not replace** the PR gate scans.

**Do not merge** until `pr-quality-gate` is green.

## Layer 3 — GitHub branch protection (admin setup)

On `main` / `master` in GitHub **Settings → Branches**:

1. Require a pull request before merging.
2. Require status checks to pass — minimum: **`gate`** job inside `pr-quality-gate` (or the full workflow name per GitHub UI).
3. Require linear history or squash (team preference).
4. Restrict who can push bypassing rules (no one for normal devs).
5. Enable **Secret scanning** and **Push protection** (GitHub Advanced Security if available).
6. Enable **Dependabot** security updates ([dependabot.yml](../.github/dependabot.yml)).

Document owner: platform team. Without branch protection, bad code can still reach the remote with `--no-verify`.

SARIF upload and severity policy: [SECURITY-SCANNING.md](SECURITY-SCANNING.md).

Deploy (P4) and CI Slack notify use **environment secrets** and **repository variables** — not repo-level secret sprawl. See [GITHUB-ACTIONS-SECRETS.md](GITHUB-ACTIONS-SECRETS.md).

## Layer 4 — Post-merge (runtime)

Production alarms and Slack: [MONITORING-SLACK.md](MONITORING-SLACK.md) and Terraform [observability module](../src/problem1/terraform/modules/observability/).

## Hook bypass

Do not use `git push --no-verify` or skip required CI checks to force a green merge. Fix findings or get an explicit team exception documented in the PR.

After `git add`, run `bash scripts/verify-clean-tree.sh`. Workstation-only and generated paths are defined in [.gitignore](../.gitignore) only — not duplicated in this doc.
