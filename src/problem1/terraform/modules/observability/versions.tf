terraform {
  required_version = ">= 1.16.0, < 2.0.0"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.6.0, < 3.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.100.0, < 6.0.0"
    }
  }
}
