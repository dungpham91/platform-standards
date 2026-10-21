# Terragrunt checks

Validates Terragrunt HCL **format and syntax** for live stacks (no AWS credentials required).

## Run

From repository root:

```bash
bash scripts/terragrunt-fmt-check.sh
```

Requires [Terragrunt](https://terragrunt.gruntwork.io/) on `PATH` (same version as CI — [VERSION-PINS.md](../../../../../docs/VERSION-PINS.md)).

## What is covered

- `terragrunt hcl fmt --check --file` on [root.hcl](../root.hcl), [dev/terragrunt.hcl](../dev/terragrunt.hcl), [prod/terragrunt.hcl](../prod/terragrunt.hcl)
- `terragrunt hcl validate` from the [live/](../) directory (syntax only, no AWS)

Plan/apply tests need `TG_STATE_BUCKET`, `TF_VAR_db_password`, and `TF_VAR_redis_auth_token` — see [../README.md](../README.md).
