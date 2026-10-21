# Naming conventions

Consistent names make problems, modules, and CI jobs easy to find.

## Top-level layout

| Pattern | Example | Use |
| --- | --- | --- |
| `src/problem{N}/` | `src/problem3/` | Assessment problem deliverables |
| `docs/{TOPIC}.md` | `docs/REPO-GUARDRAILS.md` | Team runbooks (UPPER-KEBAB topic) |
| `scripts/{action}-{scope}.sh` | `scripts/checkov-iac-gate.sh` | Repo automation (lowercase kebab) |
| `tests/{scope}_{kind}.sh` | `tests/problem3_smoke.sh`, `tests/iac_scan_paths_smoke.sh` | Cross-problem verification |
| `.github/workflows/{scope}-{purpose}.yml` | `problem4-backend-ci.yml` | GitHub Actions (lowercase kebab) |

Every `*.sh` starts with a **metadata header** (Script, Purpose, Version, Requires, Usage, Exit codes, Related). Bump **Version** when behavior or requirements change.

## Problem 1 — Terraform

| Pattern | Example |
| --- | --- |
| Module directory | `modules/foundation`, `modules/network` (single lowercase noun) |
| Stack wrapper | `modules/stack/regional/` |
| Live Terragrunt | `live/dev/terragrunt.hcl`, `live/root.hcl` |
| Module tests | `tests/{module}.tftest.hcl` |
| Lock file | `.terraform.lock.hcl` per module (commit) |
| Module I/O files | `variables.tf`, `outputs.tf` — blocks sorted **A–Z** by name (`scripts/terraform-io-sort.sh`) |

## Problems 2–5

| Pattern | Example |
| --- | --- |
| Write-up | `SOLUTION.md` at problem root |
| Problem-local scripts | `src/problem2/scripts/issue1-disk-triage.sh` (`issue{N}-{topic}.sh`) |
| Apps (Problem 4) | `src/problem4/apps/backend`, `apps/frontend` |
| App tests | `{app}/test/*.test.js` |

## Do not commit

Workstation-local and generated paths: see [.gitignore](../.gitignore) (not repeated here).

Before push: `bash scripts/verify-clean-tree.sh` (also runs in `quality-gate-quick.sh`).
