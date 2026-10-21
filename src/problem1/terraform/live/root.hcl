# Terragrunt root — remote state (S3) and shared tags for all environments.

locals {
  aws_region   = "ap-southeast-1"
  name_prefix  = "platform-trading"
  service_name = "platform-trading"
  owner        = "platform-team"
}

remote_state {
  backend = "s3"

  generate {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = get_env("TG_STATE_BUCKET", "platform-terraform-state-CHANGE_ME")
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = get_env("TG_LOCK_TABLE", "platform-terraform-locks-CHANGE_ME")
  }
}

generate "versions" {
  path      = "versions.generated.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.16.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.100.0, < 6.0.0"
    }
  }
}
EOF
}

generate "provider" {
  path      = "provider.generated.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = {
      CostCenter  = var.cost_center
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner
      Project     = "${local.name_prefix}"
      Service     = var.service_name
    }
  }
}
EOF
}

inputs = {
  aws_region   = local.aws_region
  name_prefix  = local.name_prefix
  owner        = local.owner
  service_name = local.service_name
}
