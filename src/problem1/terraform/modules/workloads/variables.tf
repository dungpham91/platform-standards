variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names and tags."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}
