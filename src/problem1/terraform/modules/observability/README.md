# observability

Platform alerting: CloudWatch → SNS → optional Lambda → Slack. ALB 5xx and RDS CPU alarms are included; extend with custom metrics as services land on ECS.

## Usage

```hcl
module "observability" {
  source = "../../observability"

  alb_arn_suffix             = module.edge.alb_arn_suffix
  enable_slack_notifications = true
  environment                = "prod"
  kms_key_arn                = module.foundation.kms_key_arn
  name_prefix                = "platform-trading"
  slack_webhook_url          = var.slack_webhook_url
}
```

## Requirements

| Name | Version |
| --- | --- |
| terraform | >= 1.16.0, < 2.0.0 |
| aws | >= 5.100.0, < 6.0.0 |
| archive | >= 2.6.0, < 3.0.0 |

## Inputs

| Name | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `alb_arn_suffix` | `string` | no | `""` | ALB ARN suffix for CloudWatch ALB metrics |
| `enable_slack_notifications` | `bool` | no | `false` | Subscribe SNS alerts to Slack via Lambda |
| `environment` | `string` | yes | — | Environment name (`dev`, `staging`, `prod`) |
| `kms_key_arn` | `string` | yes | — | CMK for SNS encryption |
| `name_prefix` | `string` | yes | — | Prefix for resource names and tags |
| `slack_webhook_url` | `string` | no | `""` | Slack incoming webhook (sensitive) |

## Outputs

| Name | Description |
| --- | --- |
| `sns_topic_arn` | SNS topic for platform alarms |

## Tests

```bash
terraform init -backend=false
terraform validate
terraform test
```

See [tests/observability.tftest.hcl](tests/observability.tftest.hcl).
