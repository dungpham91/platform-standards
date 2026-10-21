# data

Data tier: RDS PostgreSQL (orders) and ElastiCache Redis (cache/sessions). Engine **version and instance class** are set by Terragrunt inputs, not hardcoded here.

## Usage

```hcl
module "data" {
  source = "../../data"

  allowed_security_group_ids = [module.workloads.app_security_group_id]
  db_password                = var.db_password
  enable_multi_az            = var.enable_multi_az
  environment                = "dev"
  kms_key_arn                = module.foundation.kms_key_arn
  name_prefix                = "platform-trading"
  postgres_engine_version    = "15.8"
  postgres_instance_class    = "db.t4g.micro"
  private_subnet_ids         = module.network.private_subnet_ids
  redis_auth_token           = var.redis_auth_token
  redis_engine_version       = "7.1"
  redis_node_type            = "cache.t4g.micro"
  redis_num_cache_clusters   = 1
  vpc_id                     = module.network.vpc_id
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
| `allowed_security_group_ids` | `list(string)` | yes | App tier SGs allowed to reach 5432/6379 |
| `db_password` | `string` | yes | RDS master password (sensitive) |
| `db_username` | `string` | no | RDS username (default `trading_admin`) |
| `enable_multi_az` | `bool` | yes | RDS Multi-AZ |
| `environment` | `string` | yes | Environment name (`dev`, `staging`, `prod`) |
| `kms_key_arn` | `string` | no | CMK for storage and Performance Insights |
| `name_prefix` | `string` | yes | Prefix for resource names and tags |
| `postgres_engine_version` | `string` | yes | PostgreSQL engine version pin |
| `postgres_instance_class` | `string` | yes | RDS instance class |
| `private_subnet_ids` | `list(string)` | yes | Private subnets for RDS/ElastiCache |
| `redis_auth_token` | `string` | no | AUTH token when transit encryption is enabled |
| `redis_engine_version` | `string` | yes | Redis engine version pin |
| `redis_node_type` | `string` | yes | ElastiCache node type |
| `redis_num_cache_clusters` | `number` | yes | Redis cluster count |
| `vpc_id` | `string` | yes | VPC ID |

## Outputs

| Name | Description |
| --- | --- |
| `data_security_group_id` | SG for RDS and Redis |
| `db_endpoint` | RDS hostname (sensitive) |
| `redis_primary_endpoint` | Redis primary endpoint (sensitive) |

## Tests

```bash
terraform init -backend=false
terraform validate
terraform test
```

See [tests/data.tftest.hcl](tests/data.tftest.hcl).
