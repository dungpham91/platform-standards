# Trading platform — Terraform + Terragrunt

## Layout

| Path | Role |
| --- | --- |
| [live/root.hcl](live/root.hcl) | **S3 remote state**, generated provider, shared tags (`CostCenter`, …) |
| [live/dev](live/dev/terragrunt.hcl) | Dev stack inputs |
| [live/prod](live/prod/terragrunt.hcl) | Prod stack inputs |
| [modules/stack/regional](modules/stack/regional) | Composed regional cell |
| [modules/*](modules/) | foundation, network, workloads, data, edge, observability |

## Commands

```bash
export TG_STATE_BUCKET=platform-terraform-state-YOUR_SUFFIX
export TG_LOCK_TABLE=platform-terraform-locks-YOUR_SUFFIX
export TF_VAR_db_password='from-secret-manager'
# When Slack alarms enabled (prod): export TF_VAR_slack_webhook_url='...'
cd live/dev
terragrunt init
terragrunt plan
```

## Module promotion

Tag repo → apply dev → staging → prod with same tag. Separate state keys per Terragrunt path.

## CI

fmt, module I/O A–Z (`scripts/terraform-io-sort.sh`), validate + module tests, Trivy, Checkov — [.github/workflows/pr-quality-gate.yml](../../../.github/workflows/pr-quality-gate.yml).

Tooling rationale: [docs/SCANNING-TOOLS.md](../../../docs/SCANNING-TOOLS.md).
