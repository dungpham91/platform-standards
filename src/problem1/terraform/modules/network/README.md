# network

Regional VPC for the trading stack: private subnets for workloads and data, public subnets for the ALB, NAT for outbound from private tiers.

Wraps [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws) (see [VERSION-PINS.md](../../../../../docs/VERSION-PINS.md)).

## Usage

```hcl
module "network" {
  source = "../../network"

  environment = "dev"
  name_prefix = "platform-trading"
  # optional: vpc_cidr, az_count
}
```

## Requirements

| Name | Version |
| --- | --- |
| terraform | >= 1.16.0, < 2.0.0 |
| aws | >= 5.100.0, < 6.0.0 |

## Inputs

| Name | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `az_count` | `number` | no | `2` | Number of AZs used for subnets |
| `environment` | `string` | yes | — | `dev`, `staging`, or `prod` |
| `name_prefix` | `string` | yes | — | Prefix for resource names and tags |
| `vpc_cidr` | `string` | no | `10.20.0.0/16` | VPC CIDR |

## Outputs

| Name | Description |
| --- | --- |
| `private_subnet_ids` | Private subnet ids (workloads, RDS, Redis) |
| `public_subnet_ids` | Public subnet ids (ALB) |
| `vpc_id` | VPC id |

## Tests

```bash
terraform init -backend=false
terraform validate
terraform test
```

See [tests/network.tftest.hcl](tests/network.tftest.hcl).
