# Terragrunt live stacks

## Required environment

```bash
export TG_STATE_BUCKET=platform-terraform-state-YOUR_SUFFIX
export TG_LOCK_TABLE=platform-terraform-locks-YOUR_SUFFIX
export TF_VAR_db_password='from-secret-manager'
export TF_VAR_redis_auth_token='min-16-chars-from-secret-manager'
```

When `enable_slack_notifications = true` (prod):

```bash
export TF_VAR_slack_webhook_url='https://hooks.slack.com/services/...'
```

## Commands

```bash
cd dev   # or prod
terragrunt init
terragrunt plan
```

Shared config: [root.hcl](root.hcl).
