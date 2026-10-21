# edge

Internet-facing Application Load Balancer and optional regional WAF (production). TLS termination happens at the ALB; target groups for ECS are wired in a later iteration.

## Usage

```hcl
module "edge" {
  source = "../../edge"

  environment       = "dev"
  name_prefix       = "platform-trading"
  public_subnet_ids = module.network.public_subnet_ids
  vpc_id            = module.network.vpc_id
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
| `environment` | `string` | yes | Environment name (`dev`, `staging`, `prod`) |
| `name_prefix` | `string` | yes | Prefix for resource names and tags |
| `public_subnet_ids` | `list(string)` | yes | Public subnet IDs for the ALB |
| `vpc_id` | `string` | yes | VPC ID |

## Outputs

| Name | Description |
| --- | --- |
| `alb_arn` | ALB ARN |
| `alb_arn_suffix` | ARN suffix for CloudWatch ALB metrics |
| `alb_dns_name` | Public DNS name of the ALB |

## Notes

- Public ALB is intentional for the trading API; WAF attaches when `environment == "prod"`.
- `drop_invalid_header_fields` is enabled on the load balancer.

## Tests

```bash
terraform init -backend=false
terraform validate
terraform test
```

See [tests/edge.tftest.hcl](tests/edge.tftest.hcl).
