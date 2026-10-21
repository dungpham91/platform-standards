variable "az_count" {
  type        = number
  description = "Number of AZs for subnets."
  default     = 2
}

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

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block."
  default     = "10.20.0.0/16"
}
