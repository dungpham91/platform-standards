# foundation

Account-level security baseline for the trading platform: encryption key, immutable audit storage, organization-style CloudTrail, and GuardDuty.

## Usage

Called from [stack/regional](../stack/regional/main.tf). Standalone example:

```hcl
module "foundation" {
  source = "../../foundation"

  audit_bucket_name = "devopslite-trading-dev-audit-UNIQUE_SUFFIX"
  environment       = "dev"
  name_prefix       = "devopslite-trading"
}
```

## Requirements

| Name | Version |
| --- | --- |
| terraform | >= 1.16.0, < 2.0.0 |
| aws | >= 5.100.0, < 6.0.0 |

## Inputs

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `audit_bucket_name` | `string` | yes | Globally unique S3 bucket for CloudTrail and audit logs |
| `environment` | `string` | yes | Environment label (`dev`, `staging`, `prod`) |
| `name_prefix` | `string` | yes | Prefix for resource names and tags |

## Outputs

| Name | Description |
| --- | --- |
| `audit_bucket_id` | Audit log S3 bucket id |
| `kms_key_arn` | Platform CMK ARN for encryption at rest (RDS, SNS, audit bucket) |

## Resources (summary)

- KMS key with rotation
- Versioned, encrypted audit S3 bucket with access logging
- CloudTrail (multi-region) → S3 and CloudWatch Logs
- GuardDuty detector

## Tests

From this directory:

```bash
terraform init -backend=false
terraform validate
terraform test
```

Mock plan tests live in [tests/foundation.tftest.hcl](tests/foundation.tftest.hcl).
