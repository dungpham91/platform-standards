# workloads

Application tier security group for ECS/Fargate tasks. Egress to the data tier is completed by separate rules in [stack/regional/sg_rules.tf](../stack/regional/sg_rules.tf).

## Usage

```hcl
module "workloads" {
  source = "../../workloads"

  environment = "dev"
  name_prefix = "platform-trading"
  vpc_id      = module.network.vpc_id
}
```

Pass `app_security_group_id` output to the data module `allowed_security_group_ids`.

## Requirements

| Name | Version |
| --- | --- |
| terraform | >= 1.16.0, < 2.0.0 |
| aws | >= 5.100.0, < 6.0.0 |

## Inputs

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `environment` | `string` | yes | Environment name (`dev`, `staging`, `prod`) |
| `name_prefix` | `string` | yes | Prefix for resource names and tags |
| `vpc_id` | `string` | yes | VPC ID from network module |

## Outputs

| Name | Description |
| --- | --- |
| `app_security_group_id` | SG attached to API/order service tasks |

## Tests

```bash
terraform init -backend=false
terraform validate
terraform test
```

See [tests/workloads.tftest.hcl](tests/workloads.tftest.hcl).
